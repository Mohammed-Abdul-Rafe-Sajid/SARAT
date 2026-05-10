# PowerShell script to remove Mapbox token from git history
param(
    [string]$TokenPattern = "pk\.eyJ1[^'\"]+"
)

# Files to check
$files = @("webapp/OutputForApp.jsp", "webapp/Output_Fast.jsp")

# For each file, remove the token pattern
foreach ($file in $files) {
    if (Test-Path $file) {
        $content = Get-Content $file -Raw
        $content = $content -replace $TokenPattern, '<YOUR_MAPBOX_TOKEN>'
        Set-Content $file -Value $content -NoNewline
    }
}
