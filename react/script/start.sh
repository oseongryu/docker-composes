#!/bin/sh
set -e

PORT=${PORT:-8000}
echo "=== RN Community Metro Server ==="
echo "작업 디렉토리: $(pwd)"
echo "포트: ${PORT}"

# node_modules 확인 및 설치
if [ ! -d "node_modules" ] || [ ! -d "node_modules/react-native" ]; then
    echo "node_modules 설치 중..."
    npm install --legacy-peer-deps
else
    echo "node_modules 캐시 사용"
fi

echo "Metro 서버 시작..."
npx react-native start --port ${PORT} --host 0.0.0.0
