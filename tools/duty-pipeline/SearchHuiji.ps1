. "$PSScriptRoot\lib\Fetch-Huiji.ps1"
# Use search to find correct page names
foreach ($kw in @('大地之臍','大地之脐','阿拉米格','复制工厂','复制工厂的伪造蓝色万灵药','复制公司','人偶军事基地','范式之塔','银晶塔')) {
    $results = Search-HuijiPages -Keyword $kw -Limit 5
    Write-Host "=== $kw ==="
    if ($results) { $results | ForEach-Object { Write-Host "  $_" } }
    else { Write-Host "  (no results)" }
}
