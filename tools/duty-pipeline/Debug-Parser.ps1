. "$PSScriptRoot\lib\CGW-Parser.ps1"
$wt = Get-Content "Z:\Source Code\FF14Hint\tools\duty-pipeline\data\cache\cgw\Syrcus_Tower.wikitext" -Raw -Encoding UTF8
$bosses = Extract-CGWBosses -Wikitext $wt
Write-Host "Found $($bosses.Count) bosses"
foreach ($b in $bosses) {
    Write-Host "[$($b.Name)] abilities=$($b.Abilities.Count)"
    foreach ($a in $b.Abilities) {
        Write-Host "  - $($a.Name): $($a.Desc.Substring(0, [Math]::Min(80, $a.Desc.Length)))"
    }
}
