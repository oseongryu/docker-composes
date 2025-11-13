#!/bin/bash

# GitLab 초기 설정 및 시작 스크립트

echo "================================"
echo "GitLab Docker Compose Setup"
echo "================================"
echo ""

# Docker와 Docker Compose 확인
if ! command -v docker &> /dev/null; then
    echo "Error: Docker is not installed. Please install Docker first."
    exit 1
fi

if ! command -v docker-compose &> /dev/null; then
    echo "Error: Docker Compose is not installed. Please install Docker Compose first."
    exit 1
fi

# 데이터 디렉토리 생성
echo "Creating data directories..."
mkdir -p ./data/config
mkdir -p ./data/logs
mkdir -p ./data/data

# 권한 설정 (GitLab 컨테이너의 기본 UID:GID는 998:998)
echo "Setting permissions..."
echo "Note: You may need to enter your password for sudo"
sudo chown -R 998:998 ./data
sudo chmod -R 755 ./data

# GitLab 시작
echo ""
echo "Starting GitLab..."
docker-compose up -d


