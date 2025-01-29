LH /L:0;1,42896 /S C:\DOS\SMARTDRV.EXE
@ECHO OFF
PROMPT $p$g
PATH C:\EXCEL;C:\WINWORD;C:\WINDOWS;C:\DOS
PATH %PATH%;C:\MOUSE
SET LMOUSE=C:\MOUSE
LH /L:1,65536 C:\MOUSE\MOUSE
SET TEMP=C:\DOS
MODE CON CODEPAGE PREPARE=((850) C:\DOS\EGA.CPI)
MODE CON CODEPAGE SELECT=850
LH /L:1,16464 KEYB GR,,C:\DOS\KEYBOARD.SYS
LH /L:1,14064 C:\DOS\SHARE.EXE/L:100 /F:9192
goto %config%
:normal
win
goto ende

:michael
choice /c:qdn /t:n,5 QBasic, Debug, Nichts
if errorlevel 3 goto ende
if errorlevel 2 goto deb
if errorlevel 1 goto qbas

:deb
debug
goto ende

:qbas
qbsic
goto ende

goto ende

:ende
