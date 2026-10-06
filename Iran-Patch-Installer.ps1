#Requires -Version 5.1
<#
.SYNOPSIS
  نصاب هوشمند و جامع پچ ضد تحریم Google Antigravity برای کاربران ایران
.DESCRIPTION
  این اسکریپت به صورت خودکار:
  1. پورت پراکسی فعال (Clash Verge 7897, Clash 7890, v2rayN 10809, Sing-box 2080 و ...) را اسکن و تست می‌کند.
  2. نسخه‌های نصب‌شده Antigravity IDE و Antigravity 2 را شناسایی می‌کند.
  3. تزریق هوشمند version.dll و تنظیم config.json را در تمامی مسیرها انجام می‌دهد.
  4. تنظیمات VS Code و متغیرهای محیطی سیستم را اعمال می‌کند.
  5. میانبرهای دسکتاپ را برای اجرای بدون مشکل احراز هویت ایجاد می‌کند.
#>

param(
    [switch]$Quiet,
    [switch]$Auto,
    [int]$CustomPort = 0
)

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$Host.UI.RawUI.WindowTitle = "Antigravity Iran Proxy Patch Installer | نصاب پچ ضد تحریم آنتی‌گرویتی"

function Safe-ReadHost($prompt, $default="") {
    if ($Quiet -or $Auto -or [Console]::IsInputRedirected) {
        return $default
    }
    try {
        $res = Read-Host $prompt
        if ([string]::IsNullOrWhiteSpace($res)) { return $default }
        return $res
    } catch {
        return $default
    }
}

function Print-Header {
    if (-not $Quiet) {
        Clear-Host
        Write-Host "======================================================================" -ForegroundColor Cyan
        Write-Host "         پچ جامع و هوشمند ضد تحریم Google Antigravity برای ایران       " -ForegroundColor Yellow
        Write-Host "              (رفع تضمینی مشکل ورود به گوگل و خطاهای تحریم)            " -ForegroundColor Green
        Write-Host "======================================================================" -ForegroundColor Cyan
        Write-Host ""
    }
}

function Write-Step($title) {
    Write-Host "`n[+] $title" -ForegroundColor Cyan
}

function Write-Success($msg) {
    Write-Host "  [OK] $msg" -ForegroundColor Green
}

function Write-Warn($msg) {
    Write-Host "  [!] $msg" -ForegroundColor Yellow
}

function Write-Fail($msg) {
    Write-Host "  [X] $msg" -ForegroundColor Red
}

Print-Header

# -------------------------------------------------------------
# گام ۱: پیدا کردن مسیر پچ و فایل‌های اصلی (DLL و قالب‌ها)
# -------------------------------------------------------------
Write-Step "بررسی فایل‌های اصلی پچ..."
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

# جستجوی version.dll
$dllCandidates = @(
    (Join-Path $ScriptDir "Antigravity IDE\antigravity-proxy-patch\proxy\version.dll"),
    (Join-Path $ScriptDir "Antigravity 2\antigravity-proxy-patch\proxy\version.dll"),
    (Join-Path $ScriptDir "proxy\version.dll")
)

$DllPath = ""
foreach ($cand in $dllCandidates) {
    if (Test-Path $cand) {
        $DllPath = $cand
        break
    }
}

if (-not $DllPath) {
    Write-Fail "فایل version.dll پیدا نشد! لطفاً مطمئن شوید بسته پچ به صورت کامل دانلود شده است."
    Read-Host "برای خروج Enter را بزنید"
    exit 1
}
Write-Success "فایل version.dll با موفقیت یافت شد: $DllPath"

# جستجوی قالب کانفیگ
$templateCandidates = @(
    (Join-Path $ScriptDir "Antigravity IDE\antigravity-proxy-patch\config.proxy.template.json"),
    (Join-Path $ScriptDir "Antigravity 2\antigravity-proxy-patch\config.proxy.template.json"),
    (Join-Path $ScriptDir "config.proxy.template.json")
)

$TemplatePath = ""
foreach ($cand in $templateCandidates) {
    if (Test-Path $cand) {
        $TemplatePath = $cand
        break
    }
}

# -------------------------------------------------------------
# گام ۲: تشخیص خودکار پورت پراکسی فعال
# -------------------------------------------------------------
Write-Step "اسکن خودکار نرم‌افزارهای فیلترشکن / پراکسی فعال..."

