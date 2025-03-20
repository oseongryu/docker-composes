## db

### mysql

```
DEMO?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=Asia/Seoul
```

### oracle

```bash
docker cp ~/emt.dmp db-oracle:/test
<!-- C:\Users\f5074\Downloads\doc-master\EMT_doc\8_EMT.dmp -->

docker exec -it emt-db bash

impdp emt/emt directory=save file=emt.dmp

sqlplus "/as sysdba"
drop user emt cascade;
drop directory save;
create user emt identified by emt default tablespace users;
grant connect, resource to emt;
create directory save as '/test';
grant read, write on directory save to emt;
exit
impdp emt/emt directory=save file=emt.dmp

impdp emt/emt directory=save dumpfile=EMT.DMP logfile=emp.log full=y
impdp emt/emt directory=save dumpfile=EMT.DMP logfile=emp.log schemas=emt
impdp emt/emt directory=save dumpfile=emt.DMP logfile=emt.log schemas=emt

impdp emt/emt dumpfile=emt.dmp logfile=emt.log schemas=emt

impdp emt/emt file=/test/emt.dmp logfile=emt.log schemas=emt

cp -r EMT.DMP /u01/app/oracle/admin/XE/dpdump/

schemas=emt
docker exec  -it   db_193 expdp klrice/klrice@xe tables=t1 directory=docker_vol dumpfile=klrice.dmp logfile=klrice_exp.log
```

## mariadb

```bash
docker-compose up -d
docker-compose up --build -d

docker-compose stop
docker-compose down
docker-compose down -v  # volumes 포함 삭제

docker exec -it docker-compose-db-1 bash
mysql -uroot -p1234
```

## nuxt-ustra

```bash
# 이미지 재빌드가 필요하면 --build 옵션 추가, 그렇지 않으면 이미 작성된 이미지를 사용하게 됨
docker-compose up -d
docker-compose up --build -d

docker-compose stop
docker-compose down

docker exec -it nuxt-ustra-vue-1 bash
docker exec -it nuxt-ustra-spring-1 bash
```

### docker 수동 실행

```bash
docker run -it -d -p 10100:10100 -p 10200:10200 --privileged --restart=always --name centos-spring oseongryu/centos-spring:0.0.5 /sbin/init
docker exec -it centos-spring bash
```

### 네트워크 연결확인

```bash
docker network ls

docker exec nuxt-ustra-vue-1 ping nuxt-ustra-spring-1

### 네트워크 정보확인
docker network inspect our-net
docker network inspect bridge

### 네트워크 연결해제
docker network connect our-net centos-vue
docker network disconnect bridge centos-vue

### 네트워크 삭제
docker network rm our-net
```

## jekyll

```bash
docker run -it -d -p 4000:4000 -v /c/Users/oseongryu/git/test:/usr/src/apptest/ --name centos-ruby ruby:2.6 bash
docker exec -it centos-jekyll bash

gem install bundler
gem install bundler:2.3.26
bundler _2.3.26_ install
bundle exec jekyll serve -H 0.0.0.0 -t
```

## emt

### oracle

```bash
# docker cp ~/emt.dmp emt-db:/test
# C:\Users\f5074\Downloads\doc-master\EMT_doc\8_EMT.dmp
docker exec -it emt-db bash

sqlplus "/as sysdba"
drop user emt cascade;
drop directory save;
create user emt identified by emt default tablespace users;
grant connect, resource to emt;

create directory save as '/app';
grant read, write on directory save to emt;
exit

impdp emt/emt directory=save file=/app/emt.dmp logfile=emt.log full=y
impdp emt/emt directory=save file=/app/emt.dmp logfile=emt.log schemas=emt

cp -r EMT.DMP /u01/app/oracle/admin/XE/dpdump/

# docker exec  -it   db_193 expdp klrice/klrice@xe tables=t1 directory=docker_vol dumpfile=klrice.dmp logfile=klrice_exp.log
docker exec was-emt ping db-emt
```

## gptinfo

```bash
docker cp /docker-composes/gptinfo/mysql/init/20231120.sql db-mysql:/20231120.sql
sudo docker exec -it db-mysql bash
mysql -uroot -p testdb < /20231120.sql

# /usr/local/mysql/bin/mysqldump -u root -p[password] [database_name] > /[backup_directory]/[database_name]_$(date '+%Y_%m_%d).sql
mysqldump -u root -p testdb > /20231218.sql
docker cp db-mysql:/20231218.sql ~/git/docker-composes/gptinfo/mysql/init/

```

## automation

