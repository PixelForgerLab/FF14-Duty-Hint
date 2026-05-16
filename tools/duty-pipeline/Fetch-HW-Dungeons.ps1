. "$PSScriptRoot\lib\Fetch-CGW.ps1"

# HW dungeon CGW page titles
$pages = @(
    'The_Dusk_Vigil',
    'Sohm_Al',
    'The_Aery',
    'The_Vault',
    'The_Great_Gubal_Library',
    'The_Aetherochemical_Research_Facility',
    'Neverreap',
    'The_Fractal_Continuum',
    'Sohr_Khai',
    'Xelphatol',
    'The_Antitower',
    'Baelsar%27s_Wall',
    'Sohm_Al_(Hard)',
    'Haukke_Manor_(Hard)',
    'The_Lost_City_of_Amdapor_(Hard)',
    'Hullbreaker_Isle_(Hard)',
    'Pharos_Sirius_(Hard)',
    'The_Great_Gubal_Library_(Hard)',
    "Saint_Mocianne%27s_Arboretum"
)

foreach ($p in $pages) {
    $title = [System.Uri]::UnescapeDataString($p)
    Write-Host "Fetching: $title"
    $wt = Get-CGWPageWikitext -Title $title
    if ($wt) {
        Write-Host "  cached ($($wt.Length) chars)"
    } else {
        Write-Host "  FAILED"
    }
}
