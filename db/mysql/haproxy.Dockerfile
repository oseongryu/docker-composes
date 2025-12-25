FROM haproxy:2.9-alpine

# root 권한으로 socat 설치
USER root
RUN apk add --no-cache socat

# 보안을 위해 haproxy 사용자로 다시 전환
USER haproxy

# HAProxy 설정 파일은 volume으로 마운트됨
