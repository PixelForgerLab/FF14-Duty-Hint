. "$PSScriptRoot\lib\CGW-Parser.ps1"
$wt = Get-Content "Z:\Source Code\FF14Hint\tools\duty-pipeline\data\cache\cgw\Syrcus_Tower.wikitext" -Raw -Encoding UTF8

# Manually replicate Extract-CGWBosses with debug
$bossPattern = '(?ms)===\s*([^=]*?\[\[[^\]\|]+(?:\|[^\]]+)?\]\][^=]*?)\s*===\s*(.*?)(?====|$)'
$matches = [regex]::Matches($wt, $bossPattern)
Write-Host "Found $($matches.Count) boss sections"
foreach ($m in $matches | Select-Object -First 3) {
    $header = $m.Groups[1].Value
    $section = $m.Groups[2].Value
    Write-Host ""
    Write-Host "Header: $($header.Substring(0, [Math]::Min(80, $header.Length)))"
    Write-Host "Section length: $($section.Length)"
    Write-Host "First 150 chars: $($section.Substring(0, [Math]::Min(150, $section.Length)))"
    # Test prose pattern
    $prosePattern = "(?:'''([A-Z][A-Za-z'-][^']{2,40})'''|\{\{action icon\|([^\}]+?)\}\})([^.!\n]{0,250}[.!])"
    $proseMatches = [regex]::Matches($section, $prosePattern)
    Write-Host "Prose matches: $($proseMatches.Count)"
    foreach ($pm in $proseMatches | Select-Object -First 3) {
        Write-Host "  - $($pm.Groups[1].Value)"
    }
}
