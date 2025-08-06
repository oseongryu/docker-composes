#!/bin/bash
sh_result=$(uname -m)

if [ ! -d "/app" ]; then
    sudo mkdir -p /app
fi
cd /app

if [ "$sh_result" = "aarch64" ]; then
    wget -O code-stable.tar.gz https://update.code.visualstudio.com/latest/linux-arm64/stable
else
    wget -O code-stable.tar.gz https://update.code.visualstudio.com/latest/linux-x64/stable
fi

sudo tar -zxvf code-stable*.tar.gz

if [ "$sh_result" = "aarch64" ]; then
    app_name=VSCode-linux-arm64
else 
    app_name=VSCode-linux-x64
fi

if [ "$sh_result" = "aarch64" ]; then
    sudo chown root:root /app/$app_name
    sudo chmod 777 /app/$app_name
    sudo mkdir /app/$app_name/data
    sudo chmod 777 /app/$app_name/data
    sudo mv /app/$app_name /opt/
else 
    sudo chown root:root /app/$app_name
    sudo chmod 777 /app/$app_name
    sudo mkdir /app/$app_name/data
    sudo chmod 777 /app/$app_name/data
    sudo mv /app/$app_name /opt/
fi

# https://gist.github.com/rob-murray/6828864
# create file:
sudo touch /usr/share/applications/code.desktop
sudo chown root:root /usr/share/applications/code.desktop
sudo chmod 777 /usr/share/applications/code.desktop

sudo echo "[Desktop Entry]" >> /usr/share/applications/code.desktop
sudo echo "Name=Visual Studio Code" >> /usr/share/applications/code.desktop
sudo echo "Comment=Code Editing. Redefined." >> /usr/share/applications/code.desktop
sudo echo "GenericName=Text Editor" >> /usr/share/applications/code.desktop

sudo echo "Exec=/opt/$app_name/code %F" >> /usr/share/applications/code.desktop

sudo echo "Icon=/opt/$app_name/resources/app/resources/linux/code.png" >> /usr/share/applications/code.desktop
sudo echo "Type=Application" >> /usr/share/applications/code.desktop
sudo echo "StartupNotify=false" >> /usr/share/applications/code.desktop
sudo echo "StartupWMClass=Code" >> /usr/share/applications/code.desktop
sudo echo "Categories=TextEditor;Development;IDE;" >> /usr/share/applications/code.desktop
sudo echo "MimeType=application/x-code-workspace;" >> /usr/share/applications/code.desktop
sudo echo "Actions=new-empty-window;" >> /usr/share/applications/code.desktop
sudo echo "Keywords=vscode;" >> /usr/share/applications/code.desktop

sudo echo "[Desktop Action new-empty-window]" >> /usr/share/applications/code.desktop
sudo echo "Name=New Empty Window" >> /usr/share/applications/code.desktop

sudo echo "Exec=/opt/$app_name/code --new-window %F" >> /usr/share/applications/code.desktop
sudo echo "Icon=vscode" >> /usr/share/applications/code.desktop


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