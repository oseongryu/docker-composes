FROM oseongryu/ubuntu-desktop:20.04
ENV TZ Asia/Seoul

ENV URL="https://gist.githubusercontent.com/oseongryu/d50f81d8894af19821c9f2e5d9b6646b/raw/314c91ad55816f727c7a08c3859111c72342c1c2"
ADD ${URL}/automation_init.sh /script/
ADD ${URL}/automation_init_python.sh /script/
ADD ${URL}/app_chrome.sh /script/
ADD ${URL}/init_korean.sh /script/
ADD ${URL}/init_user.sh /script/

ARG TARGETPLATFORM

# 작업 전 처리
RUN if [ "$TARGETPLATFORM" = "linux/arm64" ]; then sed -i 's#ports.ubuntu.com#mirror.yuki.net.uk#g' /etc/apt/sources.list; \
    elif [ "$TARGETPLATFORM" = "linux/arm/v7" ]; then sed -i 's#ports.ubuntu.com#mirror.yuki.net.uk#g' /etc/apt/sources.list; \
    else sed -i 's#archive.ubuntu.com#mirror.kakao.com#g' /etc/apt/sources.list; fi
RUN apt upgrade -y

# update, upgrade
RUN apt update -y && apt upgrade -y

# pyenv
ENV DEBIAN_FRONTEND=noninteractive
# RUN apt -y install python3-pip python3-tk python3-dev python-tk
# RUN apt -y install xvfb scrot fonts-indic fonts-noto-cjk psmisc gnome-screenshot
RUN sh /script/automation_init.sh
RUN sh /script/automation_init_python.sh
RUN sh /script/init_korean.sh
# RUN sh /script/init_user.sh
# RUN sh /script/app_chrome.sh

# 작업 후 복구
RUN if [ "$TARGETPLATFORM" = "linux/arm64" ]; then sed -i 's#mirror.yuki.net.uk#ports.ubuntu.com#g' /etc/apt/sources.list; \
    elif [ "$TARGETPLATFORM" = "linux/arm/v7" ]; then sed -i 's#mirror.yuki.net.uk#ports.ubuntu.com#g' /etc/apt/sources.list; \
    else sed -i 's#mirror.kakao.com#archive.ubuntu.com#g' /etc/apt/sources.list; fi
RUN apt upgrade -y