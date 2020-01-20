::------------------------------------------------------------------------------
:: NAME:         LEXER OS Project
:: CONTRIBUTORS: Cross_Sans21 and Shadow_Thief
:: VERSION:      Meta Dev, build 20200106_1938
::               See CHANGELOG for a complete version history
::
:: DEPENDENCIES: BatBox 3.1 - https://app.box.com/s/425wmab6sgvvi8wi080i
::               CMDMenuSel 1.4 - https://github.com/max20091/cmdmenusel
::------------------------------------------------------------------------------
:: Make a copy of the file before modifying it and update CHANGELOG with what
:: you did. Use comments starting with your initials to talk about why you
:: chose to do something a certain way. These will be deleted before a public
:: release.
::------------------------------------------------------------------------------
@echo off
setlocal enabledelayedexpansion
mode con cols=80 lines=25

:: ST: "The fake load and setup should be optional"
if "%~1"=="--buzzkill" goto :desktopSetup

call :boot
REM call :checkFiles
REM call :checkSettings
call :loadingBar
call :setUDI

:desktopSetup
:: This is more for restarting
mode con cols=100 lines=25
cls
:: Disable the cursor if we haven't already
batbox /h 0 /c 0x07

:: Draw the top and bottom lines
for /L %%A in (0,1,98) do (
	batbox /g %%A 0 /c 0x22 /d "."
	batbox /g %%A 24 /c 0x22 /d "."
)

:: Draw the start button
for /L %%A in (1,1,7) do batbox /g %%A 24 /c 0x11 /d "."
batbox /g 2 24 /c 0x1F /d "START"

:desktop
:: Add the clock in the top right corner
batbox /g 94 0 /c 0x20 /d "%time:~0,5%"

:: Wait for the user to click somewhere
call :getClick
title [%mouse_X%:%mouse_Y%] - %mouse_C%

for /L %%A in (1,1,7) do (
	if "%mouse_X%" == "%%A" if "%mouse_Y%" == "24" goto :startMenu
)
goto :desktop

:startMenu
for /L %%A in (23,-1,13) do (
	batbox /g 1 %%A /c 0x11 /d "                              "
)
set "menu_option=batbox /g 1 xxx /c 0x1F /d"
%menu_option:xxx=14% " Control Panel                "
%menu_option:xxx=15% " Games 				        "
%menu_option:xxx=16% " LEXER Mailer					"
%menu_option:xxx=21% " About...                     "
%menu_option:xxx=22% " Restart                      "
%menu_option:xxx=23% " Exit                         "

:clickStart
call :getClick
title [%mouse_X%:%mouse_Y%] - %mouse_C%
for /L %%A in (1,1,30) do (
	if "%mouse_X%"=="%%A" (
		if "%mouse_Y%"=="24" (
			for /L %%B in (13,1,23) do (
				batbox /g 1 %%B /c 0x00 /d "                              "
			)
			goto :desktop
		)
		if "%mouse_Y%"=="14" goto :ctrlPanel
		if "%mouse_Y%"=="15" goto :games
		if "%mouse_Y%"=="21" goto :about
		if "%mouse_Y%"=="22" goto :desktopSetup
		if "%mouse_Y%"=="16" goto :mailer
		if "%mouse_Y%"=="23" (
			batbox /h 1 /c 0x07
			cls
			exit /b
		)
	)
)
goto :clickStart

:ctrlPanel
for /L %%A in (14,1,18) do (
	batbox /g 31 %%A /c 0x11 /d "                                "
)
set "ctrl_panel_option=batbox /g 32 xxx /c 0x1F /d"
%ctrl_panel_option:xxx=14% "Security and Updates           "
%ctrl_panel_option:xxx=15% "Network (Not Available)        "
%ctrl_panel_option:xxx=16% "Programs and Features          "
%ctrl_panel_option:xxx=17% "Elevated Prompt                "
%ctrl_panel_option:xxx=18% "Personalization (Not Available)"

:clickCtrlPanel
call :getClick
title [%mouse_X%:%mouse_Y%] - %mouse_C%
:: See if we're closing the Control Panel
for /L %%A in (1,1,30) do (
	if "%mouse_X%"=="%%A" if "%mouse_Y%"=="14" (
		for /L %%B in (18,-1,14) do (
			batbox /g 31 %%B /c 0x00 /d "                                "
		)
		goto :clickStart
	)
)
:: Nah, we're not
for /L %%A in (31,1,63) do (
	if "%mouse_X%"=="%%A" (
		REM if "%mouse_Y%"=="14" goto :securityAndUpdates
		REM if "%mouse_Y%"=="16" goto :programsAndFeatures
		if "%mouse_Y%"=="17" goto :elevPrompt
	)
)
goto :clickCtrlPanel

