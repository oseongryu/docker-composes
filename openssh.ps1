$OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

# powershell -ExecutionPolicy Bypass -File .\openssh.ps1
# 1. 한글 출력 인코딩 설정 (최상단에 추가)
# 2. 관리자 권한 체크 로직
if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "ERROR: Administrator privileges required!" -ForegroundColor Red
    exit
}

# --- [설정 변수] ---
$newPort = "2222"
$sftpRoot = "C:\app"  # <--- 사용자가 접속했을 때 보게 될 폴더 경로
$configPath = "C:\ProgramData\ssh\sshd_config"

# 1. OpenSSH 서버 설치 확인 및 설치 (최초 설정)
$capability = Get-WindowsCapability -Online | Where-Object Name -like 'OpenSSH.Server*'
if ($capability.State -ne 'Installed') {
    Write-Host "Installing OpenSSH Server..." -ForegroundColor Yellow
    Add-WindowsCapability -Online -Name $capability.Name
}

# 2. 서비스 시작 및 자동 실행 설정 (설정 파일 자동 생성 유도)
Start-Service sshd -ErrorAction SilentlyContinue
Set-Service -Name sshd -StartupType 'Automatic'

# 3. SFTP 전용 폴더 생성 (없으면 생성)
if (!(Test-Path $sftpRoot)) {
    New-Item -ItemType Directory -Path $sftpRoot -Force | Out-Null
    Write-Host "SFTP Root folder created: $sftpRoot" -ForegroundColor Green
}

# 4. 설정 파일(sshd_config) 수정
if (Test-Path $configPath) {
    # 기존 Port 및 SFTP 관련 설정 제거 (중복 방지)
    $content = Get-Content $configPath | Where-Object { 
        $_ -notmatch "^#?Port\s+\d+" -and 
        $_ -notmatch "^Subsystem\s+sftp" -and
        $_ -notmatch "^Match\s+All" -and
        $_ -notmatch "^\s+ChrootDirectory" -and
        $_ -notmatch "^\s+ForceCommand"
    }

    # 새 설정 데이터 구성
    $newSettings = @(
        "Port $newPort",
        "Subsystem sftp internal-sftp", # internal-sftp 사용 권장 (Chroot 시 필수)
        "",
        "# [SFTP Root Directory Setup]",
        "Match All",
        "    ChrootDirectory $sftpRoot",
        "    ForceCommand internal-sftp",
        "    AllowTcpForwarding no",
        "    X11Forwarding no"
    )

    # 설정 병합 및 저장
    $newContent = $newSettings + $content
    $newContent | Set-Content $configPath -Encoding UTF8
    Write-Host "SSH Config updated: Port $newPort, SFTP Root $sftpRoot" -ForegroundColor Green
}

# 5. 서비스 재시작 (설정 반영)
Restart-Service sshd
Write-Host "--- Setup Complete ---" -ForegroundColor Cyan
Get-Service sshd
netstat -an | findstr /i "listening" | findstr ":$newPort"