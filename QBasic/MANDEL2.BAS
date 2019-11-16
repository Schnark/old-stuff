DECLARE SUB rueck (n!)
DECLARE SUB punkt (n!)
DECLARE SUB anzeige ()
DIM SHARED dx: DIM SHARED dy: DIM SHARED yo: DIM SHARED xl:
CLS
INPUT "Konvergenzschritte (ca. 30-100):       ", tiefe
INPUT "Konverenzabstand (Quadrat, ca. 30-100):", grenze
INPUT "Rechter x-Wert:                        ", xr
INPUT "Linker x-Wert:                         ", xl
INPUT "Oberer y-Wert:                         ", yo
INPUT "Unterer x-Wert:                        ", yu
INPUT "Schrittweite (x):                      ", schrittex
INPUT "Schrittweite (y):                      ", schrittey
SCREEN 12
weiter: CLS
dx = (xr - xl) / 640
dy = (yo - yu) / 480
FOR k = 0 TO 640 STEP schrittex
        re = xl + k * dx
        FOR l = 0 TO 480 STEP schrittey
                im = yu + l * dy
                x = 0: y = 0
                n = 0
                DO
                        xalt = x: yalt = y
                        x = xalt * xalt - yalt * yalt + re
                        y = 2 * xalt * yalt + im
                        n = n + 1
                LOOP UNTIL (n > tiefe) OR (x * x + y * y) > grenze
                PSET (k, l), n MOD 16
                taste$ = INKEY$
                IF taste$ = " " THEN GOTO nz
                IF taste$ = CHR$(27) THEN GOTO ende
        NEXT l
nz: NEXT k
ende: SLEEP
KEY(0) ON
ON KEY(1) GOSUB k1
ON KEY(2) GOSUB k2
ON KEY(3) GOSUB k3
ON KEY(11) GOSUB oben
ON KEY(12) GOSUB links
ON KEY(13) GOSUB rechts
ON KEY(14) GOSUB unten
DIM SHARED xb(1 TO 2): DIM SHARED yb(1 TO 2): DIM SHARED farbe(1 TO 2)
xb(1) = 0: yb(1) = schrittey * (1 + INT(20 / schrittey)): xb(2) = 0: yb(2) = yb(1)
farbe(1) = POINT(xb(1), yb(1)): farbe(2) = farbe(1)
p = 1
anzeige
DO
LOOP UNTIL INKEY$ = CHR$(27)
SLEEP
GOTO schluss
k1:
p = 1
RETURN
k2:
p = 2
RETURN
oben:
rueck (p)
IF yb(p) > 20 THEN yb(p) = yb(p) - schrittey
punkt (p)
anzeige
RETURN
unten:
rueck (p)
IF yb(p) <= 480 - schrittey THEN yb(p) = yb(p) + schrittey
punkt (p)
anzeige
RETURN
links:
rueck (p)
IF xb(p) > 0 THEN xb(p) = yb(p) - schrittex
punkt (p)
anzeige
RETURN
rechts:
rueck (p)
IF xb(p) <= 640 - schrittex THEN xb(p) = xb(p) + schrittex
punkt (p)
anzeige
RETURN
k3:
xln = xb(1): xrn = xb(2)
IF xb(1) > xb(2) THEN xln = xb(2): xrn = xb(1)
yon = yb(2): yun = yb(1)
IF yb(2) > yb(1) THEN yon = yb(1): yun = yb(2)
xln = xl + xln * dx
xrn = xl + xrn * dx
yon = yo + yon * dy
yun = yo + yun * dy
xl = xln: xr = xrn: yo = yon: yu = yun
GOTO weiter
RETURN
schluss: SLEEP
  SCREEN 0
  WIDTH 80, 25
  COLOR 7, 0
  MaxCol = 80
  CLS

SUB anzeige
LOCATE 1, 1
text1$ = "x1= " + LTRIM$(STR$(xl + xb(1) * dx)) + " y1= " + LTRIM$(STR$(yo + yb(1) * dy))
text2$ = "x2= " + LTRIM$(STR$(xl + xb(2) * dx)) + " y2= " + LTRIM$(STR$(yo + yb(2) * dy))
text1$ = text1$ + SPACE$(40 - LEN(text1$))
text2$ = text2$ + SPACE$(40 - LEN(text2$))
PRINT text1$ + text2$;
END SUB

SUB punkt (n)
farbe(n) = POINT(xb(n), yb(n))
PSET (xb(n), yb(n)), 4
END SUB

SUB rueck (n)
PSET (xb(n), yb(n)), farbe(n)
END SUB

