#Requires -Version 5.1
param(
    [switch]$Quiet,
    [switch]$Auto
)

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$Host.UI.RawUI.WindowTitle = "Uninstall Google Antigravity Iran Patch"

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
    Write-Host "              Hazfe Patch Zed-Tahrim Google Antigravity               " -ForegroundColor Yellow
    Write-Host "======================================================================" -ForegroundColor Cyan
    Write-Host ""
}

$targets = @(
    (Join-Path $env:LOCALAPPDATA "Programs\Antigravity IDE"),
    (Join-Path $env:LOCALAPPDATA "Programs\Antigravity")
)

foreach ($dir in $targets) {
    if (Test-Path $dir) {
        Write-Host "[+] Dar hale paksaziye $dir..." -ForegroundColor Cyan
        
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
                try { Remove-Item -Path $f -Force; Write-Host "  - Hazf shod: $f" -ForegroundColor Green } catch {}
            }
        }
    }
}

# Paksaziye motaghayyerhaye mohiti
Write-Host "`n[+] Paksaziye motaghayyerhaye mohiti..." -ForegroundColor Cyan
try {
    [Environment]::SetEnvironmentVariable("HTTP_PROXY", $null, "User")
    [Environment]::SetEnvironmentVariable("HTTPS_PROXY", $null, "User")
    [Environment]::SetEnvironmentVariable("http_proxy", $null, "User")
    [Environment]::SetEnvironmentVariable("https_proxy", $null, "User")
    [Environment]::SetEnvironmentVariable("NO_PROXY", $null, "User")
    Write-Host "  - Motaghayyerhaye mohiti ba movafaghiyat pak shodand." -ForegroundColor Green
} catch {}


# Paksaziye mianborhaye Desktop
Write-Host "`n[+] Barresiye mianborhaye Desktop..." -ForegroundColor Cyan
$desktopPath = [Environment]::GetFolderPath("Desktop")
$shortcutDirs = @($desktopPath, (Join-Path $desktopPath "01 Apps"))

foreach ($sDir in $shortcutDirs) {
    if (Test-Path $sDir) {
        Get-ChildItem -Path $sDir -Filter "*Iran Patch*.lnk" -ErrorAction SilentlyContinue | ForEach-Object {
            try { Remove-Item -Path $_.FullName -Force; Write-Host "  - Mianbor hazf shod: $($_.Name)" -ForegroundColor Green } catch {}
        }
    }
}

Write-Host "`nPatch ba movafaghiyat be tore kamel hazf shod." -ForegroundColor Green
Safe-ReadHost "Baraye khorooj Enter ra bezanid"
