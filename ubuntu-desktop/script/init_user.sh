# sudo adduser ubuntu #password: password


USERNAME=ubuntu
USER_UID=1000
USER_GID=$USER_UID
USER_PASSWD=password


groupadd --gid $USER_GID $USERNAME \
    && useradd --uid $USER_UID --gid $USER_GID -m $USERNAME \
    && echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME \
    && chmod 0440 /etc/sudoers.d/$USERNAME

# password
echo $USERNAME:$USER_PASSWD | chpasswd

# xsession
mkdir /home/$USERNAME
chown $USERNAME:$USERNAME /home/$USERNAME
echo "xfce4-session" > /home/$USERNAME/.xsession

# change shell
chsh -s /bin/bash $USERNAME

