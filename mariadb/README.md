
# 이미지 재빌드가 필요하면 --build 옵션 추가
# 그렇지 않으면 이미 작성된 이미지를 사용하게 됨
docker-compose up -d
docker-compose up --build -d

docker-compose stop
docker-compose down

docker exec -it docker-compose-db-1 bash
mysql -uroot -p1234

