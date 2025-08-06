FROM oseongryu/ubuntu-desktop:20.04
ENV TZ Asia/Seoul

ENV URL="https://gist.githubusercontent.com/oseongryu/d50f81d8894af19821c9f2e5d9b6646b/raw"
ADD ${URL}/update_file_list.txt /script/
ADD ${URL}/update_scripts.sh /script/
ADD ${URL}/init_korean.sh /script/
ADD ${URL}/init_user.sh /script/
ADD ${URL}/python_automation.sh /script/


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
RUN sh /script/update_scripts.sh

RUN sh /script/init_korean.sh
RUN sh /script/init_user.sh
RUN sh /script/python_automation.sh

# mac
# https://formulae.brew.sh/formula/pulseaudio 설치
# brew install pulseaudio
# 여서ㄴ됨
# pulseaudio --start
# pulseaudio -vvv
# ls /run/user/$(id -u)/pulse/


# 이건 됨
# pulseaudio --load=module-native-protocol-tcp --exit-idle-time=-1 --daemon
# pulseaudio --load="module-native-protocol-tcp" --exit-idle-time=-1 --daemon
#docker run -it -e PULSE_SERVER=docker.for.mac.localhost -v ~/.config/pulse:/home/pulseaudio/.config/pulse --entrypoint speaker-test --rm jess/pulseaudio -c 2 -l 1 -t wav

RUN apt-get update && apt-get install -y pulseaudio
# paplay /usr/share/sounds/alsa/Front_Center.wav
# 작업 후 복구
RUN if [ "$TARGETPLATFORM" = "linux/arm64" ]; then sed -i 's#mirror.yuki.net.uk#ports.ubuntu.com#g' /etc/apt/sources.list; \
    elif [ "$TARGETPLATFORM" = "linux/arm/v7" ]; then sed -i 's#mirror.yuki.net.uk#ports.ubuntu.com#g' /etc/apt/sources.list; \
    else sed -i 's#mirror.kakao.com#archive.ubuntu.com#g' /etc/apt/sources.list; fi
# update, upgrade
RUN apt update -y && apt upgrade -y