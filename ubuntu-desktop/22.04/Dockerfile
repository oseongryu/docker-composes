FROM ubuntu:20.04
# windows의 경우
# ENTRYPOINT ["/usr/sbin/init"]
# CMD ["systemctl"]
# 설치시 사용자 입력을 요구하는 것을 방지하는 설정
ARG DEBIAN_FRONTEND=noninteractive

ENV TZ Asia/Seoul
CMD ["/sbin/init"]

ARG TARGETPLATFORM

# RUN sed -i 's#kr.archive.ubuntu.com#mirror.kakao.com/ubuntu-ports#g' /etc/apt/sources.list #amd
# RUN sed -i 's#mirror.kakao.com#ports.ubuntu.com/ubuntu-ports#g' /etc/apt/sources.list # arm
RUN if [ "$TARGETPLATFORM" = "linux/arm64" ]; then sed -i 's/ports.ubuntu.com/mirror.yuki.net.uk/g' /etc/apt/sources.list; \
    elif [ "$ARCHITECTURE" = "linux/arm/v7" ]; then sed -i 's/ports.ubuntu.com/mirror.yuki.net.uk/g' /etc/apt/sources.list; \
    else sed -i 's#kr.archive.ubuntu.com#mirror.kakao.com/ubuntu-ports#g' /etc/apt/sources.list; fi

RUN apt upgrade -y

# # update, upgrade
RUN apt-get update && apt-get upgrade -y \
    && apt install -y init systemd sudo \
    && apt install -y build-essential \
    && apt install -y vim curl \
    && apt install -y net-tools iputils-ping \
    && apt-get clean autoclean \
    && apt-get autoremove -y \
    && rm -rf /var/lib/{apt,dpkg,cache,log}

# xfce4 필요시
# https://askubuntu.com/questions/899391/getting-input-output-error-running-anything-on-remote-desktop
RUN apt install -y xfce4 xfce4-goodies xfce4-session

RUN apt install -y ubuntu-desktop
