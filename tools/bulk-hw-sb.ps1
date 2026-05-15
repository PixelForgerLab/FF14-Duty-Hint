$utf8 = [System.Text.UTF8Encoding]::new($false)
$base = "data\duties"

function Write-Duty($id, $name, $nameEn, $expansion, $type, $playerCount, $jobLevel, $ilvl, $highEnd, $bossName, $bossEn, $hint) {
  $path = "$base\$id.json"
  if (-not (Test-Path $path)) { Write-Host "Missing: $id"; return }
  $ilvlJson = if ($null -eq $ilvl) { "null" } else { $ilvl.ToString() }
  $heJson = if ($highEnd) { "true" } else { "false" }
  $content = @"
{
    "id": "$id",
    "name": "$name",
    "nameEn": "$nameEn",
    "expansion": "$expansion",
    "type": "$type",
    "playerCount": $playerCount,
    "iLvlSync": $ilvlJson,
    "jobLevelSync": $jobLevel,
    "highEnd": $heJson,
    "quality": "needs-update",
    "mnemonic": [
        "$hint",
        "詳細機制請參考 Console Games Wiki 或 Hector Hectorson 攻略"
    ],
    "notes": "FFXIV 副本。⚠️ 詳細機制限制建議參考外部攻略。",
    "bosses": [
        {
            "name": "$bossName",
            "nameEn": "$bossEn",
            "mnemonic": ["看 telegraph 預警"],
            "phases": [
                {
                    "name": "主戰",
                    "mechanics": [
                        {
                            "name": "標準機制",
                            "type": "other",
                            "description": "副本內含 raid-wide AoE、tankbuster、stack、spread 等標準機制。",
                            "tips": ["參考外部攻略", "看 telegraph 與 AoE 預警"]
                        }
                    ]
                }
            ]
        }
    ]
}
"@
  [System.IO.File]::WriteAllText($path, $content, $utf8)
  Write-Host "OK: $id"
}

$hwExp = "3.x 蒼穹之禁城 (Heavensward)"
$sbExp = "4.x 紅蓮之狂潮 (Stormblood)"

# HW MSQ Dungeons + popular content
Write-Duty "dusk_vigil" "黎明哨塔" "The Dusk Vigil" $hwExp "dungeon" 4 51 $null $false "Raven" "渡鴉" "3.0 HW MSQ 第一副本 (Lv 51)，3 個 boss"
Write-Duty "sohm_al" "蒼天庇護所索姆阿爾" "Sohm Al" $hwExp "dungeon" 4 53 $null $false "Tioman" "提歐曼" "3.0 HW MSQ 第二副本 (Lv 53)，龍主題"
Write-Duty "aery" "巢窟" "The Aery" $hwExp "dungeon" 4 55 $null $false "Nidhogg's Heart" "尼德霍格" "3.0 HW 龍詩戰爭 boss"
Write-Duty "vault" "至高聖堂教皇廳" "The Vault" $hwExp "dungeon" 4 57 $null $false "Charibert" "夏里貝爾" "3.0 HW 教皇廳"
Write-Duty "great_gubal_library" "古巴爾要塞圖書館" "The Great Gubal Library" $hwExp "dungeon" 4 59 $null $false "Liquid Flame" "液態火焰" "3.0 HW MSQ 副本 (Lv 59)"
Write-Duty "aetherochemical_research_facility" "魔科學研究所" "The Aetherochemical Research Facility" $hwExp "dungeon" 4 60 $null $false "Igeyorhm + Lahabrea" "Ascian 雙頭目" "3.0 HW MSQ 終戰副本，Ascian 對決"
Write-Duty "neverreap" "永世的彼方" "Neverreap" $hwExp "dungeon" 4 60 $null $false "Soufflot" "蘇佛羅" "3.0 HW Lv 60 副本"
Write-Duty "fractal_continuum" "聖天大陸" "The Fractal Continuum" $hwExp "dungeon" 4 60 $null $false "Brawler" "戰鬥者" "3.0 HW Lv 60 副本"
Write-Duty "antitower" "反塔" "The Antitower" $hwExp "dungeon" 4 60 $null $false "Allagan Bolide" "亞拉戈大彗星" "3.1 HW Lv 60 副本，水晶之塔致敬"
Write-Duty "lost_city_of_amdapor_hard" "失落之都 安姆達普爾遺址（高難度）" "The Lost City of Amdapor (Hard)" $hwExp "dungeon" 4 60 $null $false "Diabolos Hollow" "迪亞布魯虛影" "3.2 HW Hard 副本"
Write-Duty "saint_mocianne_arboretum" "聖摩茜安植物園" "Saint Mocianne's Arboretum" $hwExp "dungeon" 4 60 $null $false "Tristitia" "崔斯提西亞" "3.3 HW Lv 60 副本"
Write-Duty "pharos_sirius_hard" "賽利斯燈塔（高難度）" "Pharos Sirius (Hard)" $hwExp "dungeon" 4 60 $null $false "Aerial Eye" "空中之眼" "3.4 HW Hard 副本"
Write-Duty "sohr_khai" "索爾凱獻祭之所" "Sohr Khai" $hwExp "dungeon" 4 60 $null $false "Forgall" "弗加爾" "3.5 HW Lv 60 副本"
Write-Duty "haukke_manor_hard" "侯克瑪納莊園（高難度）" "Haukke Manor (Hard)" $hwExp "dungeon" 4 50 $null $false "Lady Amandine" "亞曼汀夫人" "3.x HW Hard 副本"

