# Convert-S2T.ps1 — 簡體中文 → 繁體中文 converter.
# 利用 zh.wikipedia.org MediaWiki API 的 variant=zh-tw 變體轉換。
# 為了節省 API 呼叫，傳入字串以特殊分隔符串接後一次轉換。

$script:WikiApi = "https://zh.wikipedia.org/w/api.php"
$script:S2TCacheDir = Join-Path $PSScriptRoot "..\data\cache\s2t"
$script:S2TSeparator = "‖SEP‖"  # 不太可能出現在 wiki 文本內

function Convert-SimplifiedToTraditional {
    <#
    .SYNOPSIS
        Convert one or more simplified-Chinese strings to Traditional Chinese (zh-tw).
    .DESCRIPTION
        - 單字串呼叫：直接轉換並回傳字串。
        - 多字串呼叫：以 ‖SEP‖ 分隔串接後一次性轉換，回傳同樣長度的字串陣列。
        Cache 儲存每個輸入字串的轉換結果（avoid 重複 API 呼叫）。
    .EXAMPLE
        Convert-SimplifiedToTraditional "暴风破"
        Convert-SimplifiedToTraditional @("绝命战士", "希瓦·米特隆", "暴风破")
    #>
    param(
        [Parameter(Mandatory, ValueFromPipeline)][string[]]$InputString
    )
    begin {
        $allInputs = @()
    }
    process {
        $allInputs += $InputString
    }
    end {
        if ($allInputs.Count -eq 0) { return @() }

        # 結果陣列 + 需要實際 API 呼叫的索引
        $results = New-Object string[] $allInputs.Count
        $needsFetchIdx = @()
        $needsFetchStr = @()
        for ($i = 0; $i -lt $allInputs.Count; $i++) {
            $s = $allInputs[$i]
            if ([string]::IsNullOrWhiteSpace($s)) { $results[$i] = $s; continue }
            $cacheKey = [System.BitConverter]::ToString(
                [System.Security.Cryptography.SHA256]::Create().ComputeHash(
                    [System.Text.Encoding]::UTF8.GetBytes($s)
                )
            ).Replace("-","").Substring(0,16)
            $cachePath = Join-Path $script:S2TCacheDir "$cacheKey.txt"
            if (Test-Path $cachePath) {
                $results[$i] = Get-Content $cachePath -Raw -Encoding UTF8
            } else {
                $needsFetchIdx += $i
                $needsFetchStr += $s
            }
        }

        if ($needsFetchStr.Count -gt 0) {
            # 一次 batch 最多 ~5000 字（safety）
            $joined = $needsFetchStr -join $script:S2TSeparator
            $body = @{
                action = 'parse'
                format = 'json'
                contentmodel = 'wikitext'
                prop = 'text'
                disablelimitreport = '1'
                disabletoc = '1'
                variant = 'zh-tw'
                text = $joined
            }
            $tmp = [System.IO.Path]::GetTempFileName()
            $bodyFile = [System.IO.Path]::GetTempFileName()
            try {
                $bodyStr = ($body.GetEnumerator() | ForEach-Object {
                    "$($_.Key)=$([System.Uri]::EscapeDataString($_.Value))"
                }) -join '&'
                [System.IO.File]::WriteAllText($bodyFile, $bodyStr, [System.Text.UTF8Encoding]::new($false))
                & curl.exe -A "FF14HintBot/1.0" -s -X POST `
                    -H "Content-Type: application/x-www-form-urlencoded" `
                    --data-binary "@$bodyFile" `
                    -o $tmp $script:WikiApi | Out-Null
                $resp = Get-Content $tmp -Raw -Encoding UTF8 | ConvertFrom-Json
                if ($resp.error) {
                    Write-Warning "S2T API error: $($resp.error.info)"
                    foreach ($idx in $needsFetchIdx) { $results[$idx] = $allInputs[$idx] }
                } else {
                    # 把回傳的 HTML 去掉 tag、把分隔符還原成個別字串
                    $html = $resp.parse.text.'*'
                    # 移除所有 HTML tag
                    $plain = [regex]::Replace($html, '<[^>]+>', '')
                    # 解 HTML entities
                    $plain = [System.Net.WebUtility]::HtmlDecode($plain)
                    $plain = $plain.Trim()
                    # 拆回原本的字串
                    $pieces = $plain -split [regex]::Escape($script:S2TSeparator)
                    if ($pieces.Count -ne $needsFetchStr.Count) {
                        Write-Warning "S2T split count mismatch: got $($pieces.Count), expected $($needsFetchStr.Count)"
                    }
                    for ($k = 0; $k -lt $needsFetchIdx.Count -and $k -lt $pieces.Count; $k++) {
                        $idx = $needsFetchIdx[$k]
                        $tw  = $pieces[$k].Trim()
                        $results[$idx] = $tw
                        # cache it
                        $orig = $allInputs[$idx]
                        $cacheKey = [System.BitConverter]::ToString(
                            [System.Security.Cryptography.SHA256]::Create().ComputeHash(
                                [System.Text.Encoding]::UTF8.GetBytes($orig)
                            )
                        ).Replace("-","").Substring(0,16)
                        $cachePath = Join-Path $script:S2TCacheDir "$cacheKey.txt"
                        Set-Content -Path $cachePath -Value $tw -Encoding UTF8 -NoNewline
                    }
                }
                Start-Sleep -Milliseconds 600
            } finally {
                Remove-Item $tmp,$bodyFile -Force -ErrorAction SilentlyContinue
            }
        }

        if ($results.Count -eq 1) { return $results[0] }
        return $results
    }
}
