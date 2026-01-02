# Windows RDP Port Change Script
# Run as Administrator
# powershell -ExecutionPolicy Bypass -File .\change-rdp-port.ps1

# ============================================
# Set Port Number Here
# ============================================
$NewPort = 13389


# ============================================
# Steps to Execute
# 1: Registry Modification
# 3: Restart Service
# 4: Verification
# 11: Firewall Rule
# 12: Modify Existing Firewall Rule
# ============================================
# $Steps = @(1,3,4)
$Steps = @(12)

# ============================================
# Firewall Rule Name
# ============================================
$FirewallRuleName = "app-13389"

# ============================================
# Allowed Remote IPs
# Mode: "Any" or "Specific"
# ============================================
$AllowedIPsMode = "Specific"  # "Any" or "Specific"
$AllowedIPs = @(
    "192.168.1.100",
    "10.0.0.50"
)

# ============================================
# Step 12 Settings
# Mode: "AddIP" or "RemoveAll"
# ============================================
$ModifyFireMode = "AddIP"  # "AddIP" or "RemoveAll"

# IP Mode for AddIP: "Any" or "Specific"
$ModifyFireIpsMode = "Specific"  # "Any" or "Specific"
$ModifyFireIps = @(
    "192.168.1.100",
    "10.0.0.50"
)
# ============================================

# Function to normalize IP format (convert CIDR to subnet mask)
function Normalize-IPAddress {
    param([string]$ip)

    $ip = $ip.Trim()

    # CIDR to Subnet Mask conversion table
    $cidrTable = @{
        '/8' = '/255.0.0.0'
        '/16' = '/255.255.0.0'
        '/24' = '/255.255.255.0'
        '/32' = '/255.255.255.255'
    }

    # Check if it's CIDR format and convert to subnet mask
    foreach ($cidr in $cidrTable.Keys) {
        if ($ip -like "*$cidr") {
            $ip = $ip -replace [regex]::Escape($cidr), $cidrTable[$cidr]
            break
        }
    }

    return $ip
}

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
    $FirewallRule = Get-NetFirewallRule -DisplayName "$FirewallRuleName" -ErrorAction SilentlyContinue

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

# 11. Firewall Rule
if ($Steps -contains 11) {
    Write-Host "`n[2/4] Adding Firewall Rule..." -ForegroundColor Cyan
    try {
        $existingRule = Get-NetFirewallRule -DisplayName "$FirewallRuleName" -ErrorAction SilentlyContinue
        if ($existingRule) {
            Remove-NetFirewallRule -DisplayName "$FirewallRuleName"
            Write-Host "Existing custom rule removed" -ForegroundColor Yellow
        }

        # Check AllowedIPsMode
        if ($AllowedIPsMode -eq "Any") {
            New-NetFirewallRule -DisplayName "$FirewallRuleName" -Direction Inbound -Protocol TCP -LocalPort $NewPort -Action Allow -Profile Any -Enabled True
            Write-Host "OK Firewall rule added: TCP $NewPort (All IPs)" -ForegroundColor Green
        } elseif ($AllowedIPsMode -eq "Specific") {
            $IPList = $AllowedIPs -join ','
            New-NetFirewallRule -DisplayName "$FirewallRuleName" -Direction Inbound -Protocol TCP -LocalPort $NewPort -RemoteAddress $AllowedIPs -Action Allow -Profile Any -Enabled True
            Write-Host "OK Firewall rule added: TCP $NewPort (Allowed IPs: $IPList)" -ForegroundColor Green
        } else {
            Write-Host "ERROR Invalid AllowedIPsMode: $AllowedIPsMode" -ForegroundColor Red
            Write-Host "Use 'Any' or 'Specific'" -ForegroundColor Yellow
            exit 1
        }
    } catch {
        Write-Host "ERROR Firewall rule failed: $_" -ForegroundColor Red
        exit 1
    }
} else {
    Write-Host "`n[2/4] Skipped - Firewall Rule" -ForegroundColor Yellow
}

