:start
@echo off
color 0
title AntonOS
cls
goto bootscreen

:bootscreen
rem Print 20 dots, one per 0.3 seconds to simulate boot progress
for /l %%i in (1,1,20) do (
    <nul set /p=.
    timeout /t 0 >nul
    ping -n 1 -w 300 127.0.0.1 >nul
)
echo.
echo Boot sequence complete.
timeout /t 1 >nul
goto userscreen

:passwordscreen
cls
echo Please put in the Password.
set /p password= Password:
if "%password%"=="maus" goto desktop
goto passwordfailedscreen

:desktop
for /f "delims=" %%a in ('echo prompt $E^| cmd') do set "ESC=%%a"
cls
echo Welcome to the Desktop.
echo.
echo It is  %time%  on the  %date%
echo.
echo %ESC%[34m
type "C:\Users\herzo\Downloads\AntonOS\ascii.txt"
echo %ESC%[0m
echo.
echo 1) File creator
echo 2) List written files
echo 3) App Launcher
echo 4) Settings
echo.
echo Press q to exit
choice /c 123q4i /n
if errorlevel 6 goto randomnumber
if errorlevel 5 goto settings
if errorlevel 4 exit
if errorlevel 3 goto applauncher
if errorlevel 2 goto filelist
if errorlevel 1 goto writer
goto desktop

:passwordfailedscreen
cls
echo Wrong Password!
echo.
setlocal enabledelayedexpansion
set "keys=1ABCDEFGHIJKLMNOPQRSTUVWXYZ"
choice /c %keys% /n /m "Press 1 to try again, or any other key to exit: "
set /a index=%errorlevel%-1
set "key=!keys:~%index%,1!"
endlocal & set "key=%key%"
if /i "%key%"=="1" goto passwordscreen
exit

:writer
set "writerfolder=C:\Users\herzo\Downloads\AntonOS\Written Files"
cls
echo Welcome to writer. You can write text files here. They are saved in the "Written Files" folder.
echo To go back simply press enter.
echo.
set /p filename= Filename: 
if "%filename%"=="" goto desktop

if not exist "%writerfolder%" mkdir "%writerfolder%"
set "full=%writerfolder%\%filename%.txt"
type nul > "%full%"

echo.
echo Start typing. Press Enter to add a new line.
echo Type :save on its own line and press Enter to finish and return to the desktop.
echo.

rem Enable delayed expansion so we can safely echo lines that contain special chars
setlocal enabledelayedexpansion

:writeLoop
set /p "line=> "
if "!line!"==":save" (
    endlocal
    echo.
    echo File saved to "%full%".
    timeout /t 1 >nul
    goto desktop
)
>>"%full%" echo(!line!
goto writeLoop

:filelist
set "writerfolder=C:\Users\herzo\Downloads\AntonOS\Written Files"

cls
if not exist "%writerfolder%" mkdir "%writerfolder%"

rem Get ESC for colors
for /f "delims=" %%a in ('echo prompt $E^| cmd') do set "ESC=%%a"

:: --- Build numbered file list ---
setlocal enabledelayedexpansion
set count=0
pushd "%writerfolder%"
for /f "delims=" %%f in ('dir /b /a-d *.txt 2^>nul') do (
    set /a count+=1
    set "file!count!=%%f"
)
popd

if !count! equ 0 (
    endlocal
    echo No .txt files found in "%writerfolder%".
    pause
    goto desktop
)

cls
echo Files in "%writerfolder%":
for /l %%i in (1,1,!count!) do echo   %%i^) !file%%i!
echo.
echo 1) View file
echo 2) Rename file
echo 3) Delete file
echo 4) Back to desktop
choice /c 1234 /n
set "option=%errorlevel%"
endlocal & set "option=%option%"

if "%option%"=="1" goto fileread
if "%option%"=="2" goto filerename
if "%option%"=="3" goto filedelete
goto desktop


:: ======================================================
:: VIEW FILE
:: ======================================================
:fileread
cls
setlocal enabledelayedexpansion
set count=0
pushd "%writerfolder%"
for /f "delims=" %%f in ('dir /b /a-d *.txt 2^>nul') do (
    set /a count+=1
    set "file!count!=%%f"
)
popd

if !count! equ 0 (endlocal & goto filelist)

cls
echo Choose a file to view:
for /l %%i in (1,1,!count!) do echo   %%i^) !file%%i!
echo.
set /p "choice=Enter number: "
if "!choice!"=="" (endlocal & goto filelist)
if !choice! gtr !count! (endlocal & goto filelist)
set "filename=!file%choice%!"
cls
echo ----- [ !filename! ] -----
type "%writerfolder%\!filename!"
echo -------------------------------
echo.
echo Press any key to return.
pause >nul
endlocal
goto filelist


