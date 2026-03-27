# Update Python using winget

# Ensure winget exists
if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
    Write-Host "Winget not found. Install the App Installer package from Microsoft Store." -ForegroundColor Red
    exit 1
}

Write-Host "Checking for Python updates..." -ForegroundColor Cyan

# Attempt upgrade for main Python package
winget upgrade --id Python.Python.3 --accept-package-agreements --accept-source-agreements --silent

Write-Host "Python update process completed." -ForegroundColor Green