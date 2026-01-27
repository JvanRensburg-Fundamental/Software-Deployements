$InstallerUrl = "https://www.filehorse.com/download/file/9MxDVowrq2m3OGZe5ovTkH8nGpywzG2EHdRRpec0FUtu4l6oDuFwIZTVWVJmiqeFgRUNYv5V2Utw2_jDNo23UC5r8IXKHY6ymO-jrviBz-I/"
$InstallerPath = "C:\Temp\TortoiseSVN-1.14.9.29743-x64-svn-1.14.5.msi"

# Ensure Temp folder exists
if (!(Test-Path -Path "C:\Temp")) {
    New-Item -Path "C:\Temp" -ItemType Directory -Force
}

# Wait for redirect to stabilize
Start-Sleep -Seconds 10

# Download installer
Invoke-WebRequest -Uri $InstallerUrl -OutFile $InstallerPath

# Install silently
Start-Process msiexec.exe -ArgumentList "/i `"$InstallerPath`" /qn /norestart" -Wait

# Cleanup
Remove-Item -Path $InstallerPath -Force
