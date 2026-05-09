# claude-auth-vnc — Claude Code 멀티 프로필 인증 헬퍼

`git-worktree-web` (wm) 백엔드의 멀티 프로필 기능에 여러 anthropic 계정의 Claude Code credentials 를 등록하기 위한 도구. wm 백엔드가 헤드리스 컨테이너라 `claude login` 의 OAuth 브라우저 흐름이 안 되는 문제를 별도 GUI 컨테이너로 우회한다.

## 전체 그림

두 개의 컨테이너로 분리:

| 컨테이너 | 용도 | 빈도 |
|---|---|---|
| `claude-auth-vnc/` | **첫 로그인** — 노VNC 로 chromium 직접 조작, anthropic SSO 통과 | 계정당 1회 |
| `claude-auth/` | **재인증** — 영속 chromium 프로필을 헤드리스로 재사용, 토큰 갱신만 | 토큰 만료마다 |

두 컨테이너가 같은 `./data/chrome-profiles/<label>/` 디렉토리를 공유 (또는 복사) 하면, 처음 한 번 노VNC 로 세션 박은 뒤 이후 만료 시엔 헤드리스로 자동 갱신 가능.

wm 백엔드로 push 하는 방식은 두 경우 다 동일 — 기존 `git-worktree-web/scripts/claude-credentials-register.sh` 를 그대로 재사용해서 `/api/claude/accounts` 에 POST.

## 디렉토리 구조

```
docker-composes/claude-auth-vnc/
├── Dockerfile           # python:3.12-slim + Xvfb/fluxbox/x11vnc/noVNC + chromium + Node 20 + claude CLI
├── docker-compose.yml   # 127.0.0.1:6080(웹) / 5900(VNC) 만 바인딩, ./data 영속, scripts ro
├── supervisord.conf     # Xvfb → fluxbox → x11vnc → websockify(noVNC) 4-stack
├── entrypoint.sh        # 디렉토리 골격 + 시작 안내 출력 + supervisord
├── fluxbox-startup      # 첫 노VNC 접속 시 안내 xterm 자동 띄움 (현재 표시 안 되는 이슈 있음)
├── welcome.sh           # 안내 배너 + .bashrc 에 chromium-a/b, login-a/b alias 추가
├── login.sh             # 핵심: claude login + wm push 묶어 실행 (HOME 분리로 프로필별 격리)
└── data/                # 영속 (gitignore 권장)
    ├── chrome-profiles/<label>/   # chromium --user-data-dir
    ├── claude-homes/<label>/      # claude HOME 분리 (.claude/.credentials.json)
    └── .fluxbox/startup           # entrypoint 가 첫 실행 시 깐다
```

## 빌드 & 실행

```sh
cd C:/Users/admin/git/docker-composes/claude-auth-vnc

# 첫 빌드 (이미지 ~1.2 GB 다운로드/빌드)
API_URL=https://wm-api.<your-domain> docker compose up -d --build

# 이후엔
docker compose up -d
docker compose logs -f
docker compose down
```

`SCRIPTS_DIR` 가 기본값(`../../git-worktree-web/scripts`) 으로 안 맞으면 `.env` 또는 환경변수로 override.

## 사용 흐름 (핵심)

### 0) 노VNC 접속

호스트 브라우저로:
```
http://localhost:6080/vnc.html
```
Connect 클릭. 검은 바탕의 fluxbox 데스크톱이 보이면 OK.

> ⚠️ 인증 없는 VNC 라 docker-compose 가 `127.0.0.1` 만 바인딩. 외부 노출 절대 금지 (또는 x11vnc 의 `-passwd` 옵션 추가).

### 1) 컨테이너 안 셸 확보

**옵션 A — 노VNC 에서 xterm 직접:** 데스크톱 우클릭 → Applications → xterm
**옵션 B — 호스트에서 docker exec:** (xterm 안 보일 때)
```sh
docker compose exec claude-auth-vnc bash
export DISPLAY=:99    # docker exec 셸은 DISPLAY 가 안 박혀있어 수동
```

### 2) chromium 으로 anthropic 계정 로그인 (프로필별 1회만)

