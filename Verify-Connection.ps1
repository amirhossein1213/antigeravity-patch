#Requires -Version 5.1
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$Host.UI.RawUI.WindowTitle = "تست و اعتبارسنجی اتصال Google Antigravity"

Clear-Host
Write-Host "======================================================================" -ForegroundColor Cyan
Write-Host "          ابزار بررسی سلامت و تست اتصال ضد تحریم Google Antigravity   " -ForegroundColor Yellow
Write-Host "======================================================================" -ForegroundColor Cyan
Write-Host ""

$score = 0
$total = 6

# ۱. بررسی متغیرهای محیطی
Write-Host "[۱/۶] بررسی متغیرهای محیطی ویندوز (HTTP_PROXY)..." -NoNewline
$envProxy = [Environment]::GetEnvironmentVariable("HTTP_PROXY", "User")
if ($envProxy) {
    Write-Host " [✓ فعال: $envProxy]" -ForegroundColor Green
    $score++
} else {
    Write-Host " [✗ تنظیم نشده است]" -ForegroundColor Red
}

# ۲. بررسی تنظیمات VS Code
Write-Host "[۲/۶] بررسی تنظیمات Antigravity IDE (settings.json)..." -NoNewline
$settingsPath = Join-Path $env:APPDATA "Antigravity IDE\User\settings.json"
if (Test-Path $settingsPath) {
    $content = Get-Content $settingsPath -Raw -ErrorAction SilentlyContinue
    if ($content -match '"http\.proxy"') {
        Write-Host " [✓ تنظیم شده]" -ForegroundColor Green
        $score++
    } else {
        Write-Host " [✗ مقدار http.proxy یافت نشد]" -ForegroundColor Red
    }
} else {
    Write-Host " [! فایل تنظیمات یافت نشد]" -ForegroundColor Yellow
}

# ۳. بررسی فایل‌های DLL پچ
Write-Host "[۳/۶] بررسی استقرار version.dll در پوشه برنامه..." -NoNewline
$idePath = Join-Path $env:LOCALAPPDATA "Programs\Antigravity IDE\version.dll"
$agyPath = Join-Path $env:LOCALAPPDATA "Programs\Antigravity\version.dll"
if ((Test-Path $idePath) -or (Test-Path $agyPath)) {
    Write-Host " [✓ موجود و فعال]" -ForegroundColor Green
    $score++
} else {
    Write-Host " [✗ فایل پچ DLL پیدا نشد]" -ForegroundColor Red
}

# ۴. بررسی باز بودن پورت فیلترشکن
Write-Host "[۴/۶] بررسی دسترسی به پورت فیلترشکن محلی..." -NoNewline
$proxyPort = 7897
if ($envProxy -match ':(\d+)') { $proxyPort = [int]$Matches[1] }
$tcp = New-Object System.Net.Sockets.TcpClient
$connect = $tcp.BeginConnect("127.0.0.1", $proxyPort, $null, $null)
$success = $connect.AsyncWaitHandle.WaitOne(800, $false)
if ($success) {
    try { $tcp.EndConnect($connect); $tcp.Close() } catch {}
    Write-Host " [✓ پورت $proxyPort در حال گوش دادن است]" -ForegroundColor Green
    $score++
} else {
    $tcp.Close()
    Write-Host " [✗ پورت $proxyPort بسته است! لطفاً فیلترشکن را روشن کنید]" -ForegroundColor Red
}

# ۵. تست اتصال به سرور لاگین گوگل
Write-Host "[۵/۶] تست ارتباط با سرور ورود گوگل (accounts.google.com)..." -NoNewline
try {
    $req = [System.Net.WebRequest]::Create("https://accounts.google.com")
    $req.Proxy = New-Object System.Net.WebProxy("http://127.0.0.1:$proxyPort")
    $req.Timeout = 5000
    $res = $req.GetResponse()
    $code = [int]$res.StatusCode
    $res.Close()
    if ($code -eq 200) {
        Write-Host " [✓ دسترسی کامل - HTTP 200]" -ForegroundColor Green
        $score++
    } else {
        Write-Host " [! کد پاسخ: $code]" -ForegroundColor Yellow
    }
} catch {
    Write-Host " [✗ خطا در اتصال: $($_.Exception.Message)]" -ForegroundColor Red
}

# ۶. تست اتصال به بک‌اند هوش مصنوعی گوگل
Write-Host "[۶/۶] تست ارتباط با بک‌اند هوش مصنوعی گوگل (Cloud Code)..." -NoNewline
try {
    $req2 = [System.Net.HttpWebRequest][System.Net.WebRequest]::Create("https://cloudcode.googleapis.com")
    $req2.Proxy = New-Object System.Net.WebProxy("http://127.0.0.1:$proxyPort")
    $req2.Timeout = 5000
    $res2 = $req2.GetResponse()
    $res2.Close()
    Write-Host " [✓ دسترسی کامل]" -ForegroundColor Green
    $score++
} catch [System.Net.WebException] {
    $webResp = $_.Exception.Response
    if ($webResp -ne $null) {
        $statusInt = [int]$webResp.StatusCode
        if ($statusInt -ne 403) {
            Write-Host " [✓ متصل - وضعیت HTTP $statusInt (سرویس بدون تحریم)]" -ForegroundColor Green
            $score++
        } else {
            Write-Host " [✗ خطای ۴۰۳ تحریم - آی‌پی مسدود است]" -ForegroundColor Red
        }
    } else {
        Write-Host " [✗ عدم پاسخ سرور: $($_.Exception.Message)]" -ForegroundColor Red
    }
} catch {
    Write-Host " [✗ خطا: $($_.Exception.Message)]" -ForegroundColor Red
}

Write-Host "`n----------------------------------------------------------------------" -ForegroundColor Cyan
Write-Host "امتیاز سلامت سیستم: $score از $total" -ForegroundColor $(if ($score -ge 5) { "Green" } else { "Yellow" })
if ($score -ge 5) {
    Write-Host "وضعیت سیستم: بسیار عالی! پچ فعال است و Antigravity آماده ورود بدون فیلتر می‌باشد." -ForegroundColor Green
} else {
    Write-Host "توجه: لطفاً فایل Install-Iran-Patch.bat را مجدداً اجرا کنید و از اتصال فیلترشکن خود مطمئن شوید." -ForegroundColor Yellow
}
Write-Host "----------------------------------------------------------------------`n" -ForegroundColor Cyan

Read-Host "برای خروج Enter را بزنید"
