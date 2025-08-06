FROM mysql:latest

ENV TZ=Asia/Seoul

COPY init/*.sql /docker-entrypoint-initdb.d/

EXPOSE 3306