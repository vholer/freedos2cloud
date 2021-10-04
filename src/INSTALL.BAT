@echo off

set TARGET=C:\CLOUD

echo === FreeDOS Cloud Installation ===

echo - Install Scripts
xcopy /e /i . %TARGET%
if exist %TARGET%\install.bat del %TARGET%\install.bat

REM echo - Install Packages
REM TODO: additional software - password, ...
REM ...

echo - Configure System
if "%AUTOFILE%" == "" set AUTOFILE=C:\FDAUTO.BAT
echo. >> %AUTOFILE%
echo call %TARGET%\CLOUD.BAT>>%AUTOFILE%

if "%1" == "/shutdown" shutdown
