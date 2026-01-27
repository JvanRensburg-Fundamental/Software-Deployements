# Install-DockerDesktop.ps1

$tempDir = "C:\Temp"
$url = "https://desktop.docker.com/win/stable/Docker%20Desktop%20Installer.exe"
$output = "$tempDir\DockerDesktopInstaller.exe"

# Ensure Temp folder exists
if (!(Test-Path -Path $tempDir)) {
    New-Item -Path $tempDir -ItemType Directory -Force
}

# Allow CDN redirect to settle
Start-Sleep -Seconds 10

# Download installer
Invoke-WebRequest -Uri $url -OutFile $output

# Install silently
Start-Process -FilePath $output -ArgumentList "install --quiet --accept-license" -Wait

# Cleanup
Remove-Item -Path $output -Force
