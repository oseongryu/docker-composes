#!/bin/bash

if [[ $1 != "" ]]; then
    user_data_dir_mac="$HOME/app/tools/chrome_profile_gptinfodata_m1"
    user_data_dir_linux="/home/ubuntu/chrome_profile_gptinfodata_linux"
    user_data_dir_windows="C:\app\tools\chrome_profile_gptinfodata_windows"
else
    user_data_dir_mac="/app/tools/chrome_profile"
    user_data_dir_linux="/home/ubuntu/chrome_profile"
    user_data_dir_windows="C:\app\tools\chrome_profile"
fi

# 맥관련 설정
background=0
portable=1
chrome_location_windows="C:\Program Files\Google\Chrome\Application\chrome.exe"
chrome_location_mac_portable="/app/tools/Google Chrome.app/Contents/MacOS/Google Chrome"
chrome_location_mac_applications="/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
chrome_location_linux_amd64="google-chrome-stable"
chrome_location_linux_arm64="chromium-browser"


# 공통
os_name=""
architecture_name=""
if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "cygwin" ]]; then
    os_name="windows"
    user_data_dir=$user_data_dir_windows
    chrome_location="$chrome_location_windows"

elif [[ "$OSTYPE" == "darwin"* ]]; then
    os_name="mac"
    user_data_dir="$user_data_dir_mac"
    chrome_location=$([[ $portable -eq 1 ]] && echo "$chrome_location_mac_portable" || echo "$chrome_location_mac_applications")

elif [[ "$OSTYPE" == "linux-gnu" ]]; then
    os_name="linux"
    user_data_dir="$user_data_dir_linux"

    ARCHITECTURE=$(uname -m)
    architecture_name=$([[ "$ARCHITECTURE" == "x86_64" ]] && echo "AMD64" || ([[ "$ARCHITECTURE" == "aarch64" ]] && echo "ARM64"))

    if [[ "$architecture_name" == "AMD64" ]]; then
        chrome_location="$chrome_location_linux_amd64"
    elif [[ "$architecture_name" == "ARM64" ]]; then
        chrome_location="$chrome_location_linux_arm64"
    fi

else
    os_name="etc"
fi


echo "$os_name $architecture_name"
echo "$chrome_location $user_data_dir"

# windows
if [[ "$os_name" == "windows" ]]; then
    # start /D "C:\Program Files\Google\Chrome\Application" chrome.exe --remote-debugging-port=9222
    "$chrome_location" --remote-debugging-port=9222 --user-data-dir="$user_data_dir"
elif [[ "$os_name" == "mac" ]]; then

    if [[ $background -eq 1 ]]; then
        "$chrome_location" --remote-debugging-port=9222 --user-data-dir="$user_data_dir" > /dev/null 2>&1 &
    else
        "$chrome_location" --remote-debugging-port=9222 --user-data-dir="$user_data_dir"
    fi

elif [[ "$os_name" == "linux" ]]; then
    "$chrome_location" --remote-debugging-port=9222 --disable-gpu --disable-dev-shm-usage --no-sandbox --user-data-dir="$user_data_dir"
fi
