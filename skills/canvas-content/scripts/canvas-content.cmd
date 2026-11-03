@echo off
rem Windows launcher. All resolution and formatting logic lives in the
rem PowerShell sibling; this shim only forwards the arguments. Uses
rem PowerShell 5.1 (inbox) when pwsh 7 is not on PATH.
setlocal
set "PS=powershell.exe"
where pwsh >nul 2>nul
if %errorlevel%==0 set "PS=pwsh"
"%PS%" -NoProfile -ExecutionPolicy Bypass -File "%~dp0canvas-content.ps1" %*
exit /b %errorlevel%