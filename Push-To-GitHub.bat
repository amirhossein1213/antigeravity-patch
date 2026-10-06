@echo off
cd /d "%~dp0"
title Push Antigravity Iran Patch to GitHub

echo ======================================================================
echo  Dar hale upload-e project be GitHub...
echo  https://github.com/amirhossein1213/antigeravity-patch
echo ======================================================================
echo.

git push -u origin main

if %ERRORLEVEL% EQU 0 (
    echo.
    echo [OK] Project ba movafaghiyat rooye GitHub upload shod!
) else (
    echo.
    echo [!] Push ba khata movajeh shod ya login lazem ast.
    echo     Lotfan az GitHub Desktop estefade konid ya git credential ra check konid.
)
echo.
pause
