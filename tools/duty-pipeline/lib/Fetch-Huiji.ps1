# Fetch-Huiji.ps1 — 灰機 wiki MediaWiki API wrapper with disk cache.
# CloudFlare 擋 PowerShell 的 Invoke-RestMethod，所以一律走 curl.exe。

$script:HuijiBase = "https://ff14.huijiwiki.com/api.php"
$script:HuijiUA   = "FF14HintBot/1.0 (https://github.com/PixelForgerLab/FF14-Duty-Hint)"
$script:HuijiCacheDir = Join-Path $PSScriptRoot "..\data\cache\huiji"

function Get-HuijiPageWikitext {
    <#
    .SYNOPSIS
        Fetch a page's raw wikitext from huijiwiki. Cached on disk per page name.
    .EXAMPLE
        Get-HuijiPageWikitext -Title "光暗未来绝境战"
        Get-HuijiPageWikitext -Title "光暗未来绝境战/B"
    #>
    param(
        [Parameter(Mandatory)][string]$Title,
        [switch]$ForceRefresh
    )
    $safeName = ($Title -replace '[\\/:*?"<>|]','_')
    $cachePath = Join-Path $script:HuijiCacheDir "$safeName.wikitext"
    if (-not $ForceRefresh -and (Test-Path $cachePath)) {
        return Get-Content $cachePath -Raw -Encoding UTF8
    }
    $encoded = [System.Uri]::EscapeDataString($Title)
    $url = "$($script:HuijiBase)?action=parse&format=json&prop=wikitext&page=$encoded"
    $tmp = [System.IO.Path]::GetTempFileName()
    try {
        & curl.exe -A $script:HuijiUA -s -o $tmp $url | Out-Null
        $json = Get-Content $tmp -Raw -Encoding UTF8 | ConvertFrom-Json
        if ($json.error) {
            Write-Warning "Huiji: $Title -> $($json.error.info)"
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

function Search-HuijiPages {
    <#
    .SYNOPSIS
        OpenSearch query on huijiwiki. Returns array of page titles matching keyword.
    #>
    param(
        [Parameter(Mandatory)][string]$Keyword,
        [int]$Limit = 10
    )
    $encoded = [System.Uri]::EscapeDataString($Keyword)
    $url = "$($script:HuijiBase)?action=opensearch&format=json&limit=$Limit&search=$encoded"
    $tmp = [System.IO.Path]::GetTempFileName()
    try {
        & curl.exe -A $script:HuijiUA -s -o $tmp $url | Out-Null
        $raw = Get-Content $tmp -Raw -Encoding UTF8 | ConvertFrom-Json
        Start-Sleep -Milliseconds 500
        # OpenSearch shape: [query, [titles], [descriptions], [urls]]
        return $raw[1]
    } finally {
        Remove-Item $tmp -Force -ErrorAction SilentlyContinue
    }
}

function Get-HuijiPageHtml {
    <#
    .SYNOPSIS
        Fetch parsed HTML (better for stripping templates). Cached separately.
    #>
    param(
        [Parameter(Mandatory)][string]$Title,
        [switch]$ForceRefresh
    )
    $safeName = ($Title -replace '[\\/:*?"<>|]','_')
    $cachePath = Join-Path $script:HuijiCacheDir "$safeName.html"
    if (-not $ForceRefresh -and (Test-Path $cachePath)) {
        return Get-Content $cachePath -Raw -Encoding UTF8
    }
    $encoded = [System.Uri]::EscapeDataString($Title)
    $url = "$($script:HuijiBase)?action=parse&format=json&prop=text&page=$encoded"
    $tmp = [System.IO.Path]::GetTempFileName()
    try {
        & curl.exe -A $script:HuijiUA -s -o $tmp $url | Out-Null
        $json = Get-Content $tmp -Raw -Encoding UTF8 | ConvertFrom-Json
        if ($json.error) {
            Write-Warning "Huiji HTML: $Title -> $($json.error.info)"
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
