@echo OFF
REM - This grabs and parses the directory in which this CMD file exists.
set BASEPATH=%~dp0
set BASEPATH=%BASEPATH:~0,-1%
set MAP=islands
goto setup


:setservername
if exist "%VARIABLESDIR%\server_name.txt" (
  set /p SERVERNAME=<"%VARIABLESDIR%\server_name.txt"
) else (
  echo Enter a server name. This is the name which will appear in the in game server list
  set /p SERVERNAME="Enter server name: " || set SERVERNAME=DONTJUSTPRESSENTER
)
if "%SERVERNAME%"=="DONTJUSTPRESSENTER" goto setservername
echo %SERVERNAME%>"%VARIABLESDIR%\server_name.txt"
goto :eof


:giveallguides
if exist "%VARIABLESDIR%\grantguides.txt" (
  set /p GRANTGUIDES=<"%VARIABLESDIR%\grantguides.txt"
) else (
  echo Would you like to grant guides to all players joining the server since the last
  echo restart? Enter Y for yes, N for no.
  set /p GRANTGUIDES="Grant guides to new players [Y/N]: " || set GRANTGUIDES=DONTJUSTPRESSENTER
)
if /I "%GRANTGUIDES%"=="y" (
  echo %GRANTGUIDES%>"%VARIABLESDIR%\grantguides.txt"
) else if /I "%GRANTGUIDES%"=="n" (
  echo %GRANTGUIDES%>"%VARIABLESDIR%\grantguides.txt"
) else (
  echo Please enter Y for yes, or N for no.
  echo.
  goto giveallguides
)

goto :eof


:setfirewall
if exist "%VARIABLESDIR%\enableupnp.txt" (
  set /p ENABLEUPNP=<"%VARIABLESDIR%\enableupnp.txt"
) else (
  echo To allow your server to be found in the game server browser you need to open
  echo firewall ports. Would like for firewall ports to be automatically forwarded?
  echo Enter Y for yes, N for no.
  set /p ENABLEUPNP="Enable UPnP [Y/N]: " || set ENABLEUPNP=DONTJUSTPRESSENTER
)
if /I "%ENABLEUPNP%"=="y" (
  echo %ENABLEUPNP%>"%VARIABLESDIR%\enableupnp.txt"
) else if /I "%ENABLEUPNP%"=="n" (
  echo %ENABLEUPNP%>"%VARIABLESDIR%\enableupnp.txt"
) else (
  echo Please enter Y for yes, or N for no.
  echo.
  goto setfirewall
)
goto :eof


:setwhitelisted
if exist "%VARIABLESDIR%\whitelisted.txt" (
  set /p WHITELISTED=<"%VARIABLESDIR%\whitelisted.txt"
) else (
  echo Would like for the server to be whitelisted? Enter Y for yes, N for no.
  set /p WHITELISTED="Whitelist the server [Y/N]: " || set WHITELISTED=DONTJUSTPRESSENTER
)
if /I "%WHITELISTED%"=="y" (
  echo %WHITELISTED%>"%VARIABLESDIR%\whitelisted.txt"
) else if /I "%WHITELISTED%"=="n" (
  echo %WHITELISTED%>"%VARIABLESDIR%\whitelisted.txt"
) else (
  echo Please enter Y for yes, or N for no.
  echo.
  goto setwhitelisted
)
goto :eof


:setmaxplayers
if exist "%VARIABLESDIR%\maxplayers.txt" (
  set /p MAXPLAYERS=<"%VARIABLESDIR%\maxplayers.txt"
) else (
  set /p MAXPLAYERS="Enter the maximum number of players [1-50]: " || set MAXPLAYERS=DONTJUSTPRESSENTER
)
if "%MAXPLAYERS%"=="DONTJUSTPRESSENTER" goto setservername
SET "var="&for /f "delims=0123456789" %%i in ("%MAXPLAYERS%") do set var=%%i
if defined var (
  echo Enter only numeric values.
  goto setmaxplayers
)
if %MAXPLAYERS% gtr 50 (
  echo The entered value must be no more than 50
  if exist "%VARIABLESDIR%\maxplayers.txt" (del "%VARIABLESDIR%\maxplayers.txt")
  goto setmaxplayers
)
echo %MAXPLAYERS%>"%VARIABLESDIR%\maxplayers.txt"
goto :eof


