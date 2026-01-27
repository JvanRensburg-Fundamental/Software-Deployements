$tempDir = "C:\Temp"
$InstallerUrl = "https://central.github.com/deployments/desktop/desktop/latest/win32?format=msi"
$InstallerPath = "$tempDir\GitHubDesktopSetup-x64.msi"

if (!(Test-Path -Path $tempDir)) {
    New-Item -Path $tempDir -ItemType Directory -Force
}

Start-Sleep -Seconds 10

Invoke-WebRequest -Uri $InstallerUrl -OutFile $InstallerPath

Start-Process msiexec.exe -ArgumentList "/i `"$InstallerPath`" /qn /norestart" -Wait

Remove-Item -Path $InstallerPath -Force