::------------------------------------------------------------------------------
:: Displays the About splash screen. Assumes that only the base menu is open.
::------------------------------------------------------------------------------
:about
call :clearScreen
batbox /c 0x30 /g 33 10 /d "            LEXER OS            " ^
               /g 33 11 /d "      %lexer_version%      " ^
               /g 33 12 /d "                                " ^
               /g 33 13 /d " PurpleTech Corporation (c)2020 " ^
               /g 33 14 /d "      All rights reserved.      "
>nul batbox /m
call :clearScreen
goto :desktop

::------------------------------------------------------------------------------
:: Displays the in-universe elevated command prompt
::------------------------------------------------------------------------------
:elevPrompt
call :clearScreen
batbox /g 1 1 /c 0x07 /h 1
set /p "command=$%user%:\%user%\LEXER\Sys\>"
if "%command%"=="%cm_act%" (
	echo LEXER has successfully activated
	TIMEOUT 5
	set "activated=true"
)
if "%command%"=="%cm_run_update_service%" (
	call LEXER_UPDATE.bat
)
if "%command%"=="%cm_show_commands%" (
	echo %cm_act% (Activates LEXEr)
	echo %cm_tbsht_hardware% (Troubleshoots Hardware)
	echo %cm_tbsht_input% (Troubleshoots input devices)
	echo %cm_tbsht_os% (Scans the OS for errors)
	echo %cm_dskr_scan% (Scans the health of the computer)
	echo %cm_dskr_check% (Checks if the main driver is not damaged)
	echo %cm_dskr_restore% (Replaces corrupted files with the new ones)
	echo %cm_change_color_green% (Changes color to green)
	echo %cm_change_color_red% (Changes color to red)
	echo %cm_change_color_blue% (Changes color to blue)
	echo %cm_run_update_service% (Checks for intelligence updates)
	echo %cm_run_update_os% (Checks for new versions of LEXER)
	echo %cm_replace_update_files% (Replaces files that LEXER needs to update)
	echo %cm_show_commands=/?% (Shows the list of commands)
)
REM if "%command%"=="%cm_tbsht_hardware%" goto :repairSecTroubleshoot
REM if "%command%"=="%cm_dskr_scan%" goto :diskScan
if /I "%command%"=="exit" (
	batbox /h 0
	call :clearScreen
	goto :desktop
)
goto :elevPrompt
exit /b

::------------------------------------------------------------------------------
:: Sets initial variables and randomly determines if the system will crash on
:: boot or not.
::
:: Arguments: None
:: Returns:   None
::------------------------------------------------------------------------------
:boot
title LEXER
echo Booting...
timeout 1 >nul
cls

set user=DEFAULT-User
set /a first=0
set /a corrupted=0
set /a reinstall=0
set /a drivererror=0
set /a tempuser=0
set /a errorTrig=0
set /a launchRepair=0
set /a cannotCont=0

:: CS21: "Here I will just add if some of these variables are true or not.
:: If it's true it will just give a splash error box (similar to the about splash screen)
:: and it will redirect to error handler and it will show what's wrong"

:: Get the date without worrying what the locale is
for /f %%A in ('wmic os get localdatetime /Value ^| find "."') do set %%A
set "year=%LocalDateTime:~0,4%"
set "month=%LocalDateTime:~4,2%"
set "day=%LocalDateTime:~6,2%"

:: ST: "Literally the only reason I'm keeping this here is because it will
::      be used later for something that I don't know about. Personally, I think
::      we should delete it and add it back when we need it."
::Planning to implement the color handler once personalization update gets released
set colorgreen=0x010
set colorblue=0x001
set colorred=0x100
set colormagenta=0x101
set colorbrown=0x110
set colorwhite=1x111

::Setting Command Variables for the Prompt
set cm_act=lxract /act
set cm_tbsht_hardware=lxrtbsht /hardware
set cm_tbsht_input=lxrtbsht /input
set cm_tbsht_os=lxrtbsht /scan
set cm_dskr_scan=dskr /scanhealth
set cm_dskr_check=dskr /checkhealth
set cm_dskr_restore=dskr /restorehealth
set cm_change_color_green=lxrcolor /green
set cm_change_color_red=lxrcolor /red
set cm_change_color_blue=lxrcolor /blue
set cm_run_update_service=lxrupdate /check /i
set cm_run_update_os=lxrupdate /check /l
set cm_replace_update_files=curl "$%user%:\%user%\LEXER\Sys\Distribution\Updates" /o /l
set cm_show_commands=/?

