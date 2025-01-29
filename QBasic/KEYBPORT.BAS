DECLARE FUNCTION zeichen$ (z!)
DECLARE FUNCTION bin$ (zahl!)
DECLARE SUB ton (z!, davor!)
DIM tasten$(1 TO 100, 1 TO 2)
ON ERROR GOTO fehler
FOR i = 1 TO 100
READ z$
tasten$(i, 1) = LEFT$(z$, LEN(z$) / 2): tasten$(i, 2) = RIGHT$(z$, LEN(z$) / 2)
NEXT i
CLS
alt = -1
nr = 1
DO
a = INP(&H60)
IF a <> alt THEN PRINT zeichen$(INT(a / 128)); a MOD 128; " "; tasten$(a MOD 128, 1), "   "; : alt = a: nr = nr + 1
IF nr = 6 THEN nr = 0
IF nr = 0 THEN PRINT : nr = 1
LOOP UNTIL INKEY$ = CHR$(27)
END

DATA ESCESC,1!,22,3ı,4$,5%,6&,7/,8(,9),0=,·?,Ô`,BSBS,TABTAB,qQ,wW,eE,rR,tT
DATA zZ,uU,iI,oO,pP,Åö,+*,RETRET,STRGSTRG,aA,sS,dD,fF,gG,hH,jJ,kK,lL,îô,Ñé
DATA "^¯","SHIFT lSHIFT l","#'",yY,xX,cC,vV,bB,nN,mM,",;",".:",-_
DATA "SHIFT rSHIFT r","",ALTALT,"( )( )",SFSF,F1F1,F2F2,F3F3,F4F4,F5F5,F6F6
DATA F7F7,F8F8,F9F9,F10F10,""

fehler: RESUME NEXT

FUNCTION bin$ (zahl)
z$ = OCT$(zahl)
FOR i = 1 TO LEN(z$)
SELECT CASE MID$(z$, i, 1)
CASE "0": z2$ = z2$ + "000"
CASE "1": z2$ = z2$ + "001"
CASE "2": z2$ = z2$ + "010"
CASE "3": z2$ = z2$ + "011"
CASE "4": z2$ = z2$ + "100"
CASE "5": z2$ = z2$ + "101"
CASE "6": z2$ = z2$ + "110"
CASE "7": z2$ = z2$ + "111"
END SELECT
NEXT i
bin$ = RIGHT$("00000" + z2$, 8)
END FUNCTION

FUNCTION zeichen$ (z)
IF z = 1 THEN zeichen$ = "^" ELSE zeichen$ = "v"
END FUNCTION

