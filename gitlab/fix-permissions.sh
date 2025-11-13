#!/bin/bash

# GitLab 권한 수정 스크립트

echo "================================"
echo "GitLab Permission Fix Script"
echo "================================"
echo ""

# 컨테이너 중지
echo "Stopping GitLab container..."
docker-compose down

echo ""
echo "Fixing permissions..."
echo "Note: You may need to enter your password for sudo"

# 데이터 디렉토리가 없으면 생성
if [ ! -d "./data" ]; then
    echo "Creating data directories..."
    mkdir -p ./data/config
    mkdir -p ./data/logs
    mkdir -p ./data/data
fi

# GitLab 컨테이너의 기본 UID:GID (998:998)로 소유권 변경
sudo chown -R 998:998 ./data

# 권한 설정
sudo chmod -R 755 ./data

echo ""
echo "Permissions fixed!"
echo ""
echo "Starting GitLab again..."
docker-compose up -d

echo ""
echo "================================"
echo "Done!"
echo "================================"
echo ""
echo "GitLab is starting. Please wait 3-5 minutes."
echo ""
echo "Check logs with:"
echo "  docker-compose logs -f gitlab"
echo ""
