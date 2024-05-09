FROM ubuntu:20.04
# 설치시 사용자 입력을 요구하는 것을 방지하는 설정
ARG DEBIAN_FRONTEND=noninteractive

ENV TZ Asia/Seoul

# 1
CMD ["/sbin/init"]

# # 2
# ENTRYPOINT ["/usr/sbin/init"]
# CMD ["systemctl"]

# RUN sed -i 's#kr.archive.ubuntu.com#mirror.kakao.com/ubuntu-ports#g' /etc/apt/sources.list #amd
# RUN sed -i 's#mirror.kakao.com#ports.ubuntu.com/ubuntu-ports#g' /etc/apt/sources.list # arm
ARG TARGETPLATFORM
RUN if [ "$TARGETPLATFORM" = "linux/arm64" ]; then sed -i 's/ports.ubuntu.com/mirror.yuki.net.uk/g' /etc/apt/sources.list; \
    elif [ "$ARCHITECTURE" = "linux/arm/v7" ]; then sed -i 's/ports.ubuntu.com/mirror.yuki.net.uk/g' /etc/apt/sources.list; \
    else sed -i 's#archive.ubuntu.com#mirror.kakao.com#g' /etc/apt/sources.list; fi
RUN apt upgrade -y

# # update, upgrade
RUN apt-get update && apt-get upgrade -y \
    && apt install -y init systemd sudo \
    && apt install -y build-essential \
    && apt install -y vim curl \
    && apt install -y net-tools iputils-ping

RUN apt install -y ubuntu-desktop

RUN apt install -y xrdp
RUN cp /etc/xrdp/xrdp.ini /etc/xrdp/xrdp.ini.bak
RUN sed -i 's/3389/3389/g' /etc/xrdp/xrdp.ini
RUN sed -i 's/max_bpp=32/#max_bpp=32nmax_bpp=128/g' /etc/xrdp/xrdp.ini
RUN sed -i 's/xserverbpp=24/#xserverbpp=24nxserverbpp=128/g' /etc/xrdp/xrdp.ini

RUN echo unset DBUS_SESSION_BUS_ADDRESS >> /etc/xrdp/startwm.sh
RUN echo unset XDG_RUNTIME_DIR  >> /etc/xrdp/startwm.sh

RUN /etc/init.d/xrdp stop
RUN /etc/init.d/xrdp start


# # xfce4 필요시
# # https://askubuntu.com/questions/899391/getting-input-output-error-running-anything-on-remote-desktop
# RUN apt install -y xfce4 xfce4-goodies xfce4-session
# RUN echo "xfce4-session" > ~/.xsession
# # RUN xfce4-terminal
# # RUN update-alternatives --config x-terminal-emulator


# # Variables
# ARG USERNAME=ubuntu
# ARG USER_UID=1000
# ARG USER_GID=$USER_UID
# ARG USER_PASSWD=password

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
# # echo "ubuntu:password" | chpasswd