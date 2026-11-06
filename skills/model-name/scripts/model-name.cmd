@echo off
rem Windows launcher. All resolution and formatting logic lives in the
rem PowerShell sibling; this shim only forwards the arguments. Requires
rem PowerShell 7 because Microsoft.Data.Sqlite targets .NET 8+.
setlocal
where pwsh >nul 2>nul
if errorlevel 1 (
  echo model-name: PowerShell 7 ^(pwsh^) is required. 1>&2
  exit /b 1
)
pwsh -NoProfile -ExecutionPolicy Bypass -File "%~dp0model-name.ps1" %*
exit /b %errorlevel%
