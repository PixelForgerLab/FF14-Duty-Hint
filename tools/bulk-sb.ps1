$utf8 = [System.Text.UTF8Encoding]::new($false)
$base = "data\duties"

function Write-Duty($id, $name, $nameEn, $type, $playerCount, $highEnd, $bossName, $bossEn, $hint) {
  $path = "$base\$id.json"
  if (-not (Test-Path $path)) { Write-Host "Missing: $id"; return }
  $heJson = if ($highEnd) { "true" } else { "false" }
  $content = @"
{
    "id": "$id",
    "name": "$name",
    "nameEn": "$nameEn",
    "expansion": "4.x 紅蓮之狂潮 (Stormblood)",
    "type": "$type",
    "playerCount": $playerCount,
    "iLvlSync": null,
    "jobLevelSync": 70,
    "highEnd": $heJson,
    "quality": "needs-update",
    "mnemonic": [
        "$hint",
        "詳細機制請參考 Console Games Wiki 或 Hector Hectorson 攻略"
    ],
    "notes": "4.x SB 副本。⚠️ 詳細機制限制建議參考外部攻略。",
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

# SB MSQ Dungeons (Lv 61-70)
Write-Duty "sirensong_sea" "海妖之歌海" "The Sirensong Sea" "dungeon" 4 $false "Lorelei" "羅雷萊" "4.0 SB 第一 MSQ 副本 (Lv 61)"
Write-Duty "shisui_of_the_violet_tides" "玄櫻碧波蝕水宮" "Shisui of the Violet Tides" "dungeon" 4 $false "Roonhi Tuli" "蘭塔魚精" "4.0 SB MSQ 副本 (Lv 63)，海底主題"
Write-Duty "bardams_mettle" "巴德姆考驗場" "Bardam's Mettle" "dungeon" 4 $false "Bardam the Brave" "巴德姆" "4.0 SB MSQ 副本 (Lv 65)，多神試煉"
Write-Duty "doma_castle" "多瑪城" "Doma Castle" "dungeon" 4 $false "Hypertuned Grynewaht" "格林沃斯" "4.0 SB MSQ 副本 (Lv 67)"
Write-Duty "castrum_abania" "阿瓦尼亞要塞" "Castrum Abania" "dungeon" 4 $false "Hypertuned Magitek Predator" "魔導裝甲" "4.0 SB MSQ 副本 (Lv 69)"
Write-Duty "ala_mhigo" "阿拉米格" "Ala Mhigo" "dungeon" 4 $false "Zenos yae Galvus" "傑諾斯" "4.0 SB MSQ 終戰副本 (Lv 70)，傑諾斯戰前"

# SB Post-MSQ Dungeons
Write-Duty "drowned_city_of_skalla" "沉淪之都 斯卡爾拉" "The Drowned City of Skalla" "dungeon" 4 $false "Glaukopis" "羅雷萊巨型版" "4.1 SB post-MSQ"
Write-Duty "hells_lid" "地獄之蓋" "Hells' Lid" "dungeon" 4 $false "Oni Yumemi" "鬼一夢" "4.2 SB post-MSQ"
Write-Duty "fractal_continuum_hard" "聖天大陸（高難度）" "The Fractal Continuum (Hard)" "dungeon" 4 $false "Faulkner" "福克納" "4.2 SB Hard 副本"
Write-Duty "swallows_compass" "燕子之羅盤" "The Swallow's Compass" "dungeon" 4 $false "Tenzen" "天善" "4.3 SB post-MSQ"
Write-Duty "burn" "燃燒荒野" "The Burn" "dungeon" 4 $false "Mist Dragon" "霧龍" "4.4 SB post-MSQ"
Write-Duty "ghimlyt_dark" "吉米利暗區" "The Ghimlyt Dark" "dungeon" 4 $false "Julia Garlond" "茱莉亞" "4.5 SB post-MSQ"
Write-Duty "saint_mociannes_arboretum_hard" "聖摩茜安植物園（高難度）" "Saint Mocianne's Arboretum (Hard)" "dungeon" 4 $false "Mandragora Queen" "曼陀羅女王" "4.5 SB Hard 副本"
Write-Duty "kugane_castle" "九神城" "Kugane Castle" "dungeon" 4 $false "Yojimbo" "用心棒" "4.1 SB Lv 70 副本"
Write-Duty "temple_of_the_fist" "鬥拳之神殿" "The Temple of the Fist" "dungeon" 4 $false "Genbu" "玄武" "4.0 SB Lv 70 副本"

# SB MSQ Trials
Write-Duty "pool_of_tribute" "貢納池殲滅戰" "The Pool of Tribute" "trial" 8 $false "Susano" "須佐之男" "4.0 SB Susano trial"
Write-Duty "pool_of_tribute_extreme" "貢納池殲殛戰" "The Pool of Tribute (Extreme)" "trial" 8 $true "Susano" "須佐之男" "4.0 SB Susano EX"
Write-Duty "emanation" "顯現殲滅戰" "Emanation" "trial" 8 $false "Lakshmi" "拉克什米" "4.1 SB Lakshmi trial"
Write-Duty "emanation_extreme" "顯現殲殛戰" "Emanation (Extreme)" "trial" 8 $true "Lakshmi" "拉克什米" "4.1 SB Lakshmi EX"
Write-Duty "royal_menagerie" "王宮動物園殲滅戰" "The Royal Menagerie" "trial" 8 $false "Shinryu" "神龍" "4.0 SB MSQ 終戰，傑諾斯/神龍"
Write-Duty "castrum_fluminis" "天命殲滅戰" "Castrum Fluminis" "trial" 8 $false "Yotsuyu" "四衣" "4.3 SB Yotsuyu trial"
Write-Duty "kugane_ohashi" "九重大橋殲滅戰" "Kugane Ohashi" "trial" 8 $false "Asahi" "朝日" "4.4 SB MSQ trial"
Write-Duty "jade_stoa" "玉茶亭殲滅戰" "The Jade Stoa" "trial" 8 $false "Byakko" "白虎" "4.1 SB Byakko trial"
Write-Duty "jade_stoa_extreme" "玉茶亭殲殛戰" "The Jade Stoa (Extreme)" "trial" 8 $true "Byakko" "白虎" "4.1 SB Byakko EX"
Write-Duty "hells_kier" "地獄峽谷殲滅戰" "Hells' Kier" "trial" 8 $false "Suzaku" "朱雀" "4.3 SB Suzaku trial"
Write-Duty "hells_kier_extreme" "地獄峽谷殲殛戰" "Hells' Kier (Extreme)" "trial" 8 $true "Suzaku" "朱雀" "4.3 SB Suzaku EX"
Write-Duty "wreath_of_snakes" "蛇花圈殲滅戰" "Wreath of Snakes" "trial" 8 $false "Seiryu" "青龍" "4.5 SB Seiryu trial"
Write-Duty "wreath_of_snakes_extreme" "蛇花圈殲殛戰" "Wreath of Snakes (Extreme)" "trial" 8 $true "Seiryu" "青龍" "4.5 SB Seiryu EX"
Write-Duty "great_hunt" "大狩獵戰" "The Great Hunt" "trial" 8 $false "Rathalos" "雄火龍" "4.2 SB 怪獵聯動 Rathalos trial"
Write-Duty "great_hunt_extreme" "大狩獵極戰" "The Great Hunt (Extreme)" "trial" 8 $true "Rathalos" "雄火龍" "4.2 SB Rathalos EX"
Write-Duty "minstrels_ballad_shinryus_domain" "神龍極戰" "The Minstrel's Ballad: Shinryu's Domain" "trial" 8 $true "Shinryu" "神龍" "4.0 SB Shinryu EX"
Write-Duty "minstrels_ballad_tsukuyomis_pain" "月讀極戰" "The Minstrel's Ballad: Tsukuyomi's Pain" "trial" 8 $true "Tsukuyomi" "月讀" "4.3 SB Tsukuyomi EX"

# SB Omega raids (Deltascape v1-v4, Sigmascape v1-v4, Alphascape v1-v4) + savage
$omega = @{
  "deltascape_v10" = @{ n = "歐米茄迪奧斯卡迪 1"; ne = "Deltascape V1.0"; b = "Alte Roite"; bt = "巨鳥" }
  "deltascape_v20" = @{ n = "歐米茄迪奧斯卡迪 2"; ne = "Deltascape V2.0"; b = "Catastrophe"; bt = "災難" }
  "deltascape_v30" = @{ n = "歐米茄迪奧斯卡迪 3"; ne = "Deltascape V3.0"; b = "Halicarnassus"; bt = "海利卡那索斯" }
  "deltascape_v40" = @{ n = "歐米茄迪奧斯卡迪 4"; ne = "Deltascape V4.0"; b = "Exdeath"; bt = "X 死" }
  "sigmascape_v10" = @{ n = "歐米茄西格瑪斯卡迪 1"; ne = "Sigmascape V1.0"; b = "Phantom Train"; bt = "幽靈列車" }
  "sigmascape_v20" = @{ n = "歐米茄西格瑪斯卡迪 2"; ne = "Sigmascape V2.0"; b = "Demon Wall"; bt = "惡魔之牆" }
  "sigmascape_v30" = @{ n = "歐米茄西格瑪斯卡迪 3"; ne = "Sigmascape V3.0"; b = "Guardian"; bt = "守護者" }
  "sigmascape_v40" = @{ n = "歐米茄西格瑪斯卡迪 4"; ne = "Sigmascape V4.0"; b = "Kefka"; bt = "凱夫卡" }
  "alphascape_v10" = @{ n = "歐米茄阿爾法斯卡迪 1"; ne = "Alphascape V1.0"; b = "Chaos"; bt = "卡奧斯" }
  "alphascape_v20" = @{ n = "歐米茄阿爾法斯卡迪 2"; ne = "Alphascape V2.0"; b = "Midgardsormr"; bt = "中庭巨龍" }
  "alphascape_v30" = @{ n = "歐米茄阿爾法斯卡迪 3"; ne = "Alphascape V3.0"; b = "Omega"; bt = "歐米茄 (M+F)" }
  "alphascape_v40" = @{ n = "歐米茄阿爾法斯卡迪 4"; ne = "Alphascape V4.0"; b = "Omega"; bt = "歐米茄究極" }
}
foreach ($id in $omega.Keys) {
  $e = $omega[$id]
  Write-Duty $id $e.n $e.ne "raid" 8 $false $e.bt $e.b "4.x SB Omega raid，FF V/VI/IV/VII 致敬"
  $savId = $id + "_savage"
  if (Test-Path "$base\$savId.json") {
    Write-Duty $savId "$($e.n)（零式）" "$($e.ne) (Savage)" "raid" 8 $true $e.bt $e.b "4.x SB Omega Savage"
  }
}

# SB Alliance raids (Return to Ivalice trilogy)
Write-Duty "royal_city_of_rabanastre" "拉巴納斯特皇都" "The Royal City of Rabanastre" "raid" 24 $false "Argath" "亞卡特" "4.1 Return to Ivalice 第 1 部 (FFXII)"
Write-Duty "ridorana_lighthouse" "里多拉納燈塔" "The Ridorana Lighthouse" "raid" 24 $false "Famfrit" "法夫尼爾" "4.3 Return to Ivalice 第 2 部"
Write-Duty "orbonne_monastery" "歐邦修道院" "The Orbonne Monastery" "raid" 24 $false "Ultima" "終極幻獸" "4.5 Return to Ivalice 第 3 部，T 戰術致敬"

# Misc
Write-Duty "special_event_i" "特別事件 I" "Special Event I" "trial" 8 $false "事件 Boss" "Event Boss" "聯動事件副本"

Write-Host ""
Write-Host "=== SB DONE ==="
