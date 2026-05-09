FROM python:3.12-slim

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Asia/Seoul
ENV DISPLAY=:99
ENV HOME=/data
ENV PYTHONUNBUFFERED=1

RUN apt-get update && apt-get install -y --no-install-recommends \
        curl ca-certificates jq git \
        # X stack — minimal
        xvfb fluxbox x11vnc \
        # noVNC web client + websocket bridge
        novnc websockify \
        # Browser
        chromium \
        # 사용자가 쓸 터미널
        xterm \
        # process supervisor
        supervisor \
        # X 유틸 (xsetroot 등) + dbus, fonts (xterm 의 misc-fixed 포함), locale
        x11-xserver-utils dbus-x11 xfonts-base xfonts-100dpi xfonts-75dpi fonts-dejavu fonts-noto-cjk locales \
    && sed -i 's/^# *\(en_US.UTF-8\)/\1/' /etc/locale.gen \
    && sed -i 's/^# *\(ko_KR.UTF-8\)/\1/' /etc/locale.gen \
    && locale-gen \
    && rm -rf /var/lib/apt/lists/*

# Node.js 20 (claude CLI 용)
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
    && apt-get install -y --no-install-recommends nodejs \
    && rm -rf /var/lib/apt/lists/*

# claude CLI
RUN npm install -g @anthropic-ai/claude-code

WORKDIR /app
COPY supervisord.conf /etc/supervisor/conf.d/claude-auth.conf
COPY entrypoint.sh /app/entrypoint.sh
COPY login.sh /app/login.sh
COPY fluxbox-startup /app/fluxbox-startup
COPY welcome.sh /app/welcome.sh
COPY welcome-xterm.sh /app/welcome-xterm.sh
RUN chmod +x /app/entrypoint.sh /app/login.sh /app/welcome.sh /app/welcome-xterm.sh

# 환경 기본값
ENV LANG=ko_KR.UTF-8
ENV LC_ALL=ko_KR.UTF-8
ENV PROFILE_BASE=/data/chrome-profiles
ENV CLAUDE_HOMES_BASE=/data/claude-homes

# noVNC 웹 (6080), 직접 VNC 도 노출 (5900) — 보안상 compose 에서 둘 다 localhost 바인딩 권장
EXPOSE 6080 5900

ENTRYPOINT ["/app/entrypoint.sh"]
