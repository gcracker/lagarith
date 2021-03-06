@ECHO OFF
SETLOCAL ENABLEEXTENSIONS
CD /D %~dp0

rem Check the building environment
IF NOT DEFINED VS120COMNTOOLS CALL :SUBMSG "ERROR" "Visual Studio 2012 NOT FOUND!"


rem Check for the help switches
IF /I "%~1" == "help"   GOTO SHOWHELP
IF /I "%~1" == "/help"  GOTO SHOWHELP
IF /I "%~1" == "-help"  GOTO SHOWHELP
IF /I "%~1" == "--help" GOTO SHOWHELP
IF /I "%~1" == "/?"     GOTO SHOWHELP


rem Check for the first switch
IF "%~1" == "" (
  SET "BUILDTYPE=Build"
) ELSE (
  IF /I "%~1" == "Build"     SET "BUILDTYPE=Build"   & GOTO CHECKSECONDARG
  IF /I "%~1" == "/Build"    SET "BUILDTYPE=Build"   & GOTO CHECKSECONDARG
  IF /I "%~1" == "-Build"    SET "BUILDTYPE=Build"   & GOTO CHECKSECONDARG
  IF /I "%~1" == "--Build"   SET "BUILDTYPE=Build"   & GOTO CHECKSECONDARG
  IF /I "%~1" == "Clean"     SET "BUILDTYPE=Clean"   & GOTO CHECKSECONDARG
  IF /I "%~1" == "/Clean"    SET "BUILDTYPE=Clean"   & GOTO CHECKSECONDARG
  IF /I "%~1" == "-Clean"    SET "BUILDTYPE=Clean"   & GOTO CHECKSECONDARG
  IF /I "%~1" == "--Clean"   SET "BUILDTYPE=Clean"   & GOTO CHECKSECONDARG
  IF /I "%~1" == "Rebuild"   SET "BUILDTYPE=Rebuild" & GOTO CHECKSECONDARG
  IF /I "%~1" == "/Rebuild"  SET "BUILDTYPE=Rebuild" & GOTO CHECKSECONDARG
  IF /I "%~1" == "-Rebuild"  SET "BUILDTYPE=Rebuild" & GOTO CHECKSECONDARG
  IF /I "%~1" == "--Rebuild" SET "BUILDTYPE=Rebuild" & GOTO CHECKSECONDARG

  ECHO.
  ECHO Unsupported commandline switch!
  ECHO Run "%~nx0 help" for details about the commandline switches.
  CALL :SUBMSG "ERROR" "Compilation failed!"
)


:CHECKSECONDARG
rem Check for the second switch
IF "%~2" == "" (
  SET "ARCH=all"
) ELSE (
  IF /I "%~2" == "x86"   SET "ARCH=x86" & GOTO START
  IF /I "%~2" == "/x86"  SET "ARCH=x86" & GOTO START
  IF /I "%~2" == "-x86"  SET "ARCH=x86" & GOTO START
  IF /I "%~2" == "--x86" SET "ARCH=x86" & GOTO START
  IF /I "%~2" == "x64"   SET "ARCH=x64" & GOTO START
  IF /I "%~2" == "/x64"  SET "ARCH=x64" & GOTO START
  IF /I "%~2" == "-x64"  SET "ARCH=x64" & GOTO START
  IF /I "%~2" == "--x64" SET "ARCH=x64" & GOTO START
  IF /I "%~2" == "all"   SET "ARCH=all" & GOTO START
  IF /I "%~2" == "/all"  SET "ARCH=all" & GOTO START
  IF /I "%~2" == "-all"  SET "ARCH=all" & GOTO START
  IF /I "%~2" == "--all" SET "ARCH=all" & GOTO START

  ECHO.
  ECHO Unsupported commandline switch!
  ECHO Run "%~nx0 help" for details about the commandline switches.
  CALL :SUBMSG "ERROR" "Compilation failed!"
)


:START
IF "%ARCH%" == "x64" GOTO x64
IF "%ARCH%" == "x86" GOTO x86


:x86
CALL "%VS120COMNTOOLS%..\..\VC\vcvarsall.bat" x86
CALL :SUBMSVC %BUILDTYPE% Release Win32
IF "%ARCH%" == "x86" GOTO END


:x64
IF DEFINED PROGRAMFILES(x86) (SET build_type=amd64) ELSE (SET build_type=x86_amd64)
CALL "%VS120COMNTOOLS%..\..\VC\vcvarsall.bat" %build_type%
CALL :SUBMSVC %BUILDTYPE% Release x64


CALL installer\build_installer.bat


 :END
ECHO. & ECHO.
ENDLOCAL
PAUSE
EXIT /B


:SUBMSVC
ECHO.
TITLE Building lagarith - %~1 "%~2|%~3"...
devenv /nologo lagarith.sln /%~1 "%~2|%~3"
IF %ERRORLEVEL% NEQ 0 CALL :SUBMSG "ERROR" "Compilation failed!"
EXIT /B


:SHOWHELP
TITLE "%~nx0 %1"
ECHO. & ECHO.
ECHO Usage:  %~nx0 [Clean^|Build^|Rebuild] [x86^|x64^|all]
ECHO.
ECHO Notes:  You can also prefix the commands with "-", "--" or "/".
ECHO         The arguments are not case sensitive.
ECHO. & ECHO.
ECHO Executing "%~nx0" will use the defaults: "%~nx0 build all"
ECHO.
ECHO If you skip the second argument the default one will be used.
ECHO Examples:
ECHO "%~nx0 rebuild" is the same as "%~nx0 rebuild all"
ECHO.
ECHO WARNING: "%~nx0 x86" or "%~nx0 x64" won't work.
ECHO.
ENDLOCAL
EXIT /B


:SUBMSG
ECHO. & ECHO ______________________________
ECHO [%~1] %~2
ECHO ______________________________ & ECHO.
IF /I "%~1" == "ERROR" (
  PAUSE
  EXIT
) ELSE (
  EXIT /B
)
