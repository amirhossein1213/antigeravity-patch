#Requires -Version 5.1
param(
    [switch]$Quiet,
    [switch]$Auto
)

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$Host.UI.RawUI.WindowTitle = "حذف پچ ضد تحریم Google Antigravity"

function Safe-ReadHost($prompt, $default="") {
    if ($Quiet -or $Auto -or [Console]::IsInputRedirected) { return $default }
    try {
        $res = Read-Host $prompt
        if ([string]::IsNullOrWhiteSpace($res)) { return $default }
        return $res
    } catch { return $default }
}

if (-not $Quiet) {
    Clear-Host
    Write-Host "======================================================================" -ForegroundColor Cyan
    Write-Host "                حذف پچ ضد تحریم Google Antigravity                    " -ForegroundColor Yellow
    Write-Host "======================================================================" -ForegroundColor Cyan
    Write-Host ""
}

$targets = @(
    (Join-Path $env:LOCALAPPDATA "Programs\Antigravity IDE"),
    (Join-Path $env:LOCALAPPDATA "Programs\Antigravity")
)

foreach ($dir in $targets) {
    if (Test-Path $dir) {
        Write-Host "[+] در حال پاکسازی $dir..." -ForegroundColor Cyan
        
        $filesToRemove = @(
            (Join-Path $dir "version.dll"),
            (Join-Path $dir "config.json"),
            (Join-Path $dir "config.proxy.json"),
            (Join-Path $dir "Antigravity-with-proxy.bat"),
            (Join-Path $dir "proxy.settings.txt"),
            (Join-Path $dir "resources\bin\version.dll"),
            (Join-Path $dir "resources\bin\config.json"),
            (Join-Path $dir "resources\app\extensions\antigravity\bin\version.dll"),
            (Join-Path $dir "resources\app\extensions\antigravity\bin\config.json")
        )
        
        foreach ($f in $filesToRemove) {
            if (Test-Path $f) {
                try { Remove-Item -Path $f -Force; Write-Host "  - حذف شد: $f" -ForegroundColor Green } catch {}
            }
        }
    }
}

# پاکسازی متغیرهای محیطی
Write-Host "`n[+] پاکسازی متغیرهای محیطی..." -ForegroundColor Cyan
try {
    [Environment]::SetEnvironmentVariable("HTTP_PROXY", $null, "User")
    [Environment]::SetEnvironmentVariable("HTTPS_PROXY", $null, "User")
    [Environment]::SetEnvironmentVariable("http_proxy", $null, "User")
    [Environment]::SetEnvironmentVariable("https_proxy", $null, "User")
    [Environment]::SetEnvironmentVariable("NO_PROXY", $null, "User")
    Write-Host "  - متغیرهای محیطی با موفقیت پاک شدند." -ForegroundColor Green
} catch {}


# پاکسازی میانبرهای دسکتاپ
Write-Host "`n[+] بررسی میانبرهای دسکتاپ..." -ForegroundColor Cyan
$desktopPath = [Environment]::GetFolderPath("Desktop")
$shortcutDirs = @($desktopPath, (Join-Path $desktopPath "01 Apps"))

foreach ($sDir in $shortcutDirs) {
    if (Test-Path $sDir) {
        Get-ChildItem -Path $sDir -Filter "*Iran Patch*.lnk" -ErrorAction SilentlyContinue | ForEach-Object {
            try { Remove-Item -Path $_.FullName -Force; Write-Host "  - میانبر حذف شد: $($_.Name)" -ForegroundColor Green } catch {}
        }
    }
}

Write-Host "`nپچ با موفقیت به طور کامل حذف شد." -ForegroundColor Green
Safe-ReadHost "برای خروج Enter را بزنید"
