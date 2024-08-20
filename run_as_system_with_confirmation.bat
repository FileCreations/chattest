@echo off
setlocal

echo Are you sure you want to run %1 as SYSTEM? (Y/N)
set /p response=
if /i "%response%"=="Y" (
    start "" /B cmd /c "psexec -s -i %1"
) else (
    echo Operation canceled.
)
pause
endlocal
