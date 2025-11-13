# GitLab Docker Compose

이 디렉토리는 Docker Compose를 사용하여 GitLab Community Edition을 설치하고 실행합니다.

## 🚀 빠른 시작 (Quick Start)

```bash
# 1. GitLab 시작
docker-compose up -d

# 2. 3-5분 대기 (GitLab 초기화 중...)

# 3. 초기 비밀번호 확인
docker exec -it gitlab-ce grep 'Password:' /etc/gitlab/initial_root_password

# 4. GitLab 접속: http://localhost:1080
#    Username: root
#    Password: (위에서 확인한 비밀번호)

# 5. Personal Access Token 생성 (중요!)
#    Preferences → Access Tokens → Create (api, read_repository, write_repository)

# 6. Git Push 테스트
git remote add origin http://localhost:1080/root/your-project.git
git push -u origin master
# Username: root
# Password: (Personal Access Token 입력)
```

## 구성 요소

- **GitLab CE**: GitLab Community Edition 컨테이너
- **포트**:
  - `80`: HTTP 웹 인터페이스
  - `443`: HTTPS 웹 인터페이스
  - `2222`: SSH Git 액세스

## 시작하기

### 1. GitLab 시작

```bash
cd gitlab
docker-compose up -d
```

### 2. 초기 비밀번호 확인

GitLab이 처음 시작되면 자동으로 root 사용자의 비밀번호가 생성됩니다. 다음 명령어로 확인할 수 있습니다:

```bash
docker exec -it gitlab-ce grep 'Password:' /etc/gitlab/initial_root_password
```

또는 컨테이너 내부에서 직접 확인:

```bash
docker exec -it gitlab-ce cat /etc/gitlab/initial_root_password
```

### 3. GitLab 접속

브라우저에서 다음 주소로 접속:
- `http://localhost` 또는 `http://gitlab.local`

**초기 로그인 정보:**
- 사용자명: `root`
- 비밀번호: 위에서 확인한 초기 비밀번호

### 4. Git 리포지토리 클론 (SSH)

```bash
git clone ssh://git@localhost:2222/username/repository.git
```

## 디렉토리 구조

```
gitlab/
├── docker-compose.yml
├── start.sh              # GitLab 시작 스크립트
├── fix-permissions.sh    # 권한 문제 해결 스크립트 (필요시)
└── README.md
```

**참고**: 이 설정은 Docker named volume을 사용하여 데이터를 저장합니다. 
볼륨 데이터는 Docker가 관리하므로 별도의 디렉토리가 생성되지 않습니다.

## 주의사항

1. **시스템 요구사항**: GitLab은 최소 4GB RAM을 권장합니다.
2. **초기 시작 시간**: GitLab이 완전히 시작되려면 3-5분 정도 걸릴 수 있습니다.
3. **데이터 백업**: Docker named volume에 모든 중요한 데이터가 저장됩니다. 백업 방법:
   ```bash
   # 볼륨 목록 확인
   docker volume ls | grep gitlab
   
   # 볼륨 백업
   docker run --rm -v gitlab_gitlab_config:/data -v $(pwd):/backup alpine tar czf /backup/gitlab-config-backup.tar.gz -C /data .
   docker run --rm -v gitlab_gitlab_data:/data -v $(pwd):/backup alpine tar czf /backup/gitlab-data-backup.tar.gz -C /data .
   ```

## 유용한 명령어

### GitLab 상태 확인
```bash
docker-compose ps
docker exec -it gitlab-ce gitlab-ctl status
```

### GitLab 로그 확인
```bash
docker-compose logs -f gitlab
docker exec -it gitlab-ce gitlab-ctl tail
```

### GitLab 재시작
```bash
docker-compose restart
# 또는
docker exec -it gitlab-ce gitlab-ctl restart
```

### GitLab 중지
```bash
docker-compose down
```

### GitLab 설정 재구성
```bash
docker exec -it gitlab-ce gitlab-ctl reconfigure
```

## 설정 커스터마이징

`docker-compose.yml` 파일의 `GITLAB_OMNIBUS_CONFIG` 섹션에서 GitLab 설정을 수정할 수 있습니다:

- **External URL 변경**: `external_url 'http://your-domain.com'`
- **SSH 포트 변경**: `gitlab_rails['gitlab_shell_ssh_port'] = 2222`
- **SMTP 설정**: 이메일 알림을 위한 SMTP 설정
- **백업 설정**: 자동 백업 구성

설정 변경 후에는 다음 명령어로 적용:

```bash
docker-compose down
docker-compose up -d
```

## 문제 해결

### GitLab이 시작되지 않는 경우
1. 메모리가 충분한지 확인 (최소 4GB 권장)
2. 포트 충돌 확인 (1080, 10443, 10022)
3. 로그 확인: `docker-compose logs -f gitlab`

### 비밀번호를 잊어버린 경우
```bash
docker exec -it gitlab-ce gitlab-rake "gitlab:password:reset[root]"
```

#### **오류가 발생하면 다음을 확인**

```bash

ssh -T git@localhost -p 10022 -o StrictHostKeyChecking=no
curl -I http://localhost:1080


git remote set-url origin http://localhost:1080/group1/web.git
git remote set-url origin ssh://git@localhost:10022/group1/was.git
```

## 라이선스

GitLab Community Edition은 MIT 라이선스를 따릅니다.
