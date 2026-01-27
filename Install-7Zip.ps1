# Install-7Zip.ps1

$InstallerUrl = "https://www.7-zip.org/a/7z2501-x64.msi"
$InstallerPath = "C:\Temp\7z2501-x64.msi"

# Ensure Temp folder exists
if (!(Test-Path -Path "C:\Temp")) {
    New-Item -Path "C:\Temp" -ItemType Directory -Force
}

# Download installer
Invoke-WebRequest -Uri $InstallerUrl -OutFile $InstallerPath

# Install silently
Start-Process msiexec.exe -ArgumentList "/i $InstallerPath /qn /norestart" -Wait

# Cleanup installer
Remove-Item -Path $InstallerPath -Force
