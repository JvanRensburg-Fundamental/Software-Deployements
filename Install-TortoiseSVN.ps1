$InstallerUrl = "https://sourceforge.net/projects/tortoisesvn/files/1.14.9/Application/TortoiseSVN-1.14.9.29743-x64-svn-1.14.5.msi/download"
$InstallerPath = "C:\Temp\TortoiseSVN.msi"

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
