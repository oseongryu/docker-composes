#!/bin/sh
set -e

mkdir -p /tmp/pulse /tmp/runtime-lecture /home/lecture/notes
chown lecture:lecture /tmp/pulse /tmp/runtime-lecture /home/lecture /home/lecture/notes
chmod 700 /tmp/runtime-lecture
[ -f /home/lecture/.Xauthority ] || runuser -u lecture -- touch /home/lecture/.Xauthority

rm -f /home/lecture/.config/browser/Singleton*

nssdb=/home/lecture/.pki/nssdb
for crt in /usr/local/share/ca-certificates/extra/*.crt; do
    [ -f "$crt" ] || continue
    runuser -u lecture -- mkdir -p "$nssdb"
    [ -f "$nssdb/cert9.db" ] || runuser -u lecture -- certutil -d "sql:$nssdb" -N --empty-password
    runuser -u lecture -- certutil -d "sql:$nssdb" -A -t "C,," -n "$(basename "$crt" .crt)" -i "$crt" \
        && echo "인증서등록 $(basename "$crt")" \
        || echo "인증서실패 $(basename "$crt")"
done

sed -i "s|:[0-9]*/vnc.js\"|:${CONSOLE_PORT:-8090}/vnc.js\"|" /usr/share/novnc/vnc.html

cat <<EOF
================================================================
  lecture-novnc
  화면:  http://localhost:${VNC_PORT:-6080}/vnc.html
  소리·녹음:  http://localhost:${CONSOLE_PORT:-8090}/
================================================================
EOF

exec /usr/bin/supervisord -c /etc/supervisor/conf.d/lecture.conf
