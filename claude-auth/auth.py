#!/usr/bin/env python3
"""Headless Claude Code login orchestrator.

Flow:
1. `claude login` 을 백그라운드로 spawn
2. stdout 에서 OAuth URL 파싱
3. 영속 chromium profile 로 그 URL 열기 (헤드리스)
4. 세션 쿠키 살아있으면 OAuth 가 자동 완료 → claude CLI 가 callback 캡처
5. ~/.claude/.credentials.json 을 wm 백엔드로 push (register script 재사용)

쿠키가 만료/없으면 anthropic 로그인 페이지에서 멈춤 → timeout 후 에러.
첫 로그인은 --no-headless 또는 별도 GUI 컨테이너에서 한 번 해 두고
프로필 디렉토리만 영속화하면 이후 재인증은 헤드리스로 자동.
"""
from __future__ import annotations

import argparse
import asyncio
import os
import re
import subprocess
import sys
import time
from pathlib import Path

URL_RE = re.compile(r"https://[^\s\x1b\"']*(?:oauth|authorize|claude\.ai/login)[^\s\x1b\"']*")
REGISTER_SCRIPT = "/scripts/claude-credentials-register.sh"


async def spawn_claude_login() -> asyncio.subprocess.Process:
    return await asyncio.create_subprocess_exec(
        "claude", "login",
        stdin=asyncio.subprocess.PIPE,
        stdout=asyncio.subprocess.PIPE,
        stderr=asyncio.subprocess.STDOUT,
        env={**os.environ, "TERM": "dumb", "NO_COLOR": "1"},
    )


async def read_until_url(proc: asyncio.subprocess.Process, timeout: float = 30.0) -> str | None:
    """Drain stdout until we see the OAuth URL or timeout."""
    deadline = time.monotonic() + timeout
    buf = bytearray()
    while True:
        remaining = deadline - time.monotonic()
        if remaining <= 0:
            return None
        try:
            chunk = await asyncio.wait_for(proc.stdout.read(512), timeout=remaining)
        except asyncio.TimeoutError:
            return None
        if not chunk:
            return None
        buf.extend(chunk)
        sys.stdout.write(chunk.decode(errors="replace"))
        sys.stdout.flush()
        m = URL_RE.search(buf.decode(errors="replace"))
        if m:
            return m.group(0)


async def drain_remaining(proc: asyncio.subprocess.Process, timeout: float = 30.0) -> None:
    deadline = time.monotonic() + timeout
    while True:
        remaining = deadline - time.monotonic()
        if remaining <= 0:
            return
        try:
            chunk = await asyncio.wait_for(proc.stdout.read(512), timeout=remaining)
        except asyncio.TimeoutError:
            return
        if not chunk:
            return
        sys.stdout.write(chunk.decode(errors="replace"))
        sys.stdout.flush()


async def drive_browser(url: str, profile_dir: str, headless: bool, timeout: float = 90.0) -> None:
    """Open URL in persistent chromium context. Click any approve button if shown."""
    from playwright.async_api import async_playwright

    Path(profile_dir).mkdir(parents=True, exist_ok=True)
    async with async_playwright() as p:
        ctx = await p.chromium.launch_persistent_context(
            profile_dir,
            headless=headless,
            args=["--no-sandbox", "--disable-dev-shm-usage", "--disable-blink-features=AutomationControlled"],
            viewport={"width": 1280, "height": 800},
        )
        page = ctx.pages[0] if ctx.pages else await ctx.new_page()

        try:
            await page.goto(url, wait_until="domcontentloaded", timeout=int(timeout * 1000))
        except Exception as e:
            print(f"[browser] goto error: {e}", file=sys.stderr)

        # OAuth approve 버튼이 노출되는 변형들 — 보이면 클릭
        approve_selectors = [
            "button:has-text('Authorize')",
            "button:has-text('Approve')",
            "button:has-text('Allow')",
            "button:has-text('승인')",
            "button:has-text('허용')",
            "[data-testid*='approve']",
            "[data-testid*='authorize']",
        ]
        for sel in approve_selectors:
            try:
                btn = await page.wait_for_selector(sel, timeout=2000)
                if btn:
                    print(f"[browser] clicking {sel}")
                    await btn.click()
                    break
            except Exception:
                continue

        # localhost callback 으로 redirect 가 일어나면 chromium 도 그쪽으로 이동.
        # claude CLI 가 자기 로컬 서버에서 code 잡을 시간 확보.
        try:
            await page.wait_for_url(re.compile(r"localhost|127\.0\.0\.1"), timeout=15000)
            print("[browser] redirected to localhost callback")
        except Exception:
            print("[browser] no localhost redirect detected (may be code-paste flow)")

        await asyncio.sleep(2)
        await ctx.close()


