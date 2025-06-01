@echo off

:: Utility: Windows System Cleanup and Optimization
:: Filename: windows-optimization.bat
:: Developer: Miguel Nischor <miguel@nischor.com.br>
:: Version 1.0

title Windows System Cleanup and Optimization Utility
setlocal enabledelayedexpansion

:: Color codes: 0A=Green, 0E=Yellow, 0C=Red, 07=White
set "COLOR_INFO=0A"
set "COLOR_WARNING=0E"
set "COLOR_ERROR=0C"
set "COLOR_DEFAULT=07"

:: Log file configuration
set "LOG_FILE=%~dp0windows-optimization.log"
set "TIMESTAMP="

:: Function to get current timestamp
for /f "tokens=1-6 delims=/:. " %%a in ('echo %date% %time%') do (
    set "TIMESTAMP=%%c-%%a-%%b %%d:%%e:%%f"
)

:: Initialize log file
echo ======================================== >> "%LOG_FILE%"
echo Windows System Cleanup and Optimization >> "%LOG_FILE%"
echo Started: %TIMESTAMP% >> "%LOG_FILE%"
echo ======================================== >> "%LOG_FILE%"

color %COLOR_INFO%
echo ========================================
echo    WINDOWS SYSTEM CLEANUP AND
echo       OPTIMIZATION UTILITY
echo ========================================
echo.
echo [INFO] Log file: %LOG_FILE%
echo [INFO] Log file initialized >> "%LOG_FILE%"

color %COLOR_WARNING%
echo WARNING: This script requires Administrator privileges
echo Press any key to continue...
pause >nul

:: Check if running as administrator
net session >nul 2>&1
if %errorlevel% neq 0 (
    color %COLOR_ERROR%
    echo ERROR: This script must be run as Administrator
    echo ERROR: Script must be run as Administrator >> "%LOG_FILE%"
    echo Please right-click and select "Run as administrator"
    pause
    exit /b 1
)

color %COLOR_INFO%
echo [INFO] Administrator privileges confirmed
echo [INFO] Administrator privileges confirmed >> "%LOG_FILE%"

:: Create system restore point
echo [INFO] Creating system restore point...
echo [INFO] Creating system restore point... >> "%LOG_FILE%"
wmic.exe /Namespace:\\root\default Path SystemRestore Call CreateRestorePoint "System Cleanup and Optimization", 100, 7 >nul 2>&1
if %errorlevel% neq 0 (
    color %COLOR_WARNING%
    echo WARNING: Failed to create system restore point
    echo WARNING: Failed to create system restore point >> "%LOG_FILE%"
    echo Continuing without restore point...
    timeout /t 3 >nul
) else (
    color %COLOR_INFO%
    echo [INFO] System restore point created successfully
    echo [SUCCESS] System restore point created successfully >> "%LOG_FILE%"
)

echo.
color %COLOR_INFO%
echo ========================================
echo    INITIATING SYSTEM CLEANUP
echo ========================================
echo [INFO] Starting system cleanup phase >> "%LOG_FILE%"

:: Temporary files cleanup
echo [1/10] Cleaning user temporary files...
echo [1/10] Cleaning user temporary files... >> "%LOG_FILE%"
rd "%temp%" /s /q >nul 2>&1
if %errorlevel% neq 0 (
    color %COLOR_WARNING%
    echo WARNING: Some temporary files could not be deleted (files in use)
    echo WARNING: Some temporary files could not be deleted (files in use) >> "%LOG_FILE%"
) else (
    color %COLOR_INFO%
    echo [SUCCESS] User temporary files cleaned
    echo [SUCCESS] User temporary files cleaned >> "%LOG_FILE%"
)
md "%temp%" >nul 2>&1

