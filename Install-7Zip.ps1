# ==========================================
#  Universal App Installer Template
#  Logs in C:\Temp\AppLogs
#  ErrorActionPreference = Continue
#  Deterministic exit codes
#  Optional Desktop Shortcut Creation
# ==========================================

Set-StrictMode -Version Latest
$ErrorActionPreference = "Continue"
$VerbosePreference = "Continue"

# ------------------------------------------
#  DEFINE YOUR VARIABLES HERE
# ------------------------------------------
$AppName            = "7-Zip"      # e.g. "7-Zip"
$InstallerUrl       = "https://www.7-zip.org/a/7z2501-x64.msi"      # e.g. ""
$InstallerPath      = "c:\temp\7z2501-x64.msi"      # e.g. ""
$SilentArgs         = ""      # e.g. "/S" for EXE installers
$CreateShortcut     = $false  # Set to $true to create desktop shortcut
$AppExecutablePath  = ""      # e.g. "C:\Program Files\7-Zip\7zFM.exe"

# ------------------------------------------
#  VALIDATE VARIABLES
# ------------------------------------------
if ([string]::IsNullOrWhiteSpace($AppName)) {
    Write-Host "ERROR: AppName is not defined."
    exit 1
}

if ([string]::IsNullOrWhiteSpace($InstallerPath)) {
    Write-Host "ERROR: InstallerPath is not defined."
    exit 1
}

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

$LogFile = Join-Path $LogPath "AppInstall-$($AppName)-$(Get-Date -Format 'yyyyMMdd-HHmmss').log"

function Write-Log {
    param([string]$Message)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "$timestamp  $Message" | Tee-Object -FilePath $LogFile -Append
}

Write-Log "=== Starting installation for $AppName ==="

try {
    # ------------------------------------------
    #  DOWNLOAD INSTALLER (if URL provided)
    # ------------------------------------------
    if ($InstallerUrl) {
        Write-Log "Downloading installer from $InstallerUrl"
        Invoke-WebRequest -Uri $InstallerUrl -OutFile $InstallerPath -UseBasicParsing

        if (!(Test-Path $InstallerPath)) {
            Write-Log "ERROR: Installer failed to download"
            exit 1
        }

        Write-Log "Installer downloaded successfully"
    }

    # ------------------------------------------
    #  INSTALL MSI
    # ------------------------------------------
    if ($InstallerPath -like "*.msi") {
        Write-Log "Running MSI installer for $AppName"
        $process = Start-Process msiexec.exe -ArgumentList "/i `"$InstallerPath`" /qn /norestart ALLUSERS=1" -Wait -PassThru
        Write-Log "MSI exit code: $($process.ExitCode)"

        if ($process.ExitCode -ne 0) {
            Write-Log "ERROR: MSI installer failed"
            exit 1
        }
    }

    # ------------------------------------------
    #  INSTALL EXE
    # ------------------------------------------
    if ($InstallerPath -like "*.exe") {
        Write-Log "Running EXE installer for $AppName"
        $process = Start-Process -FilePath $InstallerPath -ArgumentList $SilentArgs -Wait -PassThru
        Write-Log "EXE exit code: $($process.ExitCode)"

        if ($process.ExitCode -ne 0) {
            Write-Log "ERROR: EXE installer failed"
            exit 1
        }
    }

    # ------------------------------------------
    #  CREATE DESKTOP SHORTCUT (optional)
    # ------------------------------------------
    if ($CreateShortcut -and -not [string]::IsNullOrWhiteSpace($AppExecutablePath)) {
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

    # ------------------------------------------
    #  CLEANUP
    # ------------------------------------------
    if (Test-Path $InstallerPath) {
        Write-Log "Cleaning up installer"
        Remove-Item -Path $InstallerPath -Force
    }

    Write-Log "=== Installation completed successfully for $AppName ==="
    exit 0
}
catch {
    Write-Log "ERROR: $($_.Exception.Message)"
    Write-Log "=== Script failed for $AppName ==="
    exit 1
}