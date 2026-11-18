#!/bin/sh
exec /usr/local/bin/browser --no-sandbox --no-first-run --start-maximized --user-data-dir=/home/lecture/.config/browser --remote-debugging-address=127.0.0.1 --remote-debugging-port=9222 "$@"
