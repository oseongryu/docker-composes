FROM ubuntu:20.04
ENV TZ Asia/Seoul

# FROM automation-python2:latest
# update, upgrade
RUN         apt -y update && apt -y upgrade
# zsh
# RUN         apt -y install zsh curl git
# RUN         curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh | bash
# RUN         chsh -s /usr/bin/zsh

# pyenv
ENV DEBIAN_FRONTEND=noninteractive
RUN apt -y install python3-pip python3-tk python3-dev python-tk

RUN apt -y install xvfb scrot fonts-indic fonts-noto-cjk

# RUN  apt -y install systemd && timedatectl set-timezone Asia/Seoul && date