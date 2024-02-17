## 01_db

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

## 01_mariadb

### 이미지 재빌드가 필요하면 --build 옵션 추가
### 그렇지 않으면 이미 작성된 이미지를 사용하게 됨
```bash
docker-compose up -d
docker-compose up --build -d

docker-compose stop
docker-compose down
docker-compose down -v  # volumes 포함 삭제

docker exec -it docker-compose-db-1 bash
mysql -uroot -p1234
```

## 03_nuxt-ustra


### 이미지 재빌드가 필요하면 --build 옵션 추가
### 그렇지 않으면 이미 작성된 이미지를 사용하게 됨
```bash
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

## 04_jekyll
```bash
docker run -it -d -p 4000:4000 -v /c/Users/osryu/git-personal/test:/usr/src/apptest/ --name centos-ruby ruby:2.6 bash
docker exec -it centos-jekyll bash

gem install bundler
gem install bundler:2.3.26
bundler _2.3.26_ install
bundle exec jekyll serve -H 0.0.0.0 -t
```


## 05_emt

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
docker run -it -d -p 8089:8089 -v c:/users/osryu/git:/root/git --privileged --restart=always --name my-python oseongryu/automation-python:1.0.2 /sbin/init

docker exec -it my-python bash
python3 /root/git/python-selenium/selenium/service.py 0
docker exec -it my-python sh -c "cd /root/git/python-selenium/ && python3 /root/git/python-selenium/selenium/service.py 0"

# commit & push
docker commit my-python oseongryu/automation-python:1.0.2
docker push oseongryu/automation-python:1.0.2
```

## gcp setting
```bash
scp -P 22 ~/.ssh/id_rsa.pub instance-1:/home/oseongryu/.ssh
scp -P 22 ~/.ssh/id_rsa instance-1:/home/oseongryu/.ssh

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

mv ~/git/python-selenium  ~/git/docker-composes/06_automation/python/git

pip install -r requirements.txt

```