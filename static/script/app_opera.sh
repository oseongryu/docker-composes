#!/bin/bash

# Opera 브라우저 설치 스크립트

# 필수 패키지 설치
sudo apt update
sudo apt install -y software-properties-common apt-transport-https wget

# Opera GPG 키 추가
wget -qO- https://deb.opera.com/archive.key | sudo gpg --dearmor -o /usr/share/keyrings/opera-browser-archive-keyring.gpg

# Opera 저장소 추가
echo "deb [signed-by=/usr/share/keyrings/opera-browser-archive-keyring.gpg] https://deb.opera.com/opera-stable/ stable non-free" | sudo tee /etc/apt/sources.list.d/opera-stable.list

# 패키지 목록 업데이트 및 Opera 설치
sudo apt update
sudo apt install -y opera-stable