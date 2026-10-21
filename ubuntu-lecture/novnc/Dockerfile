FROM python:3.12-slim

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Asia/Seoul
ENV DISPLAY=:99
ENV PYTHONUNBUFFERED=1
ENV PULSE_SERVER=unix:/tmp/pulse/native
ENV XDG_RUNTIME_DIR=/tmp/runtime-lecture
ENV RESOLUTION=1600x900x24

RUN apt-get update && apt-get install -y --no-install-recommends \
        curl ca-certificates gnupg \
        xvfb fluxbox x11vnc novnc websockify xterm supervisor \
        x11-xserver-utils autocutsel dbus-x11 hsetroot \
        pulseaudio pulseaudio-utils ffmpeg \
        fonts-noto-cjk fonts-dejavu locales tzdata \
    && sed -i 's/^# *\(ko_KR.UTF-8\)/\1/' /etc/locale.gen \
    && locale-gen \
    && rm -rf /var/lib/apt/lists/*

RUN if [ "$(dpkg --print-architecture)" = "amd64" ]; then \
        curl -fsSL -o /tmp/chrome.deb https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb \
        && apt-get update && apt-get install -y --no-install-recommends /tmp/chrome.deb \
        && ln -s /usr/bin/google-chrome /usr/local/bin/browser && rm /tmp/chrome.deb; \
    else \
        apt-get update && apt-get install -y --no-install-recommends chromium \
        && ln -s /usr/bin/chromium /usr/local/bin/browser; \
    fi \
    && rm -rf /var/lib/apt/lists/*

RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
    && apt-get install -y --no-install-recommends nodejs \
    && rm -rf /var/lib/apt/lists/* \
    && npm install -g @anthropic-ai/claude-code

RUN python -m venv /opt/venv \
    && /opt/venv/bin/pip install --no-cache-dir faster-whisper==1.2.1 av==17.0.0 openpyxl==3.1.5 requests==2.32.3

RUN useradd -m -u 1000 -s /bin/bash lecture

COPY lecture.pa /etc/pulse/lecture.pa
COPY supervisord.conf /etc/supervisor/conf.d/lecture.conf
COPY entrypoint.sh /entrypoint.sh
COPY app /app
RUN chmod +x /entrypoint.sh

ENV LANG=ko_KR.UTF-8
ENV LC_ALL=ko_KR.UTF-8

EXPOSE 6080 8090

ENTRYPOINT ["/entrypoint.sh"]
