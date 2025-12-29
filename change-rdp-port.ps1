# Windows RDP Port Change Script
# Run as Administrator
# powershell -ExecutionPolicy Bypass -File .\change-rdp-port.ps1

# ============================================
# Set Port Number Here
# ============================================
$NewPort = 13389

# ============================================
# Allowed Remote IPs (Use "Any" for all IPs)
# ============================================
$AllowedIPs = @(
    "192.168.1.100",
    "10.0.0.50",
)

# ============================================
# Steps to Execute
# 1: Registry Modification
# 2: Firewall Rule
# 3: Restart Service
# 4: Verification
# 5: Modify Existing Firewall Rule
# ============================================
# $Steps = @(1,2,3,4)
$Steps = @(5)

# ============================================
# Step 5 Settings
# Mode: "AddIP" or "RemoveAll"
# ============================================
$Step5Mode = "AddIP"  # "AddIP" or "RemoveAll"
$Step5IPs = @(
    "192.168.1.100",
    "10.0.0.50",
)
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
if ($Steps -contains 1) {
    Write-Host "`n[1/4] Modifying Registry..." -ForegroundColor Cyan
    try {
        Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp' -Name PortNumber -Value $NewPort
        Write-Host "OK Registry port changed: $NewPort" -ForegroundColor Green
    } catch {
        Write-Host "ERROR Registry modification failed: $_" -ForegroundColor Red
        exit 1
    }
} else {
    Write-Host "`n[1/4] Skipped - Registry Modification" -ForegroundColor Yellow
}

# 2. Firewall Rule
if ($Steps -contains 2) {
    Write-Host "`n[2/4] Adding Firewall Rule..." -ForegroundColor Cyan
    try {
        $existingRule = Get-NetFirewallRule -DisplayName "app-13389" -ErrorAction SilentlyContinue
        if ($existingRule) {
            Remove-NetFirewallRule -DisplayName "app-13389"
            Write-Host "Existing custom rule removed" -ForegroundColor Yellow
        }

        # Check if "Any" is in the allowed IPs
        if ($AllowedIPs -contains "Any") {
            New-NetFirewallRule -DisplayName "app-13389" -Direction Inbound -Protocol TCP -LocalPort $NewPort -Action Allow -Profile Any -Enabled True
            Write-Host "OK Firewall rule added: TCP $NewPort (All IPs)" -ForegroundColor Green
        } else {
            $IPList = $AllowedIPs -join ','
            New-NetFirewallRule -DisplayName "app-13389" -Direction Inbound -Protocol TCP -LocalPort $NewPort -RemoteAddress $AllowedIPs -Action Allow -Profile Any -Enabled True
            Write-Host "OK Firewall rule added: TCP $NewPort (Allowed IPs: $IPList)" -ForegroundColor Green
        }
    } catch {
        Write-Host "ERROR Firewall rule failed: $_" -ForegroundColor Red
        exit 1
    }
} else {
    Write-Host "`n[2/4] Skipped - Firewall Rule" -ForegroundColor Yellow
}

# 3. Restart Service
if ($Steps -contains 3) {
    Write-Host "`n[3/4] Restarting Remote Desktop Services..." -ForegroundColor Cyan
    try {
        Restart-Service -Name TermService -Force
        Write-Host "OK Remote Desktop Services restarted" -ForegroundColor Green
    } catch {
        Write-Host "ERROR Service restart failed: $_" -ForegroundColor Red
        Write-Host "Please restart manually or reboot the system." -ForegroundColor Yellow
    }
} else {
    Write-Host "`n[3/4] Skipped - Restart Service" -ForegroundColor Yellow
}

# 4. Verification
if ($Steps -contains 4) {
    Write-Host "`n[4/4] Verifying Settings..." -ForegroundColor Cyan
    $NewPortValue = Get-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp' -Name PortNumber
    $FirewallRule = Get-NetFirewallRule -DisplayName "app-13389" -ErrorAction SilentlyContinue

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
} else {
    Write-Host "`n[4/4] Skipped - Verification" -ForegroundColor Yellow
}

# 5. Modify Existing Firewall Rule
if ($Steps -contains 5) {
    Write-Host "`n[5/5] Modifying Existing Firewall Rule..." -ForegroundColor Cyan

    if ($Step5Mode -eq "RemoveAll") {
        # Remove all custom RDP rules
        try {
            $existingRule = Get-NetFirewallRule -DisplayName "app-13389" -ErrorAction SilentlyContinue
            if ($existingRule) {
                Remove-NetFirewallRule -DisplayName "app-13389"
                Write-Host "OK All custom firewall rules removed" -ForegroundColor Green
            } else {
                Write-Host "No custom firewall rule found" -ForegroundColor Yellow
            }
        } catch {
            Write-Host "ERROR Failed to remove firewall rule: $_" -ForegroundColor Red
        }
    }
    elseif ($Step5Mode -eq "AddIP") {
        # Add IPs to existing rule
        try {
            $existingRule = Get-NetFirewallRule -DisplayName "app-13389" -ErrorAction SilentlyContinue
            if ($existingRule) {
                # Get current RemoteAddress
                $currentAddressFilter = Get-NetFirewallAddressFilter -AssociatedNetFirewallRule $existingRule
                $currentIPs = $currentAddressFilter.RemoteAddress

                # Merge with new IPs (remove duplicates)
                if ($currentIPs -contains "Any") {
                    Write-Host "Current rule allows all IPs. Converting to specific IPs..." -ForegroundColor Yellow
                    $mergedIPs = $Step5IPs
                } else {
                    $mergedIPs = ($currentIPs + $Step5IPs) | Select-Object -Unique
                }

                # Update the rule
                Set-NetFirewallRule -DisplayName "app-13389" -RemoteAddress $mergedIPs

                $IPList = $mergedIPs -join ', '
                Write-Host "OK IPs added to firewall rule" -ForegroundColor Green
                Write-Host "Current allowed IPs: $IPList" -ForegroundColor White
            } else {
                Write-Host "ERROR No existing custom firewall rule found" -ForegroundColor Red
                Write-Host "Please run Step 2 first to create the firewall rule" -ForegroundColor Yellow
            }
        } catch {
            Write-Host "ERROR Failed to add IPs: $_" -ForegroundColor Red
        }
    }
    else {
        Write-Host "ERROR Invalid Step5Mode: $Step5Mode" -ForegroundColor Red
        Write-Host "Use 'AddIP' or 'RemoveAll'" -ForegroundColor Yellow
    }
} else {
    Write-Host "`n[5/5] Skipped - Modify Firewall Rule" -ForegroundColor Yellow
}
