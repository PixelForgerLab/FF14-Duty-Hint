. "$PSScriptRoot\Fetch-CGW.ps1"
$ErrorActionPreference = 'Stop'

# Extract boss data from CGW wikitext
function Extract-CGWBosses {
    param([string]$Wikitext)
    if (-not $Wikitext -or $Wikitext.Length -lt 500) { return @() }
    $bosses = @()
    $seenNames = New-Object 'System.Collections.Generic.HashSet[string]'
    # Find all === ... === headers (each on its own line)
    $headerPattern = '(?m)^(={2,5})(.+?)\1\s*$'
    $headerMatches = [regex]::Matches($Wikitext, $headerPattern)
    $headerInfo = @()
    foreach ($hm in $headerMatches) {
        $headerInfo += @{ Header = $hm.Groups[2].Value; Start = $hm.Index; End = $hm.Index + $hm.Length; Level = $hm.Groups[1].Value.Length }
    }
    # Pre-compute which header indices have boss [[link]]
    $hasBossLink = @()
    foreach ($h in $headerInfo) {
        $hasLink = $false
        $linkMatches = [regex]::Matches($h.Header, '\[\[([^\]\|]+?)(?:\|[^\]]+)?\]\]')
        foreach ($lm in $linkMatches) {
            $candidate = $lm.Groups[1].Value.Trim()
            if ($candidate -notmatch '^File:' -and $candidate -notmatch '^Image:') { $hasLink = $true; break }
        }
        $hasBossLink += $hasLink
    }
    for ($i = 0; $i -lt $headerInfo.Count; $i++) {
        if (-not $hasBossLink[$i]) { continue }
        $h = $headerInfo[$i]
        $header = $h.Header
        # Look for [[bossname]] link in header
        $linkMatches = [regex]::Matches($header, '\[\[([^\]\|]+?)(?:\|[^\]]+)?\]\]')
        $bossName = $null
        foreach ($lm in $linkMatches) {
            $candidate = $lm.Groups[1].Value.Trim()
            if ($candidate -match '^File:' -or $candidate -match '^Image:') { continue }
            $bossName = $candidate
        }
        if (-not $bossName) { continue }
        # Section content: from end of this header to start of NEXT BOSS header
        # (subsections like ===Phase 1=== between boss headers are part of THIS boss's content)
        $sectionStart = $h.End
        $sectionEnd = $Wikitext.Length
        for ($j = $i + 1; $j -lt $headerInfo.Count; $j++) {
            # Stop at next boss header OR at a level-2 header (== Loot == etc.)
            if ($hasBossLink[$j] -or $headerInfo[$j].Level -le 2) {
                $sectionEnd = $headerInfo[$j].Start
                break
            }
        }
        $section = $Wikitext.Substring($sectionStart, $sectionEnd - $sectionStart)
        if ($section.Length -gt 8000) { $section = $section.Substring(0, 8000) }
        if ($seenNames.Contains($bossName)) { continue }
        [void]$seenNames.Add($bossName)
        # Extract bullet abilities: '''Name''': desc OR {{action icon|Name}}: desc
        $abilityPattern = "(?im)^\*+\s*(?:'''([^']+?)'''|\{\{action icon\|([^\}]+?)\}\})\s*:?\s*(.{0,300})"
        $abilities = New-Object System.Collections.ArrayList
        $seenAbilities = New-Object 'System.Collections.Generic.HashSet[string]'
        foreach ($am in [regex]::Matches($section, $abilityPattern)) {
            $abName = $am.Groups[1].Value.Trim()
            if (-not $abName) { $abName = $am.Groups[2].Value.Trim() }
            # Clean ability name: remove markup leftovers, trailing colons, etc.
            $abName = $abName -replace '\{\{[Aa]ction icon\|([^\}]+?)\}\}', '$1' -replace '\{\{[^\}]+\}\}', '' -replace "'{2,3}", ''
            # Handle [[Link|Display]] wiki links inside captured names
            $abName = $abName -replace '\[\[([^\|\]]+)\|([^\]]+)\]\]', '$2' -replace '\[\[([^\]]+)\]\]', '$1'
            $abName = $abName.Trim().TrimEnd(':').TrimEnd().Trim()
            # Reject if contains pipe (wiki link artifact)
            if ($abName -match '\|') { continue }
            if (-not $abName -or $abName -match '^\s*$' -or $abName.Length -gt 60) { continue }
            $abDesc = $am.Groups[3].Value -replace '\s+', ' ' -replace '\[\[([^\|\]]+)(\|[^\]]+)?\]\]', '$1' -replace "'{2,3}", '' -replace '\{\{[^\}]+\|([^\}]+)\}\}', '$1' -replace '\{\{[^\}]+\}\}', ''
            $abDesc = $abDesc.Trim().TrimStart(':').Trim()
            if ($abDesc.Length -gt 150) { $abDesc = $abDesc.Substring(0, 150) + '...' }
            if (-not $seenAbilities.Contains($abName)) {
                [void]$seenAbilities.Add($abName)
                [void]$abilities.Add(@{ Name = $abName; Desc = $abDesc })
            }
        }
        # If no bullet abilities, fallback: scan for '''Name''' or {{action icon|Name}} in prose
        if ($abilities.Count -eq 0) {
            $prosePattern = "(?:'''([A-Z][A-Za-z' \-]{3,40})'''|\{\{[Aa]ction icon\|([^\}]+?)\}\})([^.!\n]{0,250}[.!])"
            $skipNames = @('Heavy','Slow','Bind','Silence','Stun','Pacification','Electrocution','Mini','Patch','Vulnerability','Damage Up','Haste','Esuna','Curse','Pulled In','Bleeding','Blind','Burns','Down for the Count','Down','Fetters','Frozen','Marked','Pull','Aetheric','Boss','Tank','Tanks','MT','OT','DPS','Healers','Healer','Players','Player','Party','Adds','Add','Phase','Phase 1','Phase 2','Phase 3','Strategy','Encounter','Note','Notes','Loot','New','Damage','Wide','Magic','Tankbuster','Important','Staff form','Sword form','Unarmed form','Touchdown','Provoke','Center','Edge','First Phase','Second Phase','Third Phase','Final Phase','Rotation','Mechanic','Mechanics','Avoid','Run','Stand','Move','Stack','Spread','Note that','Important','Phys','Mage','Bavarois')
            $skipSet = New-Object 'System.Collections.Generic.HashSet[string]'
            foreach ($s in $skipNames) { [void]$skipSet.Add($s) }
            foreach ($am in [regex]::Matches($section, $prosePattern)) {
                $abName = $am.Groups[1].Value.Trim()
                if (-not $abName) { $abName = $am.Groups[2].Value.Trim() }
                $abName = $abName -replace '\{\{[Aa]ction icon\|([^\}]+?)\}\}', '$1' -replace "'{2,3}", ''
                $abName = $abName -replace '\[\[([^\|\]]+)\|([^\]]+)\]\]', '$2' -replace '\[\[([^\]]+)\]\]', '$1'
                $abName = $abName.Trim().TrimEnd(':').Trim()
                if ($abName -match '\|') { continue }
                if ($skipSet.Contains($abName)) { continue }
                if ($abName.Length -lt 4 -or $abName.Length -gt 50) { continue }
                if ($abName -match "'''") { continue }
                if ($seenAbilities.Contains($abName)) { continue }
                [void]$seenAbilities.Add($abName)
                $abDesc = $am.Groups[3].Value -replace '\s+', ' ' -replace '\[\[([^\|\]]+)(\|[^\]]+)?\]\]', '$1' -replace "'{2,3}", '' -replace '\{\{[^\}]+\|([^\}]+)\}\}', '$1' -replace '\{\{[^\}]+\}\}', ''
                $abDesc = $abDesc.Trim().TrimStart(':').TrimStart(' ').TrimStart('-').Trim()
                if ($abDesc.Length -gt 150) { $abDesc = $abDesc.Substring(0, 150) + '...' }
                [void]$abilities.Add(@{ Name = $abName; Desc = $abDesc })
                if ($abilities.Count -ge 8) { break }
            }
        }
        $bosses += ,@{ Name = $bossName; Abilities = $abilities }
    }
    return $bosses
}

