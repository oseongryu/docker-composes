#!/bin/sh
export DBUS_SESSION_BUS_ADDRESS=unix:path=/tmp/runtime-lecture/bus GTK_IM_MODULE=fcitx XMODIFIERS=@im=fcitx
exec /usr/local/bin/browser --no-sandbox --no-first-run --start-maximized --password-store=basic --user-data-dir=/home/lecture/.config/browser --remote-debugging-address=127.0.0.1 --remote-debugging-port=9222 "$@"