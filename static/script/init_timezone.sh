#!/bin/bash

# timezone
timedatectl set-timezone Asia/Seoul

# cd /app
# tar -zxvf code-stable-x64-1714529314.tar.gz
# tar -zxvf ideaIU-2024.1.1.tar.gz

# cp -r /app/.ssh ~/.ssh
# chmod 600 ~/.ssh/id_rsa

# mkdir /app/VSCode-linux-x64/data
# cp -r /app/VSCode-linux-x64 /usr/share/code
# chmod 777 /user/share/code

sh_result=$(uname -m)

if [ "$sh_result" = "aarch64" ]; then
    echo "arm64"
    sed -i 's#ports.ubuntu.com#mirror.yuki.net.uk#g' /etc/apt/sources.list; 
else 
    echo "amd64"
    sed -i 's#archive.ubuntu.com#mirror.kakao.com#g' /etc/apt/sources.list;
fi