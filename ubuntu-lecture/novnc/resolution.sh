#!/bin/sh
# 사용: lecture-resolution            현재 크기·설정 보기
#       lecture-resolution 1920x1080  /home/lecture/resolution 에 쓰고 적용될 때까지 기다림
#       lecture-resolution default    설정 지우고 RESOLUTION 기본값으로
#       lecture-resolution get        Xvfb 기동용 WxHxD (supervisor xvfb)
#       lecture-resolution watch      원하는 크기와 실제 크기가 다르면 X 화면을 다시 띄움 (supervisor resolution, root)
# 적용은 watch 만 한다. 파일은 서버(data/resolution)·컨테이너 어디서 고쳐도 3초 안에 반영된다.
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

raw() {
    tr -d ' \r\n' < "$FILE"
}

wanted() {
    if [ -f "$FILE" ]; then
        v=$(raw)
        valid "$v" && echo "$v"
    else
        d=${RESOLUTION:-1920x1080x24}
        echo "${d%x*}"
    fi
}

get() {
    v=$(wanted || true)
    if [ -n "$v" ]; then
        echo "${v}x$DEPTH"
    else
        echo "${RESOLUTION:-1920x1080x24}"
    fi
}

actual() {
    DISPLAY=:99 xdpyinfo 2>/dev/null | awk '/dimensions/ {print $2}'
}

recording() {
    status=$(curl -s --max-time 3 http://127.0.0.1:8090/api/status || true)
    [ -n "$status" ] && ! echo "$status" | grep -q '"recording": null'
}

apply() {
    supervisorctl stop $X_PROGRAMS >/dev/null
    supervisorctl restart xvfb >/dev/null
    i=0
    until [ -n "$(actual)" ]; do
        i=$((i + 1))
        [ "$i" -gt 50 ] && return 1
        sleep 0.2
    done
    supervisorctl start $X_PROGRAMS >/dev/null
}

watch() {
    note=
    while sleep 3; do
        cur=$(actual)
        [ -n "$cur" ] || continue
        if ! want=$(wanted); then
            [ "$note" = "bad" ] || echo "형식오류 $(raw | head -c 40)"
            note=bad
            continue
        fi
        if [ "$want" = "$cur" ]; then
            note=
            continue
        fi
        if recording; then
            [ "$note" = "wait$want" ] || echo "녹음중대기 $cur $want"
            note="wait$want"
            continue
        fi
        [ "$note" = "fail$want" ] && continue
        echo "크기변경 $cur $want"
        if apply; then
            echo "적용 $(actual)"
            note=
        else
            echo "적용실패 $want"
            note="fail$want"
        fi
    done
}

wait_applied() {
    i=0
    while [ "$i" -lt 30 ]; do
        [ "$(actual)" = "$1" ] && { echo "적용 $1"; return 0; }
        i=$((i + 1))
        sleep 1
    done
    if recording; then
        echo "녹음 중이라 대기. 녹음이 끝나면 적용된다"
    else
        echo "아직 $(actual). 로그: /var/log/resolution.log"
    fi
    return 1
}

case "${1:-}" in
    get)
        get
        ;;
    watch)
        watch
        ;;
    "")
        echo "현재 $(actual)"
        if [ -f "$FILE" ]; then
            echo "설정 $(raw) ($FILE)"
        else
            echo "설정 없음 (기본 ${RESOLUTION:-1920x1080x24})"
        fi
        ;;
    default)
        rm -f "$FILE"
        d=${RESOLUTION:-1920x1080x24}
        wait_applied "${d%x*}"
        ;;
    *)
        if ! valid "$1"; then
            echo "형식: 1920x1080 (가로 640~3840, 세로 480~2160)"
            exit 1
        fi
        echo "$1" > "$FILE"
        [ "$(id -u)" = 0 ] && chown lecture:lecture "$FILE"
        wait_applied "$1"
        ;;
esac