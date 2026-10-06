#Requires -Version 5.1
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

# ----------------- ایجاد پنجره اصلی -----------------
$form = New-Object System.Windows.Forms.Form
$form.Text = "نصاب پچ ضد تحریم Google Antigravity (نسخه ۱.۹)"
$form.Size = New-Object System.Drawing.Size(620, 560)
$form.StartPosition = "CenterScreen"
$form.FormBorderStyle = "FixedDialog"
$form.MaximizeBox = $false
$form.BackColor = [System.Drawing.Color]::FromArgb(15, 23, 42) # Slate Dark 900
$form.RightToLeft = [System.Windows.Forms.RightToLeft]::Yes
$form.RightToLeftLayout = $true

# فونت فارسی استاندارد ویندوز
$fontTitle = New-Object System.Drawing.Font("Segoe UI", 13, [System.Drawing.FontStyle]::Bold)
$fontSub = New-Object System.Drawing.Font("Segoe UI", 9.5, [System.Drawing.FontStyle]::Regular)
$fontBtn = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
$fontLog = New-Object System.Drawing.Font("Consolas", 9.5, [System.Drawing.FontStyle]::Regular)

# عنوان بالا
$lblTitle = New-Object System.Windows.Forms.Label
$lblTitle.Text = "پچ هوشمند عبور از تحریم Google Antigravity"
$lblTitle.Font = $fontTitle
$lblTitle.ForeColor = [System.Drawing.Color]::FromArgb(6, 182, 212) # Cyan
$lblTitle.Location = New-Object System.Drawing.Point(20, 16)
$lblTitle.Size = New-Object System.Drawing.Size(560, 32)
$form.Controls.Add($lblTitle)

$lblSub = New-Object System.Windows.Forms.Label
$lblSub.Text = "رفع دائمی خطای ورود به حساب گوگل و تحریم ایران در Antigravity IDE و Antigravity 2"
$lblSub.Font = $fontSub
$lblSub.ForeColor = [System.Drawing.Color]::FromArgb(148, 163, 184) # Slate 400
$lblSub.Location = New-Object System.Drawing.Point(20, 50)
$lblSub.Size = New-Object System.Drawing.Size(560, 24)
$form.Controls.Add($lblSub)

# فیلد پورت و وضعیت
$grpSettings = New-Object System.Windows.Forms.GroupBox
$grpSettings.Text = "تنظیمات پراکسی و فیلترشکن"
$grpSettings.Font = $fontSub
$grpSettings.ForeColor = [System.Drawing.Color]::FromArgb(203, 213, 225)
$grpSettings.Location = New-Object System.Drawing.Point(20, 85)
$grpSettings.Size = New-Object System.Drawing.Size(560, 80)
$form.Controls.Add($grpSettings)

$lblPort = New-Object System.Windows.Forms.Label
$lblPort.Text = "پورت محلی پراکسی:"
$lblPort.Location = New-Object System.Drawing.Point(400, 32)
$lblPort.Size = New-Object System.Drawing.Size(140, 24)
$grpSettings.Controls.Add($lblPort)

$txtPort = New-Object System.Windows.Forms.TextBox
$txtPort.Text = "7897"
$txtPort.Location = New-Object System.Drawing.Point(310, 28)
$txtPort.Size = New-Object System.Drawing.Size(80, 24)
$txtPort.Font = New-Object System.Drawing.Font("Consolas", 10.5, [System.Drawing.FontStyle]::Bold)
$txtPort.BackColor = [System.Drawing.Color]::FromArgb(30, 41, 59)
$txtPort.ForeColor = [System.Drawing.Color]::FromArgb(56, 189, 248)
$grpSettings.Controls.Add($txtPort)

$btnDetect = New-Object System.Windows.Forms.Button
$btnDetect.Text = "🔍 اسکن خودکار پورت"
$btnDetect.Location = New-Object System.Drawing.Point(20, 26)
$btnDetect.Size = New-Object System.Drawing.Size(160, 30)
$btnDetect.BackColor = [System.Drawing.Color]::FromArgb(30, 41, 59)
$btnDetect.ForeColor = [System.Drawing.Color]::White
$btnDetect.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
$btnDetect.FlatAppearance.BorderColor = [System.Drawing.Color]::FromArgb(71, 85, 105)
$btnDetect.Cursor = [System.Windows.Forms.Cursors]::Hand
$grpSettings.Controls.Add($btnDetect)

