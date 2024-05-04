FROM ubuntu:22.04
# windows의 경우
ENTRYPOINT ["/usr/sbin/init"]
CMD ["systemctl"]
ENV TZ Asia/Seoul

# 설치시 사용자 입력을 요구하는 것을 방지하는 설정
ARG DEBIAN_FRONTEND=noninteractive


# update, upgrade
RUN apt -y update && apt -y upgrade
RUN apt install -y init sudo
RUN apt install -y vim net-tools
RUN apt install -y ubuntu-desktop
