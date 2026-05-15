<#
.SYNOPSIS
    從 xivapi/ffxiv-datamining 的 ContentFinderCondition.csv 生成所有 FF14 副本的骨架 JSON。

.DESCRIPTION
    1. 下載最新的 ContentFinderCondition.csv（英文版）
    2. 過濾出實際副本（dungeon / trial / raid / ultimate / criterion / chaotic）
    3. 為每個副本生成一個骨架 JSON 檔案到 data/duties/
    4. 預設「不覆寫」已存在的檔案（保留手寫的詳細機制）

.PARAMETER OutputDir
    輸出資料夾。預設為相對於本腳本的 ../data/duties/

.PARAMETER Force
    覆寫已存在的 JSON 檔案（會清掉手寫內容，請小心）

.EXAMPLE
    pwsh ./tools/Generate-Duties.ps1
    pwsh ./tools/Generate-Duties.ps1 -Force
#>
[CmdletBinding()]
param(
    [string]$OutputDir = (Join-Path $PSScriptRoot "..\data\duties"),
    [switch]$Force
)

$ErrorActionPreference = "Stop"

# --- 對應表 ---
$ExVersionMap = @{
    "0" = "2.x 重生之境 (A Realm Reborn)"
    "1" = "3.x 蒼穹之禁城 (Heavensward)"
    "2" = "4.x 紅蓮之狂潮 (Stormblood)"
    "3" = "5.x 漆黑的反叛者 (Shadowbringers)"
    "4" = "6.x 曉月之終途 (Endwalker)"
    "5" = "7.x 黃金的遺產 (Dawntrail)"
}

# ContentType 對應到 app 內的 type 字串
$ContentTypeMap = @{
    "2"  = @{ Type = "dungeon"; Label = "Dungeon" }
    "4"  = @{ Type = "trial"; Label = "Trial" }
    "5"  = @{ Type = "raid"; Label = "Raid" }
    "21" = @{ Type = "deep_dungeon"; Label = "Deep Dungeon" }
    "26" = @{ Type = "eureka"; Label = "Eureka" }
    "28" = @{ Type = "ultimate"; Label = "Ultimate Raid" }
    "29" = @{ Type = "bozja"; Label = "Save the Queen" }
    "30" = @{ Type = "variant"; Label = "Variant / Criterion" }
    "37" = @{ Type = "chaotic"; Label = "Chaotic Alliance" }
    "38" = @{ Type = "occult"; Label = "Occult Crescent" }
}

# 我們想生成的 ContentType（其餘略過：PvP、Gold Saucer、Triple Triad 等不算副本）
$AcceptedContentTypes = @("2", "4", "5", "21", "28", "29", "30", "37", "38")

# --- 下載 CSV ---
function Invoke-DownloadCsv {
    param([string]$Url, [string]$OutFile)
    if (-not (Test-Path $OutFile) -or (Get-Item $OutFile).Length -lt 1000) {
        Write-Host "  下載 $Url ..." -ForegroundColor DarkGray
        $ProgressPreference = 'SilentlyContinue'
        Invoke-WebRequest -Uri $Url -OutFile $OutFile -UseBasicParsing
    }
}

$tempDir = Join-Path $env:TEMP "ff14_data_gen"
New-Item -ItemType Directory -Force -Path $tempDir | Out-Null

Write-Host "==> 下載 ContentFinderCondition CSVs" -ForegroundColor Cyan
$baseUrl = "https://raw.githubusercontent.com/xivapi/ffxiv-datamining/master/csv"
Invoke-DownloadCsv -Url "$baseUrl/en/ContentFinderCondition.csv" -OutFile "$tempDir\cfc_en.csv"

# --- 解析 CSV (用 .NET TextFieldParser 處理引號) ---
Add-Type -AssemblyName "Microsoft.VisualBasic"