:setbaseport
if exist "%VARIABLESDIR%\baseport.txt" (
  set /p GAMEPORTA=<"%VARIABLESDIR%\baseport.txt"
) else (
  echo.
  echo The Miscreated server runs at a base port of 64090, and uses up to the next
  echo four ports. Unless you are running multiple servers, it is advised you leave
  echo the base port set to 64090.
  echo.
  echo If you are running multiple servers on the same network, only then will you
  echo want to change this value from the default. Valid base ports are from 1024
  echo through 65531. Press enter to use the default port value.
  echo.
  set /p GAMEPORTA="Enter your desired base port [64090]: " || set GAMEPORTA=USEDEFAULTVALUE
)
if "%GAMEPORTA%"=="USEDEFAULTVALUE" set GAMEPORTA=64090
SET "var="&for /f "delims=0123456789" %%i in ("%GAMEPORTA%") do set var=%%i
if defined var (
  echo Enter only numeric values.
  goto setbaseport
)
if %GAMEPORTA% lss 1024 (
  echo The entered value must be 1024 or higher
  if exist "%VARIABLESDIR%\baseport.txt" (del "%VARIABLESDIR%\baseport.txt")
  goto setbaseport
)
if %GAMEPORTA% gtr 65531 (
  echo The entered value must be no more than 65531
  if exist "%VARIABLESDIR%\baseport.txt" (del "%VARIABLESDIR%\baseport.txt")
  goto setbaseport
)
echo %GAMEPORTA%>"%VARIABLESDIR%\baseport.txt"
set /A GAMEPORTB=%GAMEPORTA%+1
set /A GAMEPORTC=%GAMEPORTA%+2
set /A GAMEPORTD=%GAMEPORTA%+3
set /A RCONPORT=%GAMEPORTA%+4
goto :eof


:setrconpassword
if exist "%VARIABLESDIR%\rcon_password.txt" (
  set /p RCONPASS=<"%VARIABLESDIR%\rcon_password.txt"
) else (
  echo Enter the password you would like to use with your server's RCON
  set /p RCONPASS="Password: " || set RCONPASS=DONTJUSTPRESSENTER
)
if "%RCONPASS%"=="DONTJUSTPRESSENTER" goto setrconpassword
echo %RCONPASS%>"%VARIABLESDIR%\rcon_password.txt"
if not exist "%SERVERDIR%\hosting.cfg" (
  echo http_password=%RCONPASS%>>"%SERVERDIR%\hosting.cfg"
) else (
  copy /v /y "%SERVERDIR%\hosting.cfg" "%SERVERDIR%\hosting.cfg.bak" >nul
  type "%SERVERDIR%\hosting.cfg" | findstr /v "http_password=">>"%SERVERDIR%\hosting.cfg.new"
  echo http_password=%RCONPASS%>>"%SERVERDIR%\hosting.cfg.new"
  move /y "%SERVERDIR%\hosting.cfg.new" "%SERVERDIR%\hosting.cfg" >nul
)
echo.
goto :eof