echo [2/10] Cleaning Windows temporary files...
echo [2/10] Cleaning Windows temporary files... >> "%LOG_FILE%"
del /f /s /q "%windir%\temp\*.*" >nul 2>&1
rd "%windir%\temp" /s /q >nul 2>&1
if %errorlevel% neq 0 (
    color %COLOR_WARNING%
    echo WARNING: Some Windows temp files could not be deleted
    echo WARNING: Some Windows temp files could not be deleted >> "%LOG_FILE%"
) else (
    color %COLOR_INFO%
    echo [SUCCESS] Windows temporary files cleaned
    echo [SUCCESS] Windows temporary files cleaned >> "%LOG_FILE%"
)
md "%windir%\temp" >nul 2>&1

echo [3/10] Cleaning Windows cache...
echo [3/10] Cleaning Windows cache... >> "%LOG_FILE%"
del /f /s /q "%windir%\Prefetch\*.*" >nul 2>&1
if %errorlevel% neq 0 (
    color %COLOR_WARNING%
    echo WARNING: Prefetch cache cleanup incomplete
    echo WARNING: Prefetch cache cleanup incomplete >> "%LOG_FILE%"
) else (
    color %COLOR_INFO%
    echo [SUCCESS] Prefetch cache cleaned
    echo [SUCCESS] Prefetch cache cleaned >> "%LOG_FILE%"
)

del /f /s /q "%windir%\SoftwareDistribution\Download\*.*" >nul 2>&1
if %errorlevel% neq 0 (
    color %COLOR_WARNING%
    echo WARNING: Windows Update cache cleanup incomplete
    echo WARNING: Windows Update cache cleanup incomplete >> "%LOG_FILE%"
) else (
    color %COLOR_INFO%
    echo [SUCCESS] Windows Update cache cleaned
    echo [SUCCESS] Windows Update cache cleaned >> "%LOG_FILE%"
)

echo [4/10] Cleaning system event logs...
echo [4/10] Cleaning system event logs... >> "%LOG_FILE%"
set "log_errors=0"
for /f "tokens=*" %%G in ('wevtutil.exe el 2^>nul') DO (
    wevtutil.exe cl "%%G" >nul 2>&1
    if !errorlevel! neq 0 set /a log_errors+=1
)
if %log_errors% gtr 0 (
    color %COLOR_WARNING%
    echo WARNING: %log_errors% event logs could not be cleared
    echo WARNING: %log_errors% event logs could not be cleared >> "%LOG_FILE%"
) else (
    color %COLOR_INFO%
    echo [SUCCESS] System event logs cleared
    echo [SUCCESS] System event logs cleared >> "%LOG_FILE%"
)

echo [5/10] Emptying Recycle Bin...
echo [5/10] Emptying Recycle Bin... >> "%LOG_FILE%"
rd /s /q C:\$Recycle.Bin >nul 2>&1
if %errorlevel% neq 0 (
    color %COLOR_WARNING%
    echo WARNING: Recycle Bin cleanup incomplete (files in use)
    echo WARNING: Recycle Bin cleanup incomplete (files in use) >> "%LOG_FILE%"
) else (
    color %COLOR_INFO%
    echo [SUCCESS] Recycle Bin emptied
    echo [SUCCESS] Recycle Bin emptied >> "%LOG_FILE%"
)

echo [6/10] Cleaning browser cache files...
echo [6/10] Cleaning browser cache files... >> "%LOG_FILE%"
:: Chrome browser cache
del /f /s /q "%userprofile%\AppData\Local\Google\Chrome\User Data\Default\Cache\*.*" >nul 2>&1
if %errorlevel% neq 0 (
    color %COLOR_WARNING%
    echo WARNING: Chrome cache cleanup incomplete
    echo WARNING: Chrome cache cleanup incomplete >> "%LOG_FILE%"
) else (
    color %COLOR_INFO%
    echo [SUCCESS] Chrome cache cleaned
    echo [SUCCESS] Chrome cache cleaned >> "%LOG_FILE%"
)

:: Firefox browser cache
del /f /s /q "%userprofile%\AppData\Local\Mozilla\Firefox\Profiles\*.default\cache2\*.*" >nul 2>&1
if %errorlevel% neq 0 (
    color %COLOR_WARNING%
    echo WARNING: Firefox cache cleanup incomplete
    echo WARNING: Firefox cache cleanup incomplete >> "%LOG_FILE%"
) else (
    color %COLOR_INFO%
    echo [SUCCESS] Firefox cache cleaned
    echo [SUCCESS] Firefox cache cleaned >> "%LOG_FILE%"
)

