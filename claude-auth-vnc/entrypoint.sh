#!/bin/sh
# claude-auth-vnc 컨테이너 entrypoint.
# Xvfb + fluxbox + x11vnc + noVNC 스택을 supervisord 로 띄운다.
set -e

# 영속 디렉토리 골격
mkdir -p /data /data/.claude /data/chrome-profiles /data/claude-homes
mkdir -p /data/.fluxbox /data/.config

# fluxbox-startup 은 더 이상 supervisord 가 사용하지 않음 (plain fluxbox 호출로 변경됨).
# 사용자가 startfluxbox 를 수동으로 돌리는 경우에만 의미있음 — 호환용으로만 깔아둠.
cp /app/fluxbox-startup /data/.fluxbox/startup
chmod +x /data/.fluxbox/startup

# /scripts 마운트 점검
if [ ! -f /scripts/claude-credentials-register.sh ]; then
    echo "WARN: /scripts/claude-credentials-register.sh 없음 — wm push 가 동작하지 않습니다."
    echo "      docker-compose 의 SCRIPTS_DIR 이 git-worktree-web/scripts 를 가리키는지 확인."
fi

cat <<EOF
================================================================
  claude-auth-vnc 시작
  noVNC 웹:  http://localhost:6080/vnc.html
  VNC 직접:  localhost:5900 (no password)

  사용 흐름:
    1) 위 노VNC URL 을 호스트 브라우저로 연다 (Connect 클릭)
    2) 우클릭 -> xterm 실행
    3) chromium --user-data-dir=/data/chrome-profiles/A &
       (chromium 안에서 anthropic.com 로그인 — 한 번만)
    4) /app/login.sh --label A --profile A --api \$API_URL
       (claude login URL 을 chromium A 에 붙여넣고 OAuth 완료)
    5) 다른 계정은 --profile B --label B 로 반복
================================================================
EOF

exec /usr/bin/supervisord -c /etc/supervisor/conf.d/claude-auth.conf
