# ===============================================
# Microsoft Edge WebView2 Runtime Silent Installer
# ===============================================

$Installer = "MicrosoftEdgeWebView2RuntimeInstallerX64.exe"

# Check if installer exists in the same folder
if (-not (Test-Path $Installer)) {
    Write-Host "Installer not found: $Installer" -ForegroundColor Red
    exit 1
}

Write-Host "Starting silent WebView2 installation..." -ForegroundColor Cyan

Start-Process -FilePath $Installer -ArgumentList "/silent /install" -Wait

Write-Host "Microsoft Edge WebView2 Runtime installation completed." -ForegroundColor Green