:: Microsoft Edge cache
del /f /s /q "%userprofile%\AppData\Local\Microsoft\Edge\User Data\Default\Cache\*.*" >nul 2>&1
if %errorlevel% neq 0 (
    color %COLOR_WARNING%
    echo WARNING: Edge cache cleanup incomplete
    echo WARNING: Edge cache cleanup incomplete >> "%LOG_FILE%"
) else (
    color %COLOR_INFO%
    echo [SUCCESS] Edge cache cleaned
    echo [SUCCESS] Edge cache cleaned >> "%LOG_FILE%"
)

echo.
color %COLOR_INFO%
echo ========================================
echo    EXECUTING SYSTEM REPAIR TOOLS
echo ========================================
echo [INFO] Starting system repair phase >> "%LOG_FILE%"

echo [7/10] Running System File Checker (SFC)...
echo [7/10] Running System File Checker (SFC)... >> "%LOG_FILE%"
sfc /scannow >nul 2>&1
if %errorlevel% neq 0 (
    color %COLOR_ERROR%
    echo ERROR: System File Checker failed to complete
    echo ERROR: System File Checker failed to complete (Error Code: %errorlevel%) >> "%LOG_FILE%"
    echo This may indicate serious system corruption
) else (
    color %COLOR_INFO%
    echo [SUCCESS] System File Checker completed
    echo [SUCCESS] System File Checker completed >> "%LOG_FILE%"
)

echo [8/10] Running Windows Image Repair (DISM)...
echo [8/10] Running Windows Image Repair (DISM)... >> "%LOG_FILE%"
DISM /Online /Cleanup-Image /RestoreHealth >nul 2>&1
if %errorlevel% neq 0 (
    color %COLOR_ERROR%
    echo ERROR: DISM repair operation failed
    echo ERROR: DISM repair operation failed (Error Code: %errorlevel%) >> "%LOG_FILE%"
    echo System image may be corrupted
) else (
    color %COLOR_INFO%
    echo [SUCCESS] Windows Image repair completed
    echo [SUCCESS] Windows Image repair completed >> "%LOG_FILE%"
)

echo [9/10] Performing disk integrity check...
echo [9/10] Performing disk integrity check... >> "%LOG_FILE%"
echo Note: Disk check will be scheduled for next reboot
echo y | chkdsk C: /f /r /x >nul 2>&1
if %errorlevel% neq 0 (
    color %COLOR_WARNING%
    echo WARNING: Disk check scheduling may have failed
    echo WARNING: Disk check scheduling may have failed (Error Code: %errorlevel%) >> "%LOG_FILE%"
) else (
    color %COLOR_INFO%
    echo [SUCCESS] Disk check scheduled for next reboot
    echo [SUCCESS] Disk check scheduled for next reboot >> "%LOG_FILE%"
)

echo [10/10] Running Disk Cleanup utility...
echo [10/10] Running Disk Cleanup utility... >> "%LOG_FILE%"
cleanmgr /sageset:1 >nul 2>&1
cleanmgr /sagerun:1 >nul 2>&1
if %errorlevel% neq 0 (
    color %COLOR_WARNING%
    echo WARNING: Disk Cleanup utility encountered issues
    echo WARNING: Disk Cleanup utility encountered issues (Error Code: %errorlevel%) >> "%LOG_FILE%"
) else (
    color %COLOR_INFO%
    echo [SUCCESS] Disk Cleanup completed
    echo [SUCCESS] Disk Cleanup completed >> "%LOG_FILE%"
)

echo.
color %COLOR_INFO%
echo ========================================
echo    APPLYING SYSTEM OPTIMIZATIONS
echo ========================================
echo [INFO] Starting system optimization phase >> "%LOG_FILE%"

:: Disable unnecessary services
echo Optimizing Windows services...
echo [INFO] Optimizing Windows services... >> "%LOG_FILE%"
set "service_errors=0"

