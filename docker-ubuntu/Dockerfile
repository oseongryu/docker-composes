FROM ubuntu:22.04
# windows의 경우
# ENTRYPOINT ["/usr/sbin/init"]
# CMD ["systemctl"]
ENV TZ Asia/Seoul

# 설치시 사용자 입력을 요구하는 것을 방지하는 설정
ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get upgarde -y \
    && apt install -y init systemd \
    && apt install -y build-essential \
    && apt install -y vim curl \
    && apt install -y net-tools iputils-ping \
    && apt-get clean autoclean \
    && apt-get autoremove -y \
    && rm -rf /var/lib/{apt,dpkg,cache,log} \

VOLUME ["/sys/fs/cgroup"]
CMD ["/usr/sbin/init"]