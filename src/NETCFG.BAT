@echo off

rem Necessary network environment and drivers configuration formerly
rem done by (and taken from) FDNET package (script FDNET.BAT) before it
rem was removed from most recent FreeDOS.
rem
rem FreeDOS 1.2+ Basic Networking Support Package.
rem Based on Rugxulo's MetaDOS CONNECT.BAT
rem Released Under GPL v2.0 License.
rem Copyright 2016 Jerome Shidel.

rem ####################################
rem # Configuration Location

echo Configuring network environment
if "%WATTCP.CFG%" == "" SET WATTCP.CFG=%dosdir%
if "%MTCPCFG%" == "" SET MTCPCFG=%dosdir%\MTCP.CFG
if "%PICOTCP%" == "" SET PICOTCP=%dosdir%\PICOTCP.DAT

rem ####################################
rem # Detect Hardware

rem QEMU NIC model: rtl8139
pcisleep L | find 10ec:8139 >nul
if not errorlevel 1 goto REALTEK

rem QEMU NIC model: pcnet
pcisleep L | find 1022:2000 >nul
if not errorlevel 1 goto PCNET

rem TODO: ne2000_isa? (QEMU complains to me)
goto NONE

rem ####################################
rem # Load Drivers

:PCNET
echo Loading AMD PCnet FAST III Ethernet driver
%dosdir%\drivers\crynwr\pcntpk.com int=0x60 <nul >%CLOUDTMP%\CMD.OUT
if errorlevel 1 type %CLOUDTMP%\CMD.OUT
goto END

:REALTEK
echo Loading Realtek Fast Ethernet driver
%dosdir%\drivers\crynwr\rtspkt.com 0x60 <nul >%CLOUDTMP%\CMD.OUT
if errorlevel 1 type %CLOUDTMP%\CMD.OUT
goto END

:NE2000
echo Loading NE2000 driver
%dosdir%\drivers\crynwr\ne2000.com -u <nul >%CLOUDTMP%\CMD.OUT
if errorlevel 1 type %CLOUDTMP%\CMD.OUT
%dosdir%\drivers\crynwr\ne2000.com 0x60 <nul >%CLOUDTMP%\CMD.OUT
if errorlevel 1 type %CLOUDTMP%\CMD.OUT
goto END

:NONE
vecho /fRed ERROR: No supported network card found! /fGrey

:END
