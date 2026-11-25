FROM python:3.12-slim

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Asia/Seoul
ENV DISPLAY=:99
ENV PYTHONUNBUFFERED=1
ENV PULSE_SERVER=unix:/tmp/pulse/native
ENV XDG_RUNTIME_DIR=/tmp/runtime-lecture
ENV RESOLUTION=1920x1080x24

RUN apt-get update && apt-get install -y --no-install-recommends \
        curl ca-certificates gnupg libnss3-tools \
        xvfb fluxbox x11vnc novnc websockify xterm supervisor \
        x11-xserver-utils autocutsel dbus-x11 hsetroot \
        pulseaudio pulseaudio-utils ffmpeg \
        fonts-noto-cjk fonts-noto-color-emoji fonts-dejavu locales tzdata \
        fcitx5 fcitx5-hangul fcitx5-frontend-gtk3 \
    && sed -i 's/^# *\(ko_KR.UTF-8\)/\1/' /etc/locale.gen \
    && locale-gen \
    && dbus-uuidgen --ensure=/etc/machine-id \
    && rm -rf /var/lib/apt/lists/*

COPY certs/ /usr/local/share/ca-certificates/extra/
RUN update-ca-certificates
ENV SSL_CERT_FILE=/etc/ssl/certs/ca-certificates.crt
ENV REQUESTS_CA_BUNDLE=/etc/ssl/certs/ca-certificates.crt
ENV NODE_EXTRA_CA_CERTS=/etc/ssl/certs/ca-certificates.crt

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
    && /opt/venv/bin/pip install --no-cache-dir faster-whisper==1.2.1 av==17.0.0 openpyxl==3.1.5 requests==2.32.3 websockets==14.1

RUN apt-get update && apt-get install -y --no-install-recommends xdotool scrot x11-utils gnome-screenshot xclip \
    && rm -rf /var/lib/apt/lists/* \
    && /opt/venv/bin/pip install --no-cache-dir pyautogui==0.9.54 pyscreeze==1.0.1 pillow==10.0.1 opencv-python-headless==4.13.0.92 pyperclip==1.11.0 \
    && touch /root/.Xauthority
COPY sitecustomize.py /opt/venv/lib/python3.12/site-packages/sitecustomize.py

RUN useradd -m -u 1000 -s /bin/bash lecture

COPY lecture.pa /etc/pulse/lecture.pa
COPY supervisord.conf /etc/supervisor/conf.d/lecture.conf
COPY entrypoint.sh /entrypoint.sh
COPY browser.sh /usr/local/bin/lecture-browser
COPY resolution.sh /usr/local/bin/lecture-resolution
COPY shell.sh /etc/profile.d/lecture.sh
COPY fcitx5/ /etc/xdg/fcitx5/
COPY app /app
RUN chmod +x /entrypoint.sh /usr/local/bin/lecture-browser /usr/local/bin/lecture-resolution \
    && chmod 644 /etc/profile.d/lecture.sh \
    && echo '. /etc/profile.d/lecture.sh' >> /etc/bash.bashrc \
    && printf '%s\n' '*faceName: DejaVu Sans Mono' '*faceNameDoublesize: Noto Sans Mono CJK KR' '*faceSize: 11' '*inputMethod: fcitx' >> /etc/X11/app-defaults/XTerm \
    && sed -i 's|^\[begin\] (Fluxbox)$|&\n   [exec] (Browser) {/usr/local/bin/lecture-browser}\n   [exec] (Terminal) {x-terminal-emulator}\n   [separator]|' /etc/X11/fluxbox/fluxbox-menu \
    && sed -i 's|</head>|<script>document.head.append(Object.assign(document.createElement("script"), {src: location.protocol + "//" + location.hostname + ":8090/vnc.js"}))</script>\n</head>|' /usr/share/novnc/vnc.html

ENV LANG=ko_KR.UTF-8
ENV LC_ALL=ko_KR.UTF-8

EXPOSE 6080 8090

ENTRYPOINT ["/entrypoint.sh"]