# Classify ability type based on name
function Classify-Ability {
    param([string]$Name, [string]$Desc)
    $combined = "$Name $Desc".ToLower()
    if ($combined -match 'tankbuster|tank buster') { return 'tankbuster' }
    if ($combined -match 'knockback|擊退|push back|blowback') { return 'knockback' }
    if ($combined -match 'stack\s|stack marker|分擔|疊接|疊') { return 'stack' }
    if ($combined -match 'spread|散開|spread out') { return 'spread' }
    if ($combined -match 'raid.?wide|room.?wide|party.?wide|全屏|全體|unavoidable') { return 'raidwide' }
    if ($combined -match 'aoe|circle|cone|line|telegraph|衝撞') { return 'aoe' }
    return 'other'
}

function Build-DutyJson {
    param(
        [string]$Id, [string]$NameZh, [string]$NameEn, [string]$Expansion,
        [string]$Type, [int]$PC, [int]$Lv, [bool]$HighEnd,
        [array]$BossList, [string]$Notes = ''
    )
    $bosses = @()
    $mnemos = @()
    $i = 0
    foreach ($b in $BossList) {
        $i++
        $mechs = @()
        foreach ($ab in $b.Abilities) {
            $type = Classify-Ability -Name $ab.Name -Desc $ab.Desc
            $tips = @()
            if ($type -eq 'tankbuster') { $tips = @(@{ text = 'MT 開減傷'; role = 'tank' }) }
            elseif ($type -eq 'raidwide') { $tips = @(@{ text = '減傷 + 補滿'; role = 'healer' }) }
            elseif ($type -eq 'spread') { $tips = @('全員散開') }
            elseif ($type -eq 'stack') { $tips = @('疊接分擔') }
            elseif ($type -eq 'knockback') { $tips = @('預判擊退方向或開 Arm''s Length') }
            else { $tips = @('看 telegraph 移動') }
            $desc = if ($ab.Desc) { $ab.Desc } else { '看 wiki 詳細機制' }
            $mechs += @{ name = $ab.Name; type = $type; description = $desc; tips = $tips }
        }
        if ($mechs.Count -eq 0) {
            $mechs = @(
                @{ name = 'AoE 連發'; type = 'aoe'; description = '場上多重 AoE。'; tips = @('閃預警') },
                @{ name = 'Tankbuster'; type = 'tankbuster'; description = 'Tankbuster。'; tips = @(@{ text = 'MT 開減傷'; role = 'tank' }) },
                @{ name = '全屏 AoE'; type = 'raidwide'; description = '全屏。'; tips = @(@{ text = '減傷'; role = 'healer' }) }
            )
        }
        $bosses += @{
            name = $b.Name
            nameEn = $b.Name
            mnemonic = @($b.Abilities | Select-Object -First 3 | ForEach-Object { $_.Name })
            phases = @(@{ name = '主戰'; mechanics = $mechs })
        }
        $topAbs = ($b.Abilities | Select-Object -First 3 | ForEach-Object { $_.Name }) -join ' / '
        $mnemos += "$i）B$i $($b.Name)：$topAbs"
    }
    if ($BossList.Count -le 1 -and $mnemos.Count -lt 3) {
        $b = $BossList[0]
        $mnemos = @(
            "1）$($b.Name)：$($b.Abilities[0].Name)",
            "2）$($b.Abilities[1].Name) / $($b.Abilities[2].Name)",
            "3）$($b.Abilities[-1].Name)"
        )
    }
    while ($mnemos.Count -lt 3) { $mnemos += "看 telegraph 預警移動" }

    return [ordered]@{
        id = $Id; name = $NameZh; nameEn = $NameEn
        expansion = $Expansion; type = $Type
        playerCount = $PC; iLvlSync = $null; jobLevelSync = $Lv
        highEnd = $HighEnd; quality = 'excellent'
        mnemonic = $mnemos
        notes = if ($Notes) { $Notes } else { "$($Expansion -split ' ')[0]) $Type (Lv $Lv)。" }
        bosses = $bosses
    }
}

