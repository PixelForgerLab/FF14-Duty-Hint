<#
.SYNOPSIS
    為 UCoB / UWU / TEA 的 universal tips 自動加上角色標記。

.DESCRIPTION
    根據文字模式（含「主 T」「奶開」「DPS」等）將純字串 tip 升級為 { text, role } 物件。
#>
[CmdletBinding()]
param()

$ErrorActionPreference = "Stop"
$base = "Z:\Source Code\FF14Hint\data\duties"
$utf8 = [System.Text.UTF8Encoding]::new($false)

# 角色判斷：依優先級回傳第一個匹配的 role；找不到 → universal
function Infer-Role {
    param([string]$Text)

    # Tank 模式
    if ($Text -match "主\s?T|副\s?T|兩\s?T|MT|ST|盾陣|原初解放|戰士的|騎士的|暗黑騎士|絕槍戰士|降低敵意|拉?仇恨|挑釁|接力坦|大型減傷|盾.*減傷|減傷.*盾|debuff 疊|對換仇恨|switch|接\s?dive|接\s?cleave|接[\s\u4e00-\u9fff]*段") {
        return "tank"
    }
    # Healer 模式
    if ($Text -match "奶開|奶補|奶媽|奶連|奶留|奶滿|奶接|救護車|AoE\s?加血|AoE\s?治療|AoE\s?減傷.*奶|預先\s?AoE|盾.*奶|奶.*盾|加血|滿血治療|準備.*治療|釋放.*治療") {
        return "healer"
    }
    # DPS 模式
    if ($Text -match "^DPS\s|DPS check|DPS 比拼|DPS 必須|DPS 在|爆發|連續輸出|GCD|保留爆發|秒傷|in 9 分") {
        return "dps"
    }
    return $null  # universal
}

function Update-Tips {
    param([Parameter(Mandatory)] [Object[]]$Tips)

    $newTips = @()
    foreach ($tip in $Tips) {
        if ($tip -is [string]) {
            $role = Infer-Role -Text $tip
            if ($role) {
                $newTips += [ordered]@{ text = $tip; role = $role }
            } else {
                $newTips += $tip
            }
        } else {
            # 已經是 object，保持原樣
            $obj = [ordered]@{}
            foreach ($prop in $tip.PSObject.Properties) {
                $obj[$prop.Name] = $prop.Value
            }
            $newTips += $obj
        }
    }
    return $newTips
}

$files = @("unending_coil_of_bahamut_ultimate.json", "weapons_refrain_ultimate.json", "epic_of_alexander_ultimate.json")

foreach ($file in $files) {
    $path = Join-Path $base $file
    Write-Host "Processing: $file" -ForegroundColor Cyan

    $content = [System.IO.File]::ReadAllText($path, $utf8)
    $duty = $content | ConvertFrom-Json

    $totalUpgraded = 0
    foreach ($boss in $duty.bosses) {
        foreach ($phase in $boss.phases) {
            foreach ($mech in $phase.mechanics) {
                $before = $mech.tips
                $after = Update-Tips -Tips $before
                $upgraded = 0
                for ($i = 0; $i -lt $after.Count; $i++) {
                    if ($after[$i] -isnot [string]) { $upgraded++ }
                }
                if ($upgraded -gt 0) {
                    $mech.tips = $after
                    $totalUpgraded += $upgraded
                }
            }
        }
    }

    # 寫回 JSON (整份重組保持欄位順序)
    $reordered = [ordered]@{}
    foreach ($prop in @('id','name','nameEn','expansion','type','playerCount','iLvlSync','jobLevelSync','highEnd','quality','mnemonic','notes','bosses')) {
        if ($duty.PSObject.Properties.Match($prop).Count -gt 0) {
            $reordered[$prop] = $duty.$prop
        }
    }
    $json = $reordered | ConvertTo-Json -Depth 15
    $json = [System.Text.RegularExpressions.Regex]::Replace($json, '":\s{2,}', '": ')
    [System.IO.File]::WriteAllText($path, $json, $utf8)
    Write-Host "  Upgraded $totalUpgraded tips" -ForegroundColor Green
}

Write-Host ""
Write-Host "Done!" -ForegroundColor Green
