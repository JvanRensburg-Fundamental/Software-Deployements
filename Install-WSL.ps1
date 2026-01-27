# Install-WSL.ps1

Write-Host "Enabling WSL and Virtual Machine Platform..." -ForegroundColor Cyan

# Enable required Windows features
dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart

# Prepare temp directory
$tempDir = "C:\Temp"
if (!(Test-Path -Path $tempDir)) {
    New-Item -Path $tempDir -ItemType Directory -Force
}

# Download WSL2 kernel update package
$kernelUrl = "https://wslstorestorage.blob.core.windows.net/wslblob/wsl_update_x64.msi"
$kernelPath = "$tempDir\wsl_update_x64.msi"

Start-Sleep -Seconds 10

Invoke-WebRequest -Uri $kernelUrl -OutFile $kernelPath

# Install kernel silently
Start-Process msiexec.exe -ArgumentList "/i `"$kernelPath`" /qn /norestart" -Wait

# Cleanup
Remove-Item -Path $kernelPath -Force

Write-Host "WSL base installation complete." -ForegroundColor Green
