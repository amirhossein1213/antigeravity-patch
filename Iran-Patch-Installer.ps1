#Requires -Version 5.1
<#
.SYNOPSIS
  Smart & Comprehensive Anti-Sanctions Patch Installer for Google Antigravity in Iran
.DESCRIPTION
  In script be soorate khodkar:
  1. Port proxy fa'al (Clash Verge 7897, Clash 7890, v2rayN 10809, Sing-box 2080 va ...) ra scan va test mikonad.
  2. Noskhehaye nasb-shodeye Antigravity IDE va Antigravity 2 ra shenasayi mikonad.
  3. version.dll va config.json ra dar tamamiye masirha gharar midahad.
  4. Tanzimate VS Code va motaghayyerhaye mohitiye system ra e'emal mikonad.
  5. Mianborhaye Desktop ra baraye ejraye bedoone moshkel misazad.
#>

param(
    [switch]$Quiet,
    [switch]$Auto,
    [int]$CustomPort = 0
)

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$Host.UI.RawUI.WindowTitle = "Antigravity Iran Proxy Patch Installer"

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
        Write-Host "     Patch Jame va Hooshmand Zed-Tahrim Google Antigravity (Iran)     " -ForegroundColor Yellow
        Write-Host "          (Raf'e Tazmini Moshkel Vorood be Google va Tahrim)          " -ForegroundColor Green
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
# Gam 1: Peyda kardane masire patch va file-haye asli (DLL & Templates)
# -------------------------------------------------------------
Write-Step "Barresiye file-haye asliye patch..."
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

# Jostojooye version.dll
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
    Write-Fail "File version.dll peyda nashod! Lotfan motmaen shavid basteye patch kamel download shode ast."
    Safe-ReadHost "Baraye khorooj Enter ra bezanid"
    exit 1
}
Write-Success "File version.dll ba movafaghiyat yaft shod: $DllPath"

