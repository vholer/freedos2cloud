@echo off

rem *** FreeDOS Configuration for OpenNebula ***
rem
rem Respected contextualization parameters
rem - static IP configuration
rem   - ETH0_IP
rem   - ETH0_MASK
rem   - ETH0_GATEWAY
rem   - ETH0_DNS
rem   - ETH0_SEARCH_DOMAIN
rem   - ETH0_MTU
rem - ETH0_METHOD="dhcp" for DHCP configuration
rem - SET_HOSTNAME
rem - OneGate reporting:
rem   - VMID
rem   - ONEGATE_RENDPOINT
rem   - REPORT_READY
rem - START_SCRIPT_BASE64 with BAT script
rem
rem Parameters for mTCP FTPSrv
rem - SVC_FTP_ENABLE="yes"
rem - SVC_FTP_USERNAME="<FTP login>"
rem - SVC_FTP_PASSWORD="<FTP password>"
rem - SVC_FTP_SANDBOX_DIR="/drive_c/"
rem - SVC_FTP_UPLOAD_DIR defaults to "[any]"
rem - SVC_FTP_PERMISSIONS defaults to "all"
rem
rem Parameters for mTCP HTTPServ
rem - SVC_HTTP_ENABLE="yes"
rem - SVC_HTTP_CLIENTS="<number>"
rem - SVC_HTTP_DIR_INDEXES="yes"
rem - SVC_HTTP_DOC_ROOT="C:\"
rem - SVC_HTTP_PORT="80"
rem
rem Parameters for RMENU
rem - SVC_RMENU_ENABLE="yes"

rem ####################################
rem # Shared Functions

if "%1" == ":MASK2CIDR" goto MASK2CIDR
if "%1" == ":GETCVAR"   goto GETCVAR
goto MAIN

rem Converts A.B.C.D netmask into CIDR network prefix bits.
rem Table taken from https://en.wikipedia.org/wiki/Classless_Inter-Domain_Routing
:MASK2CIDR
set _RTN=
if "%2" == "255.255.255.255" set _RTN=32
if "%2" == "255.255.255.254" set _RTN=31
if "%2" == "255.255.255.252" set _RTN=30
if "%2" == "255.255.255.248" set _RTN=29
if "%2" == "255.255.255.240" set _RTN=28
if "%2" == "255.255.255.224" set _RTN=27
if "%2" == "255.255.255.192" set _RTN=26
if "%2" == "255.255.255.128" set _RTN=25
if "%2" == "255.255.255.0"   set _RTN=24
if "%2" == "255.255.254.0"   set _RTN=23
if "%2" == "255.255.252.0"   set _RTN=22
if "%2" == "255.255.248.0"   set _RTN=21
if "%2" == "255.255.240.0"   set _RTN=20
if "%2" == "255.255.224.0"   set _RTN=19
if "%2" == "255.255.192.0"   set _RTN=18
if "%2" == "255.255.128.0"   set _RTN=17
if "%2" == "255.255.0.0"     set _RTN=16
if "%2" == "255.254.0.0"     set _RTN=15
if "%2" == "255.252.0.0"     set _RTN=14
if "%2" == "255.248.0.0"     set _RTN=13
if "%2" == "255.240.0.0"     set _RTN=12
if "%2" == "255.224.0.0"     set _RTN=11
if "%2" == "255.192.0.0"     set _RTN=10
if "%2" == "255.128.0.0"     set _RTN=9
if "%2" == "255.0.0.0"       set _RTN=8
if "%2" == "254.0.0.0"       set _RTN=7
if "%2" == "252.0.0.0"       set _RTN=6
if "%2" == "248.0.0.0"       set _RTN=5
if "%2" == "240.0.0.0"       set _RTN=4
if "%2" == "224.0.0.0"       set _RTN=3
if "%2" == "192.0.0.0"       set _RTN=2
if "%2" == "128.0.0.0"       set _RTN=1
if "%2" == "0.0.0.0"         set _RTN=0
goto END

rem Parses context.sh and stores value into env. variable prefixed by ONE_,
rem or into a file set in the last optional argument.
:GETCVAR
if "%4" == "" sed -e "/^%3='.*'$/!d" -e "s/^%3='\(.*\)'$/\1/" %2 | pipeset ONE_%3
if "%4" == "" goto :END
sed -e "/^%3='.*'$/!d" -e "s/^%3='\(.*\)'$/\1/" %2 >%4
goto END

rem ####################################
rem # Main

