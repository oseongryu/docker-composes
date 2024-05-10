# https://gist.github.com/rob-murray/6828864
# create file:
sudo touch /usr/share/applications/code.desktop

sh_result=$(uname -m)

sudo echo "[Desktop Entry]" >> /usr/share/applications/code.desktop
sudo echo "Name=Visual Studio Code" >> /usr/share/applications/code.desktop
sudo echo "Comment=Code Editing. Redefined." >> /usr/share/applications/code.desktop
sudo echo "GenericName=Text Editor" >> /usr/share/applications/code.desktop

if [ "$sh_result" = "aarch64" ]; then
    sudo echo "Exec=/app/VSCode-linux-arm64/code %F" >> /usr/share/applications/code.desktop
else 
    sudo echo "Exec=/app/VSCode-linux-x64/code %F" >> /usr/share/applications/code.desktop
fi

sudo echo "Icon=/app/vscode.png" >> /usr/share/applications/code.desktop
sudo echo "Type=Application" >> /usr/share/applications/code.desktop
sudo echo "StartupNotify=false" >> /usr/share/applications/code.desktop
sudo echo "StartupWMClass=Code" >> /usr/share/applications/code.desktop
sudo echo "Categories=TextEditor;Development;IDE;" >> /usr/share/applications/code.desktop
sudo echo "MimeType=application/x-code-workspace;" >> /usr/share/applications/code.desktop
sudo echo "Actions=new-empty-window;" >> /usr/share/applications/code.desktop
sudo echo "Keywords=vscode;" >> /usr/share/applications/code.desktop

sudo echo "[Desktop Action new-empty-window]" >> /usr/share/applications/code.desktop
sudo echo "Name=New Empty Window" >> /usr/share/applications/code.desktop

if [ "$sh_result" = "aarch64" ]; then
    sudo echo "Exec=/app/VSCode-linux-x64/code --new-window %F" >> /usr/share/applications/code.desktop
else 
    sudo echo "Exec=/app/VSCode-linux-arm64/code --new-window %F" >> /usr/share/applications/code.desktop
fi
sudo echo "Icon=vscode" >> /usr/share/applications/code.desktop

sudo chmod 644 /usr/share/applications/code.desktop
sudo chown root:root /usr/share/applications/code.desktop

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
