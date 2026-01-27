# install-npp.ps1

$InstallerPath = "C:\Temp\npp.8.9.Installer.x64.msi"
$InstallerUrl = "https://raw.githubusercontent.com/JvanRensburg-Fundamental/Software-Deployements/073c2136019a541086de8324d34a25d051bb5248/npp.8.9.Installer.x64.msi"

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
