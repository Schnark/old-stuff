DECLARE FUNCTION bin$ (zahl!)
DECLARE SUB ton (z!, davor!)
CLS
PLAY "MSL16"
alt = -1
nr = 1
DO
a = INP(&H3F8)
IF a <> alt THEN PRINT a, bin$(a); : ton a, alt: alt = a: nr = nr + 1
IF nr = 4 THEN nr = 0
IF nr = 0 THEN PRINT : nr = 1
LOOP UNTIL INKEY$ <> ""

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

SUB ton (z, davor)
DIM musik$
'IF davor = 0 THEN                    'Taste
SELECT CASE z
CASE 96: musik$ = "O3C"              'links
CASE 80: musik$ = "O1C"              'rechts
CASE 32: musik$ = "O2C"             'mitte
CASE 112: musik$ = "MLO3CO1CMS"             'links + rechts
END SELECT
'END IF
PLAY "x" + VARPTR$(musik$)
'         76 0 -x
'67 -x 0           64 x 0
'         64 0 x
END SUB


