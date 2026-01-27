# Install-VisualStudio2022Pro.ps1

$tempDir = "C:\Temp"
$url = "https://aka.ms/vs/17/release/vs_Professional.exe"
$output = "$tempDir\vs_Professional.exe"

# Ensure Temp folder exists
if (!(Test-Path -Path $tempDir)) {
    New-Item -Path $tempDir -ItemType Directory -Force
}

# Allow CDN redirect to settle
Start-Sleep -Seconds 10

# Download installer
Invoke-WebRequest -Uri $url -OutFile $output

# Install silently (default workloads)
Start-Process -FilePath $output -ArgumentList "--quiet --wait --norestart" -Wait

# Cleanup
Remove-Item -Path $output -Force
