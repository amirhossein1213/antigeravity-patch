@echo off
cd /d "%~dp0"
title Uninstall Google Antigravity Iran Patch
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0Uninstall-Iran-Patch.ps1"
if errorlevel 1 (
    pause
)
