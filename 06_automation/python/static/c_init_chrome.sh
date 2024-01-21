#!/bin/bash
ls -al
echo "init chrome"

apt -y install wget
wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
apt -y install ./google-chrome-stable_current_amd64.deb

# /usr/bin/google-chrome-stable  --headless --no-sandbox --single-process --disable-dev-shm-usage
# https://study-grow.tistory.com/entry/DevToolsActivePort-file-doesnt-exist-error-%ED%95%B4%EA%B2%B0%EB%B2%95
# chrome_options.add_argument('--headless')
# chrome_options.add_argument('--no-sandbox')
# chrome_options.add_argument("--single-process")
# chrome_options.add_argument("--disable-dev-shm-usage")