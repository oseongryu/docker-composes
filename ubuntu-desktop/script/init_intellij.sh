sudo adduser ubuntu
echo "xfce4-session" > ~/.xsession

echo ubuntu ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/ubuntu

# https://gist.github.com/rob-murray/6828864
# create file:
sudo vim /usr/share/applications/intellij.desktop
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

# intellij
[Desktop Entry]
Version=13.0
Type=Application
Terminal=false
Icon[en_US]=/app/idea-IU-241.15989.150/bin/idea.png
Name[en_US]=IntelliJ
Exec=/app/idea-IU-241.15989.150/bin/idea.sh
Name=IntelliJ
Icon=/app/idea-IU-241.15989.150/bin/idea.png
Categories=TextEditor;Development;IDE;

# https://gist.github.com/rob-murray/6828864
# create file:
sudo touch /usr/share/applications/code.desktop
sudo vim /usr/share/applications/code.desktop

sudo chmod 644 /usr/share/applications/code.desktop
sudo chown root:root /usr/share/applications/code.desktop

/app/VSCode-linux-x64/bin

sudo echo "[Desktop Entry]" >> /usr/share/applications/code.desktop
sudo echo "Name=Visual Studio Code" >> /usr/share/applications/code.desktop
sudo echo "Comment=Code Editing. Redefined." >> /usr/share/applications/code.desktop
sudo echo "GenericName=Text Editor" >> /usr/share/applications/code.desktop
sudo echo "Exec=/app/VSCode-linux-x64/bin/code %F" >> /usr/share/applications/code.desktop
sudo echo "Icon=vscode" >> /usr/share/applications/code.desktop
sudo echo "Type=Application" >> /usr/share/applications/code.desktop
sudo echo "StartupNotify=false" >> /usr/share/applications/code.desktop
sudo echo "StartupWMClass=Code" >> /usr/share/applications/code.desktop
sudo echo "Categories=TextEditor;Development;IDE;" >> /usr/share/applications/code.desktop
sudo echo "MimeType=application/x-code-workspace;" >> /usr/share/applications/code.desktop
sudo echo "Actions=new-empty-window;" >> /usr/share/applications/code.desktop
sudo echo "Keywords=vscode;" >> /usr/share/applications/code.desktop


# vscode
[Desktop Entry]
Name=Visual Studio Code
Comment=Code Editing. Redefined.
GenericName=Text Editor
Exec=/usr/share/code/code %F
Icon=vscode
Type=Application
StartupNotify=false
StartupWMClass=Code
Categories=TextEditor;Development;IDE;
MimeType=application/x-code-workspace;
Actions=new-empty-window;
Keywords=vscode;

[Desktop Action new-empty-window]
Name=New Empty Window
Name[de]=Neues leeres Fenster
Name[es]=Nueva ventana vacía
Name[fr]=Nouvelle fenêtre vide
Name[it]=Nuova finestra vuota
Name[ja]=新しい空のウィンドウ
Name[ko]=새 빈 창
Name[ru]=Новое пустое окно
Name[zh_CN]=新建空窗口
Name[zh_TW]=開新空視窗
Exec=/usr/share/code/code --new-window %F
Icon=vscode




# # vscode
# [Desktop Entry]
# Name=Visual Studio Code
# Comment=Code Editing. Redefined.
# GenericName=Text Editor
# Exec=/usr/share/code/code %F
# Icon=vscode
# Type=Application
# StartupNotify=false
# StartupWMClass=Code
# Categories=TextEditor;Development;IDE;
# MimeType=application/x-code-workspace;
# Actions=new-empty-window;
# Keywords=vscode;

# [Desktop Action new-empty-window]
# Name=New Empty Window
# Name[de]=Neues leeres Fenster
# Name[es]=Nueva ventana vacía
# Name[fr]=Nouvelle fenêtre vide
# Name[it]=Nuova finestra vuota
# Name[ja]=新しい空のウィンドウ
# Name[ko]=새 빈 창
# Name[ru]=Новое пустое окно
# Name[zh_CN]=新建空窗口
# Name[zh_TW]=開新空視窗
# Exec=/usr/share/code/code --new-window %F
# Icon=vscode