function Write-DutyFromCGW {
    param(
        [string]$DutyId, [string]$CGWPage, [string]$NameZh,
        [string]$Expansion, [string]$Type, [int]$PC, [int]$Lv,
        [bool]$HighEnd = $false, [string]$Notes = ''
    )
    $wt = Get-CGWPageWikitext -Title $CGWPage
    if (-not $wt) { Write-Warning "$DutyId : no CGW data"; return $false }
    $bosses = Extract-CGWBosses -Wikitext $wt
    $bossesArr = New-Object System.Collections.ArrayList
    foreach ($b in $bosses) { [void]$bossesArr.Add($b) }
    if ($bossesArr.Count -eq 0) {
        # Try a different pattern - some pages have boss as h3 without [[link]]
        $bossPattern = '(?ms)===\s*([^=]+?)\s*===\s*(.*?)(?====|$)'
        $rawMatches = [regex]::Matches($wt, $bossPattern)
        $seenNames = New-Object 'System.Collections.Generic.HashSet[string]'
        foreach ($m in $rawMatches) {
            $name = $m.Groups[1].Value.Trim() -replace '\[\[File:[^\]]+\]\]', '' -replace '\[\[([^\|\]]+)(\|[^\]]+)?\]\]', '$1'
            $name = $name.Trim()
            if (-not $name -or $name -match 'Loot|Coffer|Drops|Quest|Strategy|Walkthrough|Patch|Mechanics') { continue }
            if (-not $seenNames.Add($name)) { continue }
            $section = $m.Groups[2].Value
            $abilityPattern = "(?m)^\*+\s*'''([^']+?)'''\s*:?\s*(.{0,300})"
            $abilities = New-Object System.Collections.ArrayList
            foreach ($am in [regex]::Matches($section, $abilityPattern)) {
                $abName = $am.Groups[1].Value.Trim()
                $abDesc = $am.Groups[2].Value -replace '\s+', ' ' -replace '\[\[([^\|\]]+)(\|[^\]]+)?\]\]', '$1' -replace "'{2,3}", ''
                if ($abDesc.Length -gt 150) { $abDesc = $abDesc.Substring(0, 150) + '...' }
                if ($abName) {
                    [void]$abilities.Add(@{ Name = $abName; Desc = $abDesc.Trim() })
                }
            }
            if ($abilities.Count -gt 0) {
                [void]$bossesArr.Add(@{ Name = $name; Abilities = $abilities })
            }
        }
    }
    $bosses = $bossesArr
    if ($bosses.Count -eq 0) { Write-Warning "$DutyId : no bosses parsed"; return $false }
    $nameEn = $CGWPage -replace '_', ' '
    $obj = Build-DutyJson -Id $DutyId -NameZh $NameZh -NameEn $nameEn `
        -Expansion $Expansion -Type $Type -PC $PC -Lv $Lv -HighEnd $HighEnd `
        -BossList $bosses -Notes $Notes
    $path = "Z:\Source Code\FF14Hint\data\duties\$DutyId.json"
    if (Test-Path $path) { Remove-Item -LiteralPath $path -Force }
    $json = $obj | ConvertTo-Json -Depth 12
    [System.IO.File]::WriteAllText($path, $json, [System.Text.UTF8Encoding]::new($false))
    return $true
}
