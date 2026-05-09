FROM python:3.12-slim

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Asia/Seoul
ENV PYTHONUNBUFFERED=1

RUN apt-get update && apt-get install -y --no-install-recommends \
        curl ca-certificates jq \
    && rm -rf /var/lib/apt/lists/*

# Node.js 20 (for claude CLI)
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
    && apt-get install -y --no-install-recommends nodejs \
    && rm -rf /var/lib/apt/lists/*

# claude CLI
RUN npm install -g @anthropic-ai/claude-code

# Playwright + bundled chromium (with system deps)
RUN pip install --no-cache-dir playwright==1.49.1 \
    && playwright install --with-deps chromium

WORKDIR /app
COPY auth.py /app/auth.py
COPY entrypoint.sh /app/entrypoint.sh
RUN chmod +x /app/entrypoint.sh

ENV PROFILE_DIR=/data/chrome-profile
ENV CLAUDE_HOME=/data/.claude
ENV HOME=/data

ENTRYPOINT ["/app/entrypoint.sh"]
