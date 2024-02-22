FROM ubuntu:20.04
ENV TZ Asia/Seoul

# update, upgrade
RUN apt -y update && apt -y upgrade
# pyenv
ENV DEBIAN_FRONTEND=noninteractive
RUN apt -y install python3-pip python3-tk python3-dev python-tk
RUN apt -y install xvfb scrot fonts-indic fonts-noto-cjk psmisc