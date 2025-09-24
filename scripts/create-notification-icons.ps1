# PowerShell script to create colored notification icons for Codex
# Run this from Windows PowerShell to generate icon files

Add-Type -AssemblyName System.Drawing

$iconDir = "$env:USERPROFILE\.codex\icons"
if (-not (Test-Path $iconDir)) {
    New-Item -ItemType Directory -Path $iconDir -Force
}

# Function to create a colored square icon
function Create-Icon {
    param(
        [string]$Color,
        [string]$Text,
        [string]$FileName
    )

    $bitmap = New-Object System.Drawing.Bitmap 256, 256
    $graphics = [System.Drawing.Graphics]::FromImage($bitmap)

    # Fill background with color
    $brush = New-Object System.Drawing.SolidBrush ([System.Drawing.ColorTranslator]::FromHtml($Color))
    $graphics.FillRectangle($brush, 0, 0, 256, 256)

    # Add text in the center
    $font = New-Object System.Drawing.Font("Segoe UI Emoji", 96, [System.Drawing.FontStyle]::Bold)
    $textBrush = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::White)
    $stringFormat = New-Object System.Drawing.StringFormat
    $stringFormat.Alignment = [System.Drawing.StringAlignment]::Center
    $stringFormat.LineAlignment = [System.Drawing.StringAlignment]::Center

    $rectangle = New-Object System.Drawing.RectangleF(0, 0, 256, 256)
    $graphics.DrawString($Text, $font, $textBrush, $rectangle, $stringFormat)

    # Save the image
    $bitmap.Save("$iconDir\$FileName", [System.Drawing.Imaging.ImageFormat]::Png)

    # Clean up
    $graphics.Dispose()
    $bitmap.Dispose()
    $brush.Dispose()
    $textBrush.Dispose()
    $font.Dispose()
}

# Create icons for each notification type
Write-Host "Creating notification icons..." -ForegroundColor Cyan

Create-Icon -Color "#28a745" -Text "✓" -FileName "success.png"  # Green
Write-Host "✅ Created success.png" -ForegroundColor Green

Create-Icon -Color "#dc3545" -Text "✕" -FileName "error.png"    # Red
Write-Host "❌ Created error.png" -ForegroundColor Red

Create-Icon -Color "#ffc107" -Text "🔒" -FileName "approval.png" # Yellow/Amber
Write-Host "🔐 Created approval.png" -ForegroundColor Yellow

Create-Icon -Color "#fd7e14" -Text "⚠" -FileName "warning.png"  # Orange
Write-Host "⚠️ Created warning.png" -ForegroundColor DarkYellow

Create-Icon -Color "#17a2b8" -Text "ℹ" -FileName "info.png"     # Cyan
Write-Host "ℹ️ Created info.png" -ForegroundColor Cyan

Create-Icon -Color "#6c757d" -Text "⏱" -FileName "longrun.png"  # Gray
Write-Host "⏱️ Created longrun.png" -ForegroundColor Gray

Write-Host "`nAll icons created in: $iconDir" -ForegroundColor Green
Write-Host "Icons will be used automatically by the notification system." -ForegroundColor Cyan