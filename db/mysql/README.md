# MySQL with HAProxy - IP 기반 접근 제어

HAProxy를 사용하여 MySQL 접근을 제어하는 Docker Compose 구성입니다.
허용된 IP만 MySQL에 접근할 수 있으며, **Runtime API를 통해 재시작 없이 실시간으로 IP를 추가/제거**할 수 있습니다.

## 아키텍처

```
클라이언트 → HAProxy (3306) → MySQL (내부 네트워크)
              ↑
         IP 필터링
```

- **HAProxy**: 3306 포트를 외부에 노출하고 IP 필터링 수행
- **MySQL**: 내부 네트워크에서만 접근 가능 (외부 직접 접근 불가)

## 시작하기

### 1. 컨테이너 실행

```bash
docker-compose up -d
```

### 2. 허용 IP 설정

`allowed_ips.txt` 파일을 편집하여 허용할 IP를 추가합니다:

```bash
# 단일 IP
192.168.1.100

# 네트워크 대역
192.168.1.0/24
10.0.0.0/8
```

## Runtime API로 실시간 IP 관리

**재시작 없이** IP를 추가/제거할 수 있습니다.

### IP 추가

```bash
docker exec db-mysql-proxy sh -c "echo 'add acl /etc/haproxy/allowed_ips.txt 203.0.113.50' | socat stdio /tmp/haproxy.sock"
```

### IP 삭제

```bash
docker exec db-mysql-proxy sh -c "echo 'del acl /etc/haproxy/allowed_ips.txt 203.0.113.50' | socat stdio /tmp/haproxy.sock"
```

### 허용된 IP 목록 확인

```bash
docker exec db-mysql-proxy sh -c "echo 'show acl /etc/haproxy/allowed_ips.txt' | socat stdio /tmp/haproxy.sock"
```

### ACL 전체 초기화 (주의!)

```bash
docker exec db-mysql-proxy sh -c "echo 'clear acl /etc/haproxy/allowed_ips.txt' | socat stdio /tmp/haproxy.sock"
```

## 파일로 IP 관리

`allowed_ips.txt` 파일을 직접 수정한 후, HAProxy에 변경사항을 알려야 합니다:

### 방법 1: 파일 수정 후 reload

```bash
# allowed_ips.txt 편집 후
docker exec db-mysql-proxy kill -HUP 1
```

### 방법 2: 컨테이너 재시작

```bash
docker restart db-mysql-proxy
```

## Stats 페이지로 실시간 모니터링

HAProxy Stats 페이지에서 **실시간으로 접속 중인 클라이언트 IP**를 확인할 수 있습니다.

### 접속 방법

웹 브라우저에서 접속:
```
http://<서버IP>:8404
```

**로그인 정보:**
- 사용자명: `admin`
- 비밀번호: `admin123`

⚠️ **보안 주의**: 운영 환경에서는 반드시 `haproxy.cfg`의 `stats auth` 설정에서 비밀번호를 변경하세요!

### Stats 페이지에서 확인 가능한 정보

- **현재 연결 중인 클라이언트 IP 주소**
- 총 연결 수 / 초당 요청 수
- 데이터 전송량 (송신/수신)
- Backend 서버(MySQL) 상태
- 에러 및 재시도 통계
- 서버 uptime

### 비밀번호 변경 방법

`haproxy.cfg` 파일 수정:
```cfg
stats auth admin:새로운비밀번호
```

변경 후 재시작:
```bash
docker-compose restart haproxy
```

## 연결 테스트

### 허용된 IP에서 접속

```bash
mysql -h <서버IP> -P 3306 -u root -p
```

### 허용되지 않은 IP에서 접속 시

연결이 즉시 거부됩니다 (연결 timeout 아님).

## 로그 확인

### HAProxy 로그

```bash
docker logs -f db-mysql-proxy
```

### MySQL 로그

```bash
docker logs -f db-mysql-proxy
```

