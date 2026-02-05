# ==========================================
#  Install-DevExpress.ps1
#  Universal DevExpress Installer (AIB-safe)
#  Logs in C:\Temp\AppLogs
# ==========================================

Set-StrictMode -Version Latest
$ErrorActionPreference = "Continue"
$VerbosePreference = "Continue"

# ------------------------------------------
#  VARIABLES (update only these)
# ------------------------------------------
$AppName        = "Developer Express"
$ZipUrl         = ""
$ZipPath        = "C:\Temp\DevExpress-25.2.3.zip"
$ExtractPath    = "C:\Temp\DevExpress"
$ConfigFile     = "AVDDevExpress_Config.ini"
$InstallerName  = "DevExpressNETComponentsSetup-25.2.3.exe"

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

$LogFile = Join-Path $LogPath "Install-$($AppName)-$(Get-Date -Format 'yyyyMMdd-HHmmss').log"

function Write-Log {
    param([string]$Message)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "$timestamp  $Message" | Tee-Object -FilePath $LogFile -Append
}

Write-Log "=== Starting $AppName installation ==="

try {
    # ------------------------------------------
    #  DOWNLOAD ZIP
    # ------------------------------------------
    Write-Log "Downloading $AppName from $ZipUrl"
    Invoke-WebRequest -Uri $ZipUrl -OutFile $ZipPath -UseBasicParsing

    if (!(Test-Path $ZipPath)) {
        Write-Log "ERROR: DevExpress ZIP failed to download"
        exit 1
    }

    Write-Log "DevExpress ZIP downloaded successfully"

    # ------------------------------------------
    #  EXTRACT ZIP
    # ------------------------------------------
    Write-Log "Extracting DevExpress media to $ExtractPath"

    if (Test-Path $ExtractPath) {
        Remove-Item -Path $ExtractPath -Recurse -Force
    }

    Expand-Archive -Path $ZipPath -DestinationPath $ExtractPath -Force

    $InstallerPath = Join-Path $ExtractPath $InstallerName
    $DEconfigPath  = Join-Path $ExtractPath $ConfigFile

    if (!(Test-Path $InstallerPath)) {
        Write-Log "ERROR: Installer not found: $InstallerPath"
        exit 1
    }

    if (!(Test-Path $DEconfigPath)) {
        Write-Log "ERROR: Config file not found: $DEconfigPath"
        exit 1
    }

    Write-Log "DevExpress media extracted successfully"
    Write-Log "Using config file: $DEconfigPath"

    # ------------------------------------------
    #  BUILD SILENT ARGUMENTS
    # ------------------------------------------
    $SilentArgs = @(
        "/quiet"
        "/acceptEula=1"
        "/installMode=registered"
        "/configFile=`"$DEconfigPath`""
    )

    Write-Log "Installer arguments: $($SilentArgs -join ' ')"

    # ------------------------------------------
    #  RUN DEVEXPRESS INSTALLER
    # ------------------------------------------
    Write-Log "Running DevExpress installer"

    $process = Start-Process -FilePath $InstallerPath `
        -ArgumentList $SilentArgs `
        -Wait `
        -PassThru `
        -NoNewWindow

    Write-Log "DevExpress installer exit code: $($process.ExitCode)"

    if ($process.ExitCode -ne 0) {
        Write-Log "ERROR: DevExpress installation failed"
        exit 1
    }

    Write-Log "DevExpress installed successfully"

    # ------------------------------------------
    #  CLEANUP
    # ------------------------------------------
    Write-Log "Cleaning up DevExpress ZIP"
    if (Test-Path $ZipPath) {
        Remove-Item -Path $ZipPath -Force
    }

    Write-Log "=== DevExpress installation completed successfully ==="
    exit 0
}
catch {
    Write-Log "ERROR: $($_.Exception.Message)"
    Write-Log "=== DevExpress installation FAILED ==="
    exit 1
}