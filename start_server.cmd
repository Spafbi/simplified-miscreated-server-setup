@echo off
goto :update

:update
echo Checking for new Simplified Miscreated Server Script updates...
setlocal EnableDelayedExpansion
set GITURL=https://api.github.com/repos/Spafbi/simplified-miscreated-server-setup/releases/latest
set DOWNLOADURL=https://github.com/Spafbi/simplified-miscreated-server-setup/releases/download/
set CORESCRIPT=start_server_core.cmd
set DOWNLOAD=0
powershell -Command "$request=${env:GITURL}; Write-Output (Invoke-WebRequest $request |ConvertFrom-Json |Select tag_name -ExpandProperty tag_name)">latest_release"

REM This if statement exists so I don't overwrite the core script while developing
if exist .\.git\ (
  set TARGETSCRIPT=start_server_core_download.cmd
) else (
  set TARGETSCRIPT=%CORESCRIPT%
)

if exist "local_release" (
  set /p CURRENT=<local_release"
) else (
  set CURRENT=0
)

if exist "latest_release" (
  set /p LATEST=<latest_release"
) else (
  set LATEST=0
)

if "%LATEST%" == "0" if "%CURRENT%" == "0" (
  echo No core script exists and the current release for download cannot be determined at this time.
  echo No action taken.
  goto :end
)

if not exist %TARGETSCRIPT% set DOWNLOAD=1
if "%CURRENT%" == "0" set DOWNLOAD=1
if not "%CURRENT%" == "%LATEST%" set DOWNLOAD=1
if "%DOWNLOAD%" == "1" call :getlatest

goto :start

:getlatest
curl -L "%DOWNLOADURL%%LATEST%/%CORESCRIPT%">%TARGETSCRIPT%
echo %LATEST%>local_release
goto :eof

:start
if exist %TARGETSCRIPT% (
%TARGETSCRIPT%
CHOICE /d Y /T 10 /M "Would you like to restart the server? (auto-restart in 10 seconds)"
IF !ERRORLEVEL! EQU 1 goto update
echo.
echo I hope you found this script use useful.
echo   -Spafbi
echo.
timeout /t 10
) else (
  echo ERROR: %CORESCRIPT% was not found.
)
goto :end

:end