# Jostojooye template config
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
# Gam 2: Tashkhise khodkare porte proxy fa'al
# -------------------------------------------------------------
Write-Step "Scan khodkare narm-afzarhaye filter-shekan / proxy-e fa'al..."

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
    
    # Test baz boodane port
    $tcp = New-Object System.Net.Sockets.TcpClient
    $connect = $tcp.BeginConnect("127.0.0.1", $port, $null, $null)
    $success = $connect.AsyncWaitHandle.WaitOne(400, $false)
    if ($success) {
        try {
            $tcp.EndConnect($connect)
            $tcp.Close()
            
            # Test ettesal be Google az tarighe in port
            Write-Host "  - Port $port ($name) dar hale ejrast; Dar hale azmayesh ettesal be Google..." -NoNewline
            try {
                $testUrl = "https://accounts.google.com"
                $req = [System.Net.WebRequest]::Create($testUrl)
                $req.Proxy = New-Object System.Net.WebProxy("http://127.0.0.1:$port")
                $req.Timeout = 4000
                $resp = $req.GetResponse()
                $resp.Close()
                Write-Host " [Movafagh]" -ForegroundColor Green
                $ActiveProxyPort = $port
                $ActiveProxyName = $name
                break
            } catch {
                Write-Host " [Pasokh nadad]" -ForegroundColor Yellow
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
    $ActiveProxyName = "Custom"
} elseif ($ActiveProxyPort -gt 0) {
    Write-Success "Proxy fa'al shenasayi shod: $ActiveProxyName rooye port $ActiveProxyPort"
    $userConfirm = Safe-ReadHost "  Aya az port $ActiveProxyPort estefade shavad? (Enter baraye taeed, ya shomareh port delkhah ra vared konid)" "$ActiveProxyPort"
    if ($userConfirm -match '^\d+$') {
        $ActiveProxyPort = [int]$userConfirm
    }
} else {
    Write-Warn "Hich proxy-e fa'ali rooye port-haye motadavel yaft nashod."
    Write-Host "  Lotfan ghabl az edameh, filter-shekane khod (Clash Verge, v2rayN ya ...) ra roshan konid." -ForegroundColor Yellow
    $portInput = Safe-ReadHost "  Shomareh port proxy HTTP khod ra vared konid (Pishfarz: 7897)" "7897"
    if ($portInput -match '^\d+$') {
        $ActiveProxyPort = [int]$portInput
    } else {
        $ActiveProxyPort = 7897
    }
}

$ProxyUrl = "http://${ActiveProxyHost}:${ActiveProxyPort}"
Write-Success "Addresse nahayiye proxy: $ProxyUrl"

# -------------------------------------------------------------
# Gam 3: Shenasayiye pooshehaye nasbe Antigravity
# -------------------------------------------------------------
Write-Step "Jostojooye noskhehaye nasb-shodeye Google Antigravity..."

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
    Write-Warn "Poosheye standarde Antigravity yaft nashod."
    $customPath = Safe-ReadHost "  Masire poosheye nasbe Antigravity ra vared konid (ya Enter baraye jostojoo)" ""
    if ($customPath -and (Test-Path $customPath)) {
        $exeName = "Antigravity IDE.exe"
        if (Test-Path (Join-Path $customPath "Antigravity.exe")) { $exeName = "Antigravity.exe" }
        $InstallationTargets += [PSCustomObject]@{
            Name = "Custom"
            Dir  = $customPath
            Exe  = $exeName
            ExePath = (Join-Path $customPath $exeName)
        }
    } else {
        Write-Fail "Hich noskhe-i az Antigravity peyda nashod. Amaliyat motevaghef shod."
        Safe-ReadHost "Baraye khorooj Enter ra bezanid"
        exit 1
    }
}

Write-Success "Tedad noskhehaye shenasayi shode: $($InstallationTargets.Count)"
foreach ($inst in $InstallationTargets) {
    Write-Host "    - $($inst.Name): $($inst.Dir)" -ForegroundColor White
}

# -------------------------------------------------------------
# Gam 4: Barresiye process-haye dar hale ejra
# -------------------------------------------------------------
Write-Step "Barresiye process-haye dar hale ejra..."
$runningProcesses = Get-Process -Name "Antigravity*", "language_server*" -ErrorAction SilentlyContinue
if ($runningProcesses -and -not $Auto -and -not $Quiet) {
    Write-Warn "Barkhi process-haye Antigravity ham-aknoon baz hastand."
    $closeConfirm = Safe-ReadHost "  Aya mayelid process-ha basteh shavand ta file-ha bedoone ghoofl jaygozin shavand? (y/n, Pishfarz: n)" "n"
    if ($closeConfirm -eq "y" -or $closeConfirm -eq "Y") {
        foreach ($p in $runningProcesses) {
            try { Stop-Process -Id $p.Id -Force -ErrorAction SilentlyContinue } catch {}
        }
        Start-Sleep -Milliseconds 800
        Write-Success "Process-ha basteh shodand."
    }
}

# -------------------------------------------------------------
# Gam 5: Amadeh-saziye mohtavaye config JSON
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
# Gam 6: E'emale patch bar rooye noskhehaye shenasayi shode
# -------------------------------------------------------------
Write-Step "E'emale patch DLL va file-haye configuration..."

foreach ($inst in $InstallationTargets) {
    Write-Host "`n  -> Dar hale patch kardane $($inst.Name)..." -ForegroundColor Yellow
    $dir = $inst.Dir
    
    # Pooshehaye fareeye binary
    $subDirs = @(
        $dir,
        (Join-Path $dir "resources\bin"),
        (Join-Path $dir "resources\app\extensions\antigravity\bin")
    )
    
    foreach ($sd in $subDirs) {
        if (-not (Test-Path $sd)) {
            $parent = Split-Path $sd -Parent
            if (Test-Path $parent) {
                try { New-Item -ItemType Directory -Path $sd -Force | Out-Null } catch {}
            }
        }
        
        if (Test-Path $sd) {
            # 1. Copy version.dll
            $targetDll = Join-Path $sd "version.dll"
            try {
                Copy-Item -Path $DllPath -Destination $targetDll -Force
                Write-Success "File version.dll copy shod dar: $sd"
            } catch {
                Write-Warn "Emkane copy version.dll dar $sd vojood nadasht (Ehtemalan file ghofl ast)."
            }
            
            # 2. Ijade config.json va config.proxy.json
            try {
                $configJsonContent | Set-Content -Path (Join-Path $sd "config.json") -Encoding UTF8 -Force
                $configJsonContent | Set-Content -Path (Join-Path $sd "config.proxy.json") -Encoding UTF8 -Force
            } catch {}
        }
    }
    
    # 3. Ijade file tanzimate matni
    $proxySettingsTxt = @"
# Antigravity Iran Proxy Settings
HOST=$ActiveProxyHost
PORT=$ActiveProxyPort
TYPE=http
"@
    $proxySettingsTxt | Set-Content -Path (Join-Path $dir "proxy.settings.txt") -Encoding ASCII -Force
    
    # 4. Sakhte launchere Antigravity-with-proxy.bat
    $exeName = $inst.Exe
    $launcherBat = @"
@echo off
cd /d "%~dp0"
set PROXY=$ProxyUrl
set HTTP_PROXY=%PROXY%
set HTTPS_PROXY=%PROXY%
set http_proxy=%PROXY%
set https_proxy=%PROXY%
set NO_PROXY=localhost,127.0.0.1,*.local

if exist "%~dp0config.proxy.json" (
  copy /Y "%~dp0config.proxy.json" "%~dp0config.json" >nul 2>&1
  if exist "%~dp0resources\bin\" copy /Y "%~dp0config.proxy.json" "%~dp0resources\bin\config.json" >nul 2>&1
  if exist "%~dp0resources\app\extensions\antigravity\bin\" copy /Y "%~dp0config.proxy.json" "%~dp0resources\app\extensions\antigravity\bin\config.json" >nul 2>&1
)

start "" "%~dp0$exeName" --proxy-server="$ProxyUrl" %*
"@
    $launcherBatPath = Join-Path $dir "Antigravity-with-proxy.bat"
    $launcherBat | Set-Content -Path $launcherBatPath -Encoding ASCII -Force
    Write-Success "Launchere proxy sakhte shod: $launcherBatPath"
    
    # 5. Sakhte mianbore Desktop
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
                Write-Success "Mianbore jadid sakhte shod: $shortcutPath"
            }
        }
    } catch {
        Write-Warn "Emkane ijade mianbore khodkar rooye Desktop vojood nadasht: $($_.Exception.Message)"
    }
}