function Read-Csv {
    param([string]$Path)

    $parser = New-Object Microsoft.VisualBasic.FileIO.TextFieldParser($Path)
    $parser.TextFieldType = [Microsoft.VisualBasic.FileIO.FieldType]::Delimited
    $parser.SetDelimiters(',')
    $parser.HasFieldsEnclosedInQuotes = $true
    $parser.TrimWhiteSpace = $false

    try {
        $header = $parser.ReadFields()
        $rows = @()
        while (-not $parser.EndOfData) {
            $fields = $parser.ReadFields()
            $obj = [ordered]@{}
            for ($i = 0; $i -lt $header.Count; $i++) {
                $colName = $header[$i]
                if ($colName -eq "#") { $colName = "Id" }
                $obj[$colName] = if ($i -lt $fields.Count) { $fields[$i] } else { "" }
            }
            $rows += [pscustomobject]$obj
        }
        return $rows
    } finally {
        $parser.Close()
    }
}

Write-Host "==> 解析 CSV" -ForegroundColor Cyan
$rows = Read-Csv -Path "$tempDir\cfc_en.csv"
Write-Host "  讀取 $($rows.Count) 列"

# --- 過濾出實際副本 ---
# Ultimates (ContentType=28) 的 IsInDutyFinder 是 False，需要特殊處理
$duties = $rows | Where-Object {
    $_.Name -and $_.Name.Trim() -ne "" -and
    $AcceptedContentTypes -contains $_.ContentType -and
    ($_.IsInDutyFinder -eq "True" -or $_.ContentType -eq "28")
}
Write-Host "  過濾後：$($duties.Count) 個副本" -ForegroundColor Green

# --- ContentMemberType 對應到人數 (供參考；目前不使用) ---
$MemberTypeToPlayers = @{
    "2" = 4
    "3" = 8
    "4" = 24
}

# --- 各 ContentType 預設人數 (供參考) ---
$ContentTypeDefaultPlayers = @{
    "2"  = 4    # Dungeon
    "4"  = 8    # Trial
    "5"  = 8    # Raid
    "21" = 4    # Deep Dungeon
    "28" = 8    # Ultimate
    "29" = 48   # Save the Queen
    "30" = 4    # Variant
    "37" = 24   # Chaotic Alliance
    "38" = 48   # Occult Crescent
}

# --- Slug 函式：英文名 → 檔名 ---
function ConvertTo-Slug {
    param([string]$Name)

    # 1. Unicode 正規化：將帶重音字元分解 (é -> e + ́)
    $normalized = $Name.Normalize([System.Text.NormalizationForm]::FormD)

    # 2. 去除組合符號（重音記號），其餘字元保留
    $sb = New-Object System.Text.StringBuilder
    foreach ($c in $normalized.ToCharArray()) {
        $cat = [System.Globalization.CharUnicodeInfo]::GetUnicodeCategory($c)
        if ($cat -ne [System.Globalization.UnicodeCategory]::NonSpacingMark) {
            [void]$sb.Append($c)
        }
    }
    $s = $sb.ToString().ToLowerInvariant()

    # 3. 去除前置 "the "
    $s = [System.Text.RegularExpressions.Regex]::Replace($s, '^the\s+', '')

    # 4. 替換 "&" → "and"
    $s = $s -replace '&', ' and '

    # 5. 去除所有非英數、空白、連字號的字元
    $s = [System.Text.RegularExpressions.Regex]::Replace($s, '[^a-z0-9\s\-]', '')

    # 6. 空白 → 底線
    $s = [System.Text.RegularExpressions.Regex]::Replace($s, '\s+', '_')
    $s = [System.Text.RegularExpressions.Regex]::Replace($s, '_+', '_')

    return $s.Trim('_', '-')
}

# --- 生成 JSON 檔案 ---
Write-Host "==> 生成 JSON 到 $OutputDir" -ForegroundColor Cyan
New-Item -ItemType Directory -Force -Path $OutputDir | Out-Null

$created = 0
$skipped = 0
$overwritten = 0
$usedIds = @{}

