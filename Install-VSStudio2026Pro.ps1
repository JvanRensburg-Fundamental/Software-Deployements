# ==========================================
#  Install-VSStudio2026Pro.ps1
#  Universal Visual Studio 2026 Pro (AIB-safe)
#  Logs in C:\Temp\AppLogs
# ==========================================

Set-StrictMode -Version Latest
$ErrorActionPreference = "Continue"
$VerbosePreference = "Continue"

# ------------------------------------------
#  VARIABLES (update only these)
# ------------------------------------------
$AppName        = "VSStudio2026Pro"
#$ZipUrl         = ""   # <-- Add your ZIP URL here
$ZipPath        = "C:\Temp\VSStudio2026Pro.zip"
$ExtractPath    = "C:\Temp\VSStudio2026Pro"
$ConfigFile     = "AVDVS2026_ConfigurationFile.json"

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

$LogFile = Join-Path $LogPath "VSStudio2026Pro-$($AppName)-$(Get-Date -Format 'yyyyMMdd-HHmmss').log"

function Write-Log {
    param([string]$Message)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "$timestamp  $Message" | Tee-Object -FilePath $LogFile -Append
}

Write-Log "=== Starting Visual Studio 2026 Pro installation ==="

try {
    # ------------------------------------------
    #  DOWNLOAD VS MEDIA ZIP
    # ------------------------------------------

    #  Write-Log "Downloading Visual Studio media from $ZipUrl"
    #Invoke-WebRequest -Uri $ZipUrl -OutFile $ZipPath -UseBasicParsing

    #if (!(Test-Path $ZipPath)) {
    #    Write-Log "ERROR: Visual Studio media ZIP failed to download"
    #    exit 1
    #}

    # Write-Log "Visual Studio media ZIP downloaded successfully"

    # ------------------------------------------
    #  EXTRACT VS MEDIA
    # ------------------------------------------
    Write-Log "Extracting Visual Studio media to $ExtractPath"

    if (Test-Path $ExtractPath) {
        Remove-Item -Path $ExtractPath -Recurse -Force
    }

    Expand-Archive -Path $ZipPath -DestinationPath $ExtractPath -Force

    if (!(Test-Path "$ExtractPath\VisualStudioSetup.exe")) {
        Write-Log "ERROR: VisualStudioSetup.exe not found after extraction"
        exit 1
    }

    Write-Log "Visual Studio media extracted successfully"

    # ------------------------------------------
    #  VALIDATE CONFIG FILE
    # ------------------------------------------
    $ConfigPath = Join-Path $ExtractPath $ConfigFile

    if (!(Test-Path $ConfigPath)) {
        Write-Log "ERROR: Visual Studio configuration file not found: $ConfigPath"
        exit 1
    }

    Write-Log "Using Visual Studio configuration file: $ConfigPath"

    # ------------------------------------------
    #  RUN VISUAL STUDIO SETUP
    # ------------------------------------------
    $SetupExe = Join-Path $ExtractPath "VisualStudioSetup.exe"

    # Visual Studio silent install syntax
    $Arguments = "--quiet --wait --norestart --config `"$ConfigPath`""

    Write-Log "Running Visual Studio setup"
    Write-Log "Command: VisualStudioSetup.exe $Arguments"

    $process = Start-Process -FilePath $SetupExe -ArgumentList $Arguments -Wait -PassThru
    Write-Log "Visual Studio exit code: $($process.ExitCode)"

    if ($process.ExitCode -ne 0) {
        Write-Log "ERROR: Visual Studio installation failed"
        exit 1
    }

    Write-Log "Visual Studio installed successfully"

    # ------------------------------------------
    #  CLEANUP
    # ------------------------------------------
    Write-Log "Cleaning up Visual Studio media ZIP"
    if (Test-Path $ZipPath) {
        Remove-Item -Path $ZipPath -Force
    }

    Write-Log "=== Visual Studio 2026 Pro installation completed successfully ==="
    exit 0
}
catch {
    Write-Log "ERROR: $($_.Exception.Message)"
    Write-Log "=== Visual Studio 2026 Pro installation FAILED ==="
    exit 1
}