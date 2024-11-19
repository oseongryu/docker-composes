# vscode
apt install -y curl git
curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.33.1/install.sh | bash

echo 'export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"' >> /etc/bashrc
echo '[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"' >> /etc/bashrc

# touch ~/.bash_profile
# echo 'export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"' >> ~/.bash_profile
# echo '[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"' >> ~/.bash_profile
# source ~/.bash_profile

nvm -v
nvm install 16.17.1
nvm use 16.17.1

npm i -g yarn

# java
# echo export JAVA_HOME8=/app/zulu8.78.0.19-ca-jdk8.0.412-linux_x64 >> ~/.bash_profile
# echo export PATH=$JAVA_HOME8/bin >> ~/.bash_profile