. "$PSScriptRoot\lib\Fetch-CGW.ps1"

# ARR + late patch DT pages
$pages = @(
    # ARR MSQ dungeons
    'Sastasha_(Hard)', 'The_Tam-Tara_Deepcroft', 'The_Tam-Tara_Deepcroft_(Hard)',
    'Copperbell_Mines', 'Copperbell_Mines_(Hard)',
    'Halatali', 'Halatali_(Hard)',
    'The_Thousand_Maws_of_Toto-Rak',
    'Haukke_Manor',
    "Brayflox%27s_Longstop", "Brayflox%27s_Longstop_(Hard)",
    'The_Sunken_Temple_of_Qarn', 'The_Sunken_Temple_of_Qarn_(Hard)',
    "Cutter%27s_Cry",
    'The_Stone_Vigil', 'The_Stone_Vigil_(Hard)',
    'Dzemael_Darkhold',
    'The_Aurum_Vale',
    "The_Wanderer%27s_Palace", "The_Wanderer%27s_Palace_(Hard)",
    'Castrum_Meridianum', 'The_Praetorium',
    'Amdapor_Keep', 'Amdapor_Keep_(Hard)',
    'Pharos_Sirius',
    'The_Lost_City_of_Amdapor',
    'Hullbreaker_Isle',
    'Snowcloak',
    'Keeper_of_the_Lake',
    # ARR trials - primal series
    'Bowl_of_Embers', 'Bowl_of_Embers_(Hard)', 'Bowl_of_Embers_(Extreme)',
    'Howling_Eye', 'Howling_Eye_(Hard)', 'Howling_Eye_(Extreme)',
    'The_Navel', 'The_Navel_(Hard)', 'The_Navel_(Extreme)',
    'The_Whorleater_(Hard)', 'The_Whorleater_(Extreme)',
    'The_Striking_Tree_(Hard)', 'The_Striking_Tree_(Extreme)',
    'Akh_Afah_Amphitheatre_(Hard)', 'Akh_Afah_Amphitheatre_(Extreme)',
    'Thornmarch_(Hard)', 'Thornmarch_(Extreme)',
    'A_Relic_Reborn%3A_The_Chimera', 'A_Relic_Reborn%3A_The_Hydra',
    'Battle_on_the_Big_Bridge', 'Battle_in_the_Big_Keep',
    "The_Dragon%27s_Neck", "The_Steps_of_Faith",
    'Chrysalis', "Urth%27s_Fount",
    "The_Minstrel%27s_Ballad%3A_Ultima%27s_Bane",
    'Porta_Decumana',
    # ARR raids - Coil + Crystal Tower
    'The_Binding_Coil_of_Bahamut_-_Turn_1', 'The_Binding_Coil_of_Bahamut_-_Turn_2',
    'The_Binding_Coil_of_Bahamut_-_Turn_3', 'The_Binding_Coil_of_Bahamut_-_Turn_4',
    'The_Binding_Coil_of_Bahamut_-_Turn_5',
    'The_Second_Coil_of_Bahamut_-_Turn_1', 'The_Second_Coil_of_Bahamut_-_Turn_2',
    'The_Second_Coil_of_Bahamut_-_Turn_3', 'The_Second_Coil_of_Bahamut_-_Turn_4',
    'The_Second_Coil_of_Bahamut_(Savage)_-_Turn_1',
    'The_Second_Coil_of_Bahamut_(Savage)_-_Turn_2',
    'The_Second_Coil_of_Bahamut_(Savage)_-_Turn_3',
    'The_Second_Coil_of_Bahamut_(Savage)_-_Turn_4',
    'The_Final_Coil_of_Bahamut_-_Turn_1', 'The_Final_Coil_of_Bahamut_-_Turn_2',
    'The_Final_Coil_of_Bahamut_-_Turn_3', 'The_Final_Coil_of_Bahamut_-_Turn_4',
    'The_Labyrinth_of_the_Ancients', 'Syrcus_Tower', 'The_World_of_Darkness',
    # Late patch DT (only ones missing)
    'Strayborough_Deadwalk', 'The_Underkeep', 'Vanguard', 'Mistwake',
    'Skydeep_Cenote', 'Clyteum', 'Meso_Terminal',
    'Hell%27s_on_Rails', "Hell%27s_on_Rails_(Extreme)",
    'Windward_Wilds', 'Windward_Wilds_(Extreme)',
    'Ageless_Necropolis', 'Interphos', 'The_Unmaking',
    "The_Minstrel%27s_Ballad%3A_Sphene%27s_Burden",
    'Jeuno%3A_The_First_Walk', 'San_d%27Oria%3A_The_Second_Walk',
    'Windurst%3A_The_Third_Walk',
    'AAC_Heavyweight_M1',
    'AlzadaalAlzadaal%27s_Legacy',
    "Gilded_Araya"
)

foreach ($p in $pages) {
    $title = [System.Uri]::UnescapeDataString($p)
    $wt = Get-CGWPageWikitext -Title $title
    if ($wt) {
        Write-Host "[OK] $title ($($wt.Length))"
    } else {
        Write-Host "[FAIL] $title"
    }
}
