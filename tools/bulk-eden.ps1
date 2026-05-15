# Bulk write Eden raids
$utf8 = [System.Text.UTF8Encoding]::new($false)
$base = "data\duties"

$edenEntries = @{
  "edens_gate_resurrection" = @{ n = "伊甸希望樂土 復生之章"; boss = "Eden Prime"; bossTC = "伊甸的禁忌之地" }
  "edens_gate_descent" = @{ n = "伊甸希望樂土 隕落之章"; boss = "Voidwalker"; bossTC = "墮入虛無者" }
  "edens_gate_inundation" = @{ n = "伊甸希望樂土 沉沒之章"; boss = "Leviathan"; bossTC = "利維坦" }
  "edens_gate_sepulture" = @{ n = "伊甸希望樂土 鎮魂之章"; boss = "Titan"; bossTC = "泰坦" }
  "edens_verse_fulmination" = @{ n = "伊甸再生樂土 雷擊之章"; boss = "Ramuh"; bossTC = "拉姆" }
  "edens_verse_furor" = @{ n = "伊甸再生樂土 狂風之章"; boss = "Ifrit + Garuda"; bossTC = "伊弗利特 + 卡耳娜" }
  "edens_verse_iconoclasm" = @{ n = "伊甸再生樂土 機獸之章"; boss = "The Idol of Darkness"; bossTC = "暗之鏡" }
  "edens_verse_refulgence" = @{ n = "伊甸再生樂土 究極之章"; boss = "Shiva"; bossTC = "希瓦" }
  "edens_promise_umbra" = @{ n = "伊甸誓約樂土 闇影之章"; boss = "Shadowkeeper"; bossTC = "影守護者" }
  "edens_promise_litany" = @{ n = "伊甸誓約樂土 連禱之章"; boss = "Fatebreaker"; bossTC = "命運破壞者" }
  "edens_promise_anamorphosis" = @{ n = "伊甸誓約樂土 變身之章"; boss = "Eden's Promise"; bossTC = "伊甸的應許" }
  "edens_promise_eternity" = @{ n = "伊甸誓約樂土 永恆之章"; boss = "Oracle of Darkness"; bossTC = "暗之預言者" }
}

foreach ($id in $edenEntries.Keys) {
  $e = $edenEntries[$id]
  foreach ($suffix in @("", "_savage")) {
    $fullId = $id + $suffix
    $path = "$base\$fullId.json"
    if (-not (Test-Path $path)) { continue }
    if ($suffix -eq "_savage") {
      $he = "true"
      $nameWithSuf = "$($e.n)（零式）"
      $prefix = "Savage 版本"
    } else {
      $he = "false"
      $nameWithSuf = $e.n
      $prefix = "伊甸樂土"
    }
    $ne = (Get-Content $path -Encoding UTF8 | ConvertFrom-Json).nameEn
    $newContent = @"
{
    "id": "$fullId",
    "name": "$nameWithSuf",
    "nameEn": "$ne",
    "expansion": "5.x 漆黑的反叛者 (Shadowbringers)",
    "type": "raid",
    "playerCount": 8,
    "iLvlSync": null,
    "jobLevelSync": 80,
    "highEnd": $he,
    "quality": "needs-update",
    "mnemonic": [
        "$prefix $($e.n)",
        "Boss: $($e.bossTC) ($($e.boss))",
        "詳細機制請參考 Console Games Wiki / Hector Hectorson 攻略"
    ],
    "notes": "5.x ShB Eden raid。Boss 為 $($e.bossTC)（$($e.boss)）。⚠️ 詳細機制限制建議參考外部攻略。",
    "bosses": [
        {
            "name": "$($e.bossTC)",
            "nameEn": "$($e.boss)",
            "mnemonic": ["看 telegraph 預警"],
            "phases": [
                {
                    "name": "主戰",
                    "mechanics": [
                        {
                            "name": "標準 raid 機制",
                            "type": "other",
                            "description": "Eden raid 標準機制：raid-wide AoE、tankbuster、stack、spread。",
                            "tips": ["參考 Hector Hectorson 攻略"]
                        }
                    ]
                }
            ]
        }
    ]
}
"@
    [System.IO.File]::WriteAllText($path, $newContent, $utf8)
    Write-Host "OK: $fullId"
  }
}
