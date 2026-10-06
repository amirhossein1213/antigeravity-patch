#Requires -Version 5.1
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$Host.UI.RawUI.WindowTitle = "Verify Google Antigravity Connection"

Clear-Host
Write-Host "======================================================================" -ForegroundColor Cyan
Write-Host "      Abzare Barresiye Salamat va Test Ettesale Google Antigravity    " -ForegroundColor Yellow
Write-Host "======================================================================" -ForegroundColor Cyan
Write-Host ""

$score = 0
$total = 6

# 1. Barresiye motaghayyerhaye mohiti
Write-Host "[1/6] Barresiye motaghayyerhaye mohitiye Windows (HTTP_PROXY)..." -NoNewline
$envProxy = [Environment]::GetEnvironmentVariable("HTTP_PROXY", "User")
if ($envProxy) {
    Write-Host " [OK] Faal: $envProxy" -ForegroundColor Green
    $score++
} else {
    Write-Host " [X] Tanzim nashode ast" -ForegroundColor Red
}

# 2. Barresiye settings.json
Write-Host "[2/6] Barresiye tanzimate Antigravity IDE (settings.json)..." -NoNewline
$settingsPath = Join-Path $env:APPDATA "Antigravity IDE\User\settings.json"
if (Test-Path $settingsPath) {
    $content = Get-Content $settingsPath -Raw -ErrorAction SilentlyContinue
    if ($content -match '"http\.proxy"') {
        Write-Host " [OK] Tanzim shode" -ForegroundColor Green
        $score++
    } else {
        Write-Host " [X] Meghdare http.proxy yaft nashod" -ForegroundColor Red
    }
} else {
    Write-Host " [!] File tanzimat yaft nashod" -ForegroundColor Yellow
}

# 3. Barresiye version.dll
Write-Host "[3/6] Barresiye esteqrare version.dll dar poosheye barnameh..." -NoNewline
$idePath = Join-Path $env:LOCALAPPDATA "Programs\Antigravity IDE\version.dll"
$agyPath = Join-Path $env:LOCALAPPDATA "Programs\Antigravity\version.dll"
if ((Test-Path $idePath) -or (Test-Path $agyPath)) {
    Write-Host " [OK] Mojood va faal" -ForegroundColor Green
    $score++
} else {
    Write-Host " [X] File patch DLL peyda nashod" -ForegroundColor Red
}

# 4. Barresiye porte proxy
Write-Host "[4/6] Barresiye dastrasi be porte filter-shekane mahalli..." -NoNewline
$proxyPort = 7897
if ($envProxy -match ':(\d+)') { $proxyPort = [int]$Matches[1] }
$tcp = New-Object System.Net.Sockets.TcpClient
$connect = $tcp.BeginConnect("127.0.0.1", $proxyPort, $null, $null)
$success = $connect.AsyncWaitHandle.WaitOne(800, $false)
if ($success) {
    try { $tcp.EndConnect($connect); $tcp.Close() } catch {}
    Write-Host " [OK] Porte $proxyPort dar hale goosh dadan ast" -ForegroundColor Green
    $score++
} else {
    $tcp.Close()
    Write-Host " [X] Porte $proxyPort basteh ast! Lotfan filter-shekan ra roshan konid" -ForegroundColor Red
}

# 5. Test ertebat ba servere voroode Google
Write-Host "[5/6] Test ertebat ba servere voroode Google (accounts.google.com)..." -NoNewline
try {
    $req = [System.Net.WebRequest]::Create("https://accounts.google.com")
    $req.Proxy = New-Object System.Net.WebProxy("http://127.0.0.1:$proxyPort")
    $req.Timeout = 5000
    $res = $req.GetResponse()
    $code = [int]$res.StatusCode
    $res.Close()
    if ($code -eq 200) {
        Write-Host " [OK] Dastrasiye kamel - HTTP 200" -ForegroundColor Green
        $score++
    } else {
        Write-Host " [!] Code pasokh: $code" -ForegroundColor Yellow
    }
} catch {
    Write-Host " [X] Khata dar ettesal: $($_.Exception.Message)" -ForegroundColor Red
}

# 6. Test ertebat ba Cloud Code
Write-Host "[6/6] Test ertebat ba backend-e hoosh masnooiye Google (Cloud Code)..." -NoNewline
try {
    $req2 = [System.Net.HttpWebRequest][System.Net.WebRequest]::Create("https://cloudcode.googleapis.com")
    $req2.Proxy = New-Object System.Net.WebProxy("http://127.0.0.1:$proxyPort")
    $req2.Timeout = 5000
    $res2 = $req2.GetResponse()
    $res2.Close()
    Write-Host " [OK] Dastrasiye kamel" -ForegroundColor Green
    $score++
} catch [System.Net.WebException] {
    $webResp = $_.Exception.Response
    if ($webResp -ne $null) {
        $statusInt = [int]$webResp.StatusCode
        if ($statusInt -ne 403) {
            Write-Host " [OK] Mottasel - Vazeeyat HTTP $statusInt (Bedoone Tahrim)" -ForegroundColor Green
            $score++
        } else {
            Write-Host " [X] Khataye 403 Tahrim - IP masdood ast" -ForegroundColor Red
        }
    } else {
        Write-Host " [X] Adame pasokhe server: $($_.Exception.Message)" -ForegroundColor Red
    }
} catch {
    Write-Host " [X] Khata: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "`n----------------------------------------------------------------------" -ForegroundColor Cyan
Write-Host "Emtiaze salamate system: $score az $total" -ForegroundColor $(if ($score -ge 5) { "Green" } else { "Yellow" })
if ($score -ge 5) {
    Write-Host "Vazeeyate system: Besyar Aali! Patch faal ast va Antigravity amadeye kar mibashad." -ForegroundColor Green
} else {
    Write-Host "Tavajjoh: Lotfan file Install-Iran-Patch.bat ra mojadadan ejra konid va az ettesale filter-shekane khod motmaen shavid." -ForegroundColor Yellow
}
Write-Host "----------------------------------------------------------------------`n" -ForegroundColor Cyan

Read-Host "Baraye khorooj Enter ra bezanid"
