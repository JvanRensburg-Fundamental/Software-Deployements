# ==========================================
#  Install-VSStudio2026Pro.ps1
# ==========================================

Set-StrictMode -Version Latest
$ErrorActionPreference = "Continue"
$VerbosePreference = "Continue"

# ------------------------------------------
#  VARIABLES
# ------------------------------------------
$AppName        = "Visual Studio 2026 Pro"
$ZipUrl         = "https://safundavdstore.blob.core.windows.net/software/VSStudio2026Pro.zip?sp=r&st=2026-02-09T22:00:25Z&se=2026-02-13T06:15:25Z&spr=https&sv=2024-11-04&sr=b&sig=yOeC9FmGOtCHQ%2F8r8vy43qW6FPHO2HodvBaaU8wCmTY%3D"
$ZipPath        = "C:\Temp\VSStudio2026Pro.zip"
$ExtractPath    = "C:\Temp\VSStudio2026Pro"
$ConfigFile     = "ChannelManifest.json"
$CreateShortcut = $true

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

    Write-Log "Downloading Visual Studio media from $ZipUrl"
    Invoke-WebRequest -Uri $ZipUrl -OutFile $ZipPath -UseBasicParsing

    if (!(Test-Path $ZipPath)) {
        Write-Log "ERROR: Visual Studio media ZIP failed to download"
        exit 1
    }

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
        Write-Log "ERROR: SQL configuration file not found: $ConfigPath"
        exit 1
    }

    Write-Log "Using SQL configuration file: $ConfigPath"

    # ------------------------------------------
    #  RUN VISUAL STUDIO SETUP
    # ------------------------------------------
    $SetupExe = "$ExtractPath\VisualStudioSetup.exe"
    $Arguments = "--noWeb --installChannelUri `"$ConfigPath`" --installPath `"C:\Program Files\Microsoft Visual Studio\2026\Professional`" --passive"

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
    #  CREATE DESKTOP SHORTCUT (optional)
    # ------------------------------------------
    if ($CreateShortcut) {

        $AppExecutablePath = "C:\Program Files\Microsoft Visual Studio\2026\Professional\Common7\IDE\devenv.exe"

        Write-Log "Checking for Visual Studio executable at $AppExecutablePath"

        if (!(Test-Path $AppExecutablePath)) {
            Write-Log "WARNING: Visual Studio executable not found. Shortcut will not be created."
        }
        else {
            Write-Log "Creating desktop shortcut for $AppName"

            $ShortcutPath = "C:\Users\Public\Desktop\$AppName.lnk"

            try {
                $WScriptShell = New-Object -ComObject WScript.Shell
                $Shortcut = $WScriptShell.CreateShortcut($ShortcutPath)
                $Shortcut.TargetPath = $AppExecutablePath
                $Shortcut.WorkingDirectory = Split-Path $AppExecutablePath
                $Shortcut.WindowStyle = 1
                $Shortcut.IconLocation = $AppExecutablePath
                $Shortcut.Save()

                Write-Log "Shortcut created at $ShortcutPath"
            }
            catch {
                Write-Log "ERROR: Failed to create shortcut - $($_.Exception.Message)"
            }
        }
    }

    # ------------------------------------------
    #  CLEANUP
    # ------------------------------------------
    Write-Log "Cleaning up Visual Studio media ZIP"
    if (Test-Path $ZipPath) {
        Remove-Item -Path $ZipPath -Force
        Remove-Item -Path $ExtractPath -Recurse -Force
    }

    Write-Log "=== Visual Studio 2026 Pro installation completed successfully ==="
    exit 0
}

catch {
    Write-Log "ERROR: $($_.Exception.Message)"
    Write-Log "=== Visual Studio 2026 Pro installation FAILED ==="
    exit 1
}