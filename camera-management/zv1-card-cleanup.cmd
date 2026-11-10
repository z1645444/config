@echo off
setlocal
cd /d "%~dp0"

echo.
echo   Sony ZV-1 card cleanup
echo   =====================
echo.
echo   1  Dry run  - only show what would be deleted (safe)
echo   2  Clean    - actually delete the listed items
echo.
set /p MODE=  Choose 1 or 2 (Enter = dry run):

if /i "%MODE%"=="2" (
  powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0zv1-card-cleanup.ps1" -Apply
) else (
  powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0zv1-card-cleanup.ps1"
)

echo.
pause