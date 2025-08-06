#!/bin/bash
sudo touch /usr/share/applications/android-studio.desktop

sudo echo "[Desktop Entry]" >> /usr/share/applications/android-studio.desktop
sudo echo "Version=1.0" >> /usr/share/applications/android-studio.desktop
sudo echo "Type=Application" >> /usr/share/applications/android-studio.desktop
sudo echo "Name=Android Studio" >> /usr/share/applications/android-studio.desktop
sudo echo "Comment=Android Studio" >> /usr/share/applications/android-studio.desktop
sudo echo "Exec=bash -i "/opt/android-studio/bin/studio.sh" %f" >> /usr/share/applications/android-studio.desktop
sudo echo "Icon=/opt/android-studio/bin/studio.png" >> /usr/share/applications/android-studio.desktop
sudo echo "Categories=Development;IDE;" >> /usr/share/applications/android-studio.desktop
sudo echo "Terminal=false" >> /usr/share/applications/android-studio.desktop
sudo echo "StartupNotify=true" >> /usr/share/applications/android-studio.desktop
sudo echo "StartupWMClass=jetbrains-android-studio" >> /usr/share/applications/android-studio.desktop
sudo echo "Name[en_GB]=android-studio.desktop" >> /usr/share/applications/android-studio.desktop

# mod permissions
sudo chmod 644 /usr/share/applications/android-studio.desktop
sudo chown root:root /usr/share/applications/android-studio.desktop



# # https://dev.to/janetmutua/installing-android-studio-on-ubuntu-2204-complete-guide-1kh8
# wget https://dl.google.com/dl/android/studio/ide-zips/2022.1.1.21/android-studio-2022.1.1.21-linux.tar.gz
# tar -zxvf android-studio-2022.1.1.21-linux.tar.gz
# sudo mv android-studio /opt/
# sudo ln -sf /opt/android-studio/bin/studio.sh /bin/android-studio

# sudo nano /usr/share/applications/android-studio.desktop

# [Desktop Entry]
# Version=1.0
# Type=Application
# Name=Android Studio
# Comment=Android Studio
# Exec=bash -i "/opt/android-studio/bin/studio.sh" %f
# Icon=/opt/android-studio/bin/studio.png
# Categories=Development;IDE;
# Terminal=false
# StartupNotify=true
# StartupWMClass=jetbrains-android-studio
# Name[en_GB]=android-studio.desktop