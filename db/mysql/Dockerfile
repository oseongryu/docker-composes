FROM mysql:8.0.21

ENV TZ Asia/Seoul

COPY init/*.sql /docker-entrypoint-initdb.d/

EXPOSE 3306