@echo off
chcp 65001 >nul
title حذف پچ Antigravity
cd /d "%~dp0"

powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0Uninstall-Iran-Patch.ps1"