:MAIN
finddisk CONTEXT >%CLOUDTMP%\CMD.OUT
if "%errorlevel%" == "0" goto CTX_SET
set /e CTX_DISK=find : <%CLOUDTMP%\CMD.OUT

:CTX_SET
if "%CTX_DISK%" == "" set CTX_DISK=D:
set CTX_FILE=%CTX_DISK%\CONTEXT.SH
if not exist %CTX_FILE% goto CLEANUP
echo Detected OpenNebula

echo - Reading contextualization
call "%0" :GETCVAR %CTX_FILE% VMID
call "%0" :GETCVAR %CTX_FILE% ETH0_IP
call "%0" :GETCVAR %CTX_FILE% ETH0_MASK
call "%0" :GETCVAR %CTX_FILE% ETH0_GATEWAY
call "%0" :GETCVAR %CTX_FILE% ETH0_DNS
call "%0" :GETCVAR %CTX_FILE% ETH0_SEARCH_DOMAIN
call "%0" :GETCVAR %CTX_FILE% ETH0_MTU
call "%0" :GETCVAR %CTX_FILE% ETH0_METHOD
call "%0" :GETCVAR %CTX_FILE% SET_HOSTNAME
call "%0" :GETCVAR %CTX_FILE% USERNAME
call "%0" :GETCVAR %CTX_FILE% ONEGATE_ENDPOINT
call "%0" :GETCVAR %CTX_FILE% REPORT_READY
call "%0" :GETCVAR %CTX_FILE% START_SCRIPT_BASE64 %CLOUDTMP%\ONE_SS.B64
call "%0" :GETCVAR %CTX_FILE% SVC_FTP_ENABLE
call "%0" :GETCVAR %CTX_FILE% SVC_FTP_USERNAME
call "%0" :GETCVAR %CTX_FILE% SVC_FTP_PASSWORD
call "%0" :GETCVAR %CTX_FILE% SVC_FTP_SANDBOX_DIR
call "%0" :GETCVAR %CTX_FILE% SVC_FTP_UPLOAD_DIR
call "%0" :GETCVAR %CTX_FILE% SVC_FTP_PERMISSIONS
call "%0" :GETCVAR %CTX_FILE% SVC_HTTP_ENABLE
call "%0" :GETCVAR %CTX_FILE% SVC_HTTP_CLIENTS
call "%0" :GETCVAR %CTX_FILE% SVC_HTTP_DIR_INDEXES
call "%0" :GETCVAR %CTX_FILE% SVC_HTTP_DOC_ROOT
call "%0" :GETCVAR %CTX_FILE% SVC_HTTP_PORT
call "%0" :GETCVAR %CTX_FILE% SVC_RMENU_ENABLE

call "%0" :MASK2CIDR %ONE_ETH0_MASK%
set ONE_ETH0_CIDR=%_RTN%

rem ####################################
rem # Networking

if "%ONE_ETH0_METHOD%" == "dhcp" goto NETWORK
if not "%ONE_ETH0_IP%" == "" goto NETWORK
echo ERROR: No network configuration found (static IP or DHCP method)
goto NETWORK_END

:NETWORK
if "%ONE_ETH0_METHOD%" == "dhcp" echo - Configuring networking for DHCP
if not "%ONE_ETH0_METHOD%" == "dhcp" echo - Configuring networking with static IP (%ONE_ETH0_IP%)
rem TODO: multiple nameservers

rem *** Networking - WatTCP ***

if "%WATTCP.CFG%" == "" goto WATTCP_SKIP

echo   - stack WatTCP
type nul >%WATTCP.CFG%\WATTCP.CFG
if not "%ONE_SET_HOSTNAME%" == ""       echo hostname=%ONE_SET_HOSTNAME%>>%WATTCP.CFG%\WATTCP.CFG
if not "%ONE_ETH0_MTU%" == ""           echo mtu=%ONE_ETH0_MTU%>>%WATTCP.CFG%\WATTCP.CFG
if "%ONE_ETH0_METHOD%" == "dhcp" goto WATTCP_DHCP

echo my_ip=%ONE_ETH0_IP%>>%WATTCP.CFG%\WATTCP.CFG
echo netmask=%ONE_ETH0_MASK%>>%WATTCP.CFG%\WATTCP.CFG
if not "%ONE_ETH0_GATEWAY%" == ""       echo gateway=%ONE_ETH0_GATEWAY%>>%WATTCP.CFG%\WATTCP.CFG
if not "%ONE_ETH0_DNS%" == ""           echo nameserver=%ONE_ETH0_DNS%>>%WATTCP.CFG%\WATTCP.CFG
if not "%ONE_ETH0_SEARCH_DOMAIN%" == "" echo domain_list=%ONE_ETH0_SEARCH_DOMAIN%>>%WATTCP.CFG%\WATTCP.CFG
goto WATTCP_END

