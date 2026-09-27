@echo off
setlocal EnableExtensions
set "PS=%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe"
if not exist "%PS%" set "PS=powershell"
for /f "tokens=2 delims=:" %%c in ('chcp') do set /a "OLDCP=%%c" >nul 2>&1
chcp 65001 >nul 2>&1
"%PS%" -NoProfile -ExecutionPolicy Bypass -File "%~dp0scrape-web-content.ps1" %*
set "RC=%errorlevel%"
if defined OLDCP chcp %OLDCP% >nul 2>&1
endlocal & exit /b %RC%