```sh
chromium --user-data-dir=/data/chrome-profiles/A --no-sandbox --no-first-run &
```
노VNC 화면에 chromium 창이 뜸 → `https://anthropic.com/login` → 평소처럼 Google SSO 등으로 로그인.
**창은 그대로 두기** (다음 단계의 OAuth 가 같은 창에 붙을 수 있게).

### 3) claude login + wm 등록을 한 방에

같은 (또는 다른) xterm 에서:
```sh
/app/login.sh --label A --profile A --api $API_URL
# 또는 alias 셋업된 셸에서:
login-a   # = /app/login.sh --label A --profile A
```

`login.sh` 가 하는 일:
1. `HOME=/data/claude-homes/A` 로 분리 (다른 라벨의 credentials 와 섞이지 않게)
2. `claude login` 실행 → OAuth URL 출력
3. **사용자가 그 URL 을 chromium A 창에 붙여넣어 승인** (수동 단계)
4. 승인 후 callback → `~/.claude/.credentials.json` 자동 생성
5. `claude-credentials-register.sh` 로 wm 백엔드 `/api/claude/accounts` 에 POST

### 4) 다른 계정 (B, C, ...) 반복

```sh
chromium --user-data-dir=/data/chrome-profiles/B --no-sandbox --no-first-run &
# (chromium B 창에서 다른 anthropic 계정으로 로그인)
/app/login.sh --label B --profile B --api $API_URL
```

핵심: chrome 프로필 디렉토리(`/data/chrome-profiles/<name>`) 를 **다르게** 줘야 anthropic 세션이 분리됨. label 도 wm 쪽 unique 라 겹치면 안 됨.

## 검증

wm 백엔드에 등록됐는지 확인:
```sh
curl -s $API_URL/api/profiles | jq .   # 또는 /api/claude/accounts
```
또는 wm UI 의 프로필 관리 화면에서 라벨 보이면 성공.

## 알려진 이슈 / 메모

- **노VNC 첫 접속 시 안내 xterm 이 자동으로 안 뜸.**
  `fluxbox-startup` 의 `xterm -e ...` 가 어디서 죽는 듯. 우회: `docker compose exec` 로 들어가거나 fluxbox 메뉴에서 직접 띄움. 디버그하려면 `docker compose exec ... cat /var/log/fluxbox*.log`, `ls -la /data/.fluxbox/startup`.

- **`login.sh` 안의 `claude login` 이 chromium 을 직접 안 열고 URL 만 출력함.**
  현재 설계는 사용자가 OAuth URL 을 직접 chromium 에 붙여넣는 흐름. 자동화하려면 xdg-open 기본 브라우저를 chromium 으로 박거나, login.sh 를 Playwright 호출하도록 확장.

- **HOME 분리 (`/data/claude-homes/<label>`)** 덕에 동시에 여러 프로필 셸을 띄워 작업해도 credentials.json 이 안 섞임. 단, 각 셸의 `HOME` 이 올바른지 항상 확인.

- **shm_size 1g** 로 잡혀있음 (compose). chromium 메모리 부족 (`tmpfs full` 류) 시 에러나면 키워보기.

## 다음 단계 (테스트 후 진행)

1. **세션이 잘 박혔는지 확인**: chromium 창 닫고 `chromium --user-data-dir=/data/chrome-profiles/A` 다시 띄웠을 때 anthropic.com 가 자동 로그인 상태로 보이는지.
2. **헤드리스 재인증 (`../claude-auth/`) 테스트**:
   - VNC 컨테이너의 `./data/chrome-profiles/A` 를 헤드리스 컨테이너의 `./data/chrome-profile/` 로 복사 (또는 같은 path 마운트).
   - `docker compose run --rm claude-auth --label A --api $API_URL` 로 자동 갱신 가능한지.
3. **(선택) login.sh 자동화**: chromium 을 백그라운드로 띄운 채 OAuth URL 을 자동으로 그 창에 던지는 헬퍼 추가 (`xdotool`, 또는 chromium DevTools protocol).

## 참고 파일

- `../claude-auth/` — 헤드리스 동등물 (Playwright 기반, 같은 register 스크립트 사용)
- `../../git-worktree-web/scripts/claude-credentials-register.sh` — wm 으로 push 하는 단일 진입점
- `../../git-worktree-web/CLAUDE.md` 의 "프로필 (멀티 프로필)" 섹션 — wm 쪽 모델 설명
