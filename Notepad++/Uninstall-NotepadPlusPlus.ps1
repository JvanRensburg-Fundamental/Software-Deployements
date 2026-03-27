Write-Output "Removing all existing versions of Notepad++..."

# Uninstall via registry uninstall strings
$uninstallKeys = @(
    "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*",
    "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*"
)

foreach ($key in $uninstallKeys) {
    Get-ItemProperty $key -ErrorAction SilentlyContinue |
    Where-Object { $_.DisplayName -like "Notepad++*" } |
    ForEach-Object {
        Write-Output "Found: $($_.DisplayName) — uninstalling..."
        if ($_.UninstallString) {
            $cmd = $_.UninstallString.Replace("/I", "/X") + " /S"
            Start-Process "cmd.exe" -ArgumentList "/c $cmd" -Wait
        }
    }
}

# Remove leftover folder
$paths = @(
    "C:\Program Files\Notepad++",
    "C:\Program Files (x86)\Notepad++"
)
foreach ($path in $paths) {
    if (Test-Path $path) {
        Write-Output "Removing leftover folder: $path"
        Remove-Item -Recurse -Force $path
    }
}

Write-Output "Notepad++ uninstall complete."