# ===========================================================
#  Notepad++ Enterprise Installer Script (Intune Compatible)
#  - Removes all existing Notepad++ installs (your script)
#  - Downloads the latest x64 version from GitHub
#  - Installs silently
# ===========================================================

Write-Output "----- Notepad++ Deployment Started -----"

# Define script locations
$ScriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$UninstallScript = Join-Path $ScriptRoot "Uninstall-NotepadPP.ps1"

# -----------------------------------------------------------
# 1. REMOVE OLD VERSIONS (Enterprise Cleanup)
# -----------------------------------------------------------
if (Test-Path $UninstallScript) {
    Write-Output "Running uninstall script to remove old versions..."
    powershell.exe -ExecutionPolicy Bypass -File $UninstallScript
} else {
    Write-Output "Uninstall script not found. Skipping removal step."
}

# -----------------------------------------------------------
# 2. GET LATEST NOTEPAD++ RELEASE FROM GITHUB
# -----------------------------------------------------------
Write-Output "Retrieving latest Notepad++ release info from GitHub..."

try {
    $ReleaseInfo = Invoke-RestMethod -Uri "https://api.github.com/repos/notepad-plus-plus/notepad-plus-plus/releases/latest" -UseBasicParsing
} catch {
    Write-Error "Failed to query GitHub API. Exiting."
    exit 1
}

$Asset = $ReleaseInfo.assets | Where-Object { $_.name -match "Installer.x64.exe" }

if (-not $Asset) {
    Write-Error "Latest Notepad++ x64 installer not found in GitHub assets. Exiting."
    exit 1
}

$DownloadUrl = $Asset.browser_download_url
$InstallerPath = "$env:TEMP\NotepadPP-Latest-x64.exe"

Write-Output "Downloading latest installer from:"
Write-Output "$DownloadUrl"

try {
    Invoke-WebRequest -Uri $DownloadUrl -OutFile $InstallerPath
} catch {
    Write-Error "Failed to download the Notepad++ installer. Exiting."
    exit 1
}

# -----------------------------------------------------------
# 3. INSTALL NOTEPAD++ SILENTLY
# -----------------------------------------------------------
Write-Output "Installing Notepad++ silently..."
Start-Process $InstallerPath -ArgumentList "/S" -Wait

if ($LASTEXITCODE -eq 0) {
    Write-Output "Notepad++ installed successfully."
} else {
    Write-Error "Notepad++ installer returned exit code $LASTEXITCODE"
    exit $LASTEXITCODE
}

Write-Output "----- Notepad++ Deployment Completed Successfully -----"
exit 0