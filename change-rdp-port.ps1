# Windows RDP Port Change Script
# Run as Administrator: powershell -ExecutionPolicy Bypass -File .\change-rdp-port.ps1

$NewPort = 3389
$FirewallRuleName = "app-$NewPort"

# Steps: 1=RegMod, 3=RestartSvc, 11=NewFirewall, 12=AddIpToFirewall
# $Steps = @(1, 2)
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

# 12. Modify Firewall Rule
if ($Steps -contains 12) {
    if ($ModifyFireMode -eq "RemoveAll") {
        Remove-NetFirewallRule -DisplayName "$FirewallRuleName" -ErrorAction SilentlyContinue
        Write-Host "Firewall rule removed" -ForegroundColor Green
    } elseif ($ModifyFireMode -eq "AddIP") {
        try {
            $rule = Get-NetFirewallRule -DisplayName "$FirewallRuleName" -ErrorAction SilentlyContinue
            if ($rule) {
                if ($ModifyFireIpsMode -eq "Any") {
                    Set-NetFirewallRule -DisplayName "$FirewallRuleName" -RemoteAddress Any
                    Write-Host "Rule updated: Allow All IPs" -ForegroundColor Green
                } else {
                    $curIPs = (Get-NetFirewallAddressFilter -AssociatedNetFirewallRule $rule).RemoteAddress
                    if ($curIPs -contains "Any") {
                        Set-NetFirewallRule -DisplayName "$FirewallRuleName" -RemoteAddress $ModifyFireIps
                        Write-Host "Rule reset to Specific IPs" -ForegroundColor Green
                    } else {
                        $normCur = $curIPs | ForEach { Normalize-IPAddress $_ }
                        $newIPs = $ModifyFireIps | Where { $normCur -notcontains (Normalize-IPAddress $_) }
                        if ($newIPs) {
                            Set-NetFirewallRule -DisplayName "$FirewallRuleName" -RemoteAddress ($curIPs + $newIPs)
                            Write-Host "Added IPs: $($newIPs -join ', ')" -ForegroundColor Green
                        } else { Write-Host "No new IPs." -ForegroundColor White }
                    }
                }
            } else { Write-Host "Rule not found" -ForegroundColor Red }
        } catch { Write-Host "Error Modify: $_" -ForegroundColor Red }
    }
}