```bash
docker run -it -d -p 8888:8888 -v c:/users/oseongryu/git:/root/git --privileged --restart=always --name automation-python oseongryu/automation-python:latest
docker run -it -d -p 8888:8888 -v ~/git:/root/git --privileged --restart=always --name automation-python oseongryu/automation-python:latest

docker exec -it automation-python bash
python3 /home/oseongryu/git/python-selenium/selenium/service.py 0
docker exec -it ubuntu-desktop sh -c "cd /home/ubuntu/git/python-selenium/ && python3 /home/ubuntu/git/python-selenium/selenium/service.py 0"
docker exec -it ubuntu-desktop sh -c "cd /home/ubuntu/git/python-selenium/ && python3 /home/ubuntu/git/python-selenium/selenium/service.py 1"
docker exec -it ubuntu-desktop sh -c "cd /home/ubuntu/git/python-selenium/ && python3 /home/ubuntu/git/python-selenium/selenium/service.py 2"
docker exec -it ubuntu-desktop sh -c "cd /home/ubuntu/git/python-selenium/ && python3 /home/ubuntu/git/python-selenium/selenium/service.py 3"
docker exec -it ubuntu-desktop sh -c "cd /home/ubuntu/git/python-selenium/ && python3 /home/ubuntu/git/python-selenium/selenium/service.py 4"
docker exec -it ubuntu-desktop sh -c "cd /home/ubuntu/git/python-selenium/ && python3 /home/ubuntu/git/python-selenium/selenium/service.py 5"
docker exec -it ubuntu-desktop sh -c "python3 /home/oseongryu/git/python-selenium/selenium/service.py 6"


# commit & push
docker commit automation-python oseongryu/automation-python:latest
docker pull oseongryu/automation-python:latest

chromium-browser --remote-debugging-port=9222 --disable-gpu --disable-dev-shm-usage --no-sandbox --user-data-dir="/home/ubuntu/chrome_profile"
```

### automation jupyter

```bash
pip install jupyterlab
cd ~
jupyter lab --generate-config -y

ipython
from jupyter_server.auth import passwd;passwd()
exit

vi /root/.jupyter/jupyter_lab_config.py
c = get_config()
c.NotebookApp.ip='localhost'
c.NotebookApp.open_browser=False
c.NotebookApp.password='argon2:$argon2id$v=19$m=10240,t=10,p=8$99ogBfKvItxIUAmudZ58Dg$V/v0sJkCnBeA3JsWaQHITcYEsuCoG9pOfE3jDtjj62k'
c.NotebookApp.password_required=True
c.NotebookApp.port=8888
c.NotebookApp.iopub_data_rate_limit=1.0e10
c.NotebookApp.terminado_settings={'shell_command': ['/bin/bash']}

nohup jupyter lab --ip 0.0.0.0 --allow-root &
```

## gcp setting

```bash
scp -P 22 ~/.ssh/id_rsa.pub instance-1:/home/oseongryu/.ssh
scp -P 22 ~/.ssh/id_rsa instance-1:/home/oseongryu/.ssh
chmod 600 ~/.ssh/id_rsa

# 파일 다운로드
scp -P 22 ~/.ssh/id_rsa instance-1:/home/oseongryu/git/python-selenium/app/fredit/screenshot/05_search/*/* ~/log

sudo apt -y update && sudo  apt -y upgrade

sudo apt install -y apt-transport-https ca-certificates curl software-properties-common
# Docker 공식 GPG 키 추가
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
# Docker repository 추가
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
# Docker 설치
sudo apt-get update
sudo apt install -y docker-ce docker-compose
# Docker 서비스 시작
sudo systemctl start docker
# 부팅 시 자동 시작 설정
sudo systemctl enable docker
# Docker 그룹에 현재 사용자 추가 (sudo 권한 없이 Docker 명령을 사용하기 위함, 로그아웃 후 다시 로그인)
sudo usermod -aG docker $USER
# 사용자를 Docker 그룹에 추가한 후에는 로그아웃하고 다시 로그인해야 변경 사항이 적용
# Docker 설치 확인
docker --version

sudo systemctl status docker


mkdir ~/git
git clone git@github.com:oseongryu/python-selenium

sudo apt install -y openjdk-8-jdk
sudo apt install net-tools
sudo apt install gnome-screenshot

### 443
scp -P 22 ~/.ssh/nginx.conf instance-1:/home/oseongryu/

cp ~/nginx.conf /etc/nginx/conf.d/


mv ~/git/python-selenium  ~/git/docker-composes/06_automation/python/git

pip install -r requirements.txt

```

### ubuntu-desktop web

```bash
# https://hub.docker.com/r/kasmweb/ubuntu-focal-desktop/tags
docker pull kasmweb/ubuntu-focal-desktop:1.14.0-rolling
sudo docker run --rm -it --shm-size=512m -p 6901:6901 -e VNC_PW=password --name ubuntu-desktop kasmweb/ubuntu-focal-desktop:1.14.0-rolling
docker run --rm -d -p 6080:80 -v $PWD:/workspace:rw -e USER=username -e PASSWORD=password-e RESOLUTION=1920x1080 --name ubuntu-novnc fredblgr/ubuntu-novnc:20.04
```

### docker in docker ubuntu

