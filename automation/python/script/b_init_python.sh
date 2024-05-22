#!/bin/bash
echo "init python"
pip install selenium==4.9.0 # firefox
pip install webdriver_manager
pip install pyautogui
pip install opencv-python
pip install python-xlib
pip install pyvirtualdisplay
pip install fake_useragent

# apt remove python3-pip
# wget https://bootstrap.pypa.io/get-pip.py
# python3 get-pip.py
# reboot
# pip install pyopenssl --upgrade
# pip install -r requirements.txt

# chmod 600 ~/.ssh/config