# -------------------------------------------------------------
# Gam 7: Beroozresaniye settings.json dar VS Code / Antigravity
# -------------------------------------------------------------
Write-Step "Beroozresaniye tanzimate dakheliye VS Code (settings.json)..."

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
        Write-Success "File tanzimat berooz shod: $settingsPath"
    } catch {
        Write-Warn "Khata dar neveshtane tanzimat: $settingsPath"
    }
}

# -------------------------------------------------------------
# Gam 8: Tanzime motaghayyerhaye mohitiye Windows
# -------------------------------------------------------------
Write-Step "Tanzime motaghayyerhaye mohitiye Windows (HTTP_PROXY / HTTPS_PROXY)..."

try {
    [Environment]::SetEnvironmentVariable("HTTP_PROXY", $ProxyUrl, "User")
    [Environment]::SetEnvironmentVariable("HTTPS_PROXY", $ProxyUrl, "User")
    [Environment]::SetEnvironmentVariable("http_proxy", $ProxyUrl, "User")
    [Environment]::SetEnvironmentVariable("https_proxy", $ProxyUrl, "User")
    [Environment]::SetEnvironmentVariable("NO_PROXY", "localhost,127.0.0.1,*.local", "User")
    Write-Success "Motaghayyerhaye mohitiye Windows baraye port $ActiveProxyPort ba movafaghiyat tanzim shodand."
} catch {
    Write-Warn "Emkane tanzime motaghayyerhaye mohiti dar sathe User vojood nadasht."
}

# -------------------------------------------------------------
# Gam 9: Test va etebarsanjiyee nahayi
# -------------------------------------------------------------
Write-Step "Azmayeshe nahayiye ettesal be server-haye Google va Gemini..."

$testUrls = @(
    @{ Name = "Google Accounts (Login & Auth)"; Url = "https://accounts.google.com" },
    @{ Name = "Google APIs Backend";            Url = "https://cloudcode.googleapis.com" }
)

foreach ($t in $testUrls) {
    Write-Host "  - Test ertebat ba $($t.Name)..." -NoNewline
    try {
        $req = [System.Net.WebRequest]::Create($t.Url)
        $req.Proxy = New-Object System.Net.WebProxy($ProxyUrl)
        $req.Timeout = 5000
        $res = $req.GetResponse()
        $res.Close()
        Write-Host " [Movafagh - HTTP 200]" -ForegroundColor Green
    } catch {
        Write-Host " [Barresi konid: $_]" -ForegroundColor Yellow
    }
}

# -------------------------------------------------------------
# Payan: Payame movafaghiyat va rahnamaaye estefadeh
# -------------------------------------------------------------
Write-Host "`n======================================================================" -ForegroundColor Green
Write-Host "         Tabrik! Patch ba movafaghiyat rooye system nasb shod         " -ForegroundColor Yellow
Write-Host "======================================================================" -ForegroundColor Green
Write-Host ""
Write-Host "Rahnamaaye Estefadeh:" -ForegroundColor Cyan
Write-Host "1. Motmaen shavid narm-afzare filter-shekane shoma (Clash / v2rayN) roshan ast." -ForegroundColor White
Write-Host "2. Narm-afzar ra az tarighe mianbore jadid rooye Desktop ejra konid:" -ForegroundColor White
Write-Host "   -> 'Antigravity IDE (Iran Patch)' ya 'Antigravity 2 (Iran Patch)'" -ForegroundColor Yellow
Write-Host "3. Dar goosheye narm-afzar rooye dokhmeye Sign in click konid ta ba movafaghiyat vared shavid." -ForegroundColor White
Write-Host ""
Write-Host "Nokteye mohem dar soorate update:" -ForegroundColor Magenta
Write-Host "Agar dar ayandeh Antigravity update shod, kafist dobareh Install-Iran-Patch.bat ra ejra konid.`n" -ForegroundColor White

Safe-ReadHost "Baraye bastane in panjereh, kelide Enter ra feshar dahid"
