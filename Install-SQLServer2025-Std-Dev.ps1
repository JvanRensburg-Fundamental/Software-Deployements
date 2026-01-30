# ==========================================
#  Install-SQLServer2025.ps1
#  Universal SQL Installer (AIB-safe)
#  Logs in C:\Temp\AppLogs
# ==========================================

Set-StrictMode -Version Latest
$ErrorActionPreference = "Continue"
$VerbosePreference = "Continue"

# ------------------------------------------
#  VARIABLES (update only these)
# ------------------------------------------
$AppName        = "SQLServer2025"
$ZipUrl         = "https://safundavdstore.blob.core.windows.net/software/SQLServer2025.zip?sp=r&st=2026-01-30T19:41:33Z&se=2026-03-31T03:56:33Z&spr=https&sv=2024-11-04&sr=b&sig=Pqw9jJteNo73qovnze4yYPpwDiKAipgKAcF%2B14SHOus%3D"
$ZipPath        = "C:\Temp\SQLServer2025.zip"
$ExtractPath    = "C:\Temp\SQLServer2025"
$ConfigFile     = "AVDSQL2025_Config.ini"

# ------------------------------------------
#  PREPARE LOGGING
# ------------------------------------------
if (!(Test-Path -Path "C:\Temp")) {
    New-Item -Path "C:\Temp" -ItemType Directory -Force | Out-Null
}

$LogPath = "C:\Temp\AppLogs"
if (!(Test-Path $LogPath)) {
    New-Item -Path $LogPath -ItemType Directory -Force | Out-Null
}

$LogFile = Join-Path $LogPath "SQLInstall-$($AppName)-$(Get-Date -Format 'yyyyMMdd-HHmmss').log"

function Write-Log {
    param([string]$Message)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "$timestamp  $Message" | Tee-Object -FilePath $LogFile -Append
}

Write-Log "=== Starting SQL Server 2025 installation ==="

try {
    # ------------------------------------------
    #  DOWNLOAD SQL MEDIA ZIP
    # ------------------------------------------
    Write-Log "Downloading SQL Server media from $ZipUrl"
    Invoke-WebRequest -Uri $ZipUrl -OutFile $ZipPath -UseBasicParsing

    if (!(Test-Path $ZipPath)) {
        Write-Log "ERROR: SQL media ZIP failed to download"
        exit 1
    }

    Write-Log "SQL media ZIP downloaded successfully"

    # ------------------------------------------
    #  EXTRACT SQL MEDIA
    # ------------------------------------------
    Write-Log "Extracting SQL Server media to $ExtractPath"

    if (Test-Path $ExtractPath) {
        Remove-Item -Path $ExtractPath -Recurse -Force
    }

    Expand-Archive -Path $ZipPath -DestinationPath $ExtractPath -Force

    if (!(Test-Path "$ExtractPath\setup.exe")) {
        Write-Log "ERROR: setup.exe not found after extraction"
        exit 1
    }

    Write-Log "SQL media extracted successfully"

    # ------------------------------------------
    #  VALIDATE CONFIG FILE
    # ------------------------------------------
    $ConfigPath = Join-Path $ExtractPath $ConfigFile

    if (!(Test-Path $ConfigPath)) {
        Write-Log "ERROR: SQL configuration file not found: $ConfigPath"
        exit 1
    }

    Write-Log "Using SQL configuration file: $ConfigPath"

    # ------------------------------------------
    #  RUN SQL SERVER SETUP
    # ------------------------------------------
    $SetupExe = Join-Path $ExtractPath "setup.exe"
    $Arguments = "/ConfigurationFile=$ConfigPath /Q /IACCEPTSQLSERVERLICENSETERMS"

    Write-Log "Running SQL Server setup"
    Write-Log "Command: setup.exe $Arguments"

    $process = Start-Process -FilePath $SetupExe -ArgumentList $Arguments -Wait -PassThru
    Write-Log "SQL Server exit code: $($process.ExitCode)"

    if ($process.ExitCode -ne 0) {
        Write-Log "ERROR: SQL Server installation failed"
        exit 1
    }

    Write-Log "SQL Server installed successfully"

    # ------------------------------------------
    #  CLEANUP
    # ------------------------------------------
    Write-Log "Cleaning up SQL media ZIP"
    if (Test-Path $ZipPath) {
        Remove-Item -Path $ZipPath -Force
    }

    Write-Log "=== SQL Server 2025 installation completed successfully ==="
    exit 0
}
catch {
    Write-Log "ERROR: $($_.Exception.Message)"
    Write-Log "=== SQL Server 2025 installation FAILED ==="
    exit 1
}