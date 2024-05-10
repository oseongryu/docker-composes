# https://jsonobject.tistory.com/m/635

# Android Studio 설치
sudo snap install android-studio --classic

# Android Studio 바로가기 생성
nano ~/.bash_alises
alias studio="/snap/bin/android-studio > /dev/null 2>&1 &"
alias studio.="/snap/bin/android-studio . > /dev/null 2>&1 &"

# Android Studio 첫 실행 후 안내에 따라 Andorid SDK Command-line Tools 설치
Settings > Languange & Frameworks > Android SDK > SDK Tools > Andorid SDK Command-line Tools

# Windows 11에서 Android ADB Interface 드라이버 설치
https://developer.android.com/studio/run/win-usb
https://developer.samsung.com/android-usb-driver

# Windows 11에서 USBIPD 설치
winget install usbipd

# WSL 2에서 adb 설치
sudo apt-get install adb -y
adb kill-server
adb start-server

# adb 실행 확인
adb devices
List of devices attached

# Android device in Container: Android Device 를 Docker container 에 연결하는 세 가지 방법
# https://changjoon-baek.medium.com/android-device-in-container-b9823cd5a6a7

# Installing Flutter on WSL2 — Windows 10: https://joshkautz.medium.com/installing-flutter-2-0-on-wsl2-2fbf0a354c78
# https://addshore.com/2022/01/installing-android-studio-on-wsl2-for-flutter/