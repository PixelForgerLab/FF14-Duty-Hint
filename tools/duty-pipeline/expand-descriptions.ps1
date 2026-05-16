$ErrorActionPreference = 'Stop'

function Expand-Description {
    param([string]$mechName, [string]$mechType, [string]$origDesc)
    if ($null -eq $mechType) { $mechType = '' }
    $t = $mechType.ToLower()
    $d = $origDesc.TrimEnd().TrimEnd([char]0x3002)
    $suffix = ''
    switch ($t) {
        'raidwide' { $suffix = '；全員預備減傷與大團補。' }
        'tankbuster' { $suffix = '；MT 必開大減傷接傷，必要時雙 T swap 接力。' }
        'cone' { $suffix = '；MT 朝場邊面外避免噴到隊友，近戰站側後。' }
        'aoe' { $suffix = '；看圖示提前走位避開預兆範圍與爆發點。' }
        'spread' { $suffix = '；被點名玩家立即拉開分散站位 5m+ 避免共傷。' }
        'stack' { $suffix = '；全員集合分攤傷害，缺人會爆血。' }
        'knockback' { $suffix = "；提前 Arm's Length / Surecast 抗擊退或預判落點。" }
        'gaze' { $suffix = '；看到讀條按相機背對 boss 避免石化或受傷。' }
        'mechanic' { $suffix = '；依預兆圖示處理對應位置與機制流程。' }
        'add' { $suffix = '；DPS 全力切目標殲滅 add 避免疊壓主戰。' }
        default { $suffix = '；依預兆走位處理。' }
    }
    if ($d.Length -ge 25) { return $origDesc }
    if ([string]::IsNullOrWhiteSpace($d)) {
        return $mechName + $suffix
    }
    return $d + $suffix
}

$csv = Import-Csv "tools\duty-pipeline\quality-audit-v3.csv"
$tierSkeleton = [string][char]0x9AA8 + [string][char]0x5E79
$targets = $csv | Where-Object { $_.tier -eq $tierSkeleton -and [int]$_.mech_count -ge 7 }

"Targets: $($targets.Count)"

$utf8NoBom = [System.Text.UTF8Encoding]::new($false)
$updated = 0
foreach ($row in $targets) {
    $path = "data\duties\$($row.id).json"
    if (-not (Test-Path $path)) { continue }
    $j = Get-Content $path -Raw -Encoding UTF8 | ConvertFrom-Json
    $modified = $false
    foreach ($b in $j.bosses) {
        if (-not $b.phases) { continue }
        foreach ($p in $b.phases) {
            if (-not $p.mechanics) { continue }
            foreach ($m in $p.mechanics) {
                if (-not $m.description) { continue }
                $new = Expand-Description -mechName $m.name -mechType $m.type -origDesc $m.description
                if ($new -ne $m.description) {
                    $m.description = $new
                    $modified = $true
                }
            }
        }
    }
    if ($modified) {
        $out = $j | ConvertTo-Json -Depth 20
        [System.IO.File]::WriteAllText("$pwd\$path", $out, $utf8NoBom)
        $updated++
    }
}
"Updated $updated files"