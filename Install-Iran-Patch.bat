@echo off
chcp 65001 >nul
cd /d "%~dp0"

:: اگر ویندوز ترمینال نصب است و در آن نیستیم، برای رندر عالی فونت فارسی در ویندوز ترمینال باز شود
if "%WT_SESSION%"=="" if "%AG_NO_WT%"=="" (
    where wt.exe >nul 2>&1
    if %ERRORLEVEL% EQU 0 (
        set AG_NO_WT=1
        start wt.exe --title "Antigravity Iran Proxy Patch" cmd.exe /c ""%~f0""
        exit /b 0
    )
)

title نصب پچ ضد تحریم Google Antigravity
echo ======================================================================
echo          در حال آماده‌سازی و اجرای نصاب پچ ضد تحریم Google Antigravity...
echo ======================================================================
echo.

powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0Iran-Patch-Installer.ps1"

if %ERRORLEVEL% NEQ 0 (
    echo.
    echo [خطا] اجرای اسکریپت با مشکل مواجه شد. لطفاً مطمئن شوید فیلترشکن شما روشن است.
    echo.
    pause
)