## Brute Force 방어 (Rate Limiting)

자동으로 무차별 대입 공격을 차단합니다.

### 차단 규칙

- **10초 동안 5회 이상 연결 시도** → 자동 차단
- **차단 시간**: 30초 (이후 자동 해제)
- **정상 사용**: 영향 없음 (일반적으로 초당 1~2회 연결)

### 작동 방식

1. 각 IP의 연결 시도를 실시간 추적
2. 10초 동안 5회 초과 시 즉시 차단
3. 30초 후 자동으로 차단 해제
4. Stats 페이지에서 차단된 연결 확인 가능

### 차단된 IP 확인

**방법 1: Runtime API (상세)**

전체 차단 목록 확인:
```bash
docker exec db-mysql-proxy sh -c "echo 'show table mysql_frontend' | socat stdio /tmp/haproxy.sock"
```

특정 IP 확인:
```bash
docker exec db-mysql-proxy sh -c "echo 'show table mysql_frontend key 192.168.1.100' | socat stdio /tmp/haproxy.sock"
```

출력 예시:
```
# table: mysql_frontend, type: ip, size:102400, used:2
0x7f8a9c000a80: key=192.168.1.100 use=0 exp=28759 conn_rate(5000)=4
0x7f8a9c000b20: key=10.0.0.50 use=0 exp=15234 conn_rate(5000)=6
```

- `conn_rate(5000)`: 5초 동안의 연결 수
- `exp`: 만료까지 남은 시간 (밀리초)
- 3회 초과하면 차단됨

**방법 2: Stats 페이지 (요약)**

```
http://<서버IP>:8404
```

"mysql_frontend" 섹션의 "Denied req" 카운터에서 총 차단 수 확인.

### Rate Limiting 조정

더 엄격하게 또는 완화하려면 `haproxy.cfg:38-40` 수정:

```cfg
# 더 엄격: 5초 동안 3회 → 차단
stick-table type ip size 100k expire 30s store conn_rate(5s)
tcp-request connection track-sc0 src
tcp-request connection reject if { sc_conn_rate(0) gt 3 }

# 더 완화: 30초 동안 20회 → 차단
stick-table type ip size 100k expire 60s store conn_rate(30s)
tcp-request connection track-sc0 src
tcp-request connection reject if { sc_conn_rate(0) gt 20 }
```

변경 후 재시작:
```bash
docker-compose restart haproxy
```

## 보안 권장사항

1. **최소 권한 원칙**: 필요한 IP만 허용
2. **정기적 검토**: 허용 IP 목록을 주기적으로 확인
3. **로그 모니터링**: 거부된 연결 시도를 모니터링
4. **방화벽 병행**: OS 레벨 방화벽과 함께 사용 권장

## 문제 해결

### IP를 추가했는데 접속이 안 됨

1. ACL 목록 확인:
   ```bash
   docker exec db-mysql-proxy sh -c "echo 'show acl /etc/haproxy/allowed_ips.txt' | socat stdio /tmp/haproxy.sock"
   ```

2. HAProxy 로그 확인:
   ```bash
   docker logs db-mysql-proxy
   ```

### socat 명령어가 안 됨

HAProxy Alpine 이미지에는 socat이 포함되어 있습니다. 컨테이너가 정상 실행 중인지 확인하세요:

```bash
docker ps | grep haproxy
```

## 파일 구조

```
.
├── docker-compose.yml      # Docker Compose 설정
├── Dockerfile              # MySQL 이미지 빌드 설정
├── haproxy.cfg             # HAProxy 설정 (Runtime API 활성화)
├── allowed_ips.txt         # 허용 IP 목록 (실시간 수정 가능)
└── README.md               # 이 문서
```

## 추가 정보

- HAProxy 버전: 2.9-alpine
- MySQL 버전: 8.0.38
- Runtime API: 활성화됨 (`/tmp/haproxy.sock`)
- Stats 페이지: http://localhost:8404 (admin/admin123)