```bash
# https://junyharang.tistory.com/442
docker run -itd --privileged \
--name ubuntu-desktop \
-e container=docker \
-v /sys/fs/cgroup:/sys/fs/cgroup:ro
-v /tmp/$(mktemp -d):/run
ubuntu-systemd \
/usr/sbin/init
```

### vscode-server

```
# https://github.com/coder/code-server
```

### components

```bash
# Dockerfile 사용시
docker build -f Dockerfile -t oseongryu/redis ./
docker run -p 6379:6379 --name env-redis -d --restart=always oseongryu/redis:latest --requirepass testpassword

# 기본 redis 이미지 사용시
docker run -itd -p 6379:6379 --name env-redis --restart=always redis --requirepass testpassword
```

<!-- ### ubuntu 22.04 grdctl

```
# Cannot autolaunch D-Bus without X11 $DISPLAY
apt-get install gnupg2 pass
export $(dbus-launch)

# Cannot autolaunch D-Bus without X11 $DISPLAY
echo $DISPLAY
export DISPLAY=:0.0
echo $DISPLAY

# failed to commit changes to dconf: Error spawning command line ?dbus-launch --autolaunch=7a8eef8ff6b44c6b898ea8eb033b6433 --binary-syntax --close-stderr
# https://askubuntu.com/questions/1005623/libdbusmenu-glib-warning-unable-to-get-session-bus-failed-to-execute-child
sudo apt-get install dbus-x11
dbus-launch
# 사용자추가

# https://www.mankier.com/1/grdctl

grdctl rdp enable
grdctl rdp enable

grdctl rdp set-credentials losst new_password

# Autolaunch error: X11 initialization failed
# https://stackoverflow.com/questions/45943505/unable-to-autolaunch-a-dbus-daemon-without-a-display-for-x11-netbeans-pi-as-r
service dbus status


systemctl --user status gnome-remote-desktop

grdctl rdp disable-view-only
grdctl rdp set-password 123456
grdctl rdp enable

grdctl vnc set-auth-method password
grdctl vnc disable-view-only
grdctl vnc set-password 123456
grdctl vnc enable

grdctl status

systemctl --user enable gnome-remote-desktop
systemctl --user start gnome-remote-desktop
systemctl --user status gnome-remote-desktop


systemctl --user status dbus.service

# ?/org/freedesktop/secrets/collection/login?
sudo apt install gnupg2 pass

sudo apt update
sudo apt install dbus-user-session

gconftool-2 --set --type=bool /desktop/gnome/remote_access/use_alternative_port true
gconftool-2 --set --type=int /desktop/gnome/remote_access/alternative_port 5555

systemctl --user start gnome-remote-desktop
grdctl vnc disable-view-only
grdctl vnc set-password 123456
grdctl vnc enable
grdctl status
sudo apt install gnupg2 pass

# VNC server
sudo dnf -y install gnome-remote-desktop
VNC_PASSWD="12345678"
grdctl vnc enable
grdctl vnc disable-view-only
grdctl vnc set-auth-method password
grdctl vnc set-password "${VNC_PASSWD::8}"
systemctl --user enable gnome-remote-desktop.service
systemctl --user restart gnome-remote-desktop.service
sudo firewall-cmd --permanent --add-service=vnc-server
sudo firewall-cmd --reload

# $DBUS_SESSION_BUS_ADDRESS and $XDG_RUNTIME_DIR not defined

#
sudo apt-get install --reinstall systemd gnome-settings-daemon gnome-settings-daemon-common


#
sudo apt install winpr-utils
sudo apt install libsecret-tools
busctl get-property org.freedesktop.Accounts /org/freedesktop/Accounts/User$(id -u) org.freedesktop.Accounts.User Session

sudo -i -u root VNC_PASS="1234" DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$(id -u root)/bus" bash -c 'echo -n ${VNC_PASS} | secret-tool store --label "GRD VNC pass" xdg:schema org.gnome.RemoteDesktop.VncPassword'
``` -->

### nuxt-dev

```bash

# docker에 파일 이동
docker exec -i centos-vue sh -c "mkdir /root/.ssh"
docker cp ~/.ssh/id_rsa centos-vue:/root/.ssh/id_rsa
docker cp ~/.ssh/id_rsa.pub centos-vue:/root/.ssh/id_rsa.pub
docker exec -i centos-vue sh -c "chmod 600 /root/.ssh/id_rsa"
docker exec -i centos-vue sh -c "chmod 644 /root/.ssh/id_rsa.pub"

# docker 실행
docker exec -it centos-vue bash


# git
yum install -y wget git
cd /app/webapp
git clone ~~~~
git checkout release

# nvm 설치
wget -qO- https://raw.githubusercontent.com/nvm-sh/nvm/v0.35.2/install.sh | bash

source ~/.bashrc

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

nvm install 12.22.9
nvm use 12.22.9
nvm alias default 12.22.9
npm install pm2 -g
npm install -g yarn
yarn install

# pm2 실행
pm2 delete all
pm2 start ecosystem.config.js

# 실행
yarn run build
```
