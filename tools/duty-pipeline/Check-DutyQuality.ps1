# Check-DutyQuality.ps1 — 驗證單一副本 JSON 品質。
# 退出碼：0 = 通過，1 = 有警告，2 = 致命錯誤
param(
    [Parameter(Mandatory)][string]$Path
)

if (-not (Test-Path $Path)) {
    Write-Error "File not found: $Path"
    exit 2
}

try {
    $json = Get-Content $Path -Raw -Encoding UTF8 | ConvertFrom-Json
} catch {
    Write-Error "JSON parse failed: $_"
    exit 2
}

$warnings = @()
$errors = @()

# 必要欄位
foreach ($field in @("id","name","nameEn","expansion","type","bosses")) {
    if (-not $json.PSObject.Properties.Name.Contains($field) -or [string]::IsNullOrWhiteSpace($json.$field)) {
        if ($field -eq "bosses") {
            if (-not $json.bosses -or $json.bosses.Count -eq 0) {
                $errors += "Missing required field or empty: $field"
            }
        } else {
            $errors += "Missing required field: $field"
        }
    }
}

# Stub 偵測
$stubPatterns = @(
    "標準機制",
    "副本內含 raid-wide AoE",
    "參考外部攻略",
    "看 telegraph 與 AoE 預警",
    "詳細機制請參考 Console Games Wiki",
    "FFXIV 副本。⚠️ 詳細機制限制建議參考外部攻略",
    "AI 預填內容"
)
$raw = Get-Content $Path -Raw -Encoding UTF8
foreach ($p in $stubPatterns) {
    if ($raw -match [regex]::Escape($p)) {
        $errors += "STUB DETECTED: '$p'"
    }
}

# Mnemonic 至少 3 項
$mnem = $json.mnemonic
if ($mnem -is [array]) {
    if ($mnem.Count -lt 3) { $warnings += "Mnemonic has only $($mnem.Count) items (recommended 3+)" }
} elseif (-not $mnem) {
    $warnings += "Missing mnemonic"
}

# 每隻 Boss 至少 1 個 phase，每個 phase 至少 2 個 mechanic
foreach ($boss in $json.bosses) {
    if (-not $boss.name) { $errors += "Boss missing name" }
    if (-not $boss.nameEn) { $warnings += "Boss '$($boss.name)' missing nameEn" }
    if (-not $boss.phases -or $boss.phases.Count -eq 0) {
        $errors += "Boss '$($boss.name)' has no phases"
        continue
    }
    foreach ($phase in $boss.phases) {
        if (-not $phase.name) { $errors += "Phase missing name in boss '$($boss.name)'" }
        if (-not $phase.mechanics -or $phase.mechanics.Count -eq 0) {
            $errors += "Phase '$($phase.name)' in boss '$($boss.name)' has no mechanics"
        } elseif ($phase.mechanics.Count -lt 2) {
            $warnings += "Phase '$($phase.name)' in boss '$($boss.name)' has only $($phase.mechanics.Count) mechanic"
        }
        # 每個機制必要欄位
        foreach ($m in $phase.mechanics) {
            if (-not $m.name) { $errors += "Mechanic missing name" }
            if (-not $m.description) { $warnings += "Mechanic '$($m.name)' missing description" }
            if (-not $m.type) { $warnings += "Mechanic '$($m.name)' missing type" }
        }
    }
}

# 摘要
$id = $json.id
Write-Host "[$id]" -NoNewline -ForegroundColor Cyan
Write-Host " bosses=$($json.bosses.Count), mechanics=$(($json.bosses.phases.mechanics | Measure-Object).Count), mnemonic=$(if ($mnem -is [array]) { $mnem.Count } else { '1' })"

if ($errors.Count -gt 0) {
    Write-Host "  ERRORS:" -ForegroundColor Red
    $errors | ForEach-Object { Write-Host "    $_" -ForegroundColor Red }
}
if ($warnings.Count -gt 0) {
    Write-Host "  WARNINGS:" -ForegroundColor Yellow
    $warnings | ForEach-Object { Write-Host "    $_" -ForegroundColor Yellow }
}
if ($errors.Count -eq 0 -and $warnings.Count -eq 0) {
    Write-Host "  OK" -ForegroundColor Green
}

if ($errors.Count -gt 0) { exit 2 }
elseif ($warnings.Count -gt 0) { exit 1 }
else { exit 0 }
