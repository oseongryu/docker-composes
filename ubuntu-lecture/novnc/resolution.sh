#!/bin/sh
# 사용: lecture-resolution            현재 크기·설정 보기
#       lecture-resolution 1920x1080  바꾸기 (X 화면·브라우저 다시 띄움, 녹음 중이면 거부)
#       lecture-resolution default    설정 지우고 RESOLUTION 기본값으로
#       lecture-resolution get        Xvfb 기동용 WxHxD 출력 (supervisor 가 부름)
set -e

FILE=/home/lecture/resolution
DEPTH=24
X_PROGRAMS="x11vnc fluxbox autocutsel fcitx5 browser"

valid() {
    echo "$1" | grep -Eq '^[0-9]{3,4}x[0-9]{3,4}$' || return 1
    w=${1%x*}
    h=${1#*x}
    [ "$w" -ge 640 ] && [ "$w" -le 3840 ] && [ "$h" -ge 480 ] && [ "$h" -le 2160 ]
}

saved() {
    [ -f "$FILE" ] || return 1
    v=$(tr -d ' \r\n' < "$FILE")
    valid "$v" && echo "$v"
}

get() {
    v=$(saved || true)
    if [ -n "$v" ]; then
        echo "${v}x$DEPTH"
    else
        echo "${RESOLUTION:-1920x1080x24}"
    fi
}

actual() {
    DISPLAY=:99 xdpyinfo 2>/dev/null | awk '/dimensions/ {print $2}'
}

restart() {
    status=$(curl -s --max-time 3 http://127.0.0.1:8090/api/status || true)
    if [ -n "$status" ] && ! echo "$status" | grep -q '"recording": null'; then
        echo "녹음 중이라 바꾸지 않음. 녹음을 끝내고 다시 실행"
        exit 1
    fi
    supervisorctl stop $X_PROGRAMS >/dev/null
    supervisorctl restart xvfb >/dev/null
    i=0
    until [ -n "$(actual)" ]; do
        i=$((i + 1))
        [ "$i" -gt 50 ] && { echo "Xvfb 시작 실패"; exit 1; }
        sleep 0.2
    done
    supervisorctl start $X_PROGRAMS >/dev/null
    echo "적용 $(actual)"
}

case "${1:-}" in
    get)
        get
        ;;
    "")
        echo "현재 $(actual)"
        echo "설정 $(saved || echo "없음 (기본 ${RESOLUTION:-1920x1080x24})")"
        ;;
    default)
        rm -f "$FILE"
        restart
        ;;
    *)
        if ! valid "$1"; then
            echo "형식: 1920x1080 (가로 640~3840, 세로 480~2160)"
            exit 1
        fi
        echo "$1" > "$FILE"
        chown lecture:lecture "$FILE" 2>/dev/null || true
        restart
        ;;
esac