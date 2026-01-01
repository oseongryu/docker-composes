// https://toycoding.tistory.com/entry/윈도우-OpenSSH-설치하기#google_vignette
// 선택적 기능
//  Invoke-Item C:\ProgramData\ssh\sshd_config
// 포트변경
// Restart-Service -Force -Name sshd

// openSSH 설치상태 확인
Get-WindowsCapability -Online |? Name -like 'OpenSSH*'

// 기능 설치하기
Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0

// openssh 서버상태확인 (STOPPED) 
Get-Service sshd  

// 서비스 시작
Start-Service sshd 

// 서버 시작 시마다 자동으로 실행되도록 설정
Set-Service -Name sshd -StartupType 'Automatic'

// 현재 서비스 확인. (RUNNING)
Get-Service sshd