SETLOCAL EnableDelayedExpansion

echo STEP 16. finding lastday flag
echo Running an increased speed lastday function...
echo(
for /L %%A in (1,1,7) do (
    If exist d:\%%A\lastday.flg SET /A FOLDER=%%A
)


:STEP19
ECHO STEP 18, 19, 20: Copying selected files from d to c

ROBOCOPY D:\0%FOLDER%\AUDITRPT C:\AUDITRPT /E /R:2 /W:2 /XO
ROBOCOPY D:\0%FOLDER%\BACKFILE C:\BACKFILE /E /R:2 /W:2 /XO
ROBOCOPY D:\0%FOLDER%\BATCHFILES C:\BATCHFILES /E /R:2 /W:2 /XO
ROBOCOPY D:\0%FOLDER%\BMA C:\BMA /E /R:2 /W:2 /XO
ROBOCOPY D:\0%FOLDER%\BOC C:\BOC /E /R:2 /W:2 /XO
ROBOCOPY D:\0%FOLDER%\COMMANDS C:\COMMANDS /E /R:2 /W:2 /XO
ROBOCOPY D:\0%FOLDER%\DOWNLOAD C:\DOWNLOAD /E /R:2 /W:2 /XO
echo kill scheduler then copy
TASKKILL /IM Scheduler.EXE /f
c:\install\sp4\nircmd killprocess scheduler
ROBOCOPY D:\0%FOLDER%\GC C:\GC /E /R:2 /W:2 /XO 
ROBOCOPY D:\0%FOLDER%\LOG C:\LOG /E /R:2 /W:2 /XO
ROBOCOPY D:\0%FOLDER%\MANAGER C:\MANAGER /E /R:2 /W:2 /XO
ROBOCOPY D:\0%FOLDER%\POSI C:\POSI /E /R:2 /W:2 /XO
ROBOCOPY D:\0%FOLDER%\QC C:\QC /E /R:2 /W:2 /XO
ROBOCOPY D:\0%FOLDER%\RBI C:\RBI /E /R:2 /W:2 /XO 
ROBOCOPY D:\0%FOLDER%\SC C:\SC /E /R:2 /W:2 /XO
ROBOCOPY D:\0%FOLDER%\SCHEDULES C:\SCHEDULES /E /R:2 /W:2 /XO
ROBOCOPY D:\0%FOLDER%\TIMECARD C:\TIMECARD /E /R:2 /W:2 /XO
ROBOCOPY D:\0%FOLDER%\UPLOAD C:\UPLOAD /E /R:2 /W:2 /XO
ROBOCOPY "D:\0%FOLDER%\RDC NAVIGATOR" "C:\RDC NAVIGATOR" /E /R:2 /W:2 /XO
ROBOCOPY D:\0%FOLDER%\FRAN C:\FRAN /E /R:2 /W:2 /XO

SET /P TEMPVAR= If you're satisfied with the copy, press 1. If you'd like to open explorer to verify, press 2.
IF %TEMPVAR% EQU 2 (
	EXPLORER D:\
	EXPLORER C:\
	ECHO After you've verified the contents to your liking, press a key to continue.
	PAUSE >NUL
)


for /L %%A in (1,1,7) do (
	echo %%A
    If exist d:\0%%A\lastday.flg SET /A FOLDER=%%A+1
	IF !FOLDER! equ 8 SET /A FOLDER=1
)

if %count% lss 7 (
	echo you have been through this loop %count% times, you have grabbed the information from folders: %folders% let's be thorough and go again.
	pause
set /a count+=1
	SET /P VAR=Do you want to go through again [Y|N]
	if /i %var%=n goto exit
	goto :STEP19
)

:Exit
DIR C:\GC\DATA\GC.GDB
MSG * STEP 16: Gc.gdb should be the only gc listed. Delete any other gc and make note of the date modified of the real gc.gdb.
EXPLORER D:\0%FOLDER%\GC\DATA
