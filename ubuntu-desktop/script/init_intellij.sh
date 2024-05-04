# https://gist.github.com/rob-murray/6828864
# create file:
sudo vim /usr/share/applications/intellij.desktop

sudo echo "[Desktop Entry]" > /usr/share/applications/intellij.desktop
sudo echo "Version=13.0" > /usr/share/applications/intellij.desktop
sudo echo "Type=Application" > /usr/share/applications/intellij.desktop
sudo echo "Terminal=false" > /usr/share/applications/intellij.desktop
sudo echo "Icon[en_US]=/home/ubuntu/DEV/idea-IU-241.15989.150/bin/idea.png" > /usr/share/applications/intellij.desktop
sudo echo "Name[en_US]=IntelliJ" > /usr/share/applications/intellij.desktop
sudo echo "Exec=/home/ubuntu/DEV/idea-IU-241.15989.150/bin/idea.sh" > /usr/share/applications/intellij.desktop
sudo echo "Name=IntelliJ" > /usr/share/applications/intellij.desktop
sudo echo "Icon=/home/ubuntu/DEV/idea-IU-241.15989.150/bin/idea.png" > /usr/share/applications/intellij.desktop
sudo echo "Categories=TextEditor;Development;IDE;" > /usr/share/applications/intellij.desktop
# mod permissions
sudo chmod 644 /usr/share/applications/intellij.desktop
sudo chown root:root /usr/share/applications/intellij.desktop

# # intellij
# [Desktop Entry]
# Version=13.0
# Type=Application
# Terminal=false
# Icon[en_US]=/home/ubuntu/DEV/idea-IU-241.15989.150/bin/idea.png
# Name[en_US]=IntelliJ
# Exec=/home/ubuntu/DEV/idea-IU-241.15989.150/bin/idea.sh
# Name=IntelliJ
# Icon=/home/ubuntu/DEV/idea-IU-241.15989.150/bin/idea.png
# Categories=TextEditor;Development;IDE;

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
