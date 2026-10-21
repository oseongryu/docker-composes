# lecture-novnc

원격훈련 강의를 **본인이 직접 수강**하면서 소리를 녹음하고, 끝나면 전사·요약 노트를 만드는 리눅스 데스크톱.

| 주소 | 용도 |
|---|---|
| `http://localhost:6080/vnc.html` | 화면 (noVNC, 소리 없음) |
| `http://localhost:8090/` | 소리 듣기 · 녹음 시작/종료 · 노트 목록 |

## 구성

- Xvfb + fluxbox + x11vnc + noVNC, 브라우저 (amd64 는 Google Chrome, arm64 는 Chromium)
- PulseAudio 가상 출력 `lecture` 가 기본 출력이다. 브라우저 소리가 여기로 나간다
- 8090 콘솔이 `lecture.monitor` 를 두 갈래로 읽는다
  - 듣기: 접속한 탭마다 ffmpeg 가 mp3 로 실시간 송출 (탭을 닫아도 녹음과 무관)
  - 녹음: 16kHz 모노 opus → `notes/<시각>_<연번>/audio.ogg`
- 녹음을 끝내면 순서대로 처리한다: faster-whisper 전사 (`transcript.txt`, `[mm:ss]` 시각 포함) → `claude -p` 요약 (`summary.md`)
- 연번을 넣으면 과정 엑셀(`COURSE_XLSX`)에서 콘텐츠명·주요훈련내용·추천사유를 찾아 요약 프롬프트에 넣는다

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

## 처음 한 번: claude 로그인

요약은 컨테이너 안의 claude CLI 로 돈다. 로그인 정보는 `data/.claude` 에 남는다.

```bash
docker exec -it -u lecture -e HOME=/home/lecture lecture-novnc claude
```

`/login` 으로 나온 URL 을 PC 브라우저에서 열어 인증하고, 받은 코드를 붙여 넣는다. 로그인 전에 녹음한 노트는 `실패` 로 남고, 콘솔의 `다시 처리` 로 요약만 다시 돌린다.

## 사용 흐름

1. 8090 콘솔에서 `듣기 시작` (브라우저 정책상 클릭이 있어야 소리가 난다)
2. noVNC 화면의 브라우저에서 강의 사이트에 로그인하고 본인인증을 한다
3. 콘솔에 연번을 넣고 `녹음 시작` → 강의 재생
4. 차시가 끝나면 `녹음 종료` → 목록에서 `처리중` → `완료` 후 summary·transcript 링크

## 지킬 것

- 화면 조작은 사람이 한다. 자동 클릭·자동 재생·진도 조작 기능은 넣지 않는다 (원격훈련 대리수강)
- 영상 파일은 받지 않는다. 재생 중인 소리만 녹음한다
- `data/` (녹음·전사·요약·브라우저 프로필·claude 로그인)는 본인 학습용이다. 커밋·공유하지 않는다
- 강의 사이트가 가상 환경이나 원격 접속을 막으면 이 데스크톱으로 수강하지 않는다
- 브라우저는 컨테이너 안에서 `--no-sandbox` 로 돈다. 강의 사이트 외 용도로 쓰지 않는다
