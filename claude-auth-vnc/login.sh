#!/bin/sh
# 한 프로필에 대해 'claude login' -> wm 등록을 묶어서 실행.
#
# 사용:
#   /app/login.sh --label A --profile A --api https://wm-api.example.com
#
# 옵션:
#   --label <name>     (필수) wm 에 등록할 라벨
#   --profile <name>   chrome 프로필 디렉토리명 (기본: label 과 동일)
#                      → 별개 HOME (/data/claude-homes/<name>) 도 자동 사용
#   --api <url>        wm 백엔드 URL (또는 $API_URL)
#   --make-default     이 계정을 default 로 마킹

set -e

LABEL=""
PROFILE=""
API_URL="${API_URL:-}"
MAKE_DEFAULT="false"

while [ $# -gt 0 ]; do
    case "$1" in
        --label)         LABEL="$2"; shift 2 ;;
        --profile)       PROFILE="$2"; shift 2 ;;
        --api)           API_URL="$2"; shift 2 ;;
        --make-default)  MAKE_DEFAULT="true"; shift ;;
        -h|--help)       sed -n '2,15p' "$0"; exit 0 ;;
        *)               echo "ERROR: 알 수 없는 옵션: $1"; exit 1 ;;
    esac
done

if [ -z "$LABEL" ]; then echo "ERROR: --label 필수"; exit 1; fi
if [ -z "$API_URL" ]; then echo "ERROR: --api 또는 \$API_URL 필요"; exit 1; fi
PROFILE="${PROFILE:-$LABEL}"

CHROME_PROFILE_DIR="/data/chrome-profiles/$PROFILE"
CLAUDE_HOME_DIR="/data/claude-homes/$PROFILE"
mkdir -p "$CHROME_PROFILE_DIR" "$CLAUDE_HOME_DIR/.claude"

# 프로필별 claude HOME 분리 — 동시에 여러 라벨을 다뤄도 credentials.json 이 안 섞임
export HOME="$CLAUDE_HOME_DIR"
unset CLAUDE_CREDENTIALS  # 백엔드 환경 잔재 차단

echo "[1/3] chromium 프로필 확인: $CHROME_PROFILE_DIR"
echo "      anthropic.com 에 로그인된 chromium 창이 떠 있는지 노VNC 에서 확인하세요."
echo "      (없으면: 다른 터미널에서  chromium --user-data-dir=$CHROME_PROFILE_DIR &  실행)"

echo
echo "[2/3] claude login — 출력되는 OAuth URL 을 chromium $PROFILE 창에 붙여넣어 승인 완료하세요."
echo "      callback 받으면 자동으로 다음 단계로 진행됩니다."
claude login

CREDS_FILE="$HOME/.claude/.credentials.json"
if [ ! -s "$CREDS_FILE" ]; then
    echo "ERROR: $CREDS_FILE 가 비어있거나 없음 — claude login 미완료."
    exit 2
fi

echo
echo "[3/3] wm 백엔드로 push (label=$LABEL, api=$API_URL)"
EXTRA=""
[ "$MAKE_DEFAULT" = "true" ] && EXTRA="--make-default"

# register 스크립트는 $HOME/.claude/.credentials.json 을 보므로 위 export HOME 그대로 사용.
sh /scripts/claude-credentials-register.sh \
    --label "$LABEL" \
    --api "$API_URL" \
    --creds-file "$CREDS_FILE" \
    --config-file "$HOME/.claude.json" \
    $EXTRA

echo
echo "[done] '$LABEL' 등록 완료. chromium 프로필($CHROME_PROFILE_DIR) 은 /data 에 영속됩니다."
