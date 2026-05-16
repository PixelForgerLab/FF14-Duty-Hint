. "$PSScriptRoot\lib\CGW-Parser.ps1"
$HW='3.x 蒼穹的禁城 (Heavensward)'; $ARR='2.x 重生之境 (A Realm Reborn)'; $DT='7.x 黃金的遺產 (Dawntrail)'; $EW='6.x 曉月之終途 (Endwalker)'

# Fix manifest with corrected pages
$fixes = @(
    @{Id='keeper_of_the_lake'; Page='The_Keeper_of_the_Lake'; Zh='湖之守護者'; Exp=$ARR; Type='dungeon'; PC=4; Lv=50; HE=$false},
    @{Id='akh_afah_amphitheatre_hard'; Page='The_Akh_Afah_Amphitheatre_(Hard)'; Zh='永生圓劇場 (零式)'; Exp=$ARR; Type='trial'; PC=8; Lv=50; HE=$false},
    @{Id='akh_afah_amphitheatre_extreme'; Page='The_Akh_Afah_Amphitheatre_(Extreme)'; Zh='永生圓劇場 (極式)'; Exp=$ARR; Type='trial'; PC=8; Lv=50; HE=$true},
    @{Id='alzadaals_legacy'; Page="Alzadaal's_Legacy_(Duty)"; Zh='阿爾扎達爾遺產'; Exp=$EW; Type='dungeon'; PC=4; Lv=90; HE=$false},
    @{Id='strayborough_deadwalk'; Page='The_Strayborough_Deadwalk'; Zh='迷途亡靈巡步'; Exp=$DT; Type='dungeon'; PC=4; Lv=100; HE=$false},
    @{Id='skydeep_cenote'; Page='The_Skydeep_Cenote'; Zh='天淵深穴'; Exp=$DT; Type='dungeon'; PC=4; Lv=96; HE=$false},
    @{Id='interphos'; Page='The_Interphos'; Zh='天際層星海'; Exp=$DT; Type='trial'; PC=8; Lv=100; HE=$false},
    @{Id='clyteum'; Page='The_Clyteum'; Zh='克麗提姆'; Exp=$DT; Type='dungeon'; PC=4; Lv=100; HE=$false},
    @{Id='ageless_necropolis'; Page='The_Ageless_Necropolis'; Zh='永恆之死城'; Exp=$DT; Type='trial'; PC=8; Lv=100; HE=$false},
    @{Id='windward_wilds'; Page='The_Windward_Wilds'; Zh='西風荒野'; Exp=$DT; Type='trial'; PC=8; Lv=100; HE=$false},
    @{Id='windward_wilds_extreme'; Page='The_Windward_Wilds_(Extreme)'; Zh='西風荒野 (殲殛戰)'; Exp=$DT; Type='trial'; PC=8; Lv=100; HE=$true},
    @{Id='gilded_araya'; Page='The_Gilded_Araya'; Zh='鍍金之朝'; Exp=$EW; Type='trial'; PC=8; Lv=90; HE=$false},
    @{Id='gilded_araya_2'; Page='The_Gilded_Araya'; Zh='鍍金之朝 (重置)'; Exp=$EW; Type='trial'; PC=8; Lv=90; HE=$false},
    @{Id='hell_on_rails'; Page='Hell_on_Rails'; Zh='地獄列車'; Exp=$DT; Type='trial'; PC=8; Lv=100; HE=$false},
    @{Id='hell_on_rails_extreme'; Page='Hell_on_Rails_(Extreme)'; Zh='地獄列車 (殲殛戰)'; Exp=$DT; Type='trial'; PC=8; Lv=100; HE=$true},
    @{Id='howling_eye'; Page='The_Howling_Eye'; Zh='咆嘯之眼'; Exp=$ARR; Type='trial'; PC=8; Lv=46; HE=$false},
    @{Id='howling_eye_hard'; Page='The_Howling_Eye_(Hard)'; Zh='咆嘯之眼 (零式)'; Exp=$ARR; Type='trial'; PC=8; Lv=50; HE=$false},
    @{Id='bowl_of_embers'; Page='The_Bowl_of_Embers'; Zh='火光之碗'; Exp=$ARR; Type='trial'; PC=8; Lv=22; HE=$false},
    @{Id='bowl_of_embers_extreme'; Page='The_Bowl_of_Embers_(Extreme)'; Zh='火光之碗 (極式)'; Exp=$ARR; Type='trial'; PC=8; Lv=50; HE=$true}
)

$ok = 0; $fail = 0
foreach ($m in $fixes) {
    $r = Write-DutyFromCGW -DutyId $m.Id -CGWPage $m.Page -NameZh $m.Zh -Expansion $m.Exp -Type $m.Type -PC $m.PC -Lv $m.Lv -HighEnd $m.HE
    if ($r) { $ok++; Write-Host "[OK] $($m.Id)" } else { $fail++; Write-Host "[FAIL] $($m.Id)" }
}
Write-Host "Wrote $ok / Failed $fail of $($fixes.Count)"
