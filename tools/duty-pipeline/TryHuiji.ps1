. "$PSScriptRoot\lib\Fetch-Huiji.ps1"
foreach ($title in @('大地之臍','大地之脐','阿拉米格','复制工厂','复制工厂战','银晶塔')) {
    Write-Host "=== $title ==="
    $wt = Get-HuijiPageWikitext -Title $title
    Write-Host "  main: $($wt.Length) chars"
    $wtB = Get-HuijiPageWikitext -Title "$title/B"
    Write-Host "  B: $($wtB.Length) chars"
}
