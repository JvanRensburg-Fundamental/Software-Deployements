# Install-SSMS.ps1

$tempDir = "C:\Temp"
$url = "https://aka.ms/ssms/22/release/vs_SSMS.exe"
$output = "$tempDir\vs_SSMS.exe"

# Ensure Temp folder exists
if (!(Test-Path -Path $tempDir)) {
    New-Item -Path $tempDir -ItemType Directory -Force
}

# Allow CDN redirect to settle
Start-Sleep -Seconds 10

# Download installer
Invoke-WebRequest -Uri $url -OutFile $output

# Install silently
Start-Process -FilePath $output -ArgumentList "/install /quiet /norestart" -Wait

# Cleanup
Remove-Item -Path $output -Force
