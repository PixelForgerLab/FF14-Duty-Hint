. "$PSScriptRoot\lib\Fetch-CGW.ps1"

# All remaining HW pages: trials, alliance, Alexander
$pages = @(
    # HW trials
    'The_Limitless_Blue', 'The_Limitless_Blue_(Extreme)',
    'Thok_ast_Thok_(Hard)', 'Thok_ast_Thok_(Extreme)',
    'The_Singularity_Reactor', 'The_Final_Steps_of_Faith',
    'The_Minstrel%27s_Ballad%3A_Thordan%27s_Reign',
    'The_Minstrel%27s_Ballad%3A_Nidhogg%27s_Rage',
    'Containment_Bay_S1T7', 'Containment_Bay_S1T7_(Extreme)',
    'Containment_Bay_P1T6', 'Containment_Bay_P1T6_(Extreme)',
    'Containment_Bay_Z1T9', 'Containment_Bay_Z1T9_(Extreme)',
    # HW alliance
    'The_Void_Ark', 'The_Weeping_City_of_Mhach', 'Dun_Scaith',
    # Alexander Normal
    'Alexander_-_The_Fist_of_the_Father',
    'Alexander_-_The_Cuff_of_the_Father',
    'Alexander_-_The_Arm_of_the_Father',
    'Alexander_-_The_Burden_of_the_Father',
    'Alexander_-_The_Fist_of_the_Son',
    'Alexander_-_The_Cuff_of_the_Son',
    'Alexander_-_The_Arm_of_the_Son',
    'Alexander_-_The_Burden_of_the_Son',
    'Alexander_-_The_Eyes_of_the_Creator',
    'Alexander_-_The_Breath_of_the_Creator',
    'Alexander_-_The_Heart_of_the_Creator',
    'Alexander_-_The_Soul_of_the_Creator',
    # Alexander Savage
    'Alexander_-_The_Fist_of_the_Father_(Savage)',
    'Alexander_-_The_Cuff_of_the_Father_(Savage)',
    'Alexander_-_The_Arm_of_the_Father_(Savage)',
    'Alexander_-_The_Burden_of_the_Father_(Savage)',
    'Alexander_-_The_Fist_of_the_Son_(Savage)',
    'Alexander_-_The_Cuff_of_the_Son_(Savage)',
    'Alexander_-_The_Arm_of_the_Son_(Savage)',
    'Alexander_-_The_Burden_of_the_Son_(Savage)',
    'Alexander_-_The_Eyes_of_the_Creator_(Savage)',
    'Alexander_-_The_Breath_of_the_Creator_(Savage)',
    'Alexander_-_The_Heart_of_the_Creator_(Savage)',
    'Alexander_-_The_Soul_of_the_Creator_(Savage)'
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
