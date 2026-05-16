# Fetch-CGW.ps1 — Console Games Wiki (ffxiv.consolegameswiki.com) wrapper.

$script:CGWBase = "https://ffxiv.consolegameswiki.com/mediawiki/api.php"
$script:CGWUA   = "FF14HintBot/1.0 (https://github.com/PixelForgerLab/FF14-Duty-Hint)"
$script:CGWCacheDir = Join-Path $PSScriptRoot "..\data\cache\cgw"

function Get-CGWPageWikitext {
    param(
        [Parameter(Mandatory)][string]$Title,
        [switch]$ForceRefresh
    )
    $safeName = ($Title -replace '[\\/:*?"<>|]','_')
    $cachePath = Join-Path $script:CGWCacheDir "$safeName.wikitext"
    if (-not $ForceRefresh -and (Test-Path $cachePath)) {
        return Get-Content $cachePath -Raw -Encoding UTF8
    }
    $encoded = [System.Uri]::EscapeDataString($Title)
    $url = "$($script:CGWBase)?action=parse&format=json&prop=wikitext&page=$encoded"
    $tmp = [System.IO.Path]::GetTempFileName()
    try {
        & curl.exe -A $script:CGWUA -s -o $tmp $url | Out-Null
        $json = Get-Content $tmp -Raw -Encoding UTF8 | ConvertFrom-Json
        if ($json.error) {
            Write-Warning "CGW: $Title -> $($json.error.info)"
            return $null
        }
        $wikitext = $json.parse.wikitext.'*'
        Set-Content -Path $cachePath -Value $wikitext -Encoding UTF8 -NoNewline
        Start-Sleep -Milliseconds 800
        return $wikitext
    } finally {
        Remove-Item $tmp -Force -ErrorAction SilentlyContinue
    }
}

function Get-CGWPageHtml {
    param(
        [Parameter(Mandatory)][string]$Title,
        [switch]$ForceRefresh
    )
    $safeName = ($Title -replace '[\\/:*?"<>|]','_')
    $cachePath = Join-Path $script:CGWCacheDir "$safeName.html"
    if (-not $ForceRefresh -and (Test-Path $cachePath)) {
        return Get-Content $cachePath -Raw -Encoding UTF8
    }
    $encoded = [System.Uri]::EscapeDataString($Title)
    $url = "$($script:CGWBase)?action=parse&format=json&prop=text&page=$encoded"
    $tmp = [System.IO.Path]::GetTempFileName()
    try {
        & curl.exe -A $script:CGWUA -s -o $tmp $url | Out-Null
        $json = Get-Content $tmp -Raw -Encoding UTF8 | ConvertFrom-Json
        if ($json.error) {
            Write-Warning "CGW HTML: $Title -> $($json.error.info)"
            return $null
        }
        $html = $json.parse.text.'*'
        Set-Content -Path $cachePath -Value $html -Encoding UTF8 -NoNewline
        Start-Sleep -Milliseconds 800
        return $html
    } finally {
        Remove-Item $tmp -Force -ErrorAction SilentlyContinue
    }
}

function Search-CGW {
    param([Parameter(Mandatory)][string]$Keyword, [int]$Limit = 10)
    $encoded = [System.Uri]::EscapeDataString($Keyword)
    $url = "$($script:CGWBase)?action=opensearch&format=json&limit=$Limit&search=$encoded"
    $tmp = [System.IO.Path]::GetTempFileName()
    try {
        & curl.exe -A $script:CGWUA -s -o $tmp $url | Out-Null
        $raw = Get-Content $tmp -Raw -Encoding UTF8 | ConvertFrom-Json
        Start-Sleep -Milliseconds 500
        return $raw[1]
    } finally {
        Remove-Item $tmp -Force -ErrorAction SilentlyContinue
    }
}
