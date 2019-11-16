CLS
INPUT "Konvergenzschritte (ca. 30-100):       ", tiefe
INPUT "Konverenzabstand (Quadrat, ca. 30-100):", grenze
INPUT "Rechter x-Wert:                        ", xr
INPUT "Linker x-Wert:                         ", xl
INPUT "Oberer y-Wert:                         ", yo
INPUT "Unterer x-Wert:                        ", yu
INPUT "Schrittweite (x):                      ", schrittex
INPUT "Schrittweite (y):                      ", schrittey
INPUT "Startwert (reel):                      ", cr
INPUT "Startwert (imagin„r):                  ", ci
SCREEN 12: CLS
dx = (xr - xl) / 640
dy = (yo - yu) / 480
FOR k = 0 TO 640 STEP schrittex
        re = xl + k * dx
        FOR l = 0 TO 480 STEP schrittey
                im = yu + l * dy
                x = re: y = im
                n = 0
                DO
                        xalt = x: yalt = y
                        x = xalt * xalt - yalt * yalt + cr
                        y = 2 * xalt * yalt + ci
                        n = n + 1
                LOOP UNTIL (n > tiefe) OR (x * x + y * y) > grenze
                PSET (k, l), n MOD 16
                IF INKEY$ = CHR$(27) THEN GOTO ende
        NEXT l
NEXT k
SLEEP
ende:  SCREEN 0
  WIDTH 80, 25
  COLOR 7, 0
  MaxCol = 80
  CLS

