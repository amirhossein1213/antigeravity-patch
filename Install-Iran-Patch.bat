@echo off
cd /d "%~dp0"

if "%WT_SESSION%"=="" (
    where wt.exe >nul 2>&1
    if not errorlevel 1 (
        start wt.exe -w 0 nt --title "Google Antigravity Iran Patch" powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0Iran-Patch-Installer.ps1"
        exit /b 0
    )
)

title Google Antigravity Iran Patch
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0Iran-Patch-Installer.ps1"
if errorlevel 1 (
    echo.
    echo An error occurred during installation.
    pause
)
