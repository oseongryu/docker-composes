#!/bin/sh
set -e

mkdir -p /tmp/pulse /tmp/runtime-lecture /home/lecture/notes
chown lecture:lecture /tmp/pulse /tmp/runtime-lecture /home/lecture /home/lecture/notes
chmod 700 /tmp/runtime-lecture

rm -f /home/lecture/.config/browser/Singleton*

cat <<EOF
================================================================
  lecture-novnc
  화면:  http://localhost:6080/vnc.html
  소리·녹음:  http://localhost:8090/
================================================================
EOF

exec /usr/bin/supervisord -c /etc/supervisor/conf.d/lecture.conf
