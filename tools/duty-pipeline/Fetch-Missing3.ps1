. "$PSScriptRoot\lib\Fetch-CGW.ps1"
foreach ($p in @('The_Meso_Terminal','Cuff_of_the_Father','The_Cuff_of_the_Father','Alexander_-_The_Cuff_of_the_Father','Alexander_Gordias','Special_Event_(I)','Special_Event_(II)')) {
    $wt = Get-CGWPageWikitext -Title $p -ForceRefresh
    if ($wt) { Write-Host "[OK] $p ($($wt.Length))" } else { Write-Host "[FAIL] $p" }
}
