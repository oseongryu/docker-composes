#!/bin/sh
# 첫 로그인 안내용 xterm 을 한 번 띄운다.
# 사용자가 닫으면 supervisord 가 재시작하지 않도록 [program:welcome] 의 autorestart=false 와 짝.
# fluxbox 등 다른 program 의 재시작과도 분리되어 있어 영향 없음.

# X 와 fluxbox 가 충분히 올라올 때까지
sleep 2

# 바탕색 (xsetroot 없으면 무시)
xsetroot -solid '#1e2030' 2>/dev/null || true

# xterm 본체 — TTF 폰트 명시로 misc-fixed 누락 시에도 동작
exec xterm \
    -geometry 100x28+30+30 \
    -fa "DejaVu Sans Mono" -fs 11 \
    -bg '#1e2030' -fg '#cad3f5' \
    -title "claude-auth helper" \
    -e sh -c "/app/welcome.sh; exec bash"
