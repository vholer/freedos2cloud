@echo off

set F2C_VER=1.0

vecho /fLightCyan "      ___      "
vecho /fLightCyan "   __/   \__   " /fGrey FreeDOS Cloud Initialization
vecho /fLightCyan "  /  \   /  \  " /fGrey version %F2C_VER%
vecho /fLightCyan "  \_________/  " /fGrey
echo.

rem ####################################
rem # Create Temporary Directory

set CLOUDTMP=%TMP%\CLOUD
if exist %CLOUDTMP%\nul deltree /Y %CLOUDTMP% >nul
md %CLOUDTMP%

rem ####################################
rem # Run Configuration Scripts

pushd \cloud
    call "netcfg.bat"

    call "type\one.bat"
    if "%_READY%" == "yes" goto :TYPE_END

    echo ERROR: No cloud configuration found!

    :TYPE_END
    set _READY=
popd

rem ####################################
rem # Cleanup Temp and Variables

:CLEANUP
if exist %CLOUDTMP%\nul deltree /Y %CLOUDTMP% >nul
set F2C_VER=
set CLOUDTMP=

echo.

rem ####################################
rem # Run Services

rem *** FTP Server ***

if "%_RUN_FTPSRV%" == "" goto RUN_FTP_END
set _RUN_FTPSRV=
echo Starting mTCP FTPSrv ...
if not exist \net\mtcp\ftpsrv.exe goto RUN_FTP_SKIP
\net\mtcp\ftpsrv.exe
goto RUN_FTP_END

:RUN_FTP_SKIP
echo ERROR: Unable to run FTPSRV, not found!
:RUN_FTP_END

rem *** HTTP Server ***

if "%_START_HTTPSERV%" == "" goto RUN_HTTP_END
echo Starting mTCP HTTPServ ...
if not exist \net\mtcp\httpserv.exe goto RUN_HTTP_SKIP
\net\mtcp\httpserv.exe %_START_HTTPSERV%
set _START_HTTPSERV=
goto RUN_HTTP_END

:RUN_HTTP_SKIP
echo ERROR: Unable to run HTTPSERV, not found!
:RUN_HTTP_END

rem *** RMENU ***

if not "%_RUN_RMENU%" == "yes" goto RUN_RMENU_END
set _RUN_RMENU=
echo Starting RMENU ...
if not exist \net\rmenu\rmenu.exe goto RUN_RMENU_SKIP
pushd \net\rmenu
    rmenu /c1
    echo.
popd
goto RUN_RMENU_END

:RUN_RMENU_SKIP
echo ERROR: Unable to run RMENU, not found!
:RUN_RMENU_END

:END
