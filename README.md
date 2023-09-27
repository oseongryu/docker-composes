## 01_db

### mysql
```
DEMO?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=Asia/Seoul
```

### oracle
```bash
docker cp ~/emt.dmp db-oracle:/test
<!-- C:\Users\f5074\Downloads\doc-master\EMT_doc\8_EMT.dmp -->

docker exec -it db-oracle bash

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
docker cp ~/emt.dmp db-oracle:/test
<!-- C:\Users\f5074\Downloads\doc-master\EMT_doc\8_EMT.dmp -->

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