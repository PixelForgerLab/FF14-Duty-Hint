. "$PSScriptRoot\lib\Fetch-CGW.ps1"
foreach ($kw in @('Ageless Necropolis','Alzadaal','Clyteum','Gilded Araya','Hell','Interphos','Skydeep','Strayborough','Windward','Meso')) {
    Write-Host "=== $kw ==="
    $r = Search-CGW -Keyword $kw -Limit 5
    if ($r) { $r | ForEach-Object { Write-Host "  $_" } }
}
