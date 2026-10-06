@echo off
cd /d "%~dp0"
title Push Antigravity Iran Patch to GitHub

echo ======================================================================
echo  Pushing project to your GitHub repository...
echo  https://github.com/amirhossein1213/antigeravity-patch
echo ======================================================================
echo.

git push -u origin main

if %ERRORLEVEL% EQU 0 (
    echo.
    echo [OK] Successfully pushed to GitHub!
) else (
    echo.
    echo [!] Push failed or authentication required.
    echo     Please use GitHub Desktop or check your git credentials.
)
echo.
pause