::Random int that decide if the error should be triggered. Every startup is random
:: ST: "I know when *I* start my computer, I want there to be a chance of it not
::      working! Also, min and max are never set, so nothing happens here anyway."
set /a gRandomWholeCritical=(%RANDOM%*max/32768)+min
set /a gRandomWholeLoad=(%RANDOM%*max/32768)+min
exit /b

::------------------------------------------------------------------------------
:: Displays a loading bar that technically serves no purpose, but gosh darn it
:: it's just so FUN!
::
:: Arguments: None
:: Returns :  None
::------------------------------------------------------------------------------
:loadingBar
batbox /g 0 10
echo ###############################################################################
echo #-----------------------------------------------------------------------------#
echo ###############################################################################
echo                                                                   Loading...
batbox /g 1 11 /h 0
for /L %%A in (1,1,77) do batbox /d "/" /w 50
exit /b

::------------------------------------------------------------------------------
:: Determines if LEXER has been "set up" yet and does so if necessary. This
:: subroutine includes multiple labels, so technically the whole thing goes
:: until you see another header or the file ends.
::
:: Arguments: None
:: Returns:   None
::------------------------------------------------------------------------------
:setUDI
:: ST: "If we flip the order of the old if statements, we can remove one."
if exist udi.txt (
	>udi.txt echo FIRST_LAUNCH: FALSE
	set "first=0"
	exit /b
)

title LEXER Setup
cls
:: ST: "It fades in, it's just super subtle because there are only two colors"
for %%A in (0 8 7 F) do batbox /g 39 11 /c 0x0%%A /d "Hi" /w 200
batbox /w 800
for %%A in (F 7 8 0) do batbox /g 39 11 /c 0x0%%A /d "Hi" /w 200

:: ST: "This array is cleaner than the four IF statements that we had before"
set "ver_menu[1]=Professional Edition"
set "ver_menu[2]=    Home Edition    "
set "ver_menu[3]= Education  Edition "
set "ver_menu[4]=Development  Edition"
batbox /g 26 0 /c 0x07 /d "SELECT YOUR VERSION OF LEXER" /g 0 3
cmdmenusel f880 "Pro" "Home" "Education" "Dev"
set "lexer_version=!ver_menu[%errorlevel%]!"

