#!/bin/bash
ls -al
echo "init chrome"

sh_result=$(uname -m)

if [ "$sh_result" = "aarch64" ]; then
    echo "arm64 chrome"
    # arm64
    # apt install chromium-browser
else 
    echo "amd64 chrome"
    # amd64
    apt -y install wget gnupg
    wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
    # apt -y install ./google-chrome-stable_current_amd64.deb
    dpkg -i google-chrome-stable_current_amd64.deb
    apt-get install -y -f
    # Chrome 실행
    google-chrome-stable
fi 
# /usr/bin/google-chrome-stable  --headless --no-sandbox --single-process --disable-dev-shm-usage
# https://study-grow.tistory.com/entry/DevToolsActivePort-file-doesnt-exist-error-%ED%95%B4%EA%B2%B0%EB%B2%95
# chrome_options.add_argument('--headless')
# chrome_options.add_argument('--no-sandbox')
# chrome_options.add_argument("--single-process")
# chrome_options.add_argument("--disable-dev-shm-usage")