foreach ($d in $duties) {
    $name = $d.Name.Trim()
    # 名稱首字大寫 (xivapi 有些是 "the Navel" → "The Navel")
    if ($name.Length -gt 0) {
        $name = $name.Substring(0,1).ToUpperInvariant() + $name.Substring(1)
    }
    $slug = ConvertTo-Slug -Name $name
    if ([string]::IsNullOrWhiteSpace($slug)) { continue }

    # 解決重複 slug：append _2, _3
    $baseSlug = $slug
    $n = 2
    while ($usedIds.ContainsKey($slug)) {
        $slug = "${baseSlug}_$n"
        $n++
    }
    $usedIds[$slug] = $true

    $outFile = Join-Path $OutputDir "$slug.json"
    if ((Test-Path $outFile) -and -not $Force) {
        $skipped++
        continue
    }

    $expansion = $ExVersionMap[$d.RequiredExVersion]
    $typeInfo = $ContentTypeMap[$d.ContentType]
    $type = $typeInfo.Type

    # 推算人數：以 ContentType 為主，搭配 ContentMemberType 區分 alliance raid
    # (xivapi 的 ContentMemberType 對 trials 有時不準，所以採用 ContentType 為基準)
    $cmt = $d.ContentMemberType
    $allianceRaidMembers = @("4","5","26","27","28","32","36")  # 三方聯軍 (24人) 對應的 CMT
    $playerCount = switch ($d.ContentType) {
        "2"  { 4 }                                                  # Dungeon
        "4"  { 8 }                                                  # Trial
        "5"  { if ($allianceRaidMembers -contains $cmt) { 24 } else { 8 } }  # Raid
        "21" { if ($cmt -eq "1") { 1 } else { 4 } }                 # Deep Dungeon
        "28" { 8 }                                                  # Ultimate
        "29" { 48 }                                                 # Save the Queen (Bozja/Zadnor)
        "30" { 4 }                                                  # Variant / Criterion
        "37" { 24 }                                                 # Chaotic Alliance
        "38" { 48 }                                                 # Occult Crescent
        default { $null }
    }

    # 若 QueueMaxPlayers 有明確且合理值，優先使用
    if (($d.QueueMaxPlayers -as [int]) -and [int]$d.QueueMaxPlayers -gt 0) {
        $playerCount = [int]$d.QueueMaxPlayers
    }

    $iLvlSync = $null
    if (($d.ItemLevelSync -as [int]) -and [int]$d.ItemLevelSync -gt 0) {
        $iLvlSync = [int]$d.ItemLevelSync
    }

    $jobLevelSync = $null
    if (($d.ClassJobLevelSync -as [int]) -and [int]$d.ClassJobLevelSync -gt 0) {
        $jobLevelSync = [int]$d.ClassJobLevelSync
    }

    $highEnd = ($d.HighEndDuty -eq "True")

    $duty = [ordered]@{
        id           = $slug
        name         = $name
        nameEn       = $name
        expansion    = $expansion
        type         = $type
        playerCount  = $playerCount
        iLvlSync     = $iLvlSync
        jobLevelSync = $jobLevelSync
        highEnd      = $highEnd
        notes        = "（此副本為自動生成骨架，歡迎透過 PR 補充機制提示！）"
        bosses       = @()
    }

    $json = $duty | ConvertTo-Json -Depth 10
    # PowerShell ConvertTo-Json 的格式清理：
    # - 移除冒號後的多餘空白 ("foo":  "bar" → "foo": "bar")
    # - 美化空陣列 ([           ] → [])
    $json = [System.Text.RegularExpressions.Regex]::Replace($json, '":\s{2,}', '": ')
    $json = [System.Text.RegularExpressions.Regex]::Replace($json, '\[\s+\]', '[]')
    $json = $json -replace "`r`n", "`n"

    $existed = Test-Path $outFile
    [System.IO.File]::WriteAllText($outFile, $json, [System.Text.UTF8Encoding]::new($false))
    if ($existed) { $overwritten++ } else { $created++ }
}

Write-Host ""
Write-Host "=== 完成 ===" -ForegroundColor Green
Write-Host "  新建：$created 個檔案" -ForegroundColor Green
Write-Host "  覆寫：$overwritten 個檔案" -ForegroundColor Yellow
Write-Host "  略過（已存在）：$skipped 個檔案" -ForegroundColor DarkGray
Write-Host ""
Write-Host "若要覆寫已存在的檔案，請加上 -Force 參數" -ForegroundColor DarkGray