:: ======================================================
:: RENAME FILE
:: ======================================================
:filerename
cls
setlocal enabledelayedexpansion
set count=0
pushd "%writerfolder%"
for /f "delims=" %%f in ('dir /b /a-d *.txt 2^>nul') do (
    set /a count+=1
    set "file!count!=%%f"
)
popd

if !count! equ 0 (endlocal & goto filelist)

cls
echo Choose a file to rename:
for /l %%i in (1,1,!count!) do echo   %%i^) !file%%i!
echo.
set /p "choice=Enter number: "
if "!choice!"=="" (endlocal & goto filelist)
if !choice! gtr !count! (endlocal & goto filelist)
set "oldname=!file%choice%!"
cls
echo Current name: !oldname!
set /p "newname=New name (without .txt): "
if "!newname!"=="" (endlocal & goto filelist)
if exist "%writerfolder%\!newname!.txt" (
    echo File already exists.
    timeout /t 1 >nul
    endlocal
    goto filelist
)
ren "%writerfolder%\!oldname!" "!newname!.txt"
echo File renamed successfully.
timeout /t 1 >nul
endlocal
goto filelist


:: ======================================================
:: DELETE FILE
:: ======================================================
:filedelete
cls
setlocal enabledelayedexpansion
set count=0
pushd "%writerfolder%"
for /f "delims=" %%f in ('dir /b /a-d *.txt 2^>nul') do (
    set /a count+=1
    set "file!count!=%%f"
)
popd

if !count! equ 0 (endlocal & goto filelist)

cls
echo Choose a file to delete:
for /l %%i in (1,1,!count!) do echo   %%i^) !file%%i!
echo.
set /p "choice=Enter number: "
if "!choice!"=="" (endlocal & goto filelist)
if !choice! gtr !count! (endlocal & goto filelist)
set "delname=!file%choice%!"
cls
echo %ESC%[38;2;255;50;50mAre you sure you want to delete "!delname!"?%ESC%[0m
choice /c YN /n /m "Press Y to confirm or N to cancel: "
if errorlevel 2 (endlocal & goto filelist)
if errorlevel 1 (
    del "%writerfolder%\!delname!"
    echo File deleted successfully.
    timeout /t 1 >nul
)
endlocal
goto filelist


:userscreen
cls
echo Which User are you?
echo.
echo 1) Root
echo 2) Guest
choice /c 12 /n 
if errorlevel 2 goto guestlogin
if errorlevel 1 goto passwordscreen

:guestlogin
cls
echo Welcome to the Guest-Login.
echo.
echo You can do absolutely nothing here
echo.
echo Press e to get back to the User-Select-Screen.
echo Press q to exit.
choice /c eq /n
if errorlevel 2 exit
if errorlevel 1 goto userscreen

:applauncher
cls 
cd "C:\Users\herzo\Downloads\AntonOS\applauncher"
echo This is the Applauncher. You can launch Apps from here.
echo.
echo %ESC%[38;2;25;103;160m 1) Steam%ESC%[0m
echo %ESC%[38;2;88;101;242m 2) Discord%ESC%[0m
echo %ESC%[38;2;30;215;96m 3) Spotify%ESC%[0m
echo.
echo To go back press x.
choice /c 123x /n
if errorlevel 4 goto desktop
if errorlevel 3 start Spotify.lnk & goto endapplauncher
if errorlevel 2 start Discord.lnk & goto endapplauncher
if errorlevel 1 start Steam.lnk & goto endapplauncher

:endapplauncher
cls
echo Your App has now Opened.
echo.
echo Press e to go to the desktop or q to exit
choice /c eq /n
if errorlevel 2 exit
if errorlevel 1 goto desktop

:settings
cls
echo This is the Settings Menu.
echo.
echo 1) System Colors
choice /c 1 /n
if errorlevel 1 goto systemcolors

:systemcolors
cls 
echo You can change the colors of the system here.
echo Sometimes these dont work properly.Be Advised
echo.
echo 1) Default
echo 2) Matrix
echo 3) Old
choice /c 123 /n 
if errorlevel 3 color 71 & goto desktop & set colorofscreen=Old
if errorlevel 2 color 0A & goto desktop & set colorofscreen=Matrix
if errorlevel 1 color 07 & goto desktop & set colorofscreen=Default

:randomnumber
cls
for /f "delims=" %%a in ('echo prompt $E^| cmd') do set "ESC=%%a"
set /a test=%RANDOM% *1000/32768 + 1
rem set /a test2=%RANDOM% *1000/32768 + 1
set /a test3=%RANDOM% *10/32768 + 1
set /a test4=%RANDOM% *10/32768 + 1
echo Grabbing IP..
timeout 5 /nobreak >nul
echo.
echo Sucess!
ping 127.0.0.1 -n 2 >nul
cls
echo IP Adress:
echo.
echo 192.%test%.%test3%.%test4%
echo.
echo Press q to go to Desktop
choice /c q /n
if errorlevel 1 goto desktop