$KnownPorts = @(
    @{ Name = "Clash Verge / Mihomo"; Port = 7897 },
    @{ Name = "Clash / Clash for Windows"; Port = 7890 },
    @{ Name = "v2rayN / Xray (HTTP)"; Port = 10809 },
    @{ Name = "Sing-box / NekoBox"; Port = 2080 },
    @{ Name = "Shadowsocks (HTTP)"; Port = 1080 },
    @{ Name = "Squid / Custom Proxy"; Port = 8080 }
)

$ActiveProxyHost = "127.0.0.1"
$ActiveProxyPort = 0
$ActiveProxyName = ""

foreach ($p in $KnownPorts) {
    $port = $p.Port
    $name = $p.Name
    
    # تست باز بودن پورت
    $tcp = New-Object System.Net.Sockets.TcpClient
    $connect = $tcp.BeginConnect("127.0.0.1", $port, $null, $null)
    $success = $connect.AsyncWaitHandle.WaitOne(400, $false)
    if ($success) {
        try {
            $tcp.EndConnect($connect)
            $tcp.Close()
            
            # تست اتصال واقعی به گوگل از طریق این پورت
            Write-Host "  - پورت $port ($name) در حال اجراست؛ در حال آزمایش اتصال به گوگل..." -NoNewline
            try {
                $testUrl = "https://accounts.google.com"
                $req = [System.Net.WebRequest]::Create($testUrl)
                $req.Proxy = New-Object System.Net.WebProxy("http://127.0.0.1:$port")
                $req.Timeout = 4000
                $resp = $req.GetResponse()
                $resp.Close()
                Write-Host " [موفق]" -ForegroundColor Green
                $ActiveProxyPort = $port
                $ActiveProxyName = $name
                break
            } catch {
                Write-Host " [پاسخ نداد]" -ForegroundColor Yellow
                if ($ActiveProxyPort -eq 0) {
                    $ActiveProxyPort = $port
                    $ActiveProxyName = $name
                }
            }
        } catch {
            $tcp.Close()
        }
    } else {
        $tcp.Close()
    }
}

if ($CustomPort -gt 0) {
    $ActiveProxyPort = $CustomPort
    $ActiveProxyName = "سفارشی"
} elseif ($ActiveProxyPort -gt 0) {
    Write-Success "پراکسی فعال شناسایی شد: $ActiveProxyName روی پورت $ActiveProxyPort"
    $userConfirm = Safe-ReadHost "  آیا از پورت $ActiveProxyPort استفاده شود؟ (Enter برای تایید، یا شماره پورت دلخواه را وارد کنید)" "$ActiveProxyPort"
    if ($userConfirm -match '^\d+$') {
        $ActiveProxyPort = [int]$userConfirm
    }
} else {
    Write-Warn "هیچ نرم‌افزار پراکسی فعالی روی پورت‌های متداول یافت نشد."
    Write-Host "  لطفاً قبل از ادامه، فیلترشکن خود (Clash Verge, v2rayN یا ...) را روشن کنید." -ForegroundColor Yellow
    $portInput = Safe-ReadHost "  شماره پورت پراکسی HTTP خود را وارد کنید (پیش‌فرض: 7897)" "7897"
    if ($portInput -match '^\d+$') {
        $ActiveProxyPort = [int]$portInput
    } else {
        $ActiveProxyPort = 7897
    }
}

$ProxyUrl = "http://${ActiveProxyHost}:${ActiveProxyPort}"
Write-Success "آدرس پراکسی نهایی: $ProxyUrl"

# -------------------------------------------------------------
# گام ۳: شناسایی پوشه‌های نصب Antigravity
# -------------------------------------------------------------
Write-Step "جستجوی نسخه‌های نصب‌شده Google Antigravity..."

$InstallationTargets = @()

$potentialPaths = @(
    @{ Name = "Antigravity IDE"; Dir = (Join-Path $env:LOCALAPPDATA "Programs\Antigravity IDE"); Exe = "Antigravity IDE.exe" },
    @{ Name = "Antigravity 2";   Dir = (Join-Path $env:LOCALAPPDATA "Programs\Antigravity");     Exe = "Antigravity.exe" },
    @{ Name = "Antigravity IDE (Program Files)"; Dir = "${env:ProgramFiles}\Antigravity IDE";    Exe = "Antigravity IDE.exe" },
    @{ Name = "Antigravity 2 (Program Files)";   Dir = "${env:ProgramFiles}\Antigravity";        Exe = "Antigravity.exe" }
)

foreach ($target in $potentialPaths) {
    $exeFullPath = Join-Path $target.Dir $target.Exe
    if (Test-Path $exeFullPath) {
        $InstallationTargets += [PSCustomObject]@{
            Name = $target.Name
            Dir  = $target.Dir
            Exe  = $target.Exe
            ExePath = $exeFullPath
        }
    }
}

