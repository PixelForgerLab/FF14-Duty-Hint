. "$PSScriptRoot\lib\Fetch-Huiji.ps1"
# Search for proper titles
$keywords = @('泰坦','大地之脐','大地之臍','纳维尔','范式','范式之塔','光之复活','银晶塔','水晶塔','古代人','黑暗之世界','暗之世界','塔木坦拉','塔木','银钟','銅鈴','哈罗夕','哈拉塔利','千狱','瓦那地斯','卡恩','沉没的','石之家','德泽梅亚','古巴尔','哈克','哈克庄园','流浪者皇宫','法洛斯','薩斯塔','萨斯塔','基姆利特','基姆利特暗黑地','邪教驻地','无限城','次元的狹縫','次元的狭缝','凯沛兰宁多塔')
foreach ($kw in $keywords) {
    $results = Search-HuijiPages -Keyword $kw -Limit 3
    if ($results) {
        Write-Host "$kw : $($results -join ' | ')"
    } else {
        Write-Host "$kw : (no)"
    }
}
