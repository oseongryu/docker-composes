#!/bin/sh
# claude-auth one-shot entrypoint.
#
# 사용:
#   API_URL=https://wm-api.example.com LABEL=primary \
#       docker compose run --rm claude-auth
#
#   또는 인자 방식:
#   docker compose run --rm claude-auth --label dev --api https://wm-api...
set -e

# env -> 인자 머지 (인자가 우선)
ARGS=""
if [ -n "$LABEL" ]; then ARGS="$ARGS --label $LABEL"; fi
if [ -n "$API_URL" ]; then ARGS="$ARGS --api $API_URL"; fi
if [ "$MAKE_DEFAULT" = "true" ]; then ARGS="$ARGS --make-default"; fi
if [ -n "$PROFILE_DIR" ]; then ARGS="$ARGS --profile-dir $PROFILE_DIR"; fi
if [ "$HEADLESS" = "false" ]; then ARGS="$ARGS --no-headless"; fi

# /data 가 비어있으면 기본 디렉토리만 생성
mkdir -p /data/.claude /data/chrome-profile

exec python3 /app/auth.py $ARGS "$@"
