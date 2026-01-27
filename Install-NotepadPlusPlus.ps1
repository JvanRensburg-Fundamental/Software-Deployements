# install-npp.ps1

$InstallerUrl = "https://github.com/notepad-plus-plus/notepad-plus-plus/releases/download/v8.9.1/npp.8.9.1.Installer.x64.msi"
$InstallerPath = "C:\Temp\npp.8.9.1.Installer.x64.msi"

# Ensure Temp folder exists
if (!(Test-Path -Path "C:\Temp")) {
    New-Item -Path "C:\Temp" -ItemType Directory -Force
}

# Download the installer
Invoke-WebRequest -Uri $InstallerUrl -OutFile $InstallerPath

# Install silently
Start-Process msiexec.exe -ArgumentList "/i $InstallerPath /qn /norestart" -Wait

# Cleanup
Remove-Item -Path $InstallerPath -Force
