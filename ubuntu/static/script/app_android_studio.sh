
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
