# Windows RDP Port Change Script
# Run as Administrator: powershell -ExecutionPolicy Bypass -File .\change-rdp-port.ps1

$NewPort = 3389
$FirewallRuleName = "app-$NewPort"

# Steps: 1=RegMod, 3=RestartSvc, 11=NewFirewall, 12=AddIpToFirewall
# $Steps = @(1, 2)
# 1 Registy, 2 Service, 11 New Firewall , 12 Modify Firewall
$Steps = @(12)

$AllowedIPsMode = "Specific" # Any/Specific
$AllowedIPs = @(
    "118.235.0.0/16"
)

$ModifyFireMode = "AddIP" # AddIP/RemoveAll
$ModifyFireIpsMode = "Specific" # Any/Specific
$ModifyFireIps = @(
    "118.235.0.0/16"
)

function Normalize-IPAddress([string]$ip) {
    $ip = $ip.Trim()
    $table = @{'/8'='/255.0.0.0'; '/16'='/255.255.0.0'; '/24'='/255.255.255.0'; '/32'='/255.255.255.255'}
    foreach ($k in $table.Keys) { if ($ip -like "*$k") { return $ip.Replace($k, $table[$k]) } }
    return $ip
}

if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Warning "Run as Administrator!"
    exit
}

# 1. Registry
if ($Steps -contains 1) {
    try {
        $regPath = "HKLM:\System\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp"
        # -PropertyType DWord를 추가하여 16진수/10진수 포트 값이 정확히 들어가게 함
        Set-ItemProperty -Path $regPath -Name "PortNumber" -Value $NewPort -PropertyType DWord
        Write-Host "Registry: Port changed to $NewPort (DWord)" -ForegroundColor Green
    } catch {
        Write-Host "Failed to update registry: $_" -ForegroundColor Red
    }
}

# 2. Service
if ($Steps -contains 2) {
    try {
        Restart-Service -Name TermService -Force
        Write-Host "Service restarted" -ForegroundColor Green
    } catch { Write-Host "Error Service: $_" -ForegroundColor Red }
}

# 11. New/Check Firewall Rule (포트 기준)
if ($Steps -contains 11) {
    try {
        # 현재 $NewPort를 사용하는 인바운드 TCP 규칙이 있는지 조회
        $existingRule = Get-NetFirewallRule | Get-NetFirewallServiceFilter | Where-Object { 
            $_.LocalPort -eq $NewPort 
        } | Get-NetFirewallRule -ErrorAction SilentlyContinue

        if ($existingRule) {
            # 이미 해당 포트의 규칙이 있다면 새로 만들지 않고 메시지만 출력
            # (원한다면 여기서 기존 규칙의 IP를 초기화하는 로직을 넣을 수도 있습니다)
            Write-Host "Firewall rule for port $NewPort already exists: $($existingRule.DisplayName)" -ForegroundColor Cyan
        } else {
            # 규칙이 없는 경우에만 새로 생성
            if ($AllowedIPsMode -eq "Any") {
                New-NetFirewallRule -DisplayName "$FirewallRuleName" -Direction Inbound -Protocol TCP -LocalPort $NewPort -Action Allow -Profile Any -Enabled True
                Write-Host "New Firewall created: TCP $NewPort (All IPs)" -ForegroundColor Green
            } else {
                New-NetFirewallRule -DisplayName "$FirewallRuleName" -Direction Inbound -Protocol TCP -LocalPort $NewPort -RemoteAddress $AllowedIPs -Action Allow -Profile Any -Enabled True
                Write-Host "New Firewall created: TCP $NewPort (Specific IPs)" -ForegroundColor Green
            }
        }
    } catch {
        Write-Host "Error Firewall (Step 11): $_" -ForegroundColor Red
    }
}

# 12. Modify Firewall Rule (포트 번호로 찾기)
if ($Steps -contains 12) {
    try {
        # 현재 $NewPort(예: 3389)를 LocalPort로 사용 중인 모든 인바운드 규칙 검색
        $rules = Get-NetFirewallRule | Get-NetFirewallServiceFilter | Where-Object { 
            $_.LocalPort -eq $NewPort 
        } | Get-NetFirewallRule -ErrorAction SilentlyContinue

        if ($rules) {
            foreach ($rule in $rules) {
                Write-Host "Found rule: $($rule.DisplayName) (Port: $NewPort)" -ForegroundColor Cyan
                
                if ($ModifyFireMode -eq "AddIP") {
                    $filter = Get-NetFirewallAddressFilter -AssociatedNetFirewallRule $rule
                    $curIPs = @($filter.RemoteAddress)

                    # 중복 체크 및 IP 추가 로직 (동일)
                    $normCur = $curIPs | ForEach-Object { Normalize-IPAddress $_ }
                    $newIPsToAdd = $ModifyFireIps | Where-Object { 
                        $target = Normalize-IPAddress $_
                        $normCur -notcontains $target 
                    }

                    if ($newIPsToAdd) {
                        [string[]]$finalIPList = $curIPs + $newIPsToAdd
                        Set-NetFirewallRule -Name $rule.Name -RemoteAddress $finalIPList
                        Write-Host "Added IPs to $($rule.DisplayName): $($newIPsToAdd -join ', ')" -ForegroundColor Green
                    } else {
                        Write-Host "No new IPs for $($rule.DisplayName)." -ForegroundColor White
                    }
                }
            }
        } else {
            Write-Host "No firewall rules found for port $NewPort." -ForegroundColor Yellow
        }
    } catch {
        Write-Host "Error finding rule by port: $_" -ForegroundColor Red
    }
}