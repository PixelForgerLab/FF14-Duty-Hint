$wt = Get-Content "Z:\Source Code\FF14Hint\tools\duty-pipeline\data\cache\cgw\Syrcus_Tower.wikitext" -Raw -Encoding UTF8
$pat = '(===+)\s*([^\r\n=]+?)\s*\1'
$matches = [regex]::Matches($wt, $pat)
Write-Host "Matches: $($matches.Count)"
foreach ($m in $matches | Select-Object -First 15) {
    Write-Host "  Level $($m.Groups[1].Value.Length) at $($m.Index): '$($m.Groups[2].Value)'"
}
