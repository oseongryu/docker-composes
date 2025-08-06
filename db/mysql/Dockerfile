FROM mysql:8.0.38

ENV TZ=Asia/Seoul

COPY init/*.sql /docker-entrypoint-initdb.d/

EXPOSE 3306