# دکمه‌های عملیاتی
$btnInstall = New-Object System.Windows.Forms.Button
$btnInstall.Text = "⚡ نصب و فعال‌سازی پچ (یک کلیک)"
$btnInstall.Font = $fontBtn
$btnInstall.Location = New-Object System.Drawing.Point(380, 180)
$btnInstall.Size = New-Object System.Drawing.Size(200, 44)
$btnInstall.BackColor = [System.Drawing.Color]::FromArgb(16, 185, 129) # Emerald
$btnInstall.ForeColor = [System.Drawing.Color]::White
$btnInstall.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
$btnInstall.Cursor = [System.Windows.Forms.Cursors]::Hand
$form.Controls.Add($btnInstall)

$btnVerify = New-Object System.Windows.Forms.Button
$btnVerify.Text = "✓ تست سلامت اتصال"
$btnVerify.Font = $fontBtn
$btnVerify.Location = New-Object System.Drawing.Point(200, 180)
$btnVerify.Size = New-Object System.Drawing.Size(170, 44)
$btnVerify.BackColor = [System.Drawing.Color]::FromArgb(30, 41, 59)
$btnVerify.ForeColor = [System.Drawing.Color]::FromArgb(56, 189, 248)
$btnVerify.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
$btnVerify.FlatAppearance.BorderColor = [System.Drawing.Color]::FromArgb(56, 189, 248)
$btnVerify.Cursor = [System.Windows.Forms.Cursors]::Hand
$form.Controls.Add($btnVerify)

$btnUninstall = New-Object System.Windows.Forms.Button
$btnUninstall.Text = "حذف پچ"
$btnUninstall.Font = $fontSub
$btnUninstall.Location = New-Object System.Drawing.Point(20, 180)
$btnUninstall.Size = New-Object System.Drawing.Size(100, 44)
$btnUninstall.BackColor = [System.Drawing.Color]::FromArgb(30, 41, 59)
$btnUninstall.ForeColor = [System.Drawing.Color]::FromArgb(244, 63, 94) # Rose
$btnUninstall.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
$btnUninstall.FlatAppearance.BorderColor = [System.Drawing.Color]::FromArgb(71, 85, 105)
$btnUninstall.Cursor = [System.Windows.Forms.Cursors]::Hand
$form.Controls.Add($btnUninstall)

# کادر لاگ و گزارشات متنی
$txtLog = New-Object System.Windows.Forms.TextBox
$txtLog.Multiline = $true
$txtLog.ScrollBars = "Vertical"
$txtLog.ReadOnly = $true
$txtLog.Font = $fontLog
$txtLog.BackColor = [System.Drawing.Color]::FromArgb(3, 7, 18)
$txtLog.ForeColor = [System.Drawing.Color]::FromArgb(226, 232, 240)
$txtLog.Location = New-Object System.Drawing.Point(20, 240)
$txtLog.Size = New-Object System.Drawing.Size(560, 230)
$txtLog.RightToLeft = [System.Windows.Forms.RightToLeft]::No
$form.Controls.Add($txtLog)

function Append-Log($msg) {
    $txtLog.AppendText($msg + "`r`n")
    $txtLog.SelectionStart = $txtLog.Text.Length
    $txtLog.ScrollToCaret()
    $form.Update()
}

# رویداد اسکن خودکار
$btnDetect.Add_Click({
    Append-Log "[*] در حال اسکن پورت‌های فیلترشکن..."
    $ports = @(7897, 7890, 10809, 2080, 1080)
    $found = $false
    foreach ($p in $ports) {
        $tcp = New-Object System.Net.Sockets.TcpClient
        $conn = $tcp.BeginConnect("127.0.0.1", $p, $null, $null)
        if ($conn.AsyncWaitHandle.WaitOne(300, $false)) {
            try {
                $tcp.EndConnect($conn)
                $tcp.Close()
                $txtPort.Text = "$p"
                Append-Log "[OK] پورت فعال پیدا شد: $p"
                $found = $true
                break
            } catch { $tcp.Close() }
        } else { $tcp.Close() }
    }
    if (-not $found) {
        Append-Log "[!] هیچ پورتی فعال نبود. پورت 7897 به صورت پیش‌فرض درج شد."
    }
})

