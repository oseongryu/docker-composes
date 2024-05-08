tar -zxvf /app/code-stable-x64-1714529314.tar.gz
tar -zxvf app/ideaIU-2024.1.1.tar.gz
mv /app/.ssh ~/.ssh

sh /app/script/init_user.sh
sh /app/script/init_korean.sh