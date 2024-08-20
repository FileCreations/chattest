@echo off
setlocal

:checkPrivileges
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo Requesting administrative privileges...
    powershell start-process "%~f0" -verb runas
    exit /B
)

echo Are you sure you want to run %1 as SYSTEM? (Y/N)
set /p response=
if /i "%response%"=="Y" (
    psexec -s -i "%1"
) else (
    echo Operation canceled.
)
pause
endlocal
