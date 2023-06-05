#====================================
#
# Alternate instructions: https://github.com/PowerShell/Win32-OpenSSH/wiki/Install-Win32-OpenSSH
#
#====================================

#====================================
# Verify elevated PowerShell session
#====================================

if(!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)){Write-Error "Elevated permissions are required."}

#======================
# OpenSSH installation
#======================

$vOpenSSH = Get-WindowsCapability -Online | Where-Object {$_.Name -like "OpenSSH.Server*"}
if($vOpenSSH.State -eq "NotPresent"){
    Write-Host "OpenSSH Server not installed. Attempting installation..."
    try{
        Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0
    }
    catch{
        Write-Host "Installation failed."
    }
}
elseif($vOpenSSH.State -eq "Installed"){
    Write-Host "OpenSSH Server is already installed."
}
else{
    Write-Host "OpenSSH Server not registering as either installed or missing."
}

#=======================
# OpenSSH configuration
#=======================

# Start service
Start-Service sshd

# Ensure service always starts
Set-Service -Name sshd -StartupType 'Automatic'

# Verify FW rule
Get-NetFirewallRule -Name "*ssh*"
if((Get-NetFirewallRule -name "OpenSSH-Server-In-TCP").Enabled -eq $true){}

switch(Get-NetFirewallRule -name "OpenSSH-Server-In-TCP"){
    {$_.enabled -eq $true}  {Write-Host "Firewall rule OpenSSH-Server-In-TCP is enabled."}
    {$_.enabled -eq $false} {
            Write-Host "Firewall rule OpenSSH-Server-In-TCP is not enabled. Attempting to enable."
            try{
                Set-NetFirewallRule -Name "OpenSSH-Server-In-TCP" -Enabled True
            }
            catch{
                Write-Host "Failed enabling firewall rule OpenSSH-Server-In-TCP."
            }
        }
    default {Write-Host "Firewall rule OpenSSH-Server-In-TCP not found."}
}

# Fix permissions to enable password verification

    # https://github.com/PowerShell/Win32-OpenSSH/wiki/OpenSSH-utility-scripts-to-fix-file-permissions
    Get-Content 'C:\Program Files\OpenSSH\FixHostFilePermissions.ps1' | Invoke-Expression
    Get-Content 'C:\Program Files\OpenSSH\FixUserFilePermissions.ps1' | Invoke-Expression

# Configure PowerShell as default SSH shell

New-ItemProperty -Path "HKLM:\SOFTWARE\OpenSSH" -Name DefaultShell -Value "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe" -PropertyType String -Force
