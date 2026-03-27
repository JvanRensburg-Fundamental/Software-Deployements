# ==========================================================
# Uninstall Microsoft Edge WebView2 Runtime (System-Level)
# ==========================================================

$BasePath = "${env:ProgramFiles(x86)}\Microsoft\EdgeWebView\Application"

if (-Not (Test-Path $BasePath)) {
    Write-Host "WebView2 Runtime not found on this system." -ForegroundColor Yellow
    exit 0
}

# Find the version folder (e.g., 126.0.2592.43)
$Version = Get-ChildItem -Path $BasePath -Directory | Sort-Object Name -Descending | Select-Object -First 1

if (-Not $Version) {
    Write-Host "No WebView2 version folders found." -ForegroundColor Yellow
    exit 0
}

$SetupPath = Join-Path $Version.FullName "Installer\setup.exe"

if (-Not (Test-Path $SetupPath)) {
    Write-Host "Uninstaller not found: $SetupPath" -ForegroundColor Red
    exit 1
}

Write-Host "Uninstalling Microsoft Edge WebView2 Runtime..." -ForegroundColor Cyan

Start-Process -FilePath $SetupPath `
    -ArgumentList "--uninstall --msedgewebview --system-level --force-uninstall" `
    -Wait

Write-Host "WebView2 Runtime uninstall completed." -ForegroundColor Green