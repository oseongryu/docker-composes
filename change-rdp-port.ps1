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
        Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp' -Name PortNumber -Value $NewPort
        Write-Host "Registry port: $NewPort" -ForegroundColor Green
    } catch { Write-Host "Error Registry: $_" -ForegroundColor Red }
}

# 2. Service
if ($Steps -contains 2) {
    try {
        Restart-Service -Name TermService -Force
        Write-Host "Service restarted" -ForegroundColor Green
    } catch { Write-Host "Error Service: $_" -ForegroundColor Red }
}

# 11. New Firewall Rule
if ($Steps -contains 11) {
    try {
        Remove-NetFirewallRule -DisplayName "$FirewallRuleName" -ErrorAction SilentlyContinue
        if ($AllowedIPsMode -eq "Any") {
            New-NetFirewallRule -DisplayName "$FirewallRuleName" -Direction Inbound -Protocol TCP -LocalPort $NewPort -Action Allow -Profile Any -Enabled True
            Write-Host "Firewall created: TCP $NewPort (All IPs)" -ForegroundColor Green
        } else {
            New-NetFirewallRule -DisplayName "$FirewallRuleName" -Direction Inbound -Protocol TCP -LocalPort $NewPort -RemoteAddress $AllowedIPs -Action Allow -Profile Any -Enabled True
            Write-Host "Firewall created: TCP $NewPort (Specific IPs)" -ForegroundColor Green
        }
    } catch { Write-Host "Error Firewall: $_" -ForegroundColor Red }
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