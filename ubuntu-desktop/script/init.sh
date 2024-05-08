cd /app
tar -zxvf code-stable-x64-1714529314.tar.gz
tar -zxvf ideaIU-2024.1.1.tar.gz
# mv /app/.ssh ~/.ssh

# vscode portable
mkdir /app/VSCode-linux-x64/data
sh /app/script/init_user.sh
sh /app/script/init_korean.sh