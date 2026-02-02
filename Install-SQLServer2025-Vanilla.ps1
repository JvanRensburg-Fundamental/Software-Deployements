# ==========================================
#  Install-SQLServer2025-AIB.ps1
#  AIB-safe SQL installer WITHOUT config file
# ==========================================

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# ------------------------------------------
# VARIABLES
# ------------------------------------------
$ZipUrl      = "https://safundavdstore.blob.core.windows.net/software/SQLServer2025.zip?sp=r&st=2026-01-30T21:01:01Z&se=2026-03-31T05:16:01Z&spr=https&sv=2024-11-04&sr=b&sig=swAkALT4EZKlOefB4icvG6ssNJ7woDMssLTie5rZprk%3D"
$ZipPath     = "C:\Temp\SQLServer2025.zip"
$ExtractPath = "C:\Temp\SQLServer2025"

# ------------------------------------------
# LOGGING
# ------------------------------------------
$LogPath = "C:\Temp\AppLogs"
New-Item -Path $LogPath -ItemType Directory -Force | Out-Null
$LogFile = Join-Path $LogPath "SQLInstall-$(Get-Date -Format 'yyyyMMdd-HHmmss').log"

function Write-Log {
    param([string]$Message)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "$timestamp  $Message" | Tee-Object -FilePath $LogFile -Append
}

Write-Log "=== Starting SQL Server 2025 installation ==="

try {
    # ------------------------------------------
    # Install .NET 3.5 (required for SQL)
    # ------------------------------------------
    Write-Log "Installing .NET Framework 3.5"
    Add-WindowsCapability -Online -Name NetFx3~~~~
    Write-Log ".NET Framework 3.5 installed"

    # ------------------------------------------
    # Download SQL ZIP
    # ------------------------------------------
    Write-Log "Downloading SQL Server media..."
    Invoke-WebRequest -Uri $ZipUrl -OutFile $ZipPath -UseBasicParsing
    Write-Log "Download complete"

    # ------------------------------------------
    # Extract SQL media
    # ------------------------------------------
    if (Test-Path $ExtractPath) { Remove-Item $ExtractPath -Recurse -Force }
    Write-Log "Extracting SQL media..."
    Expand-Archive -Path $ZipPath -DestinationPath $ExtractPath -Force

    # Find setup.exe (handles nested folders)
    $SetupExe = Get-ChildItem -Path $ExtractPath -Recurse -Filter "setup.exe" | Select-Object -First 1
    if (-not $SetupExe) {
        Write-Log "ERROR: setup.exe not found"
        exit 1
    }

    Write-Log "Found setup.exe at $($SetupExe.FullName)"

    # ------------------------------------------
    # Run SQL Setup (NO CONFIG FILE)
    # ------------------------------------------
    $Arguments = @(
        "/Q"
        "/ACTION=Install"
        "/FEATURES=SQL,Tools"
        "/INSTANCENAME=MSSQLSERVER"
        "/INSTANCEID=MSSQLSERVER"
        "/IACCEPTSQLSERVERLICENSETERMS"
        "/SQLSVCACCOUNT=`"NT AUTHORITY\SYSTEM`""
        "/AGTSVCACCOUNT=`"NT AUTHORITY\SYSTEM`""
        "/SQLSYSADMINACCOUNTS=`"Administrators`""
        "/SECURITYMODE=SQL"
        "/SAPWD=Denver2017"
        "/TCPENABLED=1"
        "/NPENABLED=1"
        "/BROWSERSVCSTARTUPTYPE=Automatic"
        "/SkipRules=RebootRequiredCheck"
    )

    Write-Log "Running SQL setup..."
    Write-Log "Command: $($SetupExe.FullName) $Arguments"

    $process = Start-Process -FilePath $SetupExe.FullName -ArgumentList $Arguments -Wait -PassThru
    Write-Log "SQL Server exit code: $($process.ExitCode)"

    if ($process.ExitCode -ne 0) {
        Write-Log "ERROR: SQL Server installation failed"
        exit 1
    }

    Write-Log "SQL Server installed successfully"

    # ------------------------------------------
    # Cleanup
    # ------------------------------------------
    Write-Log "Cleaning up ZIP"
    Remove-Item $ZipPath -Force

    Write-Log "=== SQL Server 2025 installation completed successfully ==="
    exit 0
}
catch {
    Write-Log "ERROR: $($_.Exception.Message)"
    Write-Log "=== SQL Server 2025 installation FAILED ==="
    exit 1
}