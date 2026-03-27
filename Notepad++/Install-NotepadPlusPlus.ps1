Write-Output "Downloading latest Notepad++ release info..."

# GitHub API endpoint for latest release
$ReleaseInfo = Invoke-RestMethod -Uri "https://api.github.com/repos/notepad-plus-plus/notepad-plus-plus/releases/latest"

# Find the 64-bit installer asset
$Asset = $ReleaseInfo.assets | Where-Object { $_.name -match "Installer.x64.exe" }

if (-not $Asset) {
    Write-Error "Could not find Notepad++ 64-bit installer in the latest release."
    exit 1
}

$DownloadUrl = $Asset.browser_download_url
$InstallerPath = "$env:TEMP\npp-latest-x64.exe"

Write-Output "Downloading installer from $DownloadUrl ..."
Invoke-WebRequest -Uri $DownloadUrl -OutFile $InstallerPath

Write-Output "Installing Notepad++ silently..."
Start-Process $InstallerPath -ArgumentList "/S" -Wait

Write-Output "Notepad++ installation completed."