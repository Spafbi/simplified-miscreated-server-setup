@echo OFF
chcp 65001>nul
setlocal EnableDelayedExpansion
REM - This grabs and parses the directory in which this CMD file exists.
set BASEPATH=%~dp0
set BASEPATH=%BASEPATH:~0,-1%
set MAP=islands
goto main


:basescfg
set HOSTINGFILE=%SERVERDIR%\hosting.cfg
if not exist "%HOSTINGFILE%" (
  echo g_gameRules_bases=^%BUILDRULE%>"%HOSTINGFILE%"
) else (
  copy /v /y "%HOSTINGFILE%" "%SERVERDIR%\hosting.cfg.bak" >nul
  powershell -Command "Write-Output (get-content '%HOSTINGFILE%' | select-string -pattern 'g_gameRules_bases').length">"%VARIABLESDIR%\temp.txt"

  echo .>nul
  set /p PSCOUNT=<"%VARIABLESDIR%\temp.txt"
  del "%VARIABLESDIR%\temp.txt"
  if "!PSCOUNT!" == "0" (
    echo g_gameRules_bases=^%BUILDRULE%>>"%HOSTINGFILE%"
  ) else (
    powershell -Command "& { Get-Content '%HOSTINGFILE%' | Foreach-Object {$_ -replace 'g_gameRules_bases=\w*', 'g_gameRules_bases=%BUILDRULE%'} | Set-Content '%HOSTINGFILE%.new';}"

    echo .>nul
    move /y "%HOSTINGFILE%.new" "%HOSTINGFILE%" >nul
  )
)
goto :eof

