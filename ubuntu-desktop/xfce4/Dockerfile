FROM ubuntu:20.04
# windows의 경우
ENTRYPOINT ["/usr/sbin/init"]
CMD ["systemctl"]
ENV TZ Asia/Seoul

# 설치시 사용자 입력을 요구하는 것을 방지하는 설정
ARG DEBIAN_FRONTEND=noninteractive


# update, upgrade
RUN apt -y update && apt -y upgrade && apt install -y init sudo

# xfce4 필요시
# https://askubuntu.com/questions/899391/getting-input-output-error-running-anything-on-remote-desktop
RUN apt install -y xfce4 && apt install -y xfce4-goodies && apt install -y xfce4-session

RUN apt install -y xubuntu-desktop
RUN apt install -y vim net-tools

RUN apt install -y xrdp
RUN cp /etc/xrdp/xrdp.ini /etc/xrdp/xrdp.ini.bak
RUN sed -i 's/3389/3389/g' /etc/xrdp/xrdp.ini
RUN sed -i 's/max_bpp=32/#max_bpp=32nmax_bpp=128/g' /etc/xrdp/xrdp.ini
RUN sed -i 's/xserverbpp=24/#xserverbpp=24nxserverbpp=128/g' /etc/xrdp/xrdp.ini

RUN echo unset DBUS_SESSION_BUS_ADDRESS >> /etc/xrdp/startwm.sh
RUN echo unset XDG_RUNTIME_DIR  >> /etc/xrdp/startwm.sh
RUN echo "xfce4-session" > ~/.xsession
# RUN xfce4-terminal
# RUN update-alternatives --config x-terminal-emulator


RUN /etc/init.d/xrdp stop
RUN /etc/init.d/xrdp start

# # Variables
# ARG USERNAME=oseongryu
# ARG USER_UID=1000
# ARG USER_GID=$USER_UID
# ARG USER_PASSWD=1234

# # 사용자 추가 필요시
# RUN groupadd --gid $USER_GID $USERNAME \
#     && useradd --uid $USER_UID --gid $USER_GID -m $USERNAME \
#     && apt-get update \
#     && apt-get install -y sudo \
#     && echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME \
#     && chmod 0440 /etc/sudoers.d/$USERNAME \
#     && echo $USERNAME:$USER_PASSWD | chpasswd

# # 사용자 비밀번호
# # https://www.clien.net/service/board/cm_linux/16608785
# # https://louky0714.tistory.com/82
# # echo "oseongryu:1234" | chpasswd