:installType
cls
batbox /g 29 0 /d "SELECT INSTALL TYPE" /g 0 3
cmdmenusel f880 "Upgrade" "Custom"
:: ST: "I got rid of the second if statement because we're railroading the user"
if "%errorlevel%"=="1" (
	echo(
	echo Sorry, this option is currently unavailable.
	echo The required files are not yet present on the system.
	pause
	goto :installType
)

:partitionSelect
title LEXER Setup: Custom Install
cls
batbox /g 22 0 /d "SELECT YOUR INSTALLATION PARTITION"
batbox /g 21 1 /d "Current Selection:  Disk Partition 0" /g 0 3
cmdmenusel f880 "Disk Partition 0 (130 GB)" "Recovery Partition 1 (200 GB)" "Continue with Installation"
:: ST: "I'm not including the first IF because the script will go here naturally
::      regardless of whether I tell it to or not."
if "%errorlevel%"=="2" (
	echo(
	echo Cannot select Recovery Partition
	pause
	goto :partitionSelect
)
if "%errorlevel%"=="3" goto :continueInstall

:partitionSelect0
title LEXER Setup: Custom Install on Partition 0
cls
batbox /g 27 0 /d "DISK PARTITION 0 (130 GB)" /g 0 3
cmdmenusel f880 "Delete" "Split" "Back"
if "%errorlevel%"=="1" (
	echo(
	echo Access Denied. Disk is currently in use.
	timeout 2
)
if "%errorlevel%"=="2" (
	echo(
	echo Access Denied. Disk is currently in use.
	timeout 2
)
if "%errorlevel%"=="3" goto :partitionSelect
goto :partitionSelect0

:continueInstall
cls
echo Expanding files...
>nul timeout 10

:: Create some "system files" for realism
:: ST: "O...kay..."
if not exist mbr.txt (
	(
		echo @echo off
		echo set SIZE=512
		echo set BASE=0x7C00
		echo set DEST=0x0600
		
		echo set ENTRY_NUM=4
		echo set ENTRY_SIZE=16
		echo set DISK_ID=0x12345678
		
		echo set TOP=8
		echo set LEFT=32
		echo set COLOR=0x02
		
		echo set BITS=16
		echo set ORG=BASE
		
		echo cls
		echo set SP=BASE
		echo set AX=0
		echo set SS=0
		echo set ES=0
		echo set DS=0
		echo set DX=0
	)>mbr.txt
)
if not exist boot.txt (
	(
		echo @echo off
		echo set menuentry="Boot first drive MBR"
		echo set root=hd1
		echo set drivemap=hd1, hd0
		echo set /a chainloader=0 + 1
		
		echo set menuentry2="Boot second drive MBR"
		echo set root2=hd2
		echo set drivemap=hd2, hd0
		echo set /a chainloader=0 + 1
	)>boot.txt
)

for %%A in ("Preparing files..."
			"Installing files..."
			"Installing updates..."
			"Finishing up...") do (
	echo %%~A
	timeout 15 >nul
)

:enterLicense
cls
if exist license.txt goto :finishSetup
set /p "license=Enter your license key: "
if "%license%"=="ptsio-jofhn-hf627-88945" (
	>license.txt echo %license%
)

:: PTS: "Cause I don't know how to automatically detect the time."
:finishSetup
cls
set reg_locale=reg query "HKCU\Control Panel\International" /v
for /f "skip=2 tokens=1,2,*" %%A in ('%reg_locale% sCountry') do set "locale_country=%%C"
for /f "skip=2 tokens=1,2,*" %%A in ('%reg_locale% LocaleName') do set "locale_language=%%C"
for /f "delims=" %%A in ('wmic path Win32_Keyboard get Caption /Value ^| find "="') do set %%A
set "locale_keyboard_layout=!caption!"
for /f "delims=" %%A in ('wmic path Win32_TimeZone get Caption /Value ^| find "="') do set "%%A"
set "locale_timezone=!caption!"

echo Settings automatically detected^^!
echo Country: !locale_country!
echo Language: !locale_language!
echo Keyboard Layout: !locale_keyboard_layout!
echo Time Zone: !locale_timezone!
pause
cls
echo Thank you for choosing LEXER^^! See you in the future^!
pause
exit /b

::------------------------------------------------------------------------------
:: Gets the location of a mouseclick from batbox /m
::
:: Arguments: None
:: Returns:   The X and Y coordinates of the mouseclick as well as the type
::            of mouseclick.
::            1 - Single left click
::            2 - Single right click
::            3 - Double left click
::            4 - Double right click
::------------------------------------------------------------------------------
:getClick
set "mouse_X="
set "mouse_Y="
set "mouse_C="
for /F "tokens=1-3 delims=:" %%A in ('batbox /m') do (
	set "mouse_X=%%A"
	set "mouse_Y=%%B"
	set "mouse_C=%%C"
)

if "%mouse_C%" == "2" call
exit /b

::------------------------------------------------------------------------------
:: Clears the entire screen except for the top and bottom lines
::
:: Arguments: None
:: Returns:   None
::------------------------------------------------------------------------------
:clearScreen
:: ST: "The ^ at the end of the line is line continuation so this entire thing
::      is one long command."
batbox /c 0x00 /g 0 1 /d "                                                                                                 " ^
               /g 0 2 /d "                                                                                                 " ^
               /g 0 3 /d "                                                                                                 " ^
               /g 0 4 /d "                                                                                                 " ^
               /g 0 5 /d "                                                                                                 " ^
               /g 0 6 /d "                                                                                                 " ^
               /g 0 7 /d "                                                                                                 " ^
               /g 0 8 /d "                                                                                                 " ^
               /g 0 9 /d "                                                                                                 " ^
               /g 0 10 /d "                                                                                                 " ^
               /g 0 11 /d "                                                                                                 " ^
               /g 0 12 /d "                                                                                                 " ^
               /g 0 13 /d "                                                                                                 " ^
               /g 0 14 /d "                                                                                                 " ^
               /g 0 15 /d "                                                                                                 " ^
               /g 0 16 /d "                                                                                                 " ^
               /g 0 17 /d "                                                                                                 " ^
               /g 0 18 /d "                                                                                                 " ^
               /g 0 19 /d "                                                                                                 " ^
               /g 0 20 /d "                                                                                                 " ^
               /g 0 21 /d "                                                                                                 " ^
               /g 0 22 /d "                                                                                                 " ^
               /g 0 23 /d "                                                                                                 "
exit /b

:diskScan
title LEXER: Disk scan
batbox /g 0 10
echo ###############################################################################
echo #-----------------------------------------------------------------------------#
echo ###############################################################################
echo                                                                 Scanning %diskC%...
batbox /g 1 11 /h 0
for /L %%A in (1,1,77) do batbox /d "/" /w 50
if "%corrupted%" == "1" (
echo LEXER Found corrupted files and bad sectors on %diskC%.
echo It is recommended to run Automatic Repair!
)
echo LEXER Found no errors and %diskC% is working normal
call :clearScreen
goto :desktop

:checkFiles
:: if exist batbox.exe goto :loadingBar
:: if not exist batbox.exe (
:: set /a "hasbatb=1"
:: )
:: if exist cmdmenusel.exe goto :loadingBar
:: if not exist cmdmenusel.exe (
:: set /a "hasmenus=1"
:: )
:: if "%hasmenus%" == "1" && "%hasbabt%" == "1" (
:: echo The following files are missing:
:: echo cmdmenusel.exe
:: echo batbox.exe
:: TIMEOUT 2
:: echo Please download these files and put it in the same file where LEXER OS is located and try again.
:: echo If you are experiencing issues, please contact purpleguygamer582@gmail.com for the support.
:: pause
:: exit /b
:: )
::  exit /b

::checkSettings
::title LEXER
:: set reg_qry=reg Query "HKCU\Console\%SystemRoot%_system32_cmd.exe\" /v
:: for /f "skip=2 tokens=1,2,*" %%A in ('%reg_locale% QuickEdit') do set "quickEdit=%%C"
:: if "%quickEdit%" == "0" call :loadingBar
:: if "%quickEdit%" == "1" (
::	reg add "HKCU\Console\%SystemRoot%_system32_cmd.exe\" /v QuickEdit /t REG_DWORD /d 0 /f
::)

:mailer
cls
title LEXER Mailer [Checking connectivity]
echo Checking if connected. . .
TIMEOUT 1
netsh interface show interface | findstr /i “wifi wireless”
ping -n 1 www.google.com | find "Reply From " > NUL
if not "%ERRORLEVEL%" == 1 (
	title LEXER Mailer [Connected]
	echo You are connected!
	goto :sendMail
)
if "%ERRORLEVEL%" == 1 (
	title LEXER Mailer [Disconnected]
	echo You need a network connection if you want to send an email
	goto :dekstop
)

:sendMail
title LEXER Mailer
set /p "address=Email: "
set /p "server=Server: "
set /p "sender=From: "
set /p "subject=Subject: "
set /p "body=Description: "
blat -to %address% -server %server% -f %from% -subject "%subject%" -body "%body%"

:errorHandler
if "%corrupted%" == "1" (

call :clearScreen
batbox /c 0x30 /g 43 10 /d " Cannot continue the operation " ^
               /g 13 12 /d " One of the files is corrupted or either it is not designed to not run on this version of LEXER " ^
               /g 13 13 /d " Please contact your system administrator, run a built in repair tool or reinstall the OS "
>nul batbox /m
call :clearScreen
goto :desktop
)

:games
for /L %%A in (15,1,17) do (
	batbox /g 31 %%A /c 0x11 /d "                                "
)
set "gms_option=batbox /g 32 xxx /c 0x1F /d"
%:::xxx=14% "Security and Updates           "
%gms_option:xxx=16% "Tic Tac Toe 			        "
%gms_option:xxx=17% "MineSweeper (Not Available)    "
%gms_option:xxx=18% "Coming soon!                   "

:clickGames
call :getClick
title [%mouse_X%:%mouse_Y%] - %mouse_C%
:: See if we're closing the Control Panel
for /L %%A in (1,1,30) do (
	if "%mouse_X%"=="%%A" if "%mouse_Y%"=="14" (
		for /L %%B in (18,-1,14) do (
			batbox /g 31 %%B /c 0x00 /d "                                "
		)
		goto :clickStart
	)
)
for /L %%A in (31,1,63) do (
	if "%mouse_X%"=="%%A" (
		if "%mouse_Y%"=="16" goto :tictactoe
	)
)
goto :clickGames

:tictactoe