# HW MSQ Trials
Write-Duty "steel_vigil" "鐵之哨塔殲滅戰" "The Steps of Faith" $hwExp "trial" 8 50 $null $false "Vishap" "維夏普" "3.0 HW 巨龍 Steps of Faith trial"
Write-Duty "thok_ast_thok" "塔克阿斯塔殲滅戰" "Thok ast Thok" $hwExp "trial" 8 50 $null $false "Ravana" "羅婆那" "3.0 HW Ravana trial"
Write-Duty "thok_ast_thok_extreme" "塔克阿斯塔殲殛戰" "Thok ast Thok (Extreme)" $hwExp "trial" 8 50 $null $true "Ravana" "羅婆那" "3.0 HW Ravana EX"
Write-Duty "limitless_blue" "無限藍空殲滅戰" "The Limitless Blue" $hwExp "trial" 8 50 $null $false "Bismarck" "畢斯馬克" "3.0 HW Bismarck trial（鯨王）"
Write-Duty "limitless_blue_extreme" "無限藍空殲殛戰" "The Limitless Blue (Extreme)" $hwExp "trial" 8 50 $null $true "Bismarck" "畢斯馬克" "3.0 HW Bismarck EX"
Write-Duty "singularity_reactor" "蒼天聖戰" "The Singularity Reactor" $hwExp "trial" 8 60 $null $false "King Thordan" "聖騎士索敦王" "3.0 HW MSQ 終戰，蒼天騎士團"
Write-Duty "minstrels_ballad_thordans_reign" "聖騎士索敦殲殛戰" "The Minstrel's Ballad: Thordan's Reign" $hwExp "trial" 8 60 $null $true "Thordan" "索敦王" "3.0 HW Thordan EX"
Write-Duty "containment_bay_s1t7" "封鎖區域 S1T7 殲滅戰" "Containment Bay S1T7" $hwExp "trial" 8 60 $null $false "Sephirot" "薩菲洛斯" "3.2 HW Sephirot trial"
Write-Duty "containment_bay_s1t7_extreme" "封鎖區域 S1T7 殲殛戰" "Containment Bay S1T7 (Extreme)" $hwExp "trial" 8 60 $null $true "Sephirot" "薩菲洛斯" "3.2 HW Sephirot EX"
Write-Duty "containment_bay_p1t6" "封鎖區域 P1T6 殲滅戰" "Containment Bay P1T6" $hwExp "trial" 8 60 $null $false "Sophia" "蘇菲亞" "3.4 HW Sophia trial"
Write-Duty "containment_bay_p1t6_extreme" "封鎖區域 P1T6 殲殛戰" "Containment Bay P1T6 (Extreme)" $hwExp "trial" 8 60 $null $true "Sophia" "蘇菲亞" "3.4 HW Sophia EX"
Write-Duty "containment_bay_z1t9" "封鎖區域 Z1T9 殲滅戰" "Containment Bay Z1T9" $hwExp "trial" 8 60 $null $false "Zurvan" "佐凡" "3.5 HW Zurvan trial"
Write-Duty "containment_bay_z1t9_extreme" "封鎖區域 Z1T9 殲殛戰" "Containment Bay Z1T9 (Extreme)" $hwExp "trial" 8 60 $null $true "Zurvan" "佐凡" "3.5 HW Zurvan EX"
Write-Duty "final_steps_of_faith" "蒼天決戰" "The Final Steps of Faith" $hwExp "trial" 8 60 $null $false "Nidhogg" "尼德霍格" "3.3 HW Nidhogg 終戰"
Write-Duty "minstrels_ballad_nidhoggs_rage" "尼德霍格殲殛戰" "The Minstrel's Ballad: Nidhogg's Rage" $hwExp "trial" 8 60 $null $true "Nidhogg" "尼德霍格" "3.3 HW Nidhogg EX"

