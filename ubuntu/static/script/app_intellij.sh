# sudo adduser ubuntu
# echo "xfce4-session" > ~/.xsession
# echo ubuntu ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/ubuntu

# https://gist.github.com/rob-murray/6828864
# create file:
sudo touch /usr/share/applications/intellij.desktop

sudo echo "[Desktop Entry]" >> /usr/share/applications/intellij.desktop
sudo echo "Version=13.0" >> /usr/share/applications/intellij.desktop
sudo echo "Type=Application" >> /usr/share/applications/intellij.desktop
sudo echo "Terminal=false" >> /usr/share/applications/intellij.desktop
sudo echo "Icon[en_US]=/app/idea-IU-241.15989.150/bin/idea.png" >> /usr/share/applications/intellij.desktop
sudo echo "Name[en_US]=IntelliJ" >> /usr/share/applications/intellij.desktop
sudo echo "Exec=/app/idea-IU-241.15989.150/bin/idea.sh" >> /usr/share/applications/intellij.desktop
sudo echo "Name=IntelliJ" >> /usr/share/applications/intellij.desktop
sudo echo "Icon=/app/idea-IU-241.15989.150/bin/idea.png" >> /usr/share/applications/intellij.desktop
sudo echo "Categories=TextEditor;Development;IDE;" >> /usr/share/applications/intellij.desktop

# mod permissions
sudo chmod 644 /usr/share/applications/intellij.desktop
sudo chown root:root /usr/share/applications/intellij.desktop

# # intellij
# [Desktop Entry]
# Version=13.0
# Type=Application
# Terminal=false
# Icon[en_US]=/app/idea-IU-241.15989.150/bin/idea.png
# Name[en_US]=IntelliJ
# Exec=/app/idea-IU-241.15989.150/bin/idea.sh
# Name=IntelliJ
# Icon=/app/idea-IU-241.15989.150/bin/idea.png
# Categories=TextEditor;Development;IDE;