def push_to_wm(label: str, api_url: str, make_default: bool) -> int:
    if not Path(REGISTER_SCRIPT).exists():
        print(f"ERROR: {REGISTER_SCRIPT} 없음. /scripts 마운트 확인.", file=sys.stderr)
        return 2
    cmd = ["sh", REGISTER_SCRIPT, "--label", label, "--api", api_url]
    if make_default:
        cmd.append("--make-default")
    print(f"[push] {' '.join(cmd)}")
    return subprocess.call(cmd)


async def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--label", required=True, help="wm 에 등록할 프로필 라벨")
    ap.add_argument("--api", default=os.environ.get("API_URL", ""), help="wm 백엔드 API URL")
    ap.add_argument("--profile-dir", default=os.environ.get("PROFILE_DIR", "/data/chrome-profile"))
    ap.add_argument("--make-default", action="store_true")
    ap.add_argument("--no-headless", action="store_true", help="headed 모드 (X11 필요)")
    ap.add_argument("--login-timeout", type=float, default=30.0)
    ap.add_argument("--browser-timeout", type=float, default=90.0)
    args = ap.parse_args()

    if not args.api:
        print("ERROR: --api 또는 $API_URL 필요.", file=sys.stderr)
        return 2

    creds_path = Path(os.environ.get("CLAUDE_HOME", str(Path.home() / ".claude"))) / ".credentials.json"
    # 이전 실행의 잔여 credentials 가 새 인증을 가릴 수 있어 비움
    if creds_path.exists():
        try:
            creds_path.unlink()
        except Exception:
            pass

    print(f"[auth] label={args.label} api={args.api} profile={args.profile_dir} headless={not args.no_headless}")
    proc = await spawn_claude_login()

    url = await read_until_url(proc, timeout=args.login_timeout)
    if not url:
        print(f"ERROR: claude login 이 {args.login_timeout}s 내 OAuth URL 을 출력하지 않음.", file=sys.stderr)
        try:
            proc.terminate()
        except Exception:
            pass
        return 3

    print(f"\n[auth] OAuth URL 캡처: {url[:120]}...")

    try:
        await drive_browser(url, args.profile_dir, headless=not args.no_headless, timeout=args.browser_timeout)
    except Exception as e:
        print(f"[auth] browser 단계 실패: {e}", file=sys.stderr)

    # claude login 이 callback 받고 종료할 시간
    await drain_remaining(proc, timeout=15.0)
    try:
        rc = await asyncio.wait_for(proc.wait(), timeout=10.0)
        print(f"[auth] claude login exit={rc}")
    except asyncio.TimeoutError:
        print("[auth] claude login 응답 없음 — 강제 종료", file=sys.stderr)
        proc.kill()
        await proc.wait()

    if not creds_path.exists() or creds_path.stat().st_size < 10:
        print("ERROR: credentials.json 미생성 — chrome 프로필이 anthropic 에 로그인되어있지 않을 가능성.", file=sys.stderr)
        print("HINT: 첫 로그인은 --no-headless 또는 별도 GUI 컨테이너에서 한 번 해 두고,", file=sys.stderr)
        print(f"      {args.profile_dir} 디렉토리를 영속화한 뒤 재실행.", file=sys.stderr)
        return 4

    return push_to_wm(args.label, args.api, args.make_default)


if __name__ == "__main__":
    try:
        rc = asyncio.run(main())
    except KeyboardInterrupt:
        rc = 130
    sys.exit(rc)