if ($InstallationTargets.Count -eq 0) {
    Write-Warn "پوشه استاندارد Antigravity یافت نشد."
    $customPath = Safe-ReadHost "  مسیر پوشه نصب Antigravity را وارد کنید (یا Enter برای جستجوی بیشتر)" ""
    if ($customPath -and (Test-Path $customPath)) {
        $exeName = "Antigravity IDE.exe"
        if (Test-Path (Join-Path $customPath "Antigravity.exe")) { $exeName = "Antigravity.exe" }
        $InstallationTargets += [PSCustomObject]@{
            Name = "سفارشی"
            Dir  = $customPath
            Exe  = $exeName
            ExePath = (Join-Path $customPath $exeName)
        }
    } else {
        Write-Fail "هیچ نصبی از Antigravity پیدا نشد. عملیات متوقف شد."
        Safe-ReadHost "برای خروج Enter را بزنید"
        exit 1
    }
}

Write-Success "تعداد نسخه‌های شناسایی شده: $($InstallationTargets.Count)"
foreach ($inst in $InstallationTargets) {
    Write-Host "    - $($inst.Name): $($inst.Dir)" -ForegroundColor White
}

# -------------------------------------------------------------
# گام ۴: بررسی پردازش‌های در حال اجرا
# -------------------------------------------------------------
Write-Step "بررسی پردازش‌های در حال اجرا..."
$runningProcesses = Get-Process -Name "Antigravity*", "language_server*" -ErrorAction SilentlyContinue
if ($runningProcesses -and -not $Auto -and -not $Quiet) {
    Write-Warn "برخی پردازش‌های Antigravity هم‌اکنون باز هستند."
    $closeConfirm = Safe-ReadHost "  آیا مایلید پردازش‌های در حال اجرا بسته شوند تا فایل‌ها بدون قفل جایگزین شوند؟ (y/n، پیش‌فرض: n)" "n"
    if ($closeConfirm -eq "y" -or $closeConfirm -eq "Y") {
        foreach ($p in $runningProcesses) {
            try { Stop-Process -Id $p.Id -Force -ErrorAction SilentlyContinue } catch {}
        }
        Start-Sleep -Milliseconds 800
        Write-Success "پردازش‌ها بسته شدند."
    }
}

# -------------------------------------------------------------
# گام ۵: آماده‌سازی محتوای کانفیگ JSON
# -------------------------------------------------------------
$configJsonContent = @"
{
  "fake_ip": {
    "cidr": "198.18.0.0/15",
    "enabled": false
  },
  "_version": "1.9",
  "_comment": "Antigravity-Proxy Iran Patch",
  "traffic_logging": false,
  "target_processes": [
    "language_server.exe",
    "language_server_windows.exe",
    "language_server_windows",
    "language_server_windows_x64.exe",
    "language_server_windows_x64",
    "Antigravity.exe",
    "Antigravity IDE.exe",
    "node.exe"
  ],
  "proxy_rules": {
    "allowed_ports": [80, 443, 8080, $ActiveProxyPort],
    "udp_fallback": "block",
    "ipv6_mode": "proxy",
    "routing": {
      "rules": [],
      "use_default_private": false,
      "default_action": "proxy",
      "enabled": true,
      "priority_mode": "order"
    },
    "udp_mode": "block",
    "dns_mode": "direct"
  },
  "child_injection_mode": "filtered",
  "timeout": {
    "recv": 60000,
    "connect": 60000,
    "send": 60000
  },
  "log_level": "info",
  "child_injection": true,
  "proxy": {
    "type": "http",
    "host": "$ActiveProxyHost",
    "port": $ActiveProxyPort
  },
  "child_injection_exclude": []
}
"@

# -------------------------------------------------------------
# گام ۶: اعمال پچ بر روی هر یک از نسخه‌های شناسایی شده
# -------------------------------------------------------------
Write-Step "اعمال پچ DLL و فایل‌های پیکربندی..."

