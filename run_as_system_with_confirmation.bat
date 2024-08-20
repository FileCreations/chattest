@echo off
setlocal

:checkPrivileges
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo Requesting administrative privileges...
    powershell start-process "%~f0" -verb runas
    exit /B
)

echo Are you sure you want to run "%~1" as SYSTEM? (Y/N)
set /p response=
if /i "%response%"=="Y" (
    echo Executing: "%~1"
    psexec -accepteula -s -i "%~1"
    if %errorLevel% neq 0 (
        echo Failed to run "%~1" as SYSTEM. Please check the path and permissions.
    )
) else (
    echo Operation canceled.
)
pause
endlocal