sc config "DiagTrack" start= disabled >nul 2>&1
if %errorlevel% neq 0 (
    set /a service_errors+=1
    echo WARNING: Failed to disable DiagTrack service >> "%LOG_FILE%"
) else (
    echo [SUCCESS] DiagTrack service disabled >> "%LOG_FILE%"
)

sc config "dmwappushservice" start= disabled >nul 2>&1
if %errorlevel% neq 0 (
    set /a service_errors+=1
    echo WARNING: Failed to disable dmwappushservice >> "%LOG_FILE%"
) else (
    echo [SUCCESS] dmwappushservice disabled >> "%LOG_FILE%"
)

sc config "WSearch" start= disabled >nul 2>&1
if %errorlevel% neq 0 (
    set /a service_errors+=1
    echo WARNING: Failed to disable WSearch service >> "%LOG_FILE%"
) else (
    echo [SUCCESS] WSearch service disabled >> "%LOG_FILE%"
)

sc config "RetailDemo" start= disabled >nul 2>&1
if %errorlevel% neq 0 (
    set /a service_errors+=1
    echo WARNING: Failed to disable RetailDemo service >> "%LOG_FILE%"
) else (
    echo [SUCCESS] RetailDemo service disabled >> "%LOG_FILE%"
)

sc config "Fax" start= disabled >nul 2>&1
if %errorlevel% neq 0 (
    set /a service_errors+=1
    echo WARNING: Failed to disable Fax service >> "%LOG_FILE%"
) else (
    echo [SUCCESS] Fax service disabled >> "%LOG_FILE%"
)

if %service_errors% gtr 0 (
    color %COLOR_WARNING%
    echo WARNING: %service_errors% services could not be optimized
    echo WARNING: %service_errors% services could not be optimized >> "%LOG_FILE%"
) else (
    color %COLOR_INFO%
    echo [SUCCESS] Windows services optimized
    echo [SUCCESS] All Windows services optimized >> "%LOG_FILE%"
)

:: Registry optimizations
echo Applying registry optimizations...
echo [INFO] Applying registry optimizations... >> "%LOG_FILE%"
set "registry_errors=0"

reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection" /v AllowTelemetry /t REG_DWORD /d 0 /f >nul 2>&1
if %errorlevel% neq 0 (
    set /a registry_errors+=1
    echo WARNING: Failed to disable telemetry >> "%LOG_FILE%"
) else (
    echo [SUCCESS] Telemetry disabled >> "%LOG_FILE%"
)

reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v Start_TrackDocs /t REG_DWORD /d 0 /f >nul 2>&1
if %errorlevel% neq 0 (
    set /a registry_errors+=1
    echo WARNING: Failed to optimize Start Menu tracking >> "%LOG_FILE%"
) else (
    echo [SUCCESS] Start Menu tracking optimized >> "%LOG_FILE%"
)

reg add "HKCU\Control Panel\Desktop\WindowMetrics" /v MinAnimate /t REG_SZ /d 0 /f >nul 2>&1
if %errorlevel% neq 0 (
    set /a registry_errors+=1
    echo WARNING: Failed to disable animations >> "%LOG_FILE%"
) else (
    echo [SUCCESS] Animations disabled >> "%LOG_FILE%"
)

reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" /v VisualFXSetting /t REG_DWORD /d 2 /f >nul 2>&1
if %errorlevel% neq 0 (
    set /a registry_errors+=1
    echo WARNING: Failed to optimize visual effects >> "%LOG_FILE%"
) else (
    echo [SUCCESS] Visual effects optimized >> "%LOG_FILE%"
)

reg add "HKCU\Control Panel\Desktop" /v MenuShowDelay /t REG_SZ /d 0 /f >nul 2>&1
if %errorlevel% neq 0 (
    set /a registry_errors+=1
    echo WARNING: Failed to optimize menu delay >> "%LOG_FILE%"
) else (
    echo [SUCCESS] Menu delay optimized >> "%LOG_FILE%"
)

