. "$PSScriptRoot\lib\Fetch-CGW.ps1"
$pages = @('Hell_on_Rails','Hell_on_Rails_(Extreme)',"Alzadaal's_Legacy",'The_Aetherfont','Lapis_Manalis','Ktisis_Hyperboreia','Smileton','The_Stigma_Dreamscape','The_Tower_of_Babil','Vanaspati','The_Mothercrystal','Asphodelos%3A_The_First_Circle','Worqor_Lar_Dor','Keeper_of_the_Lake','Alexander_-_The_Cuff_of_the_Father','Alexander_-_The_Cuff_of_the_Father_%28Savage%29','Akh_Afah_Amphitheatre','The_Binding_Coil_of_Bahamut_-_Turn_3','Special_Event_II','Special_Event_I')
foreach ($p in $pages) {
    $title = [System.Uri]::UnescapeDataString($p)
    $wt = Get-CGWPageWikitext -Title $title -ForceRefresh
    if ($wt) { Write-Host "[OK] $title ($($wt.Length))" } else { Write-Host "[FAIL] $title" }
}
