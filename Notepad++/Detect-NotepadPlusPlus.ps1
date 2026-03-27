$paths = @(
    "C:\Program Files\Notepad++\notepad++.exe",
    "C:\Program Files (x86)\Notepad++\notepad++.exe"
)

foreach ($path in $paths) {
    if (Test-Path $path) {
        exit 0  # Detected
    }
}

exit 1  # Not detected