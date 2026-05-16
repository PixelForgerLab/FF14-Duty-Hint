$ErrorActionPreference = 'Continue'
$dir = "Z:\Source Code\FF14Hint\data\duties"
$files = Get-ChildItem $dir\*.json | Where-Object { $_.Name -notmatch '^_' }

$problems = @()

foreach ($f in $files) {
    $j = Get-Content $f.FullName -Raw -Encoding UTF8 | ConvertFrom-Json
    $id = $j.id
    $issues = New-Object System.Collections.ArrayList

    # Collect all mechanic names + descriptions across all bosses
    $allMechNames = New-Object System.Collections.ArrayList
    $allMechDescs = New-Object System.Collections.ArrayList
    $bossNames = New-Object System.Collections.ArrayList
    foreach ($b in $j.bosses) {
        [void]$bossNames.Add($b.name)
        foreach ($p in $b.phases) {
            foreach ($m in $p.mechanics) {
                [void]$allMechNames.Add($m.name)
                [void]$allMechDescs.Add($m.description)
            }
        }
    }
    $totalMechs = $allMechNames.Count

    # Problem 1: Generic-only mechanics
    $genericNames = @('AoE 連發','Tankbuster','全屏 AoE','全體 AoE','範圍 AoE','Spread 散開','Stack 疊接','機制 + AoE','AoE','機制')
    $nonGenericCount = 0
    foreach ($n in $allMechNames) {
        $isGeneric = $false
        foreach ($g in $genericNames) {
            if ($n -eq $g -or $n -match "^$([regex]::Escape($g))(?:\s*\(.+\))?$") { $isGeneric = $true; break }
        }
        if (-not $isGeneric) { $nonGenericCount++ }
    }
    if ($nonGenericCount -eq 0) {
        [void]$issues.Add("ALL-GENERIC: no real ability names")
    } elseif ($nonGenericCount -lt ($totalMechs * 0.5)) {
        [void]$issues.Add("MOSTLY-GENERIC: $nonGenericCount/$totalMechs real")
    }

    # Problem 2: Markup artifacts in names
    foreach ($n in $allMechNames) {
        if ($n -match '\{\{|\}\}|\[\[|\]\]' -or $n -match '''''') {
            [void]$issues.Add("MARKUP-ARTIFACT in '$n'"); break
        }
        if ($n -match ':\s*$' -or $n -match '\|') {
            [void]$issues.Add("BROKEN-NAME '$n'"); break
        }
    }

    # Problem 3: Prose-fragment names (looks like sentence not skill name)
    foreach ($n in $allMechNames) {
        if ($n -match '^[a-z]' -and $n.Length -gt 15) {
            [void]$issues.Add("PROSE-FRAGMENT '$n'"); break
        }
        if ($n -match '(followed by|and then|will be|will cast|of the)') {
            [void]$issues.Add("PROSE-FRAGMENT '$n'"); break
        }
    }

    # Problem 4: Boss name issues
    foreach ($bn in $bossNames) {
        if ($bn -match '\{\{|\}\}|\[\[|\]\]') {
            [void]$issues.Add("BOSS-MARKUP '$bn'"); break
        }
        if ($bn -match '^(波次|波|Wave|Event|Generic|Generic|Boss)' -or $bn -match '機制$|形態$') {
            # Allow specific bosses like 'Wave 1', but flag pure 'Wave Enemies'
            if ($bn -in @('Wave Enemies','Event Boss','雜兵波次','Generic Boss')) {
                [void]$issues.Add("PLACEHOLDER-BOSS '$bn'"); break
            }
        }
    }

    # Problem 5: Very low boss/mechanic count
    if ($j.bosses.Count -eq 1 -and $totalMechs -le 3) {
        # Could be legit for very short trials, but flag for review
        $allAbsList = $allMechNames -join '|'
        if ($allAbsList -match '^(AoE 連發|Tankbuster|全屏 AoE|全體 AoE|範圍 AoE)' -and $totalMechs -le 4) {
            [void]$issues.Add("THIN-CONTENT: 1 boss, $totalMechs generic mechs")
        }
    }

    if ($issues.Count -gt 0) {
        $problems += [PSCustomObject]@{
            Id = $id
            Issues = ($issues -join '; ')
            BossCount = $j.bosses.Count
            MechCount = $totalMechs
            Quality = $j.quality
        }
    }
}

Write-Host ""
Write-Host "=========================================="
Write-Host "QUALITY AUDIT REPORT — $($files.Count) files"
Write-Host "=========================================="
Write-Host "Files with issues: $($problems.Count)"
Write-Host ""
$problems | Format-Table -AutoSize -Wrap | Out-String -Width 200