# HW Alexander raids (12 normal + 12 savage)
foreach ($tier in @("gordias", "midas", "creator")) {
  foreach ($part in @("burden_of_the_father", "burden_of_the_son", "burden_of_the_father_savage", "burden_of_the_son_savage")) {
    # Pattern: alexander_{tier}_{part}
  }
}
# Just write Alexander entries directly
$alex = @{
  "alexander_the_fist_of_the_father" = @{ n = "亞歷山卓 起源篇 父之手"; ne = "Alexander - The Fist of the Father"; b = "Faust"; bt = "浮士德"; he = $false; lvl = 60 }
  "alexander_the_cuff_of_the_father" = @{ n = "亞歷山卓 起源篇 父之臂"; ne = "Alexander - The Cuff of the Father"; b = "Living Liquid"; bt = "生命液體"; he = $false; lvl = 60 }
  "alexander_the_arm_of_the_father" = @{ n = "亞歷山卓 起源篇 父之肩"; ne = "Alexander - The Arm of the Father"; b = "Manipulator"; bt = "操縱者"; he = $false; lvl = 60 }
  "alexander_the_burden_of_the_father" = @{ n = "亞歷山卓 起源篇 父之負"; ne = "Alexander - The Burden of the Father"; b = "Brute Justice"; bt = "暴力正義"; he = $false; lvl = 60 }
  "alexander_the_fist_of_the_son" = @{ n = "亞歷山卓 律動篇 子之拳"; ne = "Alexander - The Fist of the Son"; b = "Ratfinx"; bt = "鼠靈"; he = $false; lvl = 60 }
  "alexander_the_cuff_of_the_son" = @{ n = "亞歷山卓 律動篇 子之臂"; ne = "Alexander - The Cuff of the Son"; b = "Lamebrix Strikebocks"; bt = "歪腦布偶"; he = $false; lvl = 60 }
  "alexander_the_arm_of_the_son" = @{ n = "亞歷山卓 律動篇 子之肩"; ne = "Alexander - The Arm of the Son"; b = "Refurbisher 0"; bt = "再造器 0"; he = $false; lvl = 60 }
  "alexander_the_burden_of_the_son" = @{ n = "亞歷山卓 律動篇 子之負"; ne = "Alexander - The Burden of the Son"; b = "Quickthinx Allthoughts"; bt = "全能思考者"; he = $false; lvl = 60 }
  "alexander_the_eyes_of_the_creator" = @{ n = "亞歷山卓 天動篇 眼之主"; ne = "Alexander - The Eyes of the Creator"; b = "Calofisteri"; bt = "卡洛菲斯特里"; he = $false; lvl = 60 }
  "alexander_the_breath_of_the_creator" = @{ n = "亞歷山卓 天動篇 息之主"; ne = "Alexander - The Breath of the Creator"; b = "Cruise Chaser"; bt = "巡航者"; he = $false; lvl = 60 }
  "alexander_the_heart_of_the_creator" = @{ n = "亞歷山卓 天動篇 心之主"; ne = "Alexander - The Heart of the Creator"; b = "Brute Justice + Cruise Chaser"; bt = "正義 + 巡航者"; he = $false; lvl = 60 }
  "alexander_the_soul_of_the_creator" = @{ n = "亞歷山卓 天動篇 魂之主"; ne = "Alexander - The Soul of the Creator"; b = "Alexander Prime"; bt = "亞歷山卓究極形態"; he = $false; lvl = 60 }
}
foreach ($id in $alex.Keys) {
  $e = $alex[$id]
  Write-Duty $id $e.n $e.ne $hwExp "raid" 8 $e.lvl $null $e.he $e.bt $e.b "3.x HW Alexander raid，FFV/MX 致敬"
  # Also savage version if exists
  $savId = $id + "_savage"
  $savPath = "$base\$savId.json"
  if (Test-Path $savPath) {
    Write-Duty $savId "$($e.n)（零式）" "$($e.ne) (Savage)" $hwExp "raid" 8 $e.lvl $null $true $e.bt $e.b "3.x HW Alexander Savage"
  }
}

# HW Crystal Tower Hot (Mhach trilogy 24-man alliance)
Write-Duty "void_ark" "虛空方舟" "The Void Ark" $hwExp "raid" 24 60 $null $false "Echidna" "厄客德娜" "3.1 HW Mhach 三部曲第 1 部 alliance raid"
Write-Duty "weeping_city_of_mhach" "瑪哈之淚都" "The Weeping City of Mhach" $hwExp "raid" 24 60 $null $false "Calofisteri" "卡洛菲斯特里" "3.3 HW Mhach 三部曲第 2 部"
Write-Duty "dun_scaith" "黑闇之雲堡" "Dun Scaith" $hwExp "raid" 24 60 $null $false "Diabolos" "迪亞布魯" "3.5 HW Mhach 三部曲第 3 部"

# HW Ultimate
Write-Duty "the_unending_coil_of_bahamut_ultimate" "巴哈姆特絕境戰" "The Unending Coil of Bahamut (Ultimate)" $hwExp "ultimate" 8 70 $null $true "Bahamut Prime" "巴哈姆特究極形態" "FFXIV 第 1 個絕境戰 (5.0 開放)"

Write-Host ""
Write-Host "=== HW DONE ==="
