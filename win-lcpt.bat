@echo off
setlocal enabledelayedexpansion

net session >nul 2>&1
if %errorlevel% neq 0 (
    echo Requesting administrative privileges...
    powershell -Command "Start-Process '%~dpnx0' -Verb RunAs"
    exit /b
)

set "hostsFile=%WINDIR%\System32\drivers\etc\hosts"
set "backupFile=%hostsFile%.be_backup"

:menu
cls
echo ============================================
echo      Win-LCPT (Linux Crossplay Toolkit)
echo ============================================
echo.
echo 1. Enable  (Block DNS)
echo 2. Disable (Restore original hosts file)
echo 3. Exit
echo.
set /p choice="Enter your choice (1-3): "

if "%choice%"=="1" goto enable
if "%choice%"=="2" goto disable
if "%choice%"=="3" goto end
goto menu
:enable
echo [%date% %time%] ACTION: Enable requested.

findstr /C:"paradise-s1.battleye.com" "%hostsFile%" >nul
if %errorlevel% equ 0 (
    echo.
    echo [INFO] BattlEye is already blocked in your hosts file.
    echo [%date% %time%] STATUS: Failed. Already blocked.
    pause
    goto menu
)

if not exist "%backupFile%" (
    copy /y "%hostsFile%" "%backupFile%" >nul
    echo [%date% %time%] BACKUP: Created at %backupFile%
)

echo.>> "%hostsFile%"
echo # GTA V BattlEye Block>> "%hostsFile%"
echo 0.0.0.0 paradise-s1.battleye.com>> "%hostsFile%"
echo 0.0.0.0 test-s1.battleye.com>> "%hostsFile%"
echo 0.0.0.0 paradiseenhanced-s1.battleye.com>> "%hostsFile%"

ipconfig /flushdns >nul

echo.
echo [SUCCESS] BattlEye domains have been blocked.
echo You can now play with Linux users and other LCPT users.
echo.
echo [WARNING] This disables public sessions. Make sure to disable LCPT and restart your game before attempting to go public.
echo Additionally, you must enter an Invite/Friends Only session from Story Mode, else BattlEye will kick you.
echo.
echo [%date% %time%] STATUS: Successfully added domains to hosts and flushed DNS.
pause
goto menu

:disable
echo [%date% %time%] ACTION: Disable requested.

if exist "%backupFile%" (
    copy /y "%backupFile%" "%hostsFile%" >nul
    
    ipconfig /flushdns >nul
    
    echo.
    echo [SUCCESS] Original hosts file restored. BattlEye unblocked.
    echo You can now play with stock Windows users and on public sessions.
    echo .
    echo [%date% %time%] STATUS: Successfully restored backup and flushed DNS.
) else (
    echo.
    echo [ERROR] No backup file found. Cannot restore.
    echo [%date% %time%] STATUS: Failed. No backup file found.
)
pause
goto menu

:end
exit
