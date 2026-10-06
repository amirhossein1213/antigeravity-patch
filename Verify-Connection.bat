@echo off
cd /d "%~dp0"

if "%WT_SESSION%"=="" (
    where wt.exe >nul 2>&1
    if not errorlevel 1 (
        start wt.exe -w 0 nt --title "Verify Antigravity Connection" powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0Verify-Connection.ps1"
        exit /b 0
    )
)

title Verify Antigravity Connection
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0Verify-Connection.ps1"
if errorlevel 1 (
    pause
)
