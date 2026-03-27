# Detect New Teams (MSIX)
$NewTeams = Get-AppxPackage -Name MSTeams
if ($NewTeams) { exit 0 }

# Detect Classic Teams (per-user)
$ClassicTeams = Get-ChildItem -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall" |
    Get-ItemProperty |
    Where-Object { $_.DisplayName -match "Microsoft Teams" }

if ($ClassicTeams) { exit 0 }

exit 1