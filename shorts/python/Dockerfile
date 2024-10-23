FROM ubuntu:20.04
ENV TZ Asia/Seoul

ENV URL="https://gist.githubusercontent.com/oseongryu/d50f81d8894af19821c9f2e5d9b6646b/raw/c9c4b0b0b1a153ef23364cb8703b9ee0c1de81c8"
ADD ${URL}/automation_init_python.sh /script/
ADD ${URL}/automation_init.sh /script/
ADD ${URL}/shorts_python_flask.sh /script/

ADD ${URL}/init_korean.sh /script/

ADD ${URL}/app_chrome.sh /script/

ARG TARGETPLATFORM

# 작업 전 처리
RUN if [ "$TARGETPLATFORM" = "linux/arm64" ]; then sed -i 's#ports.ubuntu.com#mirror.yuki.net.uk#g' /etc/apt/sources.list; \
    elif [ "$TARGETPLATFORM" = "linux/arm/v7" ]; then sed -i 's#ports.ubuntu.com#mirror.yuki.net.uk#g' /etc/apt/sources.list; \
    else sed -i 's#archive.ubuntu.com#mirror.kakao.com#g' /etc/apt/sources.list; fi
# update, upgrade
RUN apt update -y && apt upgrade -y

# pyenv
ENV DEBIAN_FRONTEND=noninteractive
# RUN apt -y install python3-pip python3-tk python3-dev python-tk
# RUN apt -y install xvfb scrot fonts-indic fonts-noto-cjk psmisc gnome-screenshot
RUN sh /script/automation_init.sh
RUN sh /script/automation_init_python.sh
RUN sh /script/init_korean.sh
RUN sh /script/app_chrome.sh

# 작업 후 복구
RUN if [ "$TARGETPLATFORM" = "linux/arm64" ]; then sed -i 's#mirror.yuki.net.uk#ports.ubuntu.com#g' /etc/apt/sources.list; \
    elif [ "$TARGETPLATFORM" = "linux/arm/v7" ]; then sed -i 's#mirror.yuki.net.uk#ports.ubuntu.com#g' /etc/apt/sources.list; \
    else sed -i 's#mirror.kakao.com#archive.ubuntu.com#g' /etc/apt/sources.list; fi
# update, upgrade
RUN apt update -y && apt upgrade -y