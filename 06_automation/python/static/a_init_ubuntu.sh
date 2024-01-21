#!/bin/bash
ls -al
echo "init ubuntu"
# apt -y update
# apt -y upgrade
# apt -y install python3-pip
# apt -y install python3-tk
# apt -y install python3-dev 
# apt -y install python-tk

apt -y install xvfb
apt -y install scrot

apt -y install fonts-indic
apt -y install font-noto
apt -y install fonts-noto-cjk

timedatectl set-timezone Asia/Seoul
date

