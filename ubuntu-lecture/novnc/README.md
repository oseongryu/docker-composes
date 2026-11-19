# lecture-novnc

원격훈련 강의를 **본인이 직접 수강**하면서 소리를 녹음하고, 끝나면 전사·요약 노트를 만드는 리눅스 데스크톱.

| 주소 | 용도 |
|---|---|
| `http://localhost:6080/vnc.html` | 화면 (noVNC). 왼쪽 컨트롤 막대의 스피커 버튼으로 소리 켜기·끄기 |
| `http://localhost:8090/` | 소리 듣기 · 녹음 시작/종료 · 노트 목록 |
| `http://localhost:8090/screen` | 화면 + 소리 한 탭 (위 noVNC 화면을 그대로 담고 위쪽에 소리 막대) |

## 구성

- Xvfb + fluxbox + x11vnc + noVNC, 브라우저 (amd64 는 Google Chrome, arm64 는 Chromium), fcitx5 한글 입력기 ([한글 입력](#한글-입력))
- PulseAudio 가상 출력 `lecture` 가 기본 출력이다. 브라우저 소리가 여기로 나간다
- 8090 콘솔이 `lecture.monitor` 를 두 갈래로 읽는다
  - 듣기: 접속한 탭마다 ffmpeg 가 mp3 로 실시간 송출 (탭을 닫아도 녹음과 무관). 재생 방식은 `기본`·`저지연` 두 가지 ([소리 재생 방식](#소리-재생-방식))
  - 녹음: 16kHz 모노 opus → `notes/<시각>_<연번>/audio.ogg`
- 녹음을 끝내면 순서대로 처리한다: faster-whisper 전사 (`transcript.txt`, `[mm:ss]` 시각 포함) → `claude -p` 요약 (`summary.md`)
- 녹음 중에는 브라우저가 받는 자막 파일(`.vtt`·`.srt`)도 `notes/<시각>_<연번>/subs/` 에 모은다. 처리 때 `subtitle.txt` 로 합쳐 요약의 주 근거로 쓰고, 음성 전사는 자막이 빈 구간만 보충한다
- 연번을 넣으면 과정 엑셀(`COURSE_XLSX`)에서 콘텐츠명·주요훈련내용·추천사유를 찾아 요약 프롬프트에 넣는다
- 브라우저는 supervisor 가 관리한다. 창을 모두 닫아도 몇 초 뒤 다시 뜬다
- `certs/*.crt` 는 빌드 때 시스템 신뢰 저장소에, 기동 때 브라우저 NSS 저장소에 등록된다 (회사망 SSL 검사 대응)

## 열기

### 1. 리눅스 서버에서 실행 (처음 한 번)

```bash
cd ~/git/docker-composes && git pull
cd ubuntu-lecture/novnc
mkdir -p courses
```

과정 엑셀은 원격이 없는 `~/references` 레포에만 있으므로 맥에서 서버로 복사한다. `courses/` 는 커밋되지 않는다.

```bash
# 맥에서
scp ~/references/study/"디지털 원격훈련 HRD 아카이브 과정 리스트.xlsx" <서버>:~/git/docker-composes/ubuntu-lecture/novnc/courses/
```

```bash
# 서버에서
echo 'COURSE_DIR=./courses' > .env
docker compose up -d --build
```

엑셀이 없어도 뜬다. 그때는 연번 대신 제목을 직접 넣는다.

### 2. 접속할 PC 에서 터널

포트가 서버 localhost 에만 열려 있으므로 ssh 로 연다. 수강하는 동안 이 터미널을 켜 둔다.

```bash
ssh -L 6080:localhost:6080 -L 8090:localhost:8090 <사용자>@<서버주소>
```

### 3. 브라우저 두 탭

| 탭 | 주소 | 할 일 |
|---|---|---|
| 화면 | `http://localhost:6080/vnc.html` | 연결(Connect) → 안의 브라우저로 강의 사이트 로그인 |
| 소리·녹음 | `http://localhost:8090/` | 듣기 시작 → 연번 입력 → 녹음 시작 |

화면과 소리를 한 탭으로 보려면 noVNC 왼쪽 컨트롤 막대의 스피커 버튼을 누른다 (막대가 접혀 있으면 왼쪽 가장자리 손잡이를 누른다). 위쪽에 소리 막대가 있는 `http://localhost:8090/screen` 도 된다. 녹음은 그대로 콘솔 탭에서 한다.

### 맥에서 바로 써 볼 때

```bash
cd ~/git/docker-composes/ubuntu-lecture/novnc && docker compose up -d --build
```

터널 없이 위 두 주소를 연다. 엑셀은 기본 `COURSE_DIR` 에서 찾는다. 맥은 arm64 라 브라우저가 Chromium 이어서 Chrome 전용 플레이어는 재생되지 않을 수 있다.

## 설정

`.env` 로 바꿀 수 있는 값:

| 변수 | 기본값 | 설명 |
|---|---|---|
| `BIND` | `127.0.0.1` | 포트 바인딩 주소. noVNC·콘솔 모두 인증이 없으므로 그대로 두고 터널로 접속 |
| `COURSE_DIR` | `../../../../references/study` | 과정 리스트 엑셀이 있는 폴더 |
| `WHISPER_MODEL` | `medium` | `small` 은 빠르고 `large-v3` 는 정확하다. CPU 전사라 큰 모델일수록 오래 걸린다 |
| `RESOLUTION` | `1600x900x24` | 가상 화면 해상도 |
| `AUDIO_MODE` | `basic` | 콘솔·`/screen` 의 처음 재생 방식, noVNC 스피커 버튼의 재생 방식. `basic` 기본, `low` 저지연. 콘솔·`/screen` 에서 바꾸면 그 탭에서만 바뀐다 |

## 한글 입력

noVNC 는 누른 키만 넘기므로 접속한 PC 의 한글 입력기는 쓰이지 않는다. 컨테이너 안 fcitx5 (`fcitx5-hangul`, 두벌식)로 조합한다.

- 한/영 전환: `한/영` 키, `Shift+Space`, 오른쪽 `Alt` 중 아무거나. 한/영 키가 안 먹는 PC 에서는 `Shift+Space`
- 한/영 상태는 모든 창·탭이 같이 쓴다. 강의 팝업으로 넘어가도 다시 바꿀 필요 없다
- 접속한 PC 쪽 입력기는 영문 상태로 둔다
- noVNC 클립보드로 한글을 붙여 넣으면 `?` 로 바뀐다 (x11vnc 가 Latin-1 클립보드만 지원). 한글은 직접 친다
- 설정은 `fcitx5/` (이미지의 `/etc/xdg/fcitx5`). 사용자 설정은 컨테이너를 다시 띄우면 지워지는 `/tmp/runtime-lecture/config` 에 두어 항상 이미지 설정으로 시작한다
- 브라우저는 fcitx5 와 세션 D-Bus(`/tmp/runtime-lecture/bus`)로 붙는다. `--password-store=basic` 은 빼지 않는다. 세션 D-Bus 가 생기면 Chrome 이 키링을 찾아 쿠키 암호화 방식을 바꿀 수 있고, 그러면 기존 로그인 쿠키(`v10`)를 못 읽는다

## 처음 한 번: claude 로그인

요약은 컨테이너 안의 claude CLI 로 돈다. 로그인 정보는 `data/.claude` 에 남는다.

```bash
docker exec -it -u lecture -e HOME=/home/lecture lecture-novnc claude
```

`/login` 으로 나온 URL 을 PC 브라우저에서 열어 인증하고, 받은 코드를 붙여 넣는다. 로그인 전에 녹음한 노트는 `실패` 로 남고, 콘솔의 `다시 처리` 로 요약만 다시 돌린다.

## 사용 흐름

1. 8090 콘솔에서 `듣기 시작`, 또는 noVNC 컨트롤 막대의 스피커 버튼 (브라우저 정책상 클릭이 있어야 소리가 난다)
2. noVNC 화면의 브라우저에서 강의 사이트에 로그인하고 본인인증을 한다
3. 콘솔에 연번을 넣고 `녹음 시작` → 강의 재생. 플레이어에 자막(CC)이 있으면 켠다. 켜야 자막 파일을 받아 오고, 콘솔에 `자막 N개 수집` 으로 보인다
4. 차시가 끝나면 `녹음 종료` → 목록에서 `처리중` → `완료` 후 summary·transcript 링크

## 소리 재생 방식

noVNC 는 화면만 전달하고 소리는 전달하지 않는다. 소리는 같은 `/stream.mp3` 를 두 방식 중 하나로 재생한다 (`app/player.js`).

| 방식 | 재생 | 화면 대비 지연 (로컬 측정) | 끊긴 뒤 |
|---|---|---|---|
| `기본` | `<audio src=/stream.mp3>` (이전부터 쓰던 방식) | 약 2.7초 | 끊긴 만큼 계속 늦어짐 → `다시 연결` |
| `저지연` | fetch 로 받은 조각을 MediaSource 에 바로 추가 | 약 0.5~0.7초 | 1초 넘게 밀리면 최신 위치로 이동 |

- `기본` 이 늦은 이유는 Chrome 이 mp3 스트림을 약 2초 분량씩 묶어 읽기 때문이다
- `저지연` 은 30초 지난 버퍼를 지워 오래 틀어도 메모리가 늘지 않는다
- MediaSource 의 `audio/mpeg` 를 지원하지 않는 브라우저는 `저지연` 이 비활성화된다
- ssh 터널 원격 접속에서는 네트워크 지연만큼 더 늦다 (측정 안 함)
- 녹음·전사는 컨테이너 안에서 직접 받으므로 재생 방식과 무관

### noVNC 스피커 버튼

- 이미지 빌드 때 `vnc.html` 의 `</head>` 앞에 `http://<같은 호스트>:8090/vnc.js` 를 불러오는 한 줄을 넣는다. `app/vnc.js` 가 `player.js` 를 불러와 컨트롤 막대 맨 위에 버튼을 붙인다
- 6080 페이지가 8090 스트림·상태를 읽으므로 노트 서버는 요청한 페이지의 호스트 이름이 같을 때만 `Access-Control-Allow-Origin` 을 준다. 다른 사이트는 읽을 수 없다
- `/screen` 안의 noVNC(iframe)에서는 버튼을 붙이지 않는다. 위쪽 소리 막대와 겹치기 때문이다
- 8090 을 다른 로컬 포트로 터널링하면 버튼이 뜨지 않는다 (같은 호스트의 8090 에서 불러온다)

## 자막 수집

- `app/subs.py` 가 컨테이너 안 `127.0.0.1:9222` (Chrome 원격 디버깅, 외부에 열지 않음)로 붙어 응답만 듣는다. 요청을 따로 보내거나 페이지를 조작하지 않는다
- CDP 로 보내는 명령은 `Target.setAutoAttach` (탭·iframe·worker 에 붙기), `Network.enable`, `Runtime.runIfWaitingForDebugger`, `Network.getResponseBody` (자막 본문) 넷뿐이다. Page·Emulation 도메인은 켜지 않는다
- `Runtime.runIfWaitingForDebugger` 는 빼면 안 된다. 자동으로 붙어 있으면 Chrome 이 `window.open`·`target=` 링크로 열린 팝업을 이 명령이 올 때까지 멈춰 둔다
  - 팝업은 빈 탭(`제목 없음`)으로 남고, 같은 사이트의 원래 탭도 함께 멈춘다 (화면이 어두워지고 위쪽 노란 상자에 "디버거가 다른 탭에서 일시중지되었습니다" 표시)
  - 이 노란 상자의 한글은 `□` 로 깨져 보인다. 멈춘 렌더러가 글꼴을 새로 불러오지 못해서이고 글꼴 설정과는 무관하다 (멈추지 않은 상태의 같은 오버레이는 한글 정상)
  - 붙을 때마다 `Network.enable` 다음에 바로 보내므로 팝업 첫 요청부터 자막을 받는다
- Playwright 등 자동화 라이브러리로 바꾸지 않는다. Playwright `connect_over_cdp` 는 붙는 순간 강의 브라우저 동작을 바꾼다
  - alert·confirm 을 사람에게 보이기 전에 닫는다 (confirm 은 `취소` → 다음 차시로 넘어가지 않음)
  - 모든 탭에 포커스 흉내를 켠다. 뒤쪽 탭도 `document.hasFocus()=true`, `visibilityState=visible` 로 보여 사이트가 탭 전환·자리 비움을 알 수 없다
  - 다운로드를 `/tmp/playwright-artifacts-*/<GUID>` 로 돌리고 연결이 끊기면 지운다 (`~/Downloads` 에 남지 않음)
- URL 이 `.vtt`·`.srt` 로 끝나거나 `Content-Type: text/vtt` 인 응답만, 녹음 중일 때만 저장한다
- 같은 (시각, 문장) 은 한 번만 남긴다. 한 녹음에서 여러 영상을 보면 받은 순서대로 이어진다
- `subtitle.txt` 의 시각은 영상 기준이고 `transcript.txt` 는 녹음 기준이라 서로 다르다
- SMI(SAMI) 자막, 영상에 박힌 자막, 화면에 그리기만 하는 자막은 받지 못한다. 그때는 지금처럼 음성 전사만 쓴다
- 콘솔에 `자막 수집 끊김` 이 보이면 브라우저가 꺼진 상태다. 다시 뜨면 5초 안에 자동으로 붙는다

## 브라우저 다시 열기

- 창을 모두 닫으면 supervisor 가 몇 초 안에 다시 띄운다. 프로필이 `data/` 에 있어 로그인 쿠키는 유지된다
- 새 창: noVNC 화면 바탕(빈 곳)을 우클릭 → 맨 위 `Browser`
- 그래도 안 뜨면 (연속 실패로 supervisor 가 포기한 상태)

```bash
docker exec lecture-novnc supervisorctl status browser
docker exec lecture-novnc supervisorctl restart browser
docker exec lecture-novnc tail -n 50 /var/log/browser.err.log
```

## 회사망 인증서 (SSL 검사)

회사 보안장비(소만사 등)가 HTTPS 를 중간에서 검사하면 모든 사이트 인증서가 회사 루트 CA 로 다시 서명된다. 호스트 OS 에는 그 루트가 배포돼 있지만 컨테이너에는 없어서 컨테이너 안에서만 실패한다.

### 증상

- 브라우저 주소창 `주의 요함`, `/var/log/browser.err.log` 에 `net_error -202` (ERR_CERT_AUTHORITY_INVALID)
- curl `self-signed certificate in certificate chain`, python `CERTIFICATE_VERIFY_FAILED`, node `unable to get local issuer certificate`

### 확인

발급자(`i:`)가 공인 CA 가 아니라 회사 장비 이름이면 이 경우다.

```bash
docker exec lecture-novnc sh -c "echo | openssl s_client -connect <사이트>:443 -servername <사이트> -showcerts 2>/dev/null | grep -E 's:|i:'"
#  0 s:CN=*.example.co.kr
#    i:C=KR, O=Somansa, CN=Somansa Root CA
```

### 등록

1. 호스트에서 루트 CA 를 PEM(Base-64) 으로 꺼낸다
   - Windows: `certlm.msc` → 신뢰할 수 있는 루트 인증 기관 → 해당 인증서 → 내보내기 → Base-64 X.509
   - macOS: 키체인 접근 → 시스템 → 해당 인증서 → 내보내기 (.pem)
2. `certs/<이름>.crt` 로 저장한다. `certs/` 는 커밋되지 않는다 (회사 인증서를 공개 저장소에 올리지 않는다)
3. `docker compose up -d --build`

같은 이름의 루트가 여러 개면 위 `-showcerts` 출력의 지문과 맞는 것 하나만 넣는다. 이름·serial 이 같은 인증서 둘은 NSS 에 함께 들어가지 않는다 (`SEC_ERROR_REUSED_ISSUER_AND_SERIAL`).

```bash
openssl x509 -in certs/<이름>.crt -noout -fingerprint -sha1
```

### 등록되는 곳

| 대상 | 방식 |
|---|---|
| curl · apt · openssl | 빌드 때 `update-ca-certificates` |
| python (requests · httpx · whisper 모델 내려받기) | `REQUESTS_CA_BUNDLE`, `SSL_CERT_FILE` → 시스템 번들 |
| node · claude CLI | `NODE_EXTRA_CA_CERTS` → 시스템 번들 |
| Chrome / Chromium | 기동 때 `certutil` 로 `data/.pki/nssdb` 에 등록. 로그 `인증서등록 <이름>` |

브라우저 등록 결과 확인:

```bash
docker exec -u lecture lecture-novnc certutil -d sql:/home/lecture/.pki/nssdb -L
```

### 하지 말 것

`curl -k`, `--ignore-certificate-errors`, `NODE_TLS_REJECT_UNAUTHORIZED=0`, `verify=False` 로 검증을 끄지 않는다. 당장은 되지만 진짜 중간자 공격까지 통과시키고, 끈 설정은 잊고 남는다.

## 지킬 것

- 화면 조작은 사람이 한다. 자동 클릭·자동 재생·진도 조작 기능은 넣지 않는다 (원격훈련 대리수강)
- 영상 파일은 받지 않는다. 재생 중인 소리와 브라우저가 이미 받은 자막만 저장한다
- `data/` (녹음·전사·요약·브라우저 프로필·claude 로그인)는 본인 학습용이다. 커밋·공유하지 않는다
- 강의 사이트가 가상 환경이나 원격 접속을 막으면 이 데스크톱으로 수강하지 않는다
- 브라우저는 컨테이너 안에서 `--no-sandbox` 로 돈다. 강의 사이트 외 용도로 쓰지 않는다