foreach ($inst in $InstallationTargets) {
    Write-Host "`n  -> در حال پچ کردن $($inst.Name)..." -ForegroundColor Yellow
    $dir = $inst.Dir
    
    # پوشه‌های فرعی باینری
    $subDirs = @(
        $dir,
        (Join-Path $dir "resources\bin"),
        (Join-Path $dir "resources\app\extensions\antigravity\bin")
    )
    
    foreach ($sd in $subDirs) {
        if (-not (Test-Path $sd)) {
            # اگر پوشه وجود ندارد ولی در ساختار روت است می‌سازیم یا صرفاً اگر والد وجود دارد می‌سازیم
            $parent = Split-Path $sd -Parent
            if (Test-Path $parent) {
                try { New-Item -ItemType Directory -Path $sd -Force | Out-Null } catch {}
            }
        }
        
        if (Test-Path $sd) {
            # ۱. کپی version.dll
            $targetDll = Join-Path $sd "version.dll"
            try {
                Copy-Item -Path $DllPath -Destination $targetDll -Force
                Write-Success "فایل version.dll کپی شد در: $sd"
            } catch {
                Write-Warn "امکان کپی version.dll در $sd وجود نداشت (احتمالاً فایل قفل است)."
            }
            
            # ۲. ایجاد config.json و config.proxy.json
            try {
                $configJsonContent | Set-Content -Path (Join-Path $sd "config.json") -Encoding UTF8 -Force
                $configJsonContent | Set-Content -Path (Join-Path $sd "config.proxy.json") -Encoding UTF8 -Force
            } catch {}
        }
    }
    
    # ۳. ایجاد فایل تنظیمات متنی
    $proxySettingsTxt = @"
# Antigravity Iran Proxy Settings
HOST=$ActiveProxyHost
PORT=$ActiveProxyPort
TYPE=http
"@
    $proxySettingsTxt | Set-Content -Path (Join-Path $dir "proxy.settings.txt") -Encoding ASCII -Force
    
    # ۴. ساخت فایل لانچر هوشمند Antigravity-with-proxy.bat
    $exeName = $inst.Exe
    $launcherBat = @"
@echo off
chcp 65001 >nul
setlocal
set PROXY=$ProxyUrl
set HTTP_PROXY=%PROXY%
set HTTPS_PROXY=%PROXY%
set http_proxy=%PROXY%
set https_proxy=%PROXY%
set NO_PROXY=localhost,127.0.0.1,*.local
cd /d "%~dp0"

if exist "%~dp0config.proxy.json" (
  copy /Y "%~dp0config.proxy.json" "%~dp0config.json" >nul 2>&1
  if exist "%~dp0resources\bin\" copy /Y "%~dp0config.proxy.json" "%~dp0resources\bin\config.json" >nul 2>&1
  if exist "%~dp0resources\app\extensions\antigravity\bin\" copy /Y "%~dp0config.proxy.json" "%~dp0resources\app\extensions\antigravity\bin\config.json" >nul 2>&1
)

start "" "%~dp0$exeName" --proxy-server="$ProxyUrl" %*
"@
    $launcherBatPath = Join-Path $dir "Antigravity-with-proxy.bat"
    $launcherBat | Set-Content -Path $launcherBatPath -Encoding ASCII -Force
    Write-Success "لانچر پراکسی ساخته شد: $launcherBatPath"
    
    # ۵. ساخت یا به‌روزرسانی میانبر در دسکتاپ
    try {
        $wsh = New-Object -ComObject WScript.Shell
        $desktopPath = [Environment]::GetFolderPath("Desktop")
        $shortcutTargets = @(
            (Join-Path $desktopPath "$($inst.Name) (Iran Patch).lnk"),
            (Join-Path $desktopPath "01 Apps\$($inst.Name) (Iran Patch).lnk")
        )
        
        foreach ($shortcutPath in $shortcutTargets) {
            $scDir = Split-Path $shortcutPath -Parent
            if (Test-Path $scDir) {
                $shortcut = $wsh.CreateShortcut($shortcutPath)
                $shortcut.TargetPath = $launcherBatPath
                $shortcut.WorkingDirectory = $dir
                $shortcut.IconLocation = "$($inst.ExePath),0"
                $shortcut.Description = "Launch $($inst.Name) with Iran Proxy Patch"
                $shortcut.Save()
                Write-Success "میانبر جدید ساخته شد: $shortcutPath"
            }
        }
    } catch {
        Write-Warn "امکان ایجاد میانبر خودکار روی دسکتاپ وجود نداشت: $($_.Exception.Message)"
    }
}

# -------------------------------------------------------------
# گام ۷: به‌روزرسانی تنظیمات محیط کاربری VS Code / Antigravity
# -------------------------------------------------------------
Write-Step "به‌روزرسانی تنظیمات داخلی VS Code (settings.json)..."

$settingsDirs = @(
    (Join-Path $env:APPDATA "Antigravity IDE\User"),
    (Join-Path $env:APPDATA "Antigravity\User")
)