reg add "HKLM\SYSTEM\CurrentControlSet\Control" /v WaitToKillServiceTimeout /t REG_SZ /d 2000 /f >nul 2>&1
if %errorlevel% neq 0 (
    set /a registry_errors+=1
    echo WARNING: Failed to optimize boot timeout >> "%LOG_FILE%"
) else (
    echo [SUCCESS] Boot timeout optimized >> "%LOG_FILE%"
)

reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\RunMRU" /f >nul 2>&1
echo [INFO] Run command history cleared >> "%LOG_FILE%"

if %registry_errors% gtr 0 (
    color %COLOR_WARNING%
    echo WARNING: %registry_errors% registry optimizations failed
    echo WARNING: %registry_errors% registry optimizations failed >> "%LOG_FILE%"
) else (
    color %COLOR_INFO%
    echo [SUCCESS] Registry optimizations applied
    echo [SUCCESS] All registry optimizations applied >> "%LOG_FILE%"
)

echo.
color %COLOR_INFO%
echo ========================================
echo    FINALIZING OPTIMIZATION PROCESS
echo ========================================
echo [INFO] Starting finalization phase >> "%LOG_FILE%"

:: Clear DNS resolver cache
echo Flushing DNS resolver cache...
echo [INFO] Flushing DNS resolver cache... >> "%LOG_FILE%"
ipconfig /flushdns >nul 2>&1
if %errorlevel% neq 0 (
    color %COLOR_ERROR%
    echo ERROR: DNS cache flush failed
    echo ERROR: DNS cache flush failed (Error Code: %errorlevel%) >> "%LOG_FILE%"
) else (
    color %COLOR_INFO%
    echo [SUCCESS] DNS cache flushed
    echo [SUCCESS] DNS cache flushed >> "%LOG_FILE%"
)

:: Reset Windows Sockets API
echo Resetting Winsock catalog...
echo [INFO] Resetting Winsock catalog... >> "%LOG_FILE%"
netsh winsock reset >nul 2>&1
if %errorlevel% neq 0 (
    color %COLOR_ERROR%
    echo ERROR: Winsock reset failed
    echo ERROR: Winsock reset failed (Error Code: %errorlevel%) >> "%LOG_FILE%"
) else (
    color %COLOR_INFO%
    echo [SUCCESS] Winsock catalog reset
    echo [SUCCESS] Winsock catalog reset >> "%LOG_FILE%"
)

:: Optimize system memory usage
echo Optimizing memory allocation...
echo [INFO] Optimizing memory allocation... >> "%LOG_FILE%"
rundll32.exe advapi32.dll,ProcessIdleTasks >nul 2>&1
if %errorlevel% neq 0 (
    color %COLOR_WARNING%
    echo WARNING: Memory optimization may not have completed
    echo WARNING: Memory optimization may not have completed (Error Code: %errorlevel%) >> "%LOG_FILE%"
) else (
    color %COLOR_INFO%
    echo [SUCCESS] Memory allocation optimized
    echo [SUCCESS] Memory allocation optimized >> "%LOG_FILE%"
)

:: Final timestamp
for /f "tokens=1-6 delims=/:. " %%a in ('echo %date% %time%') do (
    set "TIMESTAMP=%%c-%%a-%%b %%d:%%e:%%f"
)

echo.
color %COLOR_INFO%
echo ========================================
echo    OPTIMIZATION PROCESS COMPLETED
echo ========================================
echo.
echo Operations performed:
echo - Temporary files and cache cleanup
echo - System logs and registry cleanup
echo - System file verification and repair
echo - Service optimization and configuration
echo - Performance enhancement settings
echo - Network stack optimization
echo.

echo ======================================== >> "%LOG_FILE%"
echo Optimization process completed: %TIMESTAMP% >> "%LOG_FILE%"
echo ======================================== >> "%LOG_FILE%"
echo. >> "%LOG_FILE%"

color %COLOR_WARNING%
echo RECOMMENDATION: System restart is required
echo to apply all optimization changes.
echo.
echo [INFO] Complete log saved to: %LOG_FILE%
echo.
color %COLOR_DEFAULT%
echo Press any key to exit...
pause >nul
