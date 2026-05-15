<#
.SYNOPSIS
    FF14 Boss 名稱查找工具 (dot-source 使用)。

.USAGE
    . .\tools\BossLookup.ps1
    Find-Boss "Galvanth the Dominator"
    # 回傳：主宰者 加爾梵斯
#>

$script:_DataDir = "$env:TEMP\ff14_data_gen"
New-Item -ItemType Directory -Force -Path $script:_DataDir | Out-Null

# Download once if missing
$ProgressPreference = 'SilentlyContinue'
$downloads = @(
    @{ Url = "https://raw.githubusercontent.com/xivapi/ffxiv-datamining/master/csv/en/BNpcName.csv"; File = "bnpc_en.csv" }
    @{ Url = "https://raw.githubusercontent.com/thewakingsands/ffxiv-datamining-cn/master/BNpcName.csv"; File = "bnpc_cn.csv" }
    @{ Url = "https://raw.githubusercontent.com/BYVoid/OpenCC/master/data/dictionary/STCharacters.txt"; File = "opencc_st.txt" }
)
foreach ($d in $downloads) {
    $p = Join-Path $script:_DataDir $d.File
    if (-not (Test-Path $p) -or (Get-Item $p).Length -lt 1000) {
        Write-Host "Downloading $($d.File)..." -ForegroundColor DarkGray
        Invoke-WebRequest -Uri $d.Url -OutFile $p -UseBasicParsing
    }
}

$script:_EnLines = [System.IO.File]::ReadAllText("$script:_DataDir\bnpc_en.csv", [System.Text.UTF8Encoding]::new($false)) -split "`n"
$script:_CnLines = [System.IO.File]::ReadAllText("$script:_DataDir\bnpc_cn.csv", [System.Text.UTF8Encoding]::new($false)) -split "`n"

$script:_OpenccMap = @{}
foreach ($line in [System.IO.File]::ReadAllLines("$script:_DataDir\opencc_st.txt", [System.Text.UTF8Encoding]::new($false))) {
    if ([string]::IsNullOrWhiteSpace($line) -or $line.StartsWith('#')) { continue }
    $parts = $line.Split("`t")
    if ($parts.Count -ge 2) {
        $script:_OpenccMap[$parts[0]] = $parts[1].Split(' ')[0]
    }
}

function ConvertTo-TC {
    param([string]$Text)
    if ([string]::IsNullOrEmpty($Text)) { return $Text }
    $sb = New-Object System.Text.StringBuilder
    foreach ($c in $Text.ToCharArray()) {
        $cs = [string]$c
        if ($script:_OpenccMap.ContainsKey($cs)) {
            [void]$sb.Append($script:_OpenccMap[$cs])
        } else {
            [void]$sb.Append($c)
        }
    }
    return $sb.ToString()
}

function Find-Boss {
    param([string]$Name)
    if ([string]::IsNullOrEmpty($Name)) { return $null }
    $enRow = $script:_EnLines | Where-Object { $_ -like "*,$Name,*" } | Select-Object -First 1
    if (-not $enRow) { return $null }
    $id = ($enRow -split ',')[0]
    $cnRow = $script:_CnLines | Where-Object { $_ -match "^$id," } | Select-Object -First 1
    if (-not $cnRow) { return $null }
    $cnName = ($cnRow -split '"')[1]
    if ([string]::IsNullOrWhiteSpace($cnName)) { return $null }
    return ConvertTo-TC $cnName
}

function Lookup-Bosses {
    param([string[]]$Names)
    foreach ($n in $Names) {
        $r = Find-Boss $n
        $display = if ($r) { $r } else { '(NOT FOUND)' }
        Write-Host ("  {0,-32} : {1}" -f $n, $display)
    }
}

Write-Host "BossLookup loaded. Available: Find-Boss, Lookup-Bosses, ConvertTo-TC" -ForegroundColor Green
