
# 이미지 재빌드가 필요하면 --build 옵션 추가
# 그렇지 않으면 이미 작성된 이미지를 사용하게 됨
docker-compose up -d
docker-compose up --build -d

docker-compose stop
docker-compose down

docker exec -it nuxt-ustra-vue-1 bash
docker exec -it nuxt-ustra-spring-1 bash

# docker 수동 실행

docker run -it -d -p 10100:10100 -p 10200:10200 --privileged --restart=always --name centos-spring oseongryu/centos-spring:0.0.5 /sbin/init
docker exec -it centos-spring bash


# 네트워크 연결확인

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