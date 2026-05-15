$utf8 = [System.Text.UTF8Encoding]::new($false)
$base = "data\duties"

# Post-MSQ dungeons + alliance + EX trials + misc
$shbBulk = @{
  # Post-MSQ Dungeons
  "paglthan" = @{ n = "派格爾坦"; ne = "Paglth'an"; t = "dungeon"; ilvl = $null; he = "false"; lvl = 80; mnemonic = "5.3 ShB 後 MSQ 副本，2 個 boss + 終戰" }
  "grand_cosmos" = @{ n = "宏偉宇宙"; ne = "The Grand Cosmos"; t = "dungeon"; ilvl = $null; he = "false"; lvl = 80; mnemonic = "5.2 ShB 後 MSQ 副本" }
  "anamnesis_anyder" = @{ n = "回憶亞諾德"; ne = "Anamnesis Anyder"; t = "dungeon"; ilvl = $null; he = "false"; lvl = 80; mnemonic = "5.1 ShB 後 MSQ 副本" }
  "heroes_gauntlet" = @{ n = "英雄之路"; ne = "The Heroes' Gauntlet"; t = "dungeon"; ilvl = $null; he = "false"; lvl = 80; mnemonic = "5.3 ShB 後 MSQ 副本，多種 boss" }
  "matoyas_relict" = @{ n = "瑪托雅遺跡"; ne = "Matoya's Relict"; t = "dungeon"; ilvl = $null; he = "false"; lvl = 80; mnemonic = "5.4 ShB 後 MSQ 副本" }
  # Alliance
  "copied_factory" = @{ n = "複製工廠"; ne = "The Copied Factory"; t = "raid"; ilvl = $null; he = "false"; lvl = 80; mnemonic = "5.1 NieR 第 1 部 alliance raid（24 人）" }
  "puppets_bunker" = @{ n = "傀儡之掩體"; ne = "The Puppets' Bunker"; t = "raid"; ilvl = $null; he = "false"; lvl = 80; mnemonic = "5.3 NieR 第 2 部 alliance raid（24 人）" }
  "tower_at_paradigms_breach" = @{ n = "新世範式之塔"; ne = "The Tower at Paradigm's Breach"; t = "raid"; ilvl = $null; he = "false"; lvl = 80; mnemonic = "5.5 NieR 第 3 部 alliance raid（24 人，終戰）" }
  # EX Trials
  "dancing_plague_extreme" = @{ n = "妖精王殲殛戰"; ne = "The Dancing Plague (Extreme)"; t = "trial"; ilvl = $null; he = "true"; lvl = 80; mnemonic = "Titania EX，normal 強化版" }
  "crown_of_the_immaculate_extreme" = @{ n = "純白之冠殲殛戰"; ne = "The Crown of the Immaculate (Extreme)"; t = "trial"; ilvl = $null; he = "true"; lvl = 80; mnemonic = "Innocence EX，normal 強化版" }
  "cinder_drift" = @{ n = "餘燼漂流"; ne = "Cinder Drift"; t = "trial"; ilvl = $null; he = "false"; lvl = 80; mnemonic = "Ruby Weapon trial 5.2" }
  "cinder_drift_extreme" = @{ n = "餘燼漂流（極）"; ne = "Cinder Drift (Extreme)"; t = "trial"; ilvl = $null; he = "true"; lvl = 80; mnemonic = "Ruby Weapon EX 5.2" }
  "castrum_marinum" = @{ n = "瑪琳娜海上要塞"; ne = "Castrum Marinum"; t = "trial"; ilvl = $null; he = "false"; lvl = 80; mnemonic = "Emerald Weapon trial 5.3" }
  "castrum_marinum_extreme" = @{ n = "瑪琳娜海上要塞（極）"; ne = "Castrum Marinum (Extreme)"; t = "trial"; ilvl = $null; he = "true"; lvl = 80; mnemonic = "Emerald Weapon EX 5.3" }
  "cloud_deck" = @{ n = "天雲樓"; ne = "The Cloud Deck"; t = "trial"; ilvl = $null; he = "false"; lvl = 80; mnemonic = "Diamond Weapon trial 5.5" }
  "cloud_deck_extreme" = @{ n = "天雲樓（極）"; ne = "The Cloud Deck (Extreme)"; t = "trial"; ilvl = $null; he = "true"; lvl = 80; mnemonic = "Diamond Weapon EX 5.5" }
  "seat_of_sacrifice_extreme" = @{ n = "祭典之座（極）"; ne = "The Seat of Sacrifice (Extreme)"; t = "trial"; ilvl = $null; he = "true"; lvl = 80; mnemonic = "Elidibus EX，5.3" }
  "minstrels_ballad_hadess_elegy" = @{ n = "哈迪斯絕嘆殲殛戰"; ne = "The Minstrel's Ballad: Hades's Elegy"; t = "trial"; ilvl = $null; he = "true"; lvl = 80; mnemonic = "Hades EX，5.0" }
  "memoria_misera_extreme" = @{ n = "悲傷之眼（極）"; ne = "Memoria Misera (Extreme)"; t = "trial"; ilvl = $null; he = "true"; lvl = 80; mnemonic = "Varis EX，5.2" }
  # Misc
  "amaurot" = @{ n = "亞馬羅特（變體）"; ne = "Amaurot"; t = "dungeon"; ilvl = $null; he = "false"; lvl = 80; mnemonic = "5.0 ShB MSQ 變體副本（特殊環境）" }
  "special_event_ii" = @{ n = "特別事件 II"; ne = "Special Event II"; t = "trial"; ilvl = $null; he = "false"; lvl = 80; mnemonic = "聯動事件副本" }
}

foreach ($id in $shbBulk.Keys) {
  $e = $shbBulk[$id]
  $path = "$base\$id.json"
  if (-not (Test-Path $path)) { Write-Host "Missing: $id"; continue }
  $playerCount = if ($e.t -eq "raid") { 24 } elseif ($e.t -eq "trial") { 8 } else { 4 }
  $ilvlJson = if ($null -eq $e.ilvl) { "null" } else { $e.ilvl.ToString() }
  $newContent = @"
{
    "id": "$id",
    "name": "$($e.n)",
    "nameEn": "$($e.ne)",
    "expansion": "5.x 漆黑的反叛者 (Shadowbringers)",
    "type": "$($e.t)",
    "playerCount": $playerCount,
    "iLvlSync": $ilvlJson,
    "jobLevelSync": $($e.lvl),
    "highEnd": $($e.he),
    "quality": "needs-update",
    "mnemonic": [
        "$($e.mnemonic)",
        "詳細機制請參考 Console Games Wiki / Hector Hectorson 攻略"
    ],
    "notes": "5.x ShB 副本。⚠️ 詳細機制限制建議參考外部攻略。",
    "bosses": [
        {
            "name": "副本 Boss",
            "nameEn": "Duty Boss",
            "mnemonic": ["看 telegraph 預警"],
            "phases": [
                {
                    "name": "主戰",
                    "mechanics": [
                        {
                            "name": "標準機制",
                            "type": "other",
                            "description": "包含 raid-wide AoE、tankbuster、stack、spread 等機制。",
                            "tips": ["參考外部攻略"]
                        }
                    ]
                }
            ]
        }
    ]
}
"@
  [System.IO.File]::WriteAllText($path, $newContent, $utf8)
  Write-Host "OK: $id"
}
