SCREEN 12
DIM a%(0 TO 10)
DIM b%(0 TO 25)
IF VARPTR(b%(0)) <> 0 THEN BEEP: END

DEF SEG = VARSEG(a%(0))
FOR i% = 0 TO 10
 READ d%
 POKE VARPTR(a%(0)) + i%, d%
NEXT i%
DATA 184, 0, 0, 205, 51, 184, 1, 0, 205, 51, 203  :
'mov ax,0 int 33 mov ax,1 int 33 retf
CALL ABSOLUTE(VARPTR(a%(0)))
DEF SEG


DEF SEG = VARSEG(b%(0))
DO
RESTORE posdat
FOR i% = 0 TO 25
 READ d%
 POKE VARPTR(b%(0)) + i%, d%
NEXT i%
posdat: DATA 235, 6, 1, 2, 3, 4, 5, 6, 184, 3, 0, 205, 51, 137, 30, 2, 0, 137, 14, 4, 0, 137, 22, 6, 0, 203  :
'jmp 8 6 * db 0 mov ax,3 int 33 mov [2],bx mov [4],cx mov [6],dx retf
CALL ABSOLUTE(VARPTR(b%(0)))
bx1% = PEEK(VARPTR(b%(0)) + 2): bx2% = PEEK(VARPTR(b%(0)) + 3)
cx1% = PEEK(VARPTR(b%(0)) + 4): cx2% = PEEK(VARPTR(b%(0)) + 5)
dx1% = PEEK(VARPTR(b%(0)) + 6): dx2% = PEEK(VARPTR(b%(0)) + 7)
PRINT bx1%; bx2%
PRINT cx1%; cx2%
PRINT dx1%; dx2%
FOR i = 0 TO 25: PRINT PEEK(VARPTR(b%(0)) + i); : NEXT i
PRINT
SLEEP 5
LOOP UNTIL INKEY$ <> ""
DEF SEG

SLEEP
FOR i = 1 TO 100
COLOR i MOD 16
PRINT i;
NEXT i
BEEP
SLEEP
COLOR 15
PRINT
DO: a$ = INKEY$: LOOP UNTIL a$ = ""
DO
PRINT INP(&H3F8);
SLEEP 1
LOOP UNTIL INKEY$ <> ""
DEF SEG = VARSEG(a%(0))
FOR i% = 0 TO 5
 READ d%
 POKE VARPTR(a%(0)) + i%, d%
NEXT i%
DATA 184, 2, 0, 205, 51, 203  :
'mov ax,2 int 33 retf
CALL ABSOLUTE(VARPTR(a%(0)))
DEF SEG

SCREEN 0
WIDTH 80, 25

