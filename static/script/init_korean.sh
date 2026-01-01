#!/bin/bash

# https://shanepark.tistory.com/231
# 한글 언어 팩
apt update
apt-get install -y language-pack-ko

#Locale 설치
locale-gen ko_KR.EUC-KR

#LANG 설정 업데이트
update-locale LANG=ko_KR.UTF-8 LC_MESSAGES=POSIX

#한글 입력기 ibus 설치
apt-get install -y ibus-hangul

# 한글 폰트 설치 #나눔 글꼴 설치
apt-get install -y fonts-nanum\*