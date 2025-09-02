# Disables Luau analysis in vendored files by inserting --!nocheck
#
# - Targets: Packages/_Index/**, ServerPackages/_Index/**, _tmp_Fusion/**
# - Idempotent: Only inserts if not already present in the first 5 lines
# - Safe: Leaves project/source files outside these folders untouched

param(
    [string[]]$Roots = @('Packages/_Index', 'ServerPackages/_Index', '_tmp_Fusion')
)

Write-Host "[quiet-vendor] Scanning vendor roots: $($Roots -join ', ')"

$total = 0
$modified = 0

foreach ($root in $Roots) {
    if (-not (Test-Path $root)) { continue }
    $files = Get-ChildItem -Recurse -File -Include *.luau,*.lua -Path $root
    foreach ($f in $files) {
        $total++
        $head = @()
        try {
            $head = Get-Content -Path $f.FullName -TotalCount 5 -ErrorAction Stop
        } catch { continue }

        if ($head -match '--!nocheck') { continue }

        # Prepend --!nocheck at the very top
        $orig = Get-Content -Path $f.FullName -Raw
        $new = "--!nocheck`r`n" + $orig
        Set-Content -Path $f.FullName -Value $new -NoNewline
        $modified++
    }
}

Write-Host "[quiet-vendor] Processed $total files; inserted --!nocheck into $modified files."

