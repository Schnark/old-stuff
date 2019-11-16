DECLARE FUNCTION bin$ (zahl!)
FOR port = &H200 TO &H2FF
 CLS
 PRINT HEX$(port)
 alt = -1
 nr = 1
 DO
  a = INP(port)
  IF a <> alt THEN PRINT a, bin$(a); : alt = a: nr = nr + 1
  IF nr = 4 THEN nr = 0
  IF nr = 0 THEN PRINT : nr = 1
 LOOP UNTIL INKEY$ = CHR$(27)
NEXT port

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

