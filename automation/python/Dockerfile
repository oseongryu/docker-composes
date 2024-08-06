FROM ubuntu:20.04
ENV TZ Asia/Seoul


ARG TARGETPLATFORM
RUN if [ "$TARGETPLATFORM" = "linux/arm64" ]; then sed -i 's#ports.ubuntu.com#mirror.yuki.net.uk#g' /etc/apt/sources.list; \
    elif [ "$TARGETPLATFORM" = "linux/arm/v7" ]; then sed -i 's#ports.ubuntu.com#mirror.yuki.net.uk#g' /etc/apt/sources.list; \
    else sed -i 's#archive.ubuntu.com#mirror.kakao.com#g' /etc/apt/sources.list; fi
RUN apt upgrade -y

# update, upgrade
RUN apt -y update && apt -y upgrade
# pyenv
ENV DEBIAN_FRONTEND=noninteractive
RUN apt -y install python3-pip python3-tk python3-dev python-tk
RUN apt -y install xvfb scrot fonts-indic fonts-noto-cjk psmisc gnome-screenshot