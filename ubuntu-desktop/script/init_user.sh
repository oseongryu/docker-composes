USERNAME=ubuntu
USER_UID=1000
USER_GID=$USER_UID
USER_PASSWD=ubuntu

groupadd --gid $USER_GID $USERNAME \
    && useradd --uid $USER_UID --gid $USER_GID -m $USERNAME \
    && apt-get update \
    && apt-get install -y sudo \
    && echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME \
    && chmod 0440 /etc/sudoers.d/$USERNAME \
    && echo $USERNAME:$USER_PASSWD | chpasswd
    && echo "xfce4-session" > /home/$USERNAME/.xsession