@echo off

set F2C_VER=1.0

vecho /fLightCyan "      ___      "
vecho /fLightCyan "   __/   \__   " /fGrey FreeDOS Cloud Initialization
vecho /fLightCyan "  /  \   /  \  " /fGrey version %F2C_VER%
vecho /fLightCyan "  \_________/  " /fGrey
echo.


rem ####################################
rem # Create Temporary Directory
rem #

set CLOUDTMP=%TMP%\CLOUD
if exist %CLOUDTMP%\nul deltree /Y %CLOUDTMP% >nul
md %CLOUDTMP%


rem ####################################
rem # Run Configuration Scripts
rem #

pushd \cloud
    call "netcfg.bat"

    call "type\one.bat"
    if "%_INITIALIZED%" == "yes" goto :TYPE_END
    rem ... call other cloud types here ...

    echo ERROR: No cloud configuration found!

    :TYPE_END
popd


rem ####################################
rem # Cleanup Temporary Directory
rem #

:CLEANUP
if exist %CLOUDTMP%\nul deltree /Y %CLOUDTMP% >nul
set F2C_VER=
set CLOUDTMP=
set _INITIALIZED=

echo.


rem ####################################
rem # Run Services
rem #

if "%_START_FTPSRV%" == "" goto START_FTP_END
set _START_FTPSRV=
echo Starting mTCP FTPSrv ...
\net\mtcp\ftpsrv.exe
:START_FTP_END

if "%_START_HTTPSERV%" == "" goto START_HTTP_END
echo Starting mTCP HTTPServ ...
\net\mtcp\httpserv.exe %_START_HTTPSERV%
set _START_HTTPSERV=
:START_HTTP_END

rem if "%_START_PASSWORD%" == "" goto START_USER_END
rem set _START_PASSWORD=
rem echo Starting login screen ...
rem password /login
rem :START_USER_END
