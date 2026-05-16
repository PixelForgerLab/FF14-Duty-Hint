. "$PSScriptRoot\lib\Fetch-CGW.ps1"
$pages = @('The_Keeper_of_the_Lake','The_Akh_Afah_Amphitheatre','The_Akh_Afah_Amphitheatre_(Hard)','The_Akh_Afah_Amphitheatre_(Extreme)','Alzadaal%27s_Legacy_(Duty)','The_Strayborough_Deadwalk','The_Skydeep_Cenote','The_Interphos','The_Clyteum','The_Ageless_Necropolis','The_Windward_Wilds','The_Windward_Wilds_(Extreme)','Gilded_Araya_(Duty)','The_Gilded_Araya','The_Howling_Eye','The_Howling_Eye_(Hard)','The_Bowl_of_Embers','The_Bowl_of_Embers_(Extreme)')
foreach ($p in $pages) {
    $title = [System.Uri]::UnescapeDataString($p)
    $wt = Get-CGWPageWikitext -Title $title -ForceRefresh
    if ($wt) { Write-Host "[OK] $title ($($wt.Length))" } else { Write-Host "[FAIL] $title" }
}
