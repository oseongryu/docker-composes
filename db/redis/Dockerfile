FROM redis:latest

# https://github.com/docker-library/redis/issues/46
ENV REDIS_PASSWORD password
# RUN redis-cli config set requirepass password


CMD ["sh", "-c", "exec redis-server --requirepass \"${REDIS_PASSWORD}\""]