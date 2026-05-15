<#
.SYNOPSIS
    生成 FF14 Duty Hint 的應用程式 icon (.ico)。

.DESCRIPTION
    用 System.Drawing 繪製 multi-size icon:
    - 深色圓角背景 (#1A1A1F)
    - 金色六角形 (FF14 主題)
    - 中央 "i" 字 (info / hint)

.OUTPUT
    icon.ico (含 16/32/48/64/128/256 sizes)
    icon.png (256px 預覽)
#>
[CmdletBinding()]
param(
    [string]$OutputDir = (Join-Path $PSScriptRoot "..\src\FF14DutyHint\Resources")
)

$ErrorActionPreference = "Stop"
Add-Type -AssemblyName System.Drawing

New-Item -ItemType Directory -Force -Path $OutputDir | Out-Null

# 顏色配置（與 app 主題一致）
$bgColor = [System.Drawing.Color]::FromArgb(255, 0x1A, 0x1A, 0x1F)
$accentColor = [System.Drawing.Color]::FromArgb(255, 0xFF, 0xB3, 0x47)  # 金色
$accentDarkColor = [System.Drawing.Color]::FromArgb(255, 0xC9, 0x85, 0x20)
$textColor = [System.Drawing.Color]::FromArgb(255, 0x1A, 0x1A, 0x1F)
$borderColor = [System.Drawing.Color]::FromArgb(255, 0xFF, 0xD8, 0x80)

function New-IconBitmap {
    param([int]$Size)

    $bmp = New-Object System.Drawing.Bitmap $Size, $Size
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $g.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
    $g.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::AntiAliasGridFit

    # 1. 深色圓角背景
    $cornerRadius = [Math]::Max(2, [int]($Size * 0.18))
    $bgRect = New-Object System.Drawing.Rectangle 0, 0, $Size, $Size
    $bgPath = New-Object System.Drawing.Drawing2D.GraphicsPath
    $d = $cornerRadius * 2
    $bgPath.AddArc($bgRect.X, $bgRect.Y, $d, $d, 180, 90)
    $bgPath.AddArc($bgRect.Right - $d, $bgRect.Y, $d, $d, 270, 90)
    $bgPath.AddArc($bgRect.Right - $d, $bgRect.Bottom - $d, $d, $d, 0, 90)
    $bgPath.AddArc($bgRect.X, $bgRect.Bottom - $d, $d, $d, 90, 90)
    $bgPath.CloseFigure()
    $bgBrush = New-Object System.Drawing.SolidBrush $bgColor
    $g.FillPath($bgBrush, $bgPath)
    $bgBrush.Dispose()
    $bgPath.Dispose()

    # 2. 中央六角形 (FF14 raid icon 風格)
    $cx = $Size / 2.0
    $cy = $Size / 2.0
    $hexRadius = $Size * 0.34
    $hexPoints = New-Object System.Drawing.PointF[] 6
    for ($i = 0; $i -lt 6; $i++) {
        # 頂點在上方 (旋轉 -90 度)
        $angle = [Math]::PI / 3 * $i - [Math]::PI / 2
        $hexPoints[$i] = New-Object System.Drawing.PointF (
            [single]($cx + $hexRadius * [Math]::Cos($angle)),
            [single]($cy + $hexRadius * [Math]::Sin($angle))
        )
    }
    # 用線性漸層填充（亮金到暗金）
    $gradRect = New-Object System.Drawing.RectangleF (
        [single]($cx - $hexRadius), [single]($cy - $hexRadius),
        [single]($hexRadius * 2), [single]($hexRadius * 2)
    )
    $hexBrush = New-Object System.Drawing.Drawing2D.LinearGradientBrush $gradRect, $accentColor, $accentDarkColor, 90.0
    $g.FillPolygon($hexBrush, $hexPoints)
    $hexBrush.Dispose()

    # 六角形外框
    if ($Size -ge 32) {
        $borderPen = New-Object System.Drawing.Pen $borderColor, ([single]([Math]::Max(1, $Size / 64)))
        $g.DrawPolygon($borderPen, $hexPoints)
        $borderPen.Dispose()
    }

    # 3. 中央 "i" 字 (info / hint)
    if ($Size -ge 32) {
        $fontSize = [single]($Size * 0.45)
        $fontFamily = New-Object System.Drawing.FontFamily "Segoe UI"
        $font = New-Object System.Drawing.Font $fontFamily, $fontSize, ([System.Drawing.FontStyle]::Bold), ([System.Drawing.GraphicsUnit]::Pixel)
        $textBrush = New-Object System.Drawing.SolidBrush $textColor
        $sf = New-Object System.Drawing.StringFormat
        $sf.Alignment = [System.Drawing.StringAlignment]::Center
        $sf.LineAlignment = [System.Drawing.StringAlignment]::Center
        $rectF = New-Object System.Drawing.RectangleF 0, 0, $Size, $Size
        # 微調往上 (因為 "i" 字本身偏低)
        $rectF.Y = [single]($Size * -0.03)
        $g.DrawString("i", $font, $textBrush, $rectF, $sf)
        $textBrush.Dispose()
        $font.Dispose()
        $fontFamily.Dispose()
        $sf.Dispose()
    } else {
        # 小尺寸 (16, 24): 用一個簡單的點代表 "i" 的點
        $dotSize = [int]([Math]::Max(2, $Size * 0.18))
        $dotBrush = New-Object System.Drawing.SolidBrush $textColor
        $g.FillEllipse($dotBrush, [int]($cx - $dotSize / 2), [int]($cy - $dotSize / 2), $dotSize, $dotSize)
        $dotBrush.Dispose()
    }

    $g.Dispose()
    return $bmp
}

# 生成多個 size
$sizes = @(16, 24, 32, 48, 64, 128, 256)
$bitmaps = @{}
foreach ($size in $sizes) {
    Write-Host "  Drawing ${size}x${size}..." -ForegroundColor DarkGray
    $bitmaps[$size] = New-IconBitmap -Size $size
}

# 輸出 256px PNG 預覽
$previewPath = Join-Path $OutputDir "icon-preview.png"
$bitmaps[256].Save($previewPath, [System.Drawing.Imaging.ImageFormat]::Png)
Write-Host "✓ Preview: $previewPath" -ForegroundColor Green

# 組合成 .ico
# ICO 檔案格式: header(6) + dir entries(16 each) + image data
$icoPath = Join-Path $OutputDir "app.ico"
$ms = New-Object System.IO.MemoryStream
$bw = New-Object System.IO.BinaryWriter $ms

# Header: reserved(2)=0, type(2)=1 (icon), count(2)
$bw.Write([UInt16]0)
$bw.Write([UInt16]1)
$bw.Write([UInt16]$sizes.Count)

# 預先計算每個 image 的 PNG bytes
$imageBytes = @{}
foreach ($size in $sizes) {
    $tmpMs = New-Object System.IO.MemoryStream
    $bitmaps[$size].Save($tmpMs, [System.Drawing.Imaging.ImageFormat]::Png)
    $imageBytes[$size] = $tmpMs.ToArray()
    $tmpMs.Dispose()
}

# Directory entries (各 16 bytes)
$dataOffset = 6 + 16 * $sizes.Count
foreach ($size in $sizes) {
    $bytes = $imageBytes[$size]
    $bw.Write([byte]$(if ($size -ge 256) { 0 } else { $size }))  # width (0 = 256)
    $bw.Write([byte]$(if ($size -ge 256) { 0 } else { $size }))  # height
    $bw.Write([byte]0)         # color palette
    $bw.Write([byte]0)         # reserved
    $bw.Write([UInt16]1)       # color planes
    $bw.Write([UInt16]32)      # bits per pixel
    $bw.Write([UInt32]$bytes.Length)  # size of image data
    $bw.Write([UInt32]$dataOffset)    # offset to image data
    $dataOffset += $bytes.Length
}

# Image data (PNG bytes)
foreach ($size in $sizes) {
    $bw.Write($imageBytes[$size])
}

$bw.Flush()
[System.IO.File]::WriteAllBytes($icoPath, $ms.ToArray())
$bw.Dispose()
$ms.Dispose()
Write-Host "✓ ICO: $icoPath ($((Get-Item $icoPath).Length) bytes)" -ForegroundColor Green

# Cleanup bitmaps
foreach ($bmp in $bitmaps.Values) { $bmp.Dispose() }

Write-Host ""
Write-Host "Done! Files generated in $OutputDir" -ForegroundColor Cyan
