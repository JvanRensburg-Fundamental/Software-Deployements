# Install-SSRS.ps1

$tempDir = "C:\Temp"
$url = "https://download.microsoft.com/download/1/a/a/1aaa9177-3578-4931-b8f3-373b24f63342/SQLServerReportingServices.exe"
$output = "$tempDir\SQLServerReportingServices.exe"

# Ensure Temp folder exists
if (!(Test-Path -Path $tempDir)) {
    New-Item -Path $tempDir -ItemType Directory -Force
}

# Allow CDN redirect to settle
Start-Sleep -Seconds 10

# Download installer
Invoke-WebRequest -Uri $url -OutFile $output

# Install silently with license acceptance and Dev edition
Start-Process -FilePath $output -ArgumentList "/quiet /norestart /IAcceptLicenseTerms /Edition=Dev" -Wait

# Cleanup
Remove-Item -Path $output -Force
