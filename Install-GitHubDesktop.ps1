# ==========================================
#  Universal App Installer Template
#  Logs in C:\Temp\AppLogs
#  ErrorActionPreference = Continue
#  Deterministic exit codes
# ==========================================

Set-StrictMode -Version Latest
$ErrorActionPreference = "Continue"
$VerbosePreference = "Continue"

# Ensure C:\Temp exists
if (!(Test-Path -Path "C:\Temp")) {
    New-Item -Path "C:\Temp" -ItemType Directory -Force | Out-Null
}

# Logging directory inside Temp
$LogPath = "C:\Temp\AppLogs"
if (!(Test-Path $LogPath)) {
    New-Item -Path $LogPath -ItemType Directory -Force | Out-Null
}

$LogFile = Join-Path $LogPath "AppInstall-$(Get-Date -Format 'yyyyMMdd-HHmmss').log"

function Write-Log {
    param([string]$Message)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "$timestamp  $Message" | Tee-Object -FilePath $LogFile -Append
}

Write-Log "=== Starting application installation ==="

try {
    # ----------------------------
    #  DEFINE YOUR VARIABLES HERE
    # ----------------------------
    # Example:
    # $AppName       = "GitHub Desktop"
    # $InstallerUrl  = "https://central.github.com/deployments/desktop/desktop/latest/win32?format=msi"
    # $InstallerPath = "C:\Temp\GitHubDesktopInstaller.msi"
    # $SilentArgs    = "/S"   # for EXE installers

    Write-Log "Preparing to install $AppName"

    # ----------------------------
    #  DOWNLOAD INSTALLER
    # ----------------------------
    if ($InstallerUrl) {
        Write-Log "Downloading installer from $InstallerUrl"
        Invoke-WebRequest -Uri $InstallerUrl -OutFile $InstallerPath -UseBasicParsing

        if (!(Test-Path $InstallerPath)) {
            Write-Log "ERROR: Installer failed to download"
            exit 1
        }

        Write-Log "Installer downloaded successfully"
    }

    # ----------------------------
    #  INSTALL MSI
    # ----------------------------
    if ($InstallerPath -like "*.msi") {
        Write-Log "Running MSI installer for $AppName"
        $process = Start-Process msiexec.exe -ArgumentList "/i `"$InstallerPath`" /qn /norestart" -Wait -PassThru
        Write-Log "MSI exit code: $($process.ExitCode)"

        if ($process.ExitCode -ne 0) {
            Write-Log "ERROR: MSI installer failed"
            exit 1
        }
    }

    # ----------------------------
    #  INSTALL EXE
    # ----------------------------
    if ($InstallerPath -like "*.exe") {
        Write-Log "Running EXE installer for $AppName"
        $process = Start-Process -FilePath $InstallerPath -ArgumentList $SilentArgs -Wait -PassThru
        Write-Log "EXE exit code: $($process.ExitCode)"

        if ($process.ExitCode -ne 0) {
            Write-Log "ERROR: EXE installer failed"
            exit 1
        }
    }

    # ----------------------------
    #  CLEANUP
    # ----------------------------
    if (Test-Path $InstallerPath) {
        Write-Log "Cleaning up installer"
        Remove-Item -Path $InstallerPath -Force
    }

    Write-Log "=== Application installation completed successfully ==="
    exit 0
}
catch {
    Write-Log "ERROR: $($_.Exception.Message)"
    Write-Log "=== Script failed ==="
    exit 1
}