:WATTCP_DHCP
echo my_ip=dhcp>>%WATTCP.CFG%\WATTCP.CFG
goto WATTCP_END

:WATTCP_SKIP
echo   - skipped missing stack WatTCP
goto WATTCP_END

:WATTCP_END

rem *** Networking - mTCTP ***

if not exist \net\mtcp\nul goto MTCP_SKIP
if "%MTCPCFG%" == "" goto MTCP_SKIP

echo   - stack mTCP
echo PACKETINT 0x60>%MTCPCFG%
if not "%ONE_SET_HOSTNAME%" == ""       echo HOSTNAME %ONE_SET_HOSTNAME%>>%MTCPCFG%
if not "%ONE_ETH0_MTU%" == ""           echo MTU %ONE_ETH0_MTU%>>%MTCPCFG%
if "%ONE_ETH0_METHOD%" == "dhcp" goto MTCP_DHCP

echo IPADDR %ONE_ETH0_IP%>>%MTCPCFG%
echo NETMASK %ONE_ETH0_MASK%>>%MTCPCFG%
if not "%ONE_ETH0_GATEWAY%" == ""       echo GATEWAY %ONE_ETH0_GATEWAY%>>%MTCPCFG%
if not "%ONE_ETH0_DNS%" == ""           echo NAMESERVER %ONE_ETH0_DNS%>>%MTCPCFG%
if not "%ONE_ETH0_SEARCH_DOMAIN%" == "" echo DOMAIN %ONE_ETH0_SEARCH_DOMAIN%>>%MTCPCFG%
goto MTCP_END

:MTCP_DHCP
pushd \net\mtcp
    dhcp >%CLOUDTMP%\CMD.OUT
    if errorlevel 1 type %CLOUDTMP%\CMD.OUT
popd
goto MTCP_END

:MTCP_SKIP
echo   - skipped missing stack mTCP
goto MTCP_END

:MTCP_END

rem *** Networking - PicoTCP ***

if not exist \net\picotcp\ipcfg.exe goto PICOTCP_SKIP
if "%PICOTCP%" == "" goto PICOTCP_SKIP

echo   - stack PicoTCP
if exist %PICOTCP% del %PICOTCP%

pushd \net\picotcp
    ipcfg int 0x60

    if "%ONE_ETH0_METHOD%" == "dhcp" goto PICOTCP_DHCP

    rem TODO: IPv6
    ipcfg ip add %ONE_ETH0_IP%/%ONE_ETH0_CIDR%
    if not "%ONE_ETH0_GATEWAY%" == ""       ipcfg route add 0.0.0.0/0 %ONE_ETH0_GATEWAY%
    if not "%ONE_ETH0_DNS%" == ""           ipcfg dns add %ONE_ETH0_DNS%
    goto PICOTCP_POPD

    :PICOTCP_DHCP
    ipcfg dhcp >%CLOUDTMP%\CMD.OUT
    find ERROR %CLOUDTMP%\CMD.OUT >nul
    if not errorlevel 1 type %CLOUDTMP%\CMD.OUT
	goto PICOTCP_POPD

:PICOTCP_POPD
popd
goto PICOTCP_END

:PICOTCP_SKIP
echo   - skipped missing stack PicoTCP
goto PICOTCP_END

:PICOTCP_END
:NETWORK_END

rem ####################################
rem # FTP Server

if "%ONE_SVC_FTP_USERNAME%" == ""  goto FTP_END
if "%ONE_SVC_FTP_PASSWORD%" == ""  goto FTP_END
if "%ONE_SVC_FTP_SANDBOX_DIR%" == "" goto FTP_END
if "%MTCPCFG%" == "" goto FTPEND

echo - Configuring FTPSRV
if "%ONE_SVC_FTP_UPLOAD_DIR%" == "" set ONE_SVC_FTP_UPLOAD_DIR=[any]
if "%ONE_SVC_FTP_PERMISSIONS%" == "" set ONE_SVC_FTP_PERMISSIONS=all
echo FTPSRV_PASSWORD_FILE C:\FTPPASS.TXT>>%MTCPCFG%
echo FTPSRV_EXCLUDE_DRIVES AB>>%MTCPCFG%
echo %ONE_SVC_FTP_USERNAME% %ONE_SVC_FTP_PASSWORD% %ONE_SVC_FTP_SANDBOX_DIR% %ONE_SVC_FTP_UPLOAD_DIR% %ONE_SVC_FTP_PERMISSIONS%>C:\FTPPASS.TXT
if "%ONE_SVC_FTP_ENABLE%" == "yes" set _RUN_FTPSRV=yes
:FTP_END

