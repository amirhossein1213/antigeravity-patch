@echo off
chcp 65001 >nul
cd /d "%~dp0"
title Antigravity Iran Patch GUI
start powershell.exe -NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File "%~dp0Iran-Patch-GUI.ps1"
