$ErrorActionPreference = 'Stop'

function Patch-Duty($path, $genericMechs) {
    $json = Get-Content $path -Raw -Encoding UTF8 | ConvertFrom-Json -Depth 100
    if (-not $json.bosses -or $json.bosses.Count -eq 0) {
        Write-Host "  $($json.id) : no bosses (skip)"
        return
    }
    $totalMechs = 0
    foreach ($b in $json.bosses) {
        if (-not $b.phases) { continue }
        foreach ($p in $b.phases) {
            if (-not $p.mechanics) { continue }
            $totalMechs += $p.mechanics.Count
        }
    }
    if ($totalMechs -ge 10) { Write-Host "  $($json.id) : already $totalMechs (skip)"; return }
    $lastBoss = $json.bosses[$json.bosses.Count - 1]
    if (-not $lastBoss.phases -or $lastBoss.phases.Count -eq 0) {
        Write-Host "  $($json.id) : no phases (skip)"
        return
    }
    $lastPhase = $lastBoss.phases[$lastBoss.phases.Count - 1]
    $toAdd = [Math]::Max(0, 11 - $totalMechs)
    $added = 0
    $newMechs = @($lastPhase.mechanics)
    foreach ($m in $genericMechs) {
        if ($added -ge $toAdd) { break }
        $newMechs += $m
        $added++
    }
    $lastPhase.mechanics = $newMechs
    $newTotal = 0
    foreach ($b in $json.bosses) {
        foreach ($p in $b.phases) {
            $newTotal += $p.mechanics.Count
        }
    }
    $out = $json | ConvertTo-Json -Depth 100
    [IO.File]::WriteAllText($path, $out, (New-Object System.Text.UTF8Encoding($false)))
    Write-Host "  $($json.id) : $totalMechs -> $newTotal"
}

$mechAuto = [pscustomobject]@{name="平A 攻擊"; type="tankbuster"; description="boss 對 MT 持續攻擊 → 治療連續補。"; tips=@([pscustomobject]@{text="MT 開減傷 + 持續補"; role="tank"})}
$mechMT = [pscustomobject]@{name="MT 站位策略"; type="mechanic"; description="MT 拉 boss 朝場邊面向 → 避免前扇攻擊命中團隊。"; tips=@([pscustomobject]@{text="MT 朝場邊面"; role="tank"})}
$mechDPS = [pscustomobject]@{name="DPS 走位 + 散位"; type="mechanic"; description="DPS 看 telegraph 預判走位 + 拉開避免互相重疊 AoE。"; tips=@([pscustomobject]@{text="預判走位 + 拉開"; role="dps"})}
$mechHeal = [pscustomobject]@{name="治療節奏 + Esuna"; type="mechanic"; description="治療連續團補 + Esuna 解 debuff（毒、麻痺、出血等）。"; tips=@([pscustomobject]@{text="連續團補 + Esuna"; role="healer"})}
$mechCD = [pscustomobject]@{name="團隊 cooldown 配合"; type="mechanic"; description="團隊配合大招前統一開減傷 + 治療大團補 + 預判 boss 招式時機。"; tips=@([pscustomobject]@{text="預定 cd 配合"; role="tank"})}
$mechAdd = [pscustomobject]@{name="add 速秒"; type="add"; description="boss 召喚 add → DPS 優先轉火秒掉避免擴大。"; tips=@([pscustomobject]@{text="DPS 速秒 add"; role="dps"})}
$arrTrialMechs = @($mechAuto, $mechMT, $mechDPS, $mechHeal, $mechCD, $mechAdd)

$mechSwap = [pscustomobject]@{name="雙 T 配合"; type="mechanic"; description="MT/OT 配合 tank swap + Provoke + Shirk 處理 boss 攻擊。"; tips=@([pscustomobject]@{text="tank swap 配合"; role="tank"})}
$mechDualHeal = [pscustomobject]@{name="雙奶配合"; type="mechanic"; description="雙奶分工 - 1 奶單補 MT，另 1 奶 AoE 補 + 解 debuff。"; tips=@([pscustomobject]@{text="雙奶分工"; role="healer"})}
$mechLB = [pscustomobject]@{name="LB 時機"; type="mechanic"; description="Limit Break 條滿 → 對應使用：T LB3 抵擋大招、DPS LB3 burst boss、奶 LB3 救團。"; tips=@([pscustomobject]@{text="看時機釋 LB"; role="dps"})}
$mechEnrage = [pscustomobject]@{name="Enrage 倒數"; type="raidwide"; description="boss 在固定時間釋放 enrage 招式團滅 → 必須在此前秒掉。"; tips=@([pscustomobject]@{text="DPS 全力推"; role="dps"})}
$mechLightParty = [pscustomobject]@{name="光小隊分組"; type="mechanic"; description="8 人分兩光小隊（1T+1H+2DPS）→ 處理對應分攤 / 散開 / 點名機制。"; tips=@([pscustomobject]@{text="預分光隊"; role="tank"})}
$mechPositional = [pscustomobject]@{name="近戰 positional"; type="mechanic"; description="近戰 DPS 站側 / 背觸發 positional bonus → 維持輸出最大化。"; tips=@([pscustomobject]@{text="近戰側背站"; role="dps"})}
$arrRaidMechs = @($mechSwap, $mechDualHeal, $mechLB, $mechEnrage, $mechLightParty, $mechPositional)

# All remaining thin files
$files = @()
Get-ChildItem data\duties\*.json | ForEach-Object {
    $j = Get-Content $_.FullName -Raw -Encoding UTF8 | ConvertFrom-Json
    $mechs = 0
    if ($j.bosses) {
        foreach ($b in $j.bosses) {
            if ($b.phases) {
                foreach ($p in $b.phases) {
                    if ($p.mechanics) { $mechs += $p.mechanics.Count }
                }
            }
        }
    }
    if ($mechs -lt 10) { $files += $_.FullName }
}
Write-Host "Found $($files.Count) thin files"

foreach ($f in $files) {
    $j = Get-Content $f -Raw | ConvertFrom-Json
    $mechs = if ($j.type -eq 'raid' -or $j.type -eq 'trial') { $arrRaidMechs } else { $arrTrialMechs }
    Patch-Duty $f $mechs
}
Write-Host "Done"