rem ####################################
rem # HTTP Server

if not "%ONE_SVC_HTTP_ENABLE%" == "yes" goto HTTP_END
if "%ONE_SVC_HTTP_DOC_ROOT%" == "" goto HTTP_END

echo - Configuring HTTPSERV
set _RUN_HTTPSERV=-doc_root %ONE_SVC_HTTP_DOC_ROOT%
if not "%ONE_SVC_HTTP_CLIENTS%" == "" set _RUN_HTTPSERV=%_RUN_HTTPSERV% -clients %ONE_SVC_HTTP_CLIENTS%
if not "%ONE_SVC_HTTP_PORT%" == "" set _RUN_HTTPSERV=%_RUN_HTTPSERV% -port %ONE_SVC_HTTP_PORT%
if "%ONE_SVC_HTTP_DIR_INDEXES%" == "yes" set _RUN_HTTPSERV=%_RUN_HTTPSERV% -dir_indexes
:HTTP_END

rem ####################################
rem # RMENU

if not "%ONE_SVC_RMENU_ENABLE%" == "yes" goto RMENU_END
echo - Configuring RMENU
set _RUN_RMENU=yes
:RMENU_END

rem ####################################
rem # Start Script

if not exist %CLOUDTMP%\ONE_SS.B64 goto SCRIPT_END
type nul >%CLOUDTMP%\EMPTY
fc %CLOUDTMP%\ONE_SS.B64 %CLOUDTMP%\EMPTY >nul
if "%errorlevel%" == "0" goto SCRIPT_END

echo - Executing start script
b64 -d %CLOUDTMP%\ONE_SS.B64 >%CLOUDTMP%\ONE_SS.BAT
call "%CLOUDTMP%\ONE_SS.BAT"
@echo off
if "%errorlevel%" == "0" goto SCRIPT_END
echo    ... FAILED!
:SCRIPT_END

rem ####################################
rem # Report Ready over OneGate

if not "%ONE_REPORT_READY%" == "YES" goto READY_END
if "%ONE_ONEGATE_ENDPOINT%" == "" goto READY_END
if not exist %CTX_DISK%\token.txt goto READY_END
echo - Reporting ready state via OneGate

rem NOTE: Curl command line length can exceed the allowed size,
rem so we better put most arguments into configuration file.
set /e _TOKEN=type %CTX_DISK%\token.txt
echo --insecure>%CLOUDTMP%/curl.cfg
echo --max-time 10>>%CLOUDTMP%/curl.cfg
echo --header "X-ONEGATE-TOKEN: %_TOKEN%">>%CLOUDTMP%/curl.cfg
echo --header "X-ONEGATE-VMID: %ONE_VMID%">>%CLOUDTMP%/curl.cfg
curl -K %CLOUDTMP%\curl.cfg -X "PUT" "%ONE_ONEGATE_ENDPOINT%/vm" -d "READY=YES"
set _TOKEN=
:READY_END

set _READY=yes

rem ####################################
rem # Cleanup Environment Variables

:CLEANUP
set ONE_VMID=
set ONE_ETH0_IP=
set ONE_ETH0_MASK=
set ONE_ETH0_CIDR=
set ONE_ETH0_GATEWAY=
set ONE_ETH0_DNS=
set ONE_ETH0_SEARCH_DOMAIN=
set ONE_ETH0_MTU=
set ONE_ETH0_METHOD=
set ONE_SET_HOSTNAME=
set ONE_USERNAME=
set ONE_ONEGATE_ENDPOINT=
set ONE_REPORT_READY=
set ONE_SVC_FTP_ENABLE=
set ONE_SVC_FTP_USERNAME=
set ONE_SVC_FTP_PASSWORD=
set ONE_SVC_FTP_SANDBOX_DIR=
set ONE_SVC_FTP_UPLOAD_DIR=
set ONE_SVC_FTP_PERMISSIONS=
set ONE_SVC_HTTP_ENABLE=
set ONE_SVC_HTTP_CLIENTS=
set ONE_SVC_HTTP_DIR_INDEXES=
set ONE_SVC_HTTP_DOC_ROOT=
set ONE_SVC_HTTP_PORT=
set ONE_SVC_RMENU_ENABLE=
set CTX_DISK=
set CTX_FILE=
set _RTN=

:END
