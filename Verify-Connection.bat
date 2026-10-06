@echo off
chcp 65001 >nul
cd /d "%~dp0"

if "%WT_SESSION%"=="" if "%AG_NO_WT%"=="" (
    where wt.exe >nul 2>&1
    if %ERRORLEVEL% EQU 0 (
        set AG_NO_WT=1
        start wt.exe --title "Verify Antigravity Connection" cmd.exe /c ""%~f0""
        exit /b 0
    )
)

title بررسی وضعیت اتصال و پچ Antigravity
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0Verify-Connection.ps1"
