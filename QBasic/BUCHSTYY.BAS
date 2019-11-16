DECLARE SUB oeffnen (datei$)
DECLARE FUNCTION lesen$ (z$)
DECLARE SUB schreiben (text$, x%, y%)
DECLARE SUB speichern (datei$)
DECLARE SUB schreibez (z AS STRING, x%, y%)
DEFINT A-Z
DIM SHARED zeichen(0 TO 255) AS STRING * 16
SCREEN 12
'FOR i = 0 TO 255
'zeichen(i) = lesen$(CHR$(i))
'NEXT i
oeffnen "NORMAL.FNT"
CLS
COLOR 4
schreiben "Hallo! Dies ist ein Text zum Testen. (dsjrVTBnbZTbntbn654756$ı&ı/&%ı", 20, 20
PSET (20, 20), 1
COLOR 2
schreiben "Wer ins Ofenrohr schaut, wird schwarz.", 2, 50
COLOR 15
schreiben "îÅîÑîÔÅ†£àå¯a~[}óÎıÃ", 10, 80
'speichern "NORMAL.FNT"
SLEEP
SCREEN 0

FUNCTION lesen$ (z$)
CLS
PRINT z$
FOR y = 0 TO 15
 n = 0
 FOR x = 0 TO 7
  IF POINT(x, y) <> 0 THEN n = 2 * n + 1 ELSE n = 2 * n
 NEXT x
 s$ = s$ + CHR$(n)
NEXT y
lesen$ = s$
END FUNCTION

SUB oeffnen (datei$)
DIM z AS STRING * 1
OPEN datei$ FOR BINARY AS #1
FOR i = 0 TO 255
zz$ = ""
FOR j = 1 TO 16
GET #1, 16 * i + j, z
zz$ = zz$ + z
NEXT j
zeichen(i) = zz$
NEXT i
CLOSE #1
END SUB

SUB schreiben (text$, x, y)
FOR i = 1 TO LEN(text$)
 schreibez MID$(text$, i, 1), x + 8 * i - 8, y
NEXT i
END SUB

SUB schreibez (z AS STRING, x, y)
kette$ = zeichen(ASC(z))
FOR i = -12 TO 3
 zz = ASC(MID$(kette$, 13 + i, 1))
 FOR j = 8 TO 1 STEP -1
  bit = zz MOD 2: zz = INT(zz / 2)
  IF bit = 1 THEN PSET (x + j, y + i)
 NEXT j
NEXT i
END SUB

SUB speichern (datei$)
DIM z AS STRING * 1
OPEN datei$ FOR BINARY AS #1
FOR i = 0 TO 255
FOR j = 1 TO 16
z = MID$(zeichen(i), j, 1)
PUT #1, 16 * i + j, z
NEXT j
NEXT i
CLOSE #1
END SUB

