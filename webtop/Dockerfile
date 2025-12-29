FROM raindev11/webtop:latest

ARG DEBIAN_FRONTEND=noninteractive

RUN sed -i 's#kr.archive.ubuntu.com#mirror.kakao.com#g' /etc/apt/sources.list
RUN sed -i 's#archive.ubuntu.com#mirror.kakao.com#g' /etc/apt/sources.list
RUN sed -i 's#ports.ubuntu.com#mirror.yuki.net.uk#g' /etc/apt/sources.list

# 필요한 패키지 설치
RUN apt-get update && apt-get upgrade -y \
    && apt install -y init systemd sudo

# CMD ["/sbin/init"]