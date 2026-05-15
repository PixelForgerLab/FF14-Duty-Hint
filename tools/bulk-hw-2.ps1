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

# Alexander with actual hyphen-format ID
$alex = @{
  "alexander_-_the_fist_of_the_father" = @{ n = "亞歷山卓 起源篇 父之拳"; ne = "Alexander - The Fist of the Father"; b = "Faust"; bt = "浮士德" }
  "alexander_-_the_cuff_of_the_father" = @{ n = "亞歷山卓 起源篇 父之臂"; ne = "Alexander - The Cuff of the Father"; b = "Living Liquid"; bt = "生命液體" }
  "alexander_-_the_arm_of_the_father" = @{ n = "亞歷山卓 起源篇 父之肩"; ne = "Alexander - The Arm of the Father"; b = "Manipulator"; bt = "操縱者" }
  "alexander_-_the_burden_of_the_father" = @{ n = "亞歷山卓 起源篇 父之負"; ne = "Alexander - The Burden of the Father"; b = "Brute Justice"; bt = "暴力正義" }
  "alexander_-_the_fist_of_the_son" = @{ n = "亞歷山卓 律動篇 子之拳"; ne = "Alexander - The Fist of the Son"; b = "Ratfinx"; bt = "鼠靈" }
  "alexander_-_the_cuff_of_the_son" = @{ n = "亞歷山卓 律動篇 子之臂"; ne = "Alexander - The Cuff of the Son"; b = "Lamebrix"; bt = "歪腦布偶" }
  "alexander_-_the_arm_of_the_son" = @{ n = "亞歷山卓 律動篇 子之肩"; ne = "Alexander - The Arm of the Son"; b = "Refurbisher 0"; bt = "再造器 0" }
  "alexander_-_the_burden_of_the_son" = @{ n = "亞歷山卓 律動篇 子之負"; ne = "Alexander - The Burden of the Son"; b = "Quickthinx"; bt = "全能思考者" }
  "alexander_-_the_eyes_of_the_creator" = @{ n = "亞歷山卓 天動篇 眼之主"; ne = "Alexander - The Eyes of the Creator"; b = "Calofisteri"; bt = "卡洛菲斯特里" }
  "alexander_-_the_breath_of_the_creator" = @{ n = "亞歷山卓 天動篇 息之主"; ne = "Alexander - The Breath of the Creator"; b = "Cruise Chaser"; bt = "巡航者" }
  "alexander_-_the_heart_of_the_creator" = @{ n = "亞歷山卓 天動篇 心之主"; ne = "Alexander - The Heart of the Creator"; b = "Brute Justice + Cruise Chaser"; bt = "正義 + 巡航者" }
  "alexander_-_the_soul_of_the_creator" = @{ n = "亞歷山卓 天動篇 魂之主"; ne = "Alexander - The Soul of the Creator"; b = "Alexander Prime"; bt = "亞歷山卓究極形態" }
}
foreach ($id in $alex.Keys) {
  $e = $alex[$id]
  Write-Duty $id $e.n $e.ne $hwExp "raid" 8 60 $null $false $e.bt $e.b "3.x HW Alexander raid，FFV/MX 致敬"
  $savId = $id + "_savage"
  if (Test-Path "$base\$savId.json") {
    Write-Duty $savId "$($e.n)（零式）" "$($e.ne) (Savage)" $hwExp "raid" 8 60 $null $true $e.bt $e.b "3.x HW Alexander Savage"
  }
}

# Other HW dungeons with proper IDs
Write-Duty "baelsars_wall" "拜爾薩爾長城" "Baelsar's Wall" $hwExp "dungeon" 4 60 $null $false "Magitek Predator" "魔導裝甲掠食者" "3.5 HW Lv 60 副本"
Write-Duty "great_gubal_library_hard" "古巴爾要塞圖書館（高難度）" "The Great Gubal Library (Hard)" $hwExp "dungeon" 4 60 $null $false "Strix" "斯特利克斯" "3.x HW Hard 副本"
Write-Duty "hullbreaker_isle_hard" "破船島（高難度）" "Hullbreaker Isle (Hard)" $hwExp "dungeon" 4 60 $null $false "Sahagin" "薩岡海" "3.x HW Hard 副本"
Write-Duty "sohm_al_hard" "索姆阿爾（高難度）" "Sohm Al (Hard)" $hwExp "dungeon" 4 60 $null $false "Aiatar" "亞塔" "3.x HW Hard 副本"
Write-Duty "saint_mociannes_arboretum" "聖摩茜安植物園" "Saint Mocianne's Arboretum" $hwExp "dungeon" 4 60 $null $false "Tristitia" "崔斯提西亞" "3.3 HW Lv 60 副本"
Write-Duty "xelphatol" "謝爾法托爾" "Xelphatol" $hwExp "dungeon" 4 60 $null $false "Tozkoshka" "托茲科什卡" "3.1 HW Lv 60 副本"

# "Limitless Blue" trial uses _hard suffix in filenames (Generate-Duties artifact)
Write-Duty "limitless_blue_hard" "無限藍空殲滅戰" "The Limitless Blue" $hwExp "trial" 8 50 $null $false "Bismarck" "畢斯馬克" "3.0 HW Bismarck trial（鯨王）"
Write-Duty "thok_ast_thok_hard" "塔克阿斯塔殲滅戰" "Thok ast Thok" $hwExp "trial" 8 50 $null $false "Ravana" "羅婆那" "3.0 HW Ravana trial"

# Ultimate
$ucobPath = "$base\unending_coil_of_bahamut_ultimate.json"
if (Test-Path $ucobPath) {
  Write-Duty "unending_coil_of_bahamut_ultimate" "巴哈姆特絕境戰" "The Unending Coil of Bahamut (Ultimate)" $hwExp "ultimate" 8 70 $null $true "Bahamut Prime" "巴哈姆特究極形態" "FFXIV 第 1 個絕境戰 (5.0 開放)"
} else {
  # Maybe it's named differently
  Get-ChildItem "$base\*bahamut*ultimate*.json" | ForEach-Object { Write-Host "Bahamut ultimate file: $($_.Name)" }
}

# Steel Vigil + Steps of Faith
Write-Duty "steps_of_faith" "聖騎士守護戰" "The Steps of Faith" $hwExp "trial" 8 50 $null $false "Vishap" "維夏普" "3.0 HW Steps of Faith trial"

Write-Host ""
Write-Host "=== HW Phase 2 Done ==="