:cleanmods
if exist "%MODSDIR%" (
  echo [1m[33mCleaning up mods directory[0m ^(this ensures mods are current^)
  echo [1m[33m  removing directory:[0m %MODSDIR%
  rmdir /s /q "%MODSDIR%"
)
goto :eof


:createlocaljoin
echo [1m[33mCreating join_local_server.cmd script[0m
echo ^@echo off > join_local_server.cmd
echo explorer steam://run/299740/connect/+connect 127.0.0.1 %GAMEPORTA% >> join_local_server.cmd
goto :eof


:createmanualremoveupnpscript
echo [1m[33mCreating firewall UPnP settings manual removal script[0m
@echo off
echo @echo off> remove_upnp.cmd
echo echo ### UPnP BEFORE ###>> remove_upnp.cmd
echo upnpc\upnpc-shared.exe -L>> remove_upnp.cmd
echo echo Removing RCON mapping...>> remove_upnp.cmd
echo upnpc\upnpc-shared.exe -N %RCONPORT% %RCONPORT% TCP>> remove_upnp.cmd
echo echo Removing Miscreated UDP port mappings...>> remove_upnp.cmd
echo upnpc\upnpc-shared.exe -N %GAMEPORTA% %GAMEPORTD% UDP>> remove_upnp.cmd
echo echo ### UPnP AFTER ###>> remove_upnp.cmd
echo upnpc\upnpc-shared.exe -L>> remove_upnp.cmd
echo pause>> remove_upnp.cmd
goto :eof


:getsqlite3
echo [1m[33mDownloading SQLite3 binaries[0m
set SQLITELIBZIP=%BASEPATH%\sqlite-dll-win32-x86-3280000.zip
set SQLITEBINZIP=%BASEPATH%\sqlite-tools-win32-x86-3280000.zip

curl -L https://sqlite.org/2019/sqlite-dll-win32-x86-3280000.zip -o "%SQLITELIBZIP%"
curl -L https://sqlite.org/2019/sqlite-tools-win32-x86-3280000.zip -o "%SQLITEBINZIP%"

powershell Expand-Archive -LiteralPath '%SQLITELIBZIP%' -DestinationPath '%SQLITEPATH%'
powershell Expand-Archive -LiteralPath '%SQLITEBINZIP%' -DestinationPath '%SQLITEPATH%'

echo Moving downloaded executables...
move "%SQLITEPATH%\sqlite-tools-win32-x86-3280000\*.*" "%SQLITEPATH%\"
rmdir "%SQLITEPATH%\sqlite-tools-win32-x86-3280000"

echo Removing downloaded zip files...
del /q *.zip
goto :eof


:getsteamcmd
echo [1m[33mDownloading steamcmd binaries[0m
set STEAMARCHIVE=%BASEPATH%\steamcmd.zip
echo curl -L https://steamcdn-a.akamaihd.net/client/installer/steamcmd.zip -o "%STEAMARCHIVE%"
curl -L https://steamcdn-a.akamaihd.net/client/installer/steamcmd.zip -o "%STEAMARCHIVE%"
powershell Expand-Archive -LiteralPath '%STEAMARCHIVE%' -DestinationPath '%STEAMCMDPATH%'

echo Removing downloaded zip files...
del /q *.zip
goto :eof


:getupnphelper
echo [1m[33mGrabbing the UPnP helper[0m
set UPNPCARCHIVE=%BASEPATH%\upnpc-exe-win32-20150918.zip

curl -L http://miniupnp.tuxfamily.org/files/download.php?file=upnpc-exe-win32-20150918.zip -o "%UPNPCARCHIVE%"

powershell Expand-Archive -LiteralPath '%UPNPCARCHIVE%' -DestinationPath '%UNPNCHELPER%'

echo Removing downloaded zip files...
del /q *.zip
goto :eof


:grantallguides
echo [1m[33mGranting crafting guides to all players[0m
echo DROP TRIGGER IF EXISTS grant_all_guides;|"%SQLITEBIN%" "%SERVERDIR%\miscreated.db"
echo CREATE TRIGGER IF NOT EXISTS grant_all_guides AFTER INSERT ON ServerAccountData BEGIN UPDATE ServerAccountData SET Guide00=42949672965 WHERE ServerAccountDataID=NEW.ServerAccountDataID; END; UPDATE ServerAccountData SET Guide00=42949672965;|"%SQLITEBIN%" "%SERVERDIR%\miscreated.db"
goto :eof


:passwordcfg
set HOSTINGFILE=%SERVERDIR%\hosting.cfg
if not exist "%HOSTINGFILE%" (
  echo http_password=%RCONPASS%>>"%HOSTINGFILE%"
) else (
  copy /v /y "%HOSTINGFILE%" "%SERVERDIR%\hosting.cfg.bak" >nul
  powershell -Command "Write-Output (get-content '%HOSTINGFILE%' | select-string -pattern 'http_password').length">"%VARIABLESDIR%\temp.txt"

  echo .>nul
  set /p PSCOUNT=<"%VARIABLESDIR%\temp.txt"
  del "%VARIABLESDIR%\temp.txt"
  if "!PSCOUNT!" == "0" (
    echo http_password=%RCONPASS%>>"%HOSTINGFILE%"
  ) else (
    powershell -Command "& { Get-Content '%HOSTINGFILE%' | Foreach-Object {$_ -replace 'http_password=\w*', 'http_password=%RCONPASS%'} | Set-Content '%HOSTINGFILE%.new';}"

    echo .>nul
    move /y "%HOSTINGFILE%.new" "%HOSTINGFILE%" >nul
  )
)
goto :eof


:printconfig
echo.
echo.
echo ══════════════════════════════════════════════════════════════════════════════
echo                 The servername will be: [1m[36m%SERVERNAME%[0m
echo  The maximum number of players will be: [1m[36m%MAXPLAYERS%[0m
echo      The base game server port will be: [1m[36m%GAMEPORTA%[0m
echo.
echo              [1m[31mNOTICE:[0m Your RCON port is: [1m[36m%RCONPORT%[0m
echo.

if /I "%GRANTGUIDES%"=="y" (
  echo  ► Guides [1m[33mwill be granted[0m to all players
) else if /I "%GRANTGUIDES%"=="n" (
  echo  ► Guides [1m[33mwill not be granted[0m to all players
)

if /I "%BUILDRULE%"=="0" (
  echo  ► Base building is [1m[33mdisabled[0m
) else if /I "%BUILDRULE%"=="1" (
  echo  ► Base building is [1m[33menabled[0m[1m[33m: [0[36mdefault rules[0m
) else if /I "%BUILDRULE%"=="2" (
  echo  ► Base building is [1m[33menabled[0m[1m[33m: [0[36mbuild-anywhere[0m
)

if /I "%ENABLEUPNP%"=="y" (
  echo  ► Firewall ports [1m[33mwill be forwarded[0m
) else if /I "%ENABLEUPNP%"=="n" (
  echo  ► Firewall ports [1m[33mwill not be automatically forwarded[0m
)

if /I "%WHITELISTED%"=="y" (
  echo  ► The server [1m[33mwill be whitelisted[0m
  echo  ► You will need to add your Steam64ID to the whitelist before joining the server
) else (
  echo  ► The server [1m[33mwill not be whitelisted[0m
)
echo ══════════════════════════════════════════════════════════════════════════════
echo.
echo.
goto :eof


:removegrantallguides
echo [1m[33mRemoving grant_all_guides database trigger[0m
echo DROP TRIGGER IF EXISTS grant_all_guides;|"%SQLITEBIN%" "%SERVERDIR%\miscreated.db"
goto :eof


:removeupnp
echo [1m[33mRemoving firewall UPnP entries[0m
"%UNPNCHELPER%\upnpc-shared.exe" -N %RCONPORT% %RCONPORT% TCP >nul
"%UNPNCHELPER%\upnpc-shared.exe" -N %GAMEPORTA% %GAMEPORTD% UDP >nul
goto :eof


:servernamecfg
set HOSTINGFILE=%SERVERDIR%\hosting.cfg

if not exist "%HOSTINGFILE%" (
  echo sv_servername=%SERVERNAME%>>"%HOSTINGFILE%"
) else (
  copy /v /y "%HOSTINGFILE%" "%SERVERDIR%\hosting.cfg.bak" >nul
  powershell -Command "Write-Output (get-content '%HOSTINGFILE%' | select-string -pattern 'sv_servername').length">"%VARIABLESDIR%\temp.txt"

  echo .>nul
  set /p PSCOUNT=<"%VARIABLESDIR%\temp.txt"
  del "%VARIABLESDIR%\temp.txt"
  if "!PSCOUNT!" == "0" (
    echo sv_servername=%SERVERNAME%>>"%HOSTINGFILE%"
  ) else (
    powershell -Command "& { Get-Content '%HOSTINGFILE%' | Foreach-Object {$_ -replace 'sv_servername=.+', 'sv_servername=%SERVERNAME%'} | Set-Content '%HOSTINGFILE%.new';}"

    echo .>nul
    move /y "%HOSTINGFILE%.new" "%HOSTINGFILE%" >nul
  )
)

goto :eof


:setbaseport
echo [1m[33mLoading base server port setting...[0m
set SPACER=1

if exist "%VARIABLESDIR%\baseport.txt" (
  set /p GAMEPORTA=<"%VARIABLESDIR%\baseport.txt"
  set SPACER=0
) else (
  echo The Miscreated server runs at a base port of 64090, and uses up to the next
  echo four ports. Unless you are running multiple servers it is advised you leave
  echo the base port set to 64090.
  echo.
  echo If you are running multiple servers on the same network only then will you
  echo want to change this value from the default. Valid base ports are from 1024
  echo through 65531. Press enter to use the default port value.
  echo.
  set /p GAMEPORTA="Enter the base server port [64090]: " || set GAMEPORTA=64090
)

SET "var="&for /f "delims=0123456789" %%i in ("%GAMEPORTA%") do set var=%%i

if defined var (
  echo.
  echo Enter only numeric values.
  if exist "%VARIABLESDIR%\baseport.txt" (del "%VARIABLESDIR%\baseport.txt")
  goto setbaseport
)

if %GAMEPORTA% lss 1024 (
  echo.
  echo The entered value must be greater than 1024.
  if exist "%VARIABLESDIR%\baseport.txt" (del "%VARIABLESDIR%\baseport.txt")
  goto setbaseport
)

if %GAMEPORTA% gtr 65531 (
  echo.
  echo The entered value must be no more than 65531
  if exist "%VARIABLESDIR%\baseport.txt" (del "%VARIABLESDIR%\baseport.txt")
  goto setbaseport
)

echo ^%GAMEPORTA%>"%VARIABLESDIR%\baseport.txt"
set /A GAMEPORTB=%GAMEPORTA%+1
set /A GAMEPORTC=%GAMEPORTA%+2
set /A GAMEPORTD=%GAMEPORTA%+3
set /A RCONPORT=%GAMEPORTA%+4

if "%SPACER%" == "1" echo.

goto :eof


:setbuildrule
echo [1m[33mLoading building rule setting...[0m
set SPACER=1

if exist "%VARIABLESDIR%\buildrule.txt" (
  set /p BUILDRULE=<"%VARIABLESDIR%\buildrule.txt"
  set SPACER=0
) else (
  echo Base building rule:
  echo   0 = disable bases.
  echo   1 = normal ^(official^) building
  echo   2 = build-anywhere
  echo   WARNING: Build-anywhere is not an officially supported option. Use
  echo            of this option may result in unpredictable base building
  echo            issues.
  set /p BUILDRULE="Enter the desired build rule [0-2, default=1]: " || set BUILDRULE=1
)

SET "var="&for /f "delims=012" %%i in ("%BUILDRULE%") do set var=%%i

if defined var (
  echo.
  echo Enter a value from 0-2.
  if exist "%VARIABLESDIR%\buildrule.txt" del "%VARIABLESDIR%\buildrule.txt"
  goto setbuildrule
)

echo ^%BUILDRULE%>"%VARIABLESDIR%\buildrule.txt"

if "%SPACER%" == "1" echo.

goto :eof


:setfirewall
echo [1m[33mLoading firewall setting...[0m
set SPACER=1

if exist "%VARIABLESDIR%\enableupnp.txt" (
  set /p ENABLEUPNP=<"%VARIABLESDIR%\enableupnp.txt"
  set SPACER=0
) else (
  echo To allow your server to be found in the game server browser you need to open
  echo firewall ports. Would like for firewall ports to be automatically forwarded?
  echo Enter Y for yes, N for no.
  set /p ENABLEUPNP="Enable UPnP [Y/N, default Y]: " || set ENABLEUPNP=y
)

if /I "%ENABLEUPNP%"=="y" (
  echo ^%ENABLEUPNP%>"%VARIABLESDIR%\enableupnp.txt"
) else if /I "%ENABLEUPNP%"=="n" (
  echo ^%ENABLEUPNP%>"%VARIABLESDIR%\enableupnp.txt"
) else (
  echo.
  echo Please enter Y for yes, or N for no.
  echo.
  if exist "%VARIABLESDIR%\enableupnp.txt" del "%VARIABLESDIR%\enableupnp.txt"
  goto setfirewall
)

if "%SPACER%" == "1" echo.

goto :eof


:setgiveallguides
echo [1m[33mLoading grant guides setting...[0m
set SPACER=1

if exist "%VARIABLESDIR%\grantguides.txt" (
  set /p GRANTGUIDES=<"%VARIABLESDIR%\grantguides.txt"
  set SPACER=0
) else (
  echo Would you like to grant all crafting guides to players? Players may need
  echo to exit and rejoin to see all crafting options.
  echo Enter Y for yes, N for no.
  set /p GRANTGUIDES="Grant guides to new players [Y/N, default N]: " || set GRANTGUIDES=N
)

if /I "%GRANTGUIDES%"=="y" (
  echo ^%GRANTGUIDES%>"%VARIABLESDIR%\grantguides.txt"
) else if /I "%GRANTGUIDES%"=="n" (
  echo ^%GRANTGUIDES%>"%VARIABLESDIR%\grantguides.txt"
) else (
  echo.
  echo Please enter Y for yes, or N for no.
  echo.
  goto setgiveallguides
)

if "%SPACER%" == "1" echo.

goto :eof


:setmaxplayers
echo [1m[33mLoading max players setting...[0m
set SPACER=1

if exist "%VARIABLESDIR%\maxplayers.txt" (
  set /p MAXPLAYERS=<"%VARIABLESDIR%\maxplayers.txt"
  set SPACER=0
) else (
  set /p MAXPLAYERS="Enter the maximum number of players [1-50, default 36]: " || set MAXPLAYERS=36
)

SET "var="&for /f "delims=0123456789" %%i in ("%MAXPLAYERS%") do set var=%%i

if defined var (
  echo.
  echo Enter only numeric values.
  goto setmaxplayers
)

if %MAXPLAYERS% lss 1 (
  echo.
  echo The entered value must be greater than zero.
  if exist "%VARIABLESDIR%\maxplayers.txt" del "%VARIABLESDIR%\maxplayers.txt"
  goto setmaxplayers
)

if %MAXPLAYERS% gtr 50 (
  echo.
  echo The entered value must be no more than 50
  if exist "%VARIABLESDIR%\maxplayers.txt" del "%VARIABLESDIR%\maxplayers.txt"
  goto setmaxplayers
)

echo ^%MAXPLAYERS%>"%VARIABLESDIR%\maxplayers.txt"

if "%SPACER%" == "1" echo.

goto :eof


:setrconpassword
echo [1m[33mLoading password setting...[0m
set SPACER=1

if exist "%VARIABLESDIR%\rcon_password.txt" (
  set /p RCONPASS=<"%VARIABLESDIR%\rcon_password.txt"
  set SPACER=0
) else (
  echo Enter the password you would like to use with your server's RCON
  set /p RCONPASS="Password: " || set RCONPASS=DONTJUSTPRESSENTER
)

if "%RCONPASS%"=="DONTJUSTPRESSENTER" (
  echo.
  echo You must enter a password.
  if exist "%VARIABLESDIR%\rcon_password.txt" del "%VARIABLESDIR%\rcon_password.txt"
  goto setrconpassword
)

echo ^%RCONPASS%>"%VARIABLESDIR%\rcon_password.txt"

if "%SPACER%" == "1" echo.

goto :eof


:setservername
echo [1m[33mLoading server name setting...[0m
set SPACER=1

if exist "%VARIABLESDIR%\server_name.txt" (
  set /p SERVERNAME=<"%VARIABLESDIR%\server_name.txt"
  set SPACER=0
) else (
  echo Enter a server name. This is the name which will appear in the in game server list
  set /p SERVERNAME="Enter server name: " || set SERVERNAME=DONTJUSTPRESSENTER
)

if "%SERVERNAME%"=="DONTJUSTPRESSENTER" (
 echo.
 echo You must enter a server name.
 if exist "%VARIABLESDIR%\server_name.txt" del "%VARIABLESDIR%\server_name.txt"
 goto setservername
)

echo ^%SERVERNAME%>"%VARIABLESDIR%\server_name.txt"

if "%SPACER%" == "1" echo.

goto :eof


:setupnp
echo [1m[33mCreating firewall UPnP entries[0m
"%UNPNCHELPER%\upnpc-shared.exe" -r %GAMEPORTA% UDP %GAMEPORTB% UDP %GAMEPORTC% UDP %GAMEPORTD% UDP %RCONPORT% TCP >nul
echo.
goto :eof


:setwhitelisted
echo [1m[33mLoading whitelisting setting...[0m
set SPACER=1

if exist "%VARIABLESDIR%\whitelisted.txt" (
  set /p WHITELISTED=<"%VARIABLESDIR%\whitelisted.txt"
  set SPACER=0
) else (
  echo Would like for the server to be whitelisted? Enter Y for yes, N for no.
  set /p WHITELISTED="Whitelist the server [Y/N, default N]: " || set WHITELISTED=n
)

if /I "%WHITELISTED%"=="y" (
  echo ^%WHITELISTED%>"%VARIABLESDIR%\whitelisted.txt"
) else if /I "%WHITELISTED%"=="n" (
  echo ^%WHITELISTED%>"%VARIABLESDIR%\whitelisted.txt"
) else (
  echo.
  echo Please enter Y for yes, or N for no.
  echo.
  if exist "%VARIABLESDIR%\whitelisted.txt" del "%VARIABLESDIR%\whitelisted.txt"
  goto setwhitelisted
)

if "%SPACER%" == "1" echo.

goto :eof


:start
if /I "%GRANTGUIDES%"=="y" (
  if exist "%SERVERDIR%\miscreated.db" (
    call :grantallguides
  )
)

if /I "%ENABLEUPNP%"=="y" call :setupnp

echo Would you like to validate or update the server files? 'Y' recommended.
echo   ^( auto-validation will commence in 10 seconds ^)
CHOICE /d Y /T 10 /M "Validate and/or update the server?"
IF !ERRORLEVEL! EQU 1 call :validateserver

call :cleanmods
call :printconfig
call :startserver
echo.
echo [1m[33mThe Miscreated server exited.[0m
CHOICE /d Y /T 10 /M "Would you like to restart the server? (auto-restart in 10 seconds)"
IF !ERRORLEVEL! EQU 1 goto start

goto :eof


:startserver
echo [1m[33mStarting the Miscreated server[0m
echo |set /p="[1m[33m  command: [0m"
echo [1m[36m"%MISSERVERBIN%" %OPTIONS% -sv_port %GAMEPORTA% +sv_maxplayers %MAXPLAYERS% +map %MAP% +sv_servername "%SERVERNAME%" +http_startserver[0m
"%MISSERVERBIN%" %OPTIONS% -sv_port %GAMEPORTA% +sv_maxplayers %MAXPLAYERS% +map %MAP% +sv_servername "%SERVERNAME%" +http_startserver
if /I "%ENABLEUPNP%"=="y" (
  call :removeupnp
)
echo.
goto :eof


:validateserver
echo [1m[33mInstalling/Updating/Validating server files[0m
"%STEAMCMDBIN%" +login anonymous +force_install_dir "%SERVERDIR%" +app_update 302200 validate +quit
if not exist "%MISSERVERBIN%" (
  echo =^> ERROR:
  echo   Something went wrong: The server may not have been installed by steamcmd.
  pause
  exit /B
)
goto :eof


:main
REM - Make sure a script variables directory exists
set VARIABLESDIR=%BASEPATH%\scriptvars
if not exist "%VARIABLESDIR%" (
  echo Creating subdirectory: %VARIABLESDIR%
  md "%VARIABLESDIR%"
  echo.
)
call :setservername
call :setfirewall
call :setwhitelisted

set WLOPTION=
if /I "%WHITELISTED%"=="y" (
  set WLOPTION=-mis_whitelist
)

call :setmaxplayers
call :setbuildrule

set SERVERDIR=%BASEPATH%\MiscreatedServer
set MODSDIR=%SERVERDIR%\Mods
set MISSERVERBIN=%SERVERDIR%\Bin64_dedicated\MiscreatedServer.exe

if not exist "%SERVERDIR%" (
  echo Creating directory: "%SERVERDIR%"...
  md "%SERVERDIR%"
  echo.
)

call :setbaseport

call :setrconpassword

call :setgiveallguides

set STEAMCMDPATH=%BASEPATH%\SteamCMD
set STEAMCMDBIN=%STEAMCMDPATH%\steamcmd.exe

if not exist "%STEAMCMDPATH%" (
  echo Creating directory: "%STEAMCMDPATH%"...
  md "%STEAMCMDPATH%"
  echo.
)

if not exist "%STEAMCMDBIN%" call :getsteamcmd

set SQLITEPATH=%BASEPATH%\sqlite
set SQLITEBIN=%SQLITEPATH%\sqlite3.exe

if not exist "%SQLITEPATH%" (
  echo Creating directory: "%SQLITEPATH%"...
  md "%SQLITEPATH%"
  echo.
)

if not exist "%SQLITEBIN%" call :getsqlite3

set UNPNCHELPER=%BASEPATH%\upnpc
if not exist "%UNPNCHELPER%" (
  echo Creating directory: "%UNPNCHELPER%"...
  md "%UNPNCHELPER%"
  echo.
  call :getupnphelper
)

set OPTIONS=%WLOPTION%

if defined OPTIONS (
  echo Additional command line options: %OPTIONS%
)

call :createmanualremoveupnpscript

if /I "%GRANTGUIDES%"=="n" (
  if exist "%SERVERDIR%\miscreated.db" call :removegrantallguides
)

call :createlocaljoin

if not exist "%MISSERVERBIN%" call :validateserver

call :servernamecfg
call :passwordcfg
call :basescfg

call :start

echo.
echo I hope you found this script use useful.
echo   -Spafbi
echo.
timeout /t 10