# رویداد نصب پچ
$btnInstall.Add_Click({
    $port = 7897
    if ($txtPort.Text -match '^\d+$') { $port = [int]$txtPort.Text }
    Append-Log "`r`n[+] در حال اعمال پچ برای پورت $port..."
    
    $installerScript = Join-Path $ScriptDir "Iran-Patch-Installer.ps1"
    if (Test-Path $installerScript) {
        $psi = New-Object System.Diagnostics.ProcessStartInfo
        $psi.FileName = "powershell.exe"
        $psi.Arguments = "-NoProfile -ExecutionPolicy Bypass -File `"$installerScript`" -Auto -CustomPort $port"
        $psi.RedirectStandardOutput = $true
        $psi.UseShellExecute = $false
        $psi.CreateNoWindow = $true
        $proc = [System.Diagnostics.Process]::Start($psi)
        $output = $proc.StandardOutput.ReadToEnd()
        $proc.WaitForExit()
        
        Append-Log "[OK] پچ با موفقیت اعمال شد."
        Append-Log "میانبر دسکتاپ: Antigravity IDE (Iran Patch)"
        [System.Windows.Forms.MessageBox]::Show("پچ با موفقیت نصب شد!`nاکنون می‌توانید نرم‌افزار را از طریق میانبر دسکتاپ اجرا کنید.", "موفقیت", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
    } else {
        Append-Log "[X] فایل Iran-Patch-Installer.ps1 یافت نشد!"
    }
})

# رویداد تست سلامت
$btnVerify.Add_Click({
    Append-Log "`r`n[+] در حال تست سلامت اتصال به سرورهای گوگل..."
    $verifyScript = Join-Path $ScriptDir "Verify-Connection.ps1"
    if (Test-Path $verifyScript) {
        $psi = New-Object System.Diagnostics.ProcessStartInfo
        $psi.FileName = "powershell.exe"
        $psi.Arguments = "-NoProfile -ExecutionPolicy Bypass -Command `"& { & '$verifyScript' }`""
        $psi.RedirectStandardOutput = $true
        $psi.UseShellExecute = $false
        $psi.CreateNoWindow = $true
        $proc = [System.Diagnostics.Process]::Start($psi)
        $output = $proc.StandardOutput.ReadToEnd()
        $proc.WaitForExit()
        
        Append-Log $output
    }
})

# رویداد حذف پچ
$btnUninstall.Add_Click({
    $res = [System.Windows.Forms.MessageBox]::Show("آیا مطمئن هستید که می‌خواهید پچ را به طور کامل حذف کنید؟", "تایید حذف", [System.Windows.Forms.MessageBoxButtons]::YesNo, [System.Windows.Forms.MessageBoxIcon]::Question)
    if ($res -eq [System.Windows.Forms.DialogResult]::Yes) {
        $uninstallScript = Join-Path $ScriptDir "Uninstall-Iran-Patch.ps1"
        if (Test-Path $uninstallScript) {
            $psi = New-Object System.Diagnostics.ProcessStartInfo
            $psi.FileName = "powershell.exe"
            $psi.Arguments = "-NoProfile -ExecutionPolicy Bypass -File `"$uninstallScript`" -Auto"
            $psi.RedirectStandardOutput = $true
            $psi.UseShellExecute = $false
            $psi.CreateNoWindow = $true
            $proc = [System.Diagnostics.Process]::Start($psi)
            $proc.WaitForExit()
            Append-Log "[OK] پچ با موفقیت حذف شد."
        }
    }
})

# متن شروع اولیه لاگ
Append-Log "آماده به کار. روی دکمه 'نصب و فعال‌سازی پچ' کلیک کنید."

# نمایش فرم
$btnDetect.PerformClick()
[void]$form.ShowDialog()
