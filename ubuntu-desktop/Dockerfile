FROM ubuntu:20.04
ENTRYPOINT ["/usr/sbin/init"]
CMD ["systemctl"]
ENV TZ Asia/Seoul

# 설치시 사용자 입력을 요구하는 것을 방지하는 설정
ARG DEBIAN_FRONTEND=noninteractive

# update, upgrade
RUN apt -y update && apt -y upgrade && apt-get install -y init
# RUN apt install -y ubuntu-desktop
# RUN apt install -y xfce4
# RUN apt install -y xrdp
# RUN cp /etc/xrdp/xrdp.ini /etc/xrdp/xrdp.ini.bak
# RUN sed -i 's/3389/13389/g' /etc/xrdp/xrdp.ini
# RUN sed -i 's/max_bpp=32/#max_bpp=32nmax_bpp=128/g' /etc/xrdp/xrdp.ini
# RUN sed -i 's/xserverbpp=24/#xserverbpp=24nxserverbpp=128/g' /etc/xrdp/xrdp.ini
# RUN echo unset DBUS_SESSION_BUS_ADDRESS >> /etc/xrdp/startwm.sh
# RUN echo unset XDG_RUNTIME_DIR  >> /etc/xrdp/startwm.sh
# RUN echo "xfce4-session" > ~/.xsession

RUN apt install -y vim net-tools

# https://askubuntu.com/questions/899391/getting-input-output-error-running-anything-on-remote-desktop
# RUN xfce4-terminal
# RUN update-alternatives --config x-terminal-emulator

# RUN /etc/init.d/xrdp stop
# RUN /etc/init.d/xrdp start



# apt install slim
# cat /etc/X11/default-display-manager

# apt install lightdm

# apt install ubuntu-desktop

# reboot

# # delete GUI diplay manager 
# apt remove slim lxde
# # 불필요한 종속성제외
# apt autoremove




# cp /etc/xrdp/xrdp.ini /etc/xrdp/xrdp.ini.bak
# sed -i 's/3389/13389/g' /etc/xrdp/xrdp.ini
# sed -i 's/max_bpp=32/#max_bpp=32nmax_bpp=128/g' /etc/xrdp/xrdp.ini
# sed -i 's/xserverbpp=24/#xserverbpp=24nxserverbpp=128/g' /etc/xrdp/xrdp.ini
# echo unset DBUS_SESSION_BUS_ADDRESS >> /etc/xrdp/startwm.sh
# echo unset XDG_RUNTIME_DIR  >> /etc/xrdp/startwm.sh
# echo "xfce4-session" > ~/.xsession

# service slim start

# /etc/init.d/xrdp stop
# /etc/init.d/xrdp start