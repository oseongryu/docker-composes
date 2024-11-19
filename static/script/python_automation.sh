#!/bin/bash
ls -al
echo "init ubuntu"
apt -y update
apt -y upgrade
apt -y install python3-pip
apt -y install python3-tk
apt -y install python3-dev 
apt -y install python-tk

apt -y install xvfb
apt -y install scrot

apt -y install fonts-indic
apt -y install font-noto
apt -y install fonts-noto-cjk
apt -y install gnome-screenshot

echo "init python"
pip install selenium==4.9.0 # firefox
pip install webdriver_manager
pip install pyautogui
pip install opencv-python
pip install python-xlib
pip install pyvirtualdisplay
pip install fake_useragent
pip install psutil

# apt remove python3-pip
# wget https://bootstrap.pypa.io/get-pip.py
# python3 get-pip.py
# reboot
# pip install pyopenssl --upgrade
# pip install -r requirements.txt

# chmod 600 ~/.ssh/config