:start
call :printconfig
if /I "%GRANTGUIDES%"=="y" (
  if exist "%SERVERDIR%\miscreated.db" (
    call :grantallguides
  )
)
if /I "%ENABLEUPNP%"=="y" (
  call :setupnp
)
call :createlocaljoin
call :validateserver
call :startserver
echo.
echo [1m[33m[4mThe Miscreated server gracefully exited. Restarting...[0m
goto start


:createlocaljoin
if not exist join_local_server.cmd (
echo [1m[33m[4mCreating join_local_server.cmd script[0m
  echo ^@echo off > join_local_server.cmd
  echo explorer steam://run/299740/connect/+connect 127.0.0.1 %GAMEPORTA% >> join_local_server.cmd
)
echo.
goto :eof


:startserver
echo [1m[33m[4mStarting the Miscreated server[0m
"%MISSERVERBIN%" %OPTIONS% -sv_port %GAMEPORTA% +sv_maxplayers %MAXPLAYERS% +map %MAP% +sv_servername "%SERVERNAME%" +http_startserver
if /I "%ENABLEUPNP%"=="y" (
  call :removeupnp
)
echo.
goto :eof


:validateserver
echo [1m[33m[4mInstalling/Updating/Validating server files[0m
"%STEAMCMDBIN%" +login anonymous +force_install_dir %SERVERDIR% +app_update 302200 validate +quit
set MISSERVERBIN=%SERVERDIR%\Bin64_dedicated\MiscreatedServer.exe
if not exist "%MISSERVERBIN%" (
  echo =^> ERROR:
  echo   Something went wrong: The server may not have been installed by steamcmd.
  pause
  exit /B
)
echo.
goto :eof


:printconfig
echo.
echo.
echo                 The servername will be: [1m[33m[4m%SERVERNAME%[0m
echo  The maximum number of players will be: [1m[33m[4m%MAXPLAYERS%[0m
echo      The base game server port will be: [1m[33m[4m%GAMEPORTA%[0m
echo.
echo              [1m[31mNOTICE![0m Your RCON port is: [1m[33m[4m%RCONPORT%[0m
echo.

if /I "%GRANTGUIDES%"=="y" (
  echo Guides [1m[33m[4mwill[0m be granted to all players.
) else if /I "%GRANTGUIDES%"=="n" (
  echo Guides [1m[33m[4mwill not[0m be granted to all players.
)

if /I "%ENABLEUPNP%"=="y" (
  echo Firewall ports [1m[33m[4mwill[0m be forwarded.
) else if /I "%ENABLEUPNP%"=="n" (
  echo Firewall ports [1m[33m[4mwill not[0m be automatically forwarded...
)

if /I "%WHITELISTED%"=="y" (
  echo The server [1m[33m[4mwill[0m be whitelisted.
  echo You will need to add your Steam64ID to the whitelist before joining the server.
) else if /I "%WHITELISTED%"=="n" (
  echo The server [1m[33m[4mwill not[0m be whitelisted...
)
echo.
echo.
goto :eof


:getsteamcmd
echo [1m[33m[4mDownloading steamcmd binaries[0m
set STEAMARCHIVE="%BASEPATH%\steamcmd.zip"
curl -L https://steamcdn-a.akamaihd.net/client/installer/steamcmd.zip -o "%STEAMARCHIVE%"
@powershell Expand-Archive -LiteralPath "%STEAMARCHIVE%" -DestinationPath "%STEAMCMDPATH%"
del /q *.zip
echo.
goto :eof


:getsqlite3
echo [1m[33m[4mDownloading SQLite3 binaries[0m
set SQLITELIBZIP="%BASEPATH%\sqlite-dll-win32-x86-3280000.zip"
set SQLITEBINZIP="%BASEPATH%\sqlite-tools-win32-x86-3280000.zip"
curl -L https://sqlite.org/2019/sqlite-dll-win32-x86-3280000.zip -o "%SQLITELIBZIP%"
curl -L https://sqlite.org/2019/sqlite-tools-win32-x86-3280000.zip -o "%SQLITEBINZIP%"
@powershell Expand-Archive -LiteralPath "%SQLITELIBZIP%" -DestinationPath "%SQLITEPATH%"
@powershell Expand-Archive -LiteralPath "%SQLITEBINZIP%" -DestinationPath "%SQLITEPATH%"
move "%SQLITEPATH%\sqlite-tools-win32-x86-3280000\*.*" "%SQLITEPATH%\"
rmdir "%SQLITEPATH%\sqlite-tools-win32-x86-3280000"
del /q *.zip
echo.
goto :eof


:grantallguides
echo [1m[33m[4mGranting guides to all existing players[0m
echo UPDATE ServerAccountData SET Guide00=16777215, Guide01=16777215, Guide02=16777215, Guide03=16777215;|"%SQLITEBIN%" "%SERVERDIR%\miscreated.db"
echo.
goto :eof


:setupnp
echo [1m[33m[4mCreating firewall UPnP entries[0m
"%UNPNCHELPER%\upnpc-shared.exe" -r %GAMEPORTA% UDP %GAMEPORTB% UDP %GAMEPORTC% UDP %GAMEPORTD% UDP %RCONPORT% TCP >nul
echo.
goto :eof


:removeupnp
echo [1m[33m[4mRemoving firewall UPnP entries[0m
"%UNPNCHELPER%\upnpc-shared.exe" -N %RCONPORT% %RCONPORT% TCP >nul
"%UNPNCHELPER%\upnpc-shared.exe" -N %GAMEPORTA% %GAMEPORTD% UDP >nul
echo.
goto :eof


:createmanualremoveupnpscript
echo [1m[33m[4mCreating firewall UPnP settings manual removal script[0m
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
echo.
goto :eof


:getupnphelper
echo [1m[33m[4mGrabbing the UPnP helper[0m
set UPNPCARCHIVE="%BASEPATH%\upnpc-exe-win32-20150918.zip"
curl -L http://miniupnp.tuxfamily.org/files/download.php?file=upnpc-exe-win32-20150918.zip -o "%UPNPCARCHIVE%"
@powershell Expand-Archive -LiteralPath "%UPNPCARCHIVE%" -DestinationPath "%UNPNCHELPER%"
echo.
goto :eof


:setup
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
if /I %WHITELISTED%=="y" (
  set WHITELISTED=-mis_whitelist
) else (
  set WHITELISTED=
)

call :setmaxplayers

set SERVERDIR=%BASEPATH%\MiscreatedServer

if not exist "%SERVERDIR%" (
  echo Creating directory: "%SERVERDIR%"...
  md "%SERVERDIR%"
)

call :setbaseport

call :setrconpassword

set STEAMCMDPATH=%BASEPATH%\SteamCMD
set STEAMCMDBIN=%STEAMCMDPATH%\steamcmd.exe

if not exist "%STEAMCMDPATH%" (
  echo Creating directory: "%STEAMCMDPATH%"...
  md "%STEAMCMDPATH%"
)

if not exist "%STEAMCMDBIN%" (
  call :getsteamcmd
)

set SQLITEPATH=%BASEPATH%\sqlite
set SQLITEBIN=%SQLITEPATH%\sqlite3.exe

if not exist "%SQLITEPATH%" (
  echo Creating directory: "%SQLITEPATH%"...
  md "%SQLITEPATH%"
)

if not exist "%SQLITEBIN%" (
  call :getsqlite3
)

set OPTIONS=%WHITELISTED%
if defined OPTIONS (
  echo Additional command line options: %OPTIONS%
)

set UNPNCHELPER=%BASEPATH%\upnpc
if not exist "%UNPNCHELPER%" (
  echo Creating directory: "%UNPNCHELPER%"...
  md "%UNPNCHELPER%"
  call :getupnphelper
)

call :giveallguides

call :createmanualremoveupnpscript

call :start
