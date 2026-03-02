FROM node:22-alpine
ENV TZ=Asia/Seoul

# 빌드 필수 도구 (native 모듈용)
RUN apk add --no-cache git python3 make g++ bash

WORKDIR /app

COPY script/start.sh /start.sh
RUN chmod +x /start.sh

EXPOSE 8000

CMD ["/start.sh"]