foreach ($sDir in $settingsDirs) {
    if (-not (Test-Path $sDir)) {
        try { New-Item -ItemType Directory -Path $sDir -Force | Out-Null } catch {}
    }
    
    $settingsPath = Join-Path $sDir "settings.json"
    $settingsObj = [ordered]@{
        "http.proxy" = $ProxyUrl
        "http.proxySupport" = "override"
        "http.proxyStrictSSL" = $false
        "http.useLocalProxyConfiguration" = $false
    }
    
    if (Test-Path $settingsPath) {
        try {
            $existing = Get-Content $settingsPath -Raw -Encoding UTF8 | ConvertFrom-Json
            $existing.PSObject.Properties | ForEach-Object {
                if (-not $settingsObj.Contains($_.Name)) {
                    $settingsObj[$_.Name] = $_.Value
                }
            }
        } catch {}
    }
    
    try {
        ($settingsObj | ConvertTo-Json -Depth 10) | Set-Content -Path $settingsPath -Encoding UTF8 -Force
        Write-Success "فایل تنظیمات به‌روز شد: $settingsPath"
    } catch {
        Write-Warn "خطا در نوشتن تنظیمات: $settingsPath"
    }
}

# -------------------------------------------------------------
# گام ۸: تنظیم متغیرهای محیطی کاربر در ویندوز
# -------------------------------------------------------------
Write-Step "تنظیم متغیرهای محیطی کاربری ویندوز (HTTP_PROXY / HTTPS_PROXY)..."

try {
    [Environment]::SetEnvironmentVariable("HTTP_PROXY", $ProxyUrl, "User")
    [Environment]::SetEnvironmentVariable("HTTPS_PROXY", $ProxyUrl, "User")
    [Environment]::SetEnvironmentVariable("http_proxy", $ProxyUrl, "User")
    [Environment]::SetEnvironmentVariable("https_proxy", $ProxyUrl, "User")
    [Environment]::SetEnvironmentVariable("NO_PROXY", "localhost,127.0.0.1,*.local", "User")
    Write-Success "متغیرهای محیطی ویندوز برای پورت $ActiveProxyPort با موفقیت تنظیم شدند."
} catch {
    Write-Warn "امکان تنظیم متغیرهای محیطی در سطح User وجود نداشت."
}

# -------------------------------------------------------------
# گام ۹: تست و اعتبارسنجی نهایی اتصال
# -------------------------------------------------------------
Write-Step "آزمایش نهایی اتصال به سرورهای گوگل و Gemini..."

$testUrls = @(
    @{ Name = "Google Accounts (احراز هویت و لاگین)"; Url = "https://accounts.google.com" },
    @{ Name = "Google APIs Backend"; Url = "https://cloudcode.googleapis.com" }
)

foreach ($t in $testUrls) {
    Write-Host "  - تست ارتباط با $($t.Name)..." -NoNewline
    try {
        $req = [System.Net.WebRequest]::Create($t.Url)
        $req.Proxy = New-Object System.Net.WebProxy($ProxyUrl)
        $req.Timeout = 5000
        $res = $req.GetResponse()
        $res.Close()
        Write-Host " [موفق - HTTP 200]" -ForegroundColor Green
    } catch {
        Write-Host " [بررسی کنید: $_]" -ForegroundColor Yellow
    }
}

# -------------------------------------------------------------
# پایان: نمایش پیام موفقیت و راهنمای استفاده
# -------------------------------------------------------------
Write-Host "`n======================================================================" -ForegroundColor Green
Write-Host "            تبریک! پچ با موفقیت کامل بر روی سیستم شما نصب شد           " -ForegroundColor Yellow
Write-Host "======================================================================" -ForegroundColor Green
Write-Host ""
Write-Host "راهنمای استفاده:" -ForegroundColor Cyan
Write-Host "1. مطمئن شوید نرم‌افزار فیلترشکن شما (Clash / v2rayN) روشن است." -ForegroundColor White
Write-Host "2. نرم‌افزار را از طریق میانبر جدید روی دسکتاپ اجرا کنید:" -ForegroundColor White
Write-Host "   -> 'Antigravity IDE (ضد تحریم)' یا 'Antigravity (ضد تحریم)'" -ForegroundColor Yellow
Write-Host "3. در گوشه نرم‌افزار روی دکمه Sign in کلیک کنید تا با موفقیت وارد شوید." -ForegroundColor White
Write-Host ""
Write-Host "نکته مهم در صورت آپدیت نرم‌افزار:" -ForegroundColor Magenta
Write-Host "اگر در آینده Antigravity آپدیت شد، کافیست دوباره فایل Install-Iran-Patch.bat را اجرا کنید.`n" -ForegroundColor White

Safe-ReadHost "برای بستن این پنجره، کلید Enter را فشار دهید"
