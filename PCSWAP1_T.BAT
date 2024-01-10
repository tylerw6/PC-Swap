::BATCH FILE FOR BACK OFFICE PC SWAPS
::CREATED 1/13/2017 BY TYLER WALKER
@ECHO OFF

ECHO Would you like to pick a step to execute or start from the beginning?
SET /P STEP= Press 1 for beginning or enter the step number.     
GOTO STEP%STEP%

:STEP1
:STEP12
ECHO STEP 12:
ECHO Don't forget to have the manager plug that external backup drive in. Let it install drivers automatically.
ECHO Let's see what drive letter it assigned itself. If the hdd is drive letter d as in step 14 then we'll go to step 6
ECHO And get the folder number of the most recent backup
ECHO(
IF NOT EXIST D:\ (
	ECHO Change the external drive to letter D
	ECHO You may have to change the cd drive to letter I
	MSG * Change the external drive to letter D.
	COMPMGMT.MSC
)

:STEP13
:STEP14
ECHO STEP 13 AND 14: Verify the pc name, date, time and timezone and change if appropriate
ECHO(
HOSTNAME
ECHO(
DATE /T
ECHO(
TZUTIL /G
ECHO(
TIME /T
ECHO(
ECHO Change them as appropriate. Then press a key to continue to step 15.
PAUSE >NUL
CLS

:STEP15
ECHO STEP 15: Let's close the BMA
ECHO(
TASKKILL /F /IM GC_BACKOFFICE.EXE 2> NUL
ECHO And the Scheduler
TASKKILL /IM Scheduler.EXE /f
ECHO(
ECHO Copying txnplus from D: to C:
ROBOCOPY D:\TXNPLUS C:\TXNPLUS /E /R:2 /W:2
ECHO(
DIR D:\TXNPLUS
DIR C:\TXNPLUS
SET /P TEMPVAR= If you're satisfied with the copy, press 1. If you'd like to open explorer to verify, press 2.
IF %TEMPVAR% EQU 2 (
	EXPLORER C:\TXNPLUS
	EXPLORER D:\TXNPLUS
	ECHO After you've verified the contents to your liking, press a key to continue.
	PAUSE >nul
)
CLS

:STEP16
echo STEP 16.
IF %STEP% GTR 14 ECHO We need the folder number to go to that step.
DIR D:\LASTDAY.FLG /S
DIR D:\LASTDAY.FLG /S >> "C:\INSTALL\PCSWAP.TXT"
SET /P FOLDERNUM= Write the backup folder number above and enter it here:  
SET /A FOLDER = %FOLDERNUM%
IF NOT EXIST D:\0%FOLDER%\LASTDAY.FLG (
	CLS
	ECHO Sorry, I couldnt find the lastday.flg in  D:\0%FOLDER%. Try again.
	ECHO ---------------------------------------------------------------------------
	GOTO STEP6
)
CLS
IF %STEP% GTR 14 GOTO STEP%STEP%


:STEP17
ECHO STEP 17: PCANY Copy
ROBOCOPY D:\0%FOLDER%\PCANYUSER "C:\USERS\ALL USERS\SYMANTEC\PCANYWHERE" /E /R:2 /W:2
ECHO(
DIR D:\0%FOLDER%\PCANYUSER
DIR "C:\USERS\ALL USERS\SYMANTEC\PCANYWHERE"
SET /P TEMPVAR= If you're satisfied with the copy, press 1. If you'd like to open explorer to verify, press 2.
IF %TEMPVAR% EQU 2 (
	EXPLORER "C:\USERS\ALL USERS\SYMANTEC\PCANYWHERE"
	EXPLORER  D:\0%FOLDER%\PCANYUSER
	ECHO After you've verified the contents to your liking, press a key to continue.
	PAUSE >nul
)
CLS

:STEP18
ECHO STEP 18: Gc.gdb should be the only gc listed. please delete any other gc.
ECHO Also note the date of the gdb file.
ECHO The following formula checks the date of gc.gdb and compares it to today.
REM GET DATE MODIFIED FROM FILE AND PUT IT IN FILEDATE VARIABLE
FOR %%A IN (D:\0%FOLDER%\GC\DATA\GC.GDB) DO SET FILEDATE=%%~TA
ECHO D:\0%FOLDER%\GC\DATA\GC.GDB Date modified %filedate%
echo gc_gdb filedate
DIR D:GC_GDB\ /o:d
REM SAVE ONLY THE FIRST 10 DIGITS OF THE FILEDATE, THROWING AWAY THE TIME
SET NEWDATE=%FILEDATE:~0,10%
REM PASS THIS 10 DIGIT DATE TO GET BACK A JULIEN DATE NUMBER
CALL :DateToJDN %NEWDATE% FILENO
REM JUST TO MAKE SURE YOU HAVE A GOOD NUMBER
ECHO %FILENO%
REM PASS ONLY THE SAME DATE FORMAT TO TODAY VARIABLE, THROWING AWAY THE DAY AND TIME
SET TODAY=%DATE:~4,10%
REM TOSS IT ON TO JDN FORMULA
CALL :DateToJDN %TODAY% TODAYNO
REM CHECK YOUR NUMBER
ECHO %TODAYNO%
REM MINUS ONE FROM TODAY TO SETUP COMPARISON BASIS WITH FILE
SET /A TODAYNO-=1
REM COMPARE TODAY TO FILE DAY, IF THEY ARE MORE THAN A DAY A PART SHOW WARNING.
IF %TODAYNO% GTR %FILENO% ( 
	DIR D:GC_GDB\ /o:d
	ECHO GC.GDB Was last saved on %filedate% When was the GC file listed above last saved?
	ECHO Is the last file in the list above newer than gc.gdb?
	ECHO if so, ask shift lead if you can perform procedure 6931.
	ECHO -------------------------------------------------------------------------------------
	ECHO ::::::          GC.GBD IS MORE THAN A DAY OLD!! NOTIFY SHIFT LEADER!!          ::::::
	ECHO -------------------------------------------------------------------------------------
	ECHO Press a key to continue.
	PAUSE >NUL
)
REM IF THE ABOVE WORKS WELL, REM THESE LINES OUT
DIR D:\0%FOLDER%\GC\DATA\GC.GDB
MSG * STEP 16: Gc.gdb should be the only gc listed. Delete any other gc and make note of the date modified on gc.gdb.
EXPLORER D:\0%FOLDER%\GC\DATA
ECHO Press a key when you have deleted the extra gc files and have written down the date modified.
PAUSE >NUL
CLS
set /a count=0
set "Folders="
:STEP19
ECHO STEP 18, 19, 20: Copying selected files from d to c

ROBOCOPY D:\0%FOLDER%\AUDITRPT C:\AUDITRPT /E /R:2 /W:2
ROBOCOPY D:\0%FOLDER%\BACKFILE C:\BACKFILE /E /R:2 /W:2
ROBOCOPY D:\0%FOLDER%\BATCHFILES C:\BATCHFILES /E /R:2 /W:2
ROBOCOPY D:\0%FOLDER%\BMA C:\BMA /E /R:2 /W:2
ROBOCOPY D:\0%FOLDER%\BOC C:\BOC /E /R:2 /W:2
ROBOCOPY D:\0%FOLDER%\COMMANDS C:\COMMANDS /E /R:2 /W:2
ROBOCOPY D:\0%FOLDER%\DOWNLOAD C:\DOWNLOAD /E /R:2 /W:2
echo kill scheduler then copy
TASKKILL /IM Scheduler.EXE /f
c:\install\sp4\nircmd killprocess scheduler
ROBOCOPY D:\0%FOLDER%\GC C:\GC /E /R:2 /W:2
ROBOCOPY D:\0%FOLDER%\LOG C:\LOG /E /R:2 /W:2
ROBOCOPY D:\0%FOLDER%\MANAGER C:\MANAGER /E /R:2 /W:2
ROBOCOPY D:\0%FOLDER%\POSI C:\POSI /E /R:2 /W:2
ROBOCOPY D:\0%FOLDER%\QC C:\QC /E /R:2 /W:2
ROBOCOPY D:\0%FOLDER%\RBI C:\RBI /E /R:2 /W:2
ROBOCOPY D:\0%FOLDER%\SC C:\SC /E /R:2 /W:2
ROBOCOPY D:\0%FOLDER%\SCHEDULES C:\SCHEDULES /E /R:2 /W:2
ROBOCOPY D:\0%FOLDER%\TIMECARD C:\TIMECARD /E /R:2 /W:2
ROBOCOPY D:\0%FOLDER%\UPLOAD C:\UPLOAD /E /R:2 /W:2
ROBOCOPY "D:\0%FOLDER%\RDC NAVIGATOR" "C:\RDC NAVIGATOR" /E /R:2 /W:2
ROBOCOPY D:\0%FOLDER%\FRAN C:\FRAN /E /R:2 /W:2

SET /P TEMPVAR= If you're satisfied with the copy, press 1. If you'd like to open explorer to verify, press 2.
IF %TEMPVAR% EQU 2 (
	EXPLORER D:\
	EXPLORER C:\
	ECHO After you've verified the contents to your liking, press a key to continue.
	PAUSE >NUL
)


rem set Folders+=!folder!,
rem for /L %%A in (1,1,7) do (
rem 	echo %%A
rem     If exist d:\0%%A\lastday.flg SET /A FOLDER=%%A+1
rem 	IF !FOLDER! equ 7 SET /A FOLDER=1
rem )
rem 
rem if %count% lss 7 (
rem 	echo you have been through this loop %count% times, you have grabbed the information from folders: %folders% let's be thorough and go again.
rem 	pause
rem	set /a count+=1
rem 	goto :STEP19
rem  )


exit /b

:DateToJDN mm.dd.yyyy jdn=
setlocal
set date=%1
set /A yy=%date:~-4%, mm=1%date:~-10,2% %% 100, dd=1%date:~-7,2% %% 100
set /A a=mm-14, jdn=(1461*(yy+4800+a/12))/4+(367*(mm-2-12*(a/12)))/12-(3*((yy+4900+a/12)/100))/4+dd-32075
endlocal & set %2=%jdn%
exit /B
