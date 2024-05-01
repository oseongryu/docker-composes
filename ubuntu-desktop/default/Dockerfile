FROM ubuntu:20.04
# windows의 경우
ENTRYPOINT ["/usr/sbin/init"]
CMD ["systemctl"]
ENV TZ Asia/Seoul

# 설치시 사용자 입력을 요구하는 것을 방지하는 설정
ARG DEBIAN_FRONTEND=noninteractive


# update, upgrade
RUN apt -y update && apt -y upgrade && apt-get install -y init sudo
RUN apt install -y ubuntu-desktop
RUN apt install -y vim net-tools

RUN apt install -y xrdp
RUN cp /etc/xrdp/xrdp.ini /etc/xrdp/xrdp.ini.bak
RUN sed -i 's/3389/3389/g' /etc/xrdp/xrdp.ini
RUN sed -i 's/max_bpp=32/#max_bpp=32nmax_bpp=128/g' /etc/xrdp/xrdp.ini
RUN sed -i 's/xserverbpp=24/#xserverbpp=24nxserverbpp=128/g' /etc/xrdp/xrdp.ini

RUN /etc/init.d/xrdp stop
RUN /etc/init.d/xrdp start
