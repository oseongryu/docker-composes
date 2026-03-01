#!/bin/bash

ls -al
echo "init chrome"

sh_result=$(uname -m)

if [ "$sh_result" = "aarch64" ]; then
    echo "arm64 chrome"
    # arm64
    # apt install -y chromium-browser
    # apt install -y chromium-chromedriver
    # apt install -y firefox
else
    echo "amd64 chrome"
    # amd64
    cd /app
    apt -y install wget gnupg

    if [ ! -f "google-chrome"* ]; then
    echo "download"
        wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
        # apt -y install ./google-chrome-stable_current_amd64.deb

    fi
    dpkg -i google-chrome-stable_current_amd64.deb
    apt-get install -y -f

    # XFCE4 데스크톱 환경에서 크롬 크래시 방지 플래그 적용
    DESKTOP_FILE="/usr/share/applications/google-chrome.desktop"
    if [ -f "$DESKTOP_FILE" ]; then
        sed -i 's|Exec=/usr/bin/google-chrome-stable|Exec=/usr/bin/google-chrome-stable --disable-gpu --disable-dev-shm-usage|g' "/usr/share/applications/google-chrome.desktop"
        echo "Chrome desktop flags applied."
    fi
fi
# /usr/bin/google-chrome-stable --headless --no-sandbox --single-process --disable-dev-shm-usage --user-data-dir="/home/ubuntu/profile"
# https://study-grow.tistory.com/entry/DevToolsActivePort-file-doesnt-exist-error-%ED%95%B4%EA%B2%B0%EB%B2%95
# chrome_options.add_argument('--headless')
# chrome_options.add_argument('--no-sandbox')
# chrome_options.add_argument("--single-process")
# chrome_options.add_argument("--disable-dev-shm-usage")
# /usr/bin/google-chrome-stable --disable-dev-shm-usage --user-data-dir="/home/ubuntu/windows11_ubuntu24"