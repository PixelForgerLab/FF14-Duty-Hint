#requires -Version 5.1

$dataDir = Join-Path $PSScriptRoot "..\..\..\data\duties"
$outCsv = Join-Path $PSScriptRoot "..\quality-audit-v3.csv"

$TIER_COMPLETE = [string][char]0x5B8C + [string][char]0x6574
$TIER_NEEDS    = [string][char]0x5F85 + [string][char]0x88DC + [string][char]0x5145
$TIER_SKELETON = [string][char]0x9AA8 + [string][char]0x5E79

$results = @()
$files = Get-ChildItem $dataDir -Filter *.json

foreach ($f in $files) {
    $j = Get-Content $f.FullName -Raw -Encoding UTF8 | ConvertFrom-Json
    $id = $j.id
    $type = $j.type
    $players = $j.playerCount
    $lvl = $j.jobLevelSync
    $name = $j.name
    $nameEn = $j.nameEn
    $expansion = $j.expansion
    $bossCount = if ($j.bosses) { $j.bosses.Count } else { 0 }
    $mechCount = 0; $bilingualMech = 0; $descCount = 0; $totalDescChars = 0
    $tipsCount = 0; $roleTips = 0
    if ($j.bosses) {
        foreach ($b in $j.bosses) {
            if ($b.phases) {
                foreach ($p in $b.phases) {
                    if ($p.mechanics) {
                        foreach ($m in $p.mechanics) {
                            $mechCount++
                            $hasZh = $m.name -match '[\u4e00-\u9fff]'
                            $hasEn = $m.name -match '[A-Za-z]'
                            if ($hasZh -and $hasEn) { $bilingualMech++ }
                            if ($m.description) {
                                $totalDescChars += $m.description.Length
                                $descCount++
                            }
                            if ($m.tips) {
                                foreach ($t in $m.tips) {
                                    $tipsCount++
                                    if ($t.PSObject -and $t.PSObject.Properties['role']) { $roleTips++ }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    $avgDesc = if ($descCount -gt 0) { [math]::Round($totalDescChars / $descCount, 1) } else { 0 }
    $bilingualPct = if ($mechCount -gt 0) { [math]::Round(100 * $bilingualMech / $mechCount, 1) } else { 0 }
    $mnemonicCount = if ($j.mnemonic) { $j.mnemonic.Count } else { 0 }
    $hasPrimalSuffix = $name -match ' - '
    $hasZhName = $name -match '[\u4e00-\u9fff]'
    $hasEnName = $nameEn -and $nameEn.Length -gt 0
    $tier = $TIER_SKELETON
    $threshComplete = $false
    $threshNeeds = $false
    switch ($type) {
        'trial' {
            $threshComplete = ($mechCount -ge 10 -and $avgDesc -ge 35 -and $bilingualPct -ge 80 -and $roleTips -ge 3 -and $mnemonicCount -ge 4)
            $threshNeeds = ($mechCount -ge 5 -and $avgDesc -ge 18)
        }
        'dungeon' {
            $expectedBosses = if ($id -match 'variant|hell_on_rails|meso_terminal') { 1 } else { 3 }
            $threshComplete = ($bossCount -ge $expectedBosses -and $mechCount -ge 9 -and $avgDesc -ge 25 -and $bilingualPct -ge 80 -and $mnemonicCount -ge 3)
            $threshNeeds = ($mechCount -ge 5 -and $avgDesc -ge 18)
        }
        'raid' {
            if ($players -eq 24) {
                $threshComplete = ($bossCount -ge 3 -and $mechCount -ge 10 -and $avgDesc -ge 25 -and $bilingualPct -ge 80 -and $mnemonicCount -ge 3)
            } else {
                $threshComplete = ($mechCount -ge 6 -and $avgDesc -ge 25 -and $bilingualPct -ge 80 -and $mnemonicCount -ge 3)
            }
            $threshNeeds = ($mechCount -ge 4 -and $avgDesc -ge 18)
        }
        'ultimate' {
            $threshComplete = ($mechCount -ge 15 -and $avgDesc -ge 40 -and $bilingualPct -ge 80 -and $mnemonicCount -ge 5)
            $threshNeeds = ($mechCount -ge 8 -and $avgDesc -ge 30)
        }
        default {
            $threshComplete = ($mechCount -ge 8 -and $avgDesc -ge 25 -and $bilingualPct -ge 80)
            $threshNeeds = ($mechCount -ge 4 -and $avgDesc -ge 15)
        }
    }
    if ($threshComplete) { $tier = $TIER_COMPLETE }
    elseif ($threshNeeds) { $tier = $TIER_NEEDS }
    $results += [PSCustomObject]@{
        id = $id
        name = $name
        nameEn = $nameEn
        type = $type
        players = $players
        lvl = $lvl
        expansion = $expansion
        boss_count = $bossCount
        mech_count = $mechCount
        avg_desc = $avgDesc
        bilingual_pct = $bilingualPct
        mnemonic_count = $mnemonicCount
        total_tips = $tipsCount
        role_tips = $roleTips
        has_primal_suffix = $hasPrimalSuffix
        has_zh_name = $hasZhName
        has_en_name = $hasEnName
        tier = $tier
    }
}

$results | Export-Csv $outCsv -NoTypeInformation -Encoding UTF8
"Audited $($results.Count) duty files"
"Saved: $outCsv"
""
"Tier distribution:"
$results | Group-Object tier | Sort-Object Name | Select-Object Name, Count | Format-Table -AutoSize