# 12. Modify Existing Firewall Rule
if ($Steps -contains 12) {
    Write-Host "`n[5/5] Modifying Existing Firewall Rule..." -ForegroundColor Cyan

    if ($ModifyFireMode -eq "RemoveAll") {
        # Remove all custom RDP rules
        try {
            $existingRule = Get-NetFirewallRule -DisplayName "$FirewallRuleName" -ErrorAction SilentlyContinue
            if ($existingRule) {
                Remove-NetFirewallRule -DisplayName "$FirewallRuleName"
                Write-Host "OK All custom firewall rules removed" -ForegroundColor Green
            } else {
                Write-Host "No custom firewall rule found" -ForegroundColor Yellow
            }
        } catch {
            Write-Host "ERROR Failed to remove firewall rule: $_" -ForegroundColor Red
        }
    }
    elseif ($ModifyFireMode -eq "AddIP") {
        # Add IPs to existing rule
        try {
            $existingRule = Get-NetFirewallRule -DisplayName "$FirewallRuleName" -ErrorAction SilentlyContinue
            if ($existingRule) {
                # Check ModifyFireIpsMode
                if ($ModifyFireIpsMode -eq "Any") {
                    # Set to allow all IPs
                    Set-NetFirewallRule -DisplayName "$FirewallRuleName" -RemoteAddress Any
                    Write-Host "OK Firewall rule updated to allow all IPs" -ForegroundColor Green
                } elseif ($ModifyFireIpsMode -eq "Specific") {
                    # Get current RemoteAddress
                    $currentAddressFilter = Get-NetFirewallAddressFilter -AssociatedNetFirewallRule $existingRule
                    $currentIPs = $currentAddressFilter.RemoteAddress

                    if ($currentIPs -contains "Any") {
                        Write-Host "Current rule allows all IPs. Converting to specific IPs..." -ForegroundColor Yellow
                        $mergedIPs = $ModifyFireIps
                        $newlyAdded = $ModifyFireIps
                    } else {
                        # Check for duplicates and identify new IPs
                        $newlyAdded = @()
                        $alreadyExists = @()

                        # Normalize current IPs (convert CIDR to subnet mask)
                        $normalizedCurrentIPs = $currentIPs | ForEach-Object { Normalize-IPAddress $_ }

                        foreach ($ip in $ModifyFireIps) {
                            $normalizedIP = Normalize-IPAddress $ip

                            # Check if normalized IP exists in normalized current IPs
                            $isDuplicate = $false
                            foreach ($existingIP in $normalizedCurrentIPs) {
                                if ($existingIP -eq $normalizedIP) {
                                    $isDuplicate = $true
                                    break
                                }
                            }

                            if ($isDuplicate) {
                                $alreadyExists += $ip  # Show original format
                            } else {
                                $newlyAdded += $ip  # Show original format
                            }
                        }

                        # Show duplicate info
                        if ($alreadyExists.Count -gt 0) {
                            $existsList = $alreadyExists -join ', '
                            Write-Host "Skipped (already exists): $existsList" -ForegroundColor Yellow
                        }

                        # Merge only if there are new IPs
                        if ($newlyAdded.Count -gt 0) {
                            $mergedIPs = $currentIPs + $newlyAdded
                        } else {
                            Write-Host "No new IPs to add. All specified IPs already exist." -ForegroundColor Yellow
                            $mergedIPs = $currentIPs
                        }
                    }

                    # Update the rule
                    Set-NetFirewallRule -DisplayName "$FirewallRuleName" -RemoteAddress $mergedIPs

                    if ($newlyAdded.Count -gt 0) {
                        $newIPList = $newlyAdded -join ', '
                        Write-Host "OK New IPs added: $newIPList" -ForegroundColor Green
                    }

                    $allIPList = $mergedIPs -join ', '
                    Write-Host "Current allowed IPs: $allIPList" -ForegroundColor White
                } else {
                    Write-Host "ERROR Invalid ModifyFireIpsMode: $ModifyFireIpsMode" -ForegroundColor Red
                    Write-Host "Use 'Any' or 'Specific'" -ForegroundColor Yellow
                }
            } else {
                Write-Host "ERROR No existing custom firewall rule found" -ForegroundColor Red
                Write-Host "Please run Step 2 first to create the firewall rule" -ForegroundColor Yellow
            }
        } catch {
            Write-Host "ERROR Failed to add IPs: $_" -ForegroundColor Red
        }
    }
    else {
        Write-Host "ERROR Invalid ModifyFireMode: $ModifyFireMode" -ForegroundColor Red
        Write-Host "Use 'AddIP' or 'RemoveAll'" -ForegroundColor Yellow
    }
} else {
    Write-Host "`n[5/5] Skipped - Modify Firewall Rule" -ForegroundColor Yellow
}
