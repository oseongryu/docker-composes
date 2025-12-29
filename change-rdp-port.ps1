# Windows RDP Port Change Script
# Run as Administrator

# ============================================
# Set Port Number Here
# ============================================
$NewPort = 13389
# ============================================

# Check Administrator
if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator"))
{
    Write-Warning "This script requires Administrator privileges!"
    Write-Host "Please run PowerShell as Administrator." -ForegroundColor Red
    exit
}

Write-Host "=== Windows RDP Port Change ===" -ForegroundColor Cyan
Write-Host "New Port: $NewPort" -ForegroundColor Green

# Get Current Port
$CurrentPort = Get-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp' -Name PortNumber
Write-Host "Current RDP Port: $($CurrentPort.PortNumber)" -ForegroundColor Yellow

# 1. Registry Modification
Write-Host "`n[1/4] Modifying Registry..." -ForegroundColor Cyan
try {
    Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp' -Name PortNumber -Value $NewPort
    Write-Host "OK Registry port changed: $NewPort" -ForegroundColor Green
} catch {
    Write-Host "ERROR Registry modification failed: $_" -ForegroundColor Red
    exit 1
}

# 2. Firewall Rule
Write-Host "`n[2/4] Adding Firewall Rule..." -ForegroundColor Cyan
try {
    $existingRule = Get-NetFirewallRule -DisplayName "Remote Desktop - Custom Port" -ErrorAction SilentlyContinue
    if ($existingRule) {
        Remove-NetFirewallRule -DisplayName "Remote Desktop - Custom Port"
        Write-Host "Existing custom rule removed" -ForegroundColor Yellow
    }

    New-NetFirewallRule -DisplayName "Remote Desktop - Custom Port" -Direction Inbound -Protocol TCP -LocalPort $NewPort -Action Allow -Profile Any -Enabled True
    Write-Host "OK Firewall rule added: TCP $NewPort" -ForegroundColor Green
} catch {
    Write-Host "ERROR Firewall rule failed: $_" -ForegroundColor Red
    exit 1
}

# 3. Restart Service
Write-Host "`n[3/4] Restarting Remote Desktop Services..." -ForegroundColor Cyan
try {
    Restart-Service -Name TermService -Force
    Write-Host "OK Remote Desktop Services restarted" -ForegroundColor Green
} catch {
    Write-Host "ERROR Service restart failed: $_" -ForegroundColor Red
    Write-Host "Please restart manually or reboot the system." -ForegroundColor Yellow
}

# 4. Verification
Write-Host "`n[4/4] Verifying Settings..." -ForegroundColor Cyan
$NewPortValue = Get-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp' -Name PortNumber
$FirewallRule = Get-NetFirewallRule -DisplayName "Remote Desktop - Custom Port" -ErrorAction SilentlyContinue

Write-Host "`n=== Change Complete ===" -ForegroundColor Green
Write-Host "Registry Port: $($NewPortValue.PortNumber)" -ForegroundColor White
Write-Host "Firewall Rule: $(if($FirewallRule){'Enabled'}else{'None'})" -ForegroundColor White
Write-Host "`nConnect using:" -ForegroundColor Cyan
Write-Host "  ComputerName:$NewPort" -ForegroundColor Yellow
Write-Host "  Example: 192.168.1.100:$NewPort" -ForegroundColor Yellow

Write-Host "`nNotes:" -ForegroundColor Magenta
Write-Host "- Default RDP rule (3389) remains active" -ForegroundColor White
Write-Host "- Update port forwarding on your router if needed" -ForegroundColor White
Write-Host "- System reboot recommended" -ForegroundColor White
