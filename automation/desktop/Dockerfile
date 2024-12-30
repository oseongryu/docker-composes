FROM oseongryu/ubuntu-desktop:20.04
ENV TZ Asia/Seoul

ENV URL="https://gist.githubusercontent.com/oseongryu/d50f81d8894af19821c9f2e5d9b6646b/raw/b8e5e960eb0551295ee596c5449b7c275fca7a53"
ADD ${URL}/app_android_studio.sh /script/
ADD ${URL}/app_chrome.sh /script/
ADD ${URL}/app_intellij.sh /script/
ADD ${URL}/app_vscode.sh /script/
ADD ${URL}/app_warp.sh /script/

ADD ${URL}/init_env_nvm.sh /script/
ADD ${URL}/init_korean.sh /script/
ADD ${URL}/init_timezone.sh /script/
ADD ${URL}/init_user.sh /script/

ADD ${URL}/python_automation.sh /script/
ADD ${URL}/python_shorts.sh /script/


# COPY ./app/ /app/

ARG TARGETPLATFORM

# 작업 전 처리
RUN if [ "$TARGETPLATFORM" = "linux/arm64" ]; then sed -i 's#ports.ubuntu.com#mirror.yuki.net.uk#g' /etc/apt/sources.list; \
    elif [ "$TARGETPLATFORM" = "linux/arm/v7" ]; then sed -i 's#ports.ubuntu.com#mirror.yuki.net.uk#g' /etc/apt/sources.list; \
    else sed -i 's#archive.ubuntu.com#mirror.kakao.com#g' /etc/apt/sources.list; fi
# update, upgrade
RUN apt update -y && apt upgrade -y

# pyenv
ENV DEBIAN_FRONTEND=noninteractive
# https://www.digitalocean.com/community/tutorials/how-to-enable-remote-desktop-protocol-using-xrdp-on-ubuntu-22-04
# RUN apt -y install python3-pip python3-tk python3-dev python-tk
# RUN apt -y install xvfb scrot fonts-indic fonts-noto-cjk psmisc gnome-screenshot
RUN sh /script/init_korean.sh
RUN sh /script/init_user.sh
# RUN sh /script/python_automation.sh

# 작업 후 복구
RUN if [ "$TARGETPLATFORM" = "linux/arm64" ]; then sed -i 's#mirror.yuki.net.uk#ports.ubuntu.com#g' /etc/apt/sources.list; \
    elif [ "$TARGETPLATFORM" = "linux/arm/v7" ]; then sed -i 's#mirror.yuki.net.uk#ports.ubuntu.com#g' /etc/apt/sources.list; \
    else sed -i 's#mirror.kakao.com#archive.ubuntu.com#g' /etc/apt/sources.list; fi
# update, upgrade
RUN apt update -y && apt upgrade -y