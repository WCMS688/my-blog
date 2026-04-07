@echo off
setlocal
cd /d "%~dp0"

echo Publishing blog from %cd%
echo.

powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0publish.ps1" %*
set EXITCODE=%ERRORLEVEL%

echo.
if %EXITCODE%==0 (
  echo Done.
) else (
  echo Failed with exit code %EXITCODE%.
)
echo.
pause
exit /b %EXITCODE%
