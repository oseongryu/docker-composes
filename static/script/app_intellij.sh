#!/bin/bash
sh_result=$(uname -m)
cd /app && sudo tar -zxvf ideaIU-*.tar.gz

if [ "$sh_result" = "aarch64" ]; then
    app_name=idea-IU-241.15989.150
else 
    app_name=idea-IU-241.17890.1
fi

if [ "$sh_result" = "aarch64" ]; then
    sudo chown root:root /app/$app_name
    sudo chmod 777 /app/$app_name
    sudo mv /app/$app_name /opt/
else 
    sudo chown root:root /app/$app_name
    sudo chmod 777 /app/$app_name
    sudo mv /app/$app_name /opt/
fi

# sudo adduser ubuntu
# echo "xfce4-session" > ~/.xsession
# echo ubuntu ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/ubuntu

# https://gist.github.com/rob-murray/6828864
# create file:
sudo touch /usr/share/applications/intellij.desktop
sudo chown root:root /usr/share/applications/intellij.desktop
sudo chmod 777 /usr/share/applications/intellij.desktop

sudo echo "[Desktop Entry]" >> /usr/share/applications/intellij.desktop
sudo echo "Version=13.0" >> /usr/share/applications/intellij.desktop
sudo echo "Type=Application" >> /usr/share/applications/intellij.desktop
sudo echo "Terminal=false" >> /usr/share/applications/intellij.desktop
sudo echo "Icon[en_US]=/opt/$app_name/bin/idea.png" >> /usr/share/applications/intellij.desktop
sudo echo "Name[en_US]=IntelliJ" >> /usr/share/applications/intellij.desktop
sudo echo "Exec=/opt/$app_name/bin/idea.sh" >> /usr/share/applications/intellij.desktop
sudo echo "Name=IntelliJ" >> /usr/share/applications/intellij.desktop
sudo echo "Icon=/opt/$app_name/bin/idea.png" >> /usr/share/applications/intellij.desktop
sudo echo "Categories=TextEditor;Development;IDE;" >> /usr/share/applications/intellij.desktop

# # intellij
# [Desktop Entry]
# Version=13.0
# Type=Application
# Terminal=false
# Icon[en_US]=/opt/$app_name/bin/idea.png
# Name[en_US]=IntelliJ
# Exec=/opt/$app_name/bin/idea.sh
# Name=IntelliJ
# Icon=/opt/$app_name/bin/idea.png
# Categories=TextEditor;Development;IDE;