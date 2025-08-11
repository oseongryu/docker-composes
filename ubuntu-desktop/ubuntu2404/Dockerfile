FROM ubuntu:24.04

CMD ["/sbin/init"]

# 설치시 사용자 입력을 요구하는 것을 방지하는 설정
ARG DEBIAN_FRONTEND=noninteractive
# 다른 플랫폼에서 빌드할 때 사용되는 변수
ARG TARGETPLATFORM

# 타임존 설정
ENV TZ=Asia/Seoul

ENV URL="https://gist.githubusercontent.com/oseongryu/d50f81d8894af19821c9f2e5d9b6646b/raw/1c940213080745c16d5eed58741a8ca27b7efa2a"

ADD ${URL}/update_file_list.txt /script/
ADD ${URL}/update_scripts.sh /script/

# 작업 전 처리
RUN if [ "$TARGETPLATFORM" = "linux/arm64" ]; then sed -i 's#ports.ubuntu.com#mirror.yuki.net.uk#g' /etc/apt/sources.list; \
    elif [ "$TARGETPLATFORM" = "linux/arm/v7" ]; then sed -i 's#ports.ubuntu.com#mirror.yuki.net.uk#g' /etc/apt/sources.list; \
    else sed -i 's#archive.ubuntu.com#mirror.kakao.com#g' /etc/apt/sources.list; fi
# update, upgrade
RUN apt update -y && apt upgrade -y

# update, upgrade
RUN apt-get update && apt-get upgrade -y \
    && apt install -y init systemd sudo \
    && apt install -y build-essential \
    && apt install -y vim net-tools \
    && apt install -y curl wget \
    && apt-get clean autoclean \
    && apt-get autoremove -y \
    && rm -rf /var/lib/{apt,dpkg,cache,log}


RUN apt install -y ubuntu-desktop
RUN apt install -y xrdp

RUN cp /etc/xrdp/xrdp.ini /etc/xrdp/xrdp.ini.bak
RUN sed -i 's/3389/3389/g' /etc/xrdp/xrdp.ini
RUN sed -i 's/max_bpp=32/#max_bpp=32nmax_bpp=128/g' /etc/xrdp/xrdp.ini
RUN sed -i 's/xserverbpp=24/#xserverbpp=24nxserverbpp=128/g' /etc/xrdp/xrdp.ini

# RUN echo unset DBUS_SESSION_BUS_ADDRESS >> /etc/xrdp/startwm.sh
# RUN echo unset XDG_RUNTIME_DIR  >> /etc/xrdp/startwm.sh

RUN /etc/init.d/xrdp stop
RUN /etc/init.d/xrdp start

# xfce4 필요시
# https://askubuntu.com/questions/899391/getting-input-output-error-running-anything-on-remote-desktop
RUN apt install -y xfce4 xfce4-goodies xfce4-session
# RUN echo "xfce4-session" > ~/.xsession


RUN sh /script/update_scripts.sh
RUN sh /script/init_korean.sh
RUN sh /script/init_timezone.sh
RUN sh /script/init_user.sh
# RUN sh /script/python_automation.sh
# RUN sh /script/python_shorts.sh

# RUN sudo apt install python3.12-venv
# RUN python3 -m venv /venv
# source ~/venv/bin/activate

# 작업 후 복구
RUN if [ "$TARGETPLATFORM" = "linux/arm64" ]; then sed -i 's#mirror.yuki.net.uk#ports.ubuntu.com#g' /etc/apt/sources.list; \
    elif [ "$TARGETPLATFORM" = "linux/arm/v7" ]; then sed -i 's#mirror.yuki.net.uk#ports.ubuntu.com#g' /etc/apt/sources.list; \
    else sed -i 's#mirror.kakao.com#archive.ubuntu.com#g' /etc/apt/sources.list; fi
# update, upgrade
RUN apt update -y && apt upgrade -y