#!/bin/sh
# noVNC 첫 화면 xterm 에서 표시되는 안내. PS1 에 뜨는 helper alias 도 같이 셋업.

cat <<'BANNER'
================================================================
 claude-auth-vnc — Claude Code 멀티 프로필 인증 헬퍼
================================================================

[1] chromium 으로 anthropic 계정 로그인 (프로필별 1회만):
    $ chromium --user-data-dir=/data/chrome-profiles/A &
    -> 새 창에서 https://anthropic.com 로그인 (Google SSO 등)
    -> 로그인 완료되면 chromium 창은 그대로 두기

[2] claude login + wm 등록을 한 방에:
    $ /app/login.sh --label A --profile A --api $API_URL [--make-default]

    login.sh 가 'claude login' 을 실행해 OAuth URL 을 보여주면
    그 URL 을 [1] 에서 띄운 chromium A 창에 붙여넣어 OAuth 승인.
    승인 후 자동으로 wm 백엔드에 push 됩니다.

[3] 다른 계정은 --profile B --label B 로 반복.
    프로필 디렉토리 (/data/chrome-profiles/<name>) 가 다르면
    chromium 의 anthropic 세션이 분리됩니다.

ENV / 변수:
    API_URL      = ${API_URL:-(미설정 - compose env 로 넘기거나 --api 인자)}
    PROFILE_BASE = ${PROFILE_BASE:-/data/chrome-profiles}

================================================================
BANNER

# 자주 쓰는 alias
cat >> /data/.bashrc <<'EOF'
alias chromium-a='chromium --user-data-dir=/data/chrome-profiles/A --no-first-run --no-default-browser-check &'
alias chromium-b='chromium --user-data-dir=/data/chrome-profiles/B --no-first-run --no-default-browser-check &'
alias login-a='/app/login.sh --label A --profile A'
alias login-b='/app/login.sh --label B --profile B'
EOF
