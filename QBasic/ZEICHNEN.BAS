DECLARE SUB kartes (ymin!, ymax!, xmin!, xmax!, maxdif!, punkt!)
DECLARE SUB param (x0!, y0!, start!, ende!, schritt!, maxdif!, punkt!)
DECLARE FUNCTION funkxpar# (t#)
DECLARE FUNCTION funkypar# (t#)
DECLARE SUB polar (x0!, y0!, startwinkel!, endwinkel!, schritt!, maxdif!, punkt!)
DECLARE FUNCTION polfunk# (x#)
DECLARE SUB zeige (xy!, stelle!, punkt!, farbe!, zahl!)
DECLARE SUB achse (xy!, farbe!)
DECLARE FUNCTION funk# (x#)

'CLS
DIM SHARED ymax, ymin, xmax, xmin, y#
ON ERROR GOTO fehler
GOTO weiter
fehler: y# = 10000
RESUME NEXT

weiter:
CONST maxx = 640
CONST maxy = 480

punkt = 0
ymax = 1
ymin = -1
xmax = 4
xmin = -4
maxdif = 30

streckx = (xmax - xmin) / maxx
strecky = -maxy / (ymax - ymin)
SCREEN 12
DIM SHARED m
m = SQR(2)
achse 1, 4
achse 0, 4

'kartes ymin, ymax, xmin, xmax, maxdif, punkt
' y=funk(x)
'polar -xmin / streckx, -strecky * ymax, 0, 6.3, .01, maxdif, punkt
' r=polfunk(p)
param -xmin / streckx, -strecky * ymax, -10, 10, .1, maxdif, punkt
' x=funkxpar(t); y=funkypar(t)

'zeige 0, 1, 1, 1, 1
'zeige 1, 1, 1, 1, 1
'zeige 0, 2, 1, 1, 1
'zeige 1, -2, 1, 1, 1
'zeige 0, -3, 1, 1, 1
SLEEP
  SCREEN 0
  WIDTH 80, 25
  COLOR 7, 0
  MaxCol = 80
  CLS

SUB achse (xy, farbe)
strecky = -maxy / (ymax - ymin)
streckx = (xmax - xmin) / maxx

IF xy = 0 THEN
LINE (0, -strecky * ymax)-(maxx, -strecky * ymax), farbe    '4
ELSE
LINE (-xmin / streckx, 0)-(-xmin / streckx, maxy), farbe
END IF
END SUB

FUNCTION funk# (x#)
'y# = ATN(x# / SQR(1 - x# ^ 2))
'y# = SIN(x#) + SIN(x# ^ 2) + SIN(x# ^ 3)
y# = SIN(x#) * SIN(100 * x#)
'y# = COS(x# ^ 3) * (100 + x#) / 3 + TAN(x#) / 2 + 50 * x# ^ 2 * SIN(x#)
'y# = SIN(x#) / x# ^ 2 + COS(x# ^ 2 + x#) / x# ^ 3 + TAN(x# ^ 2 + x# ^ 3) / x# ^ 4
funk# = y#
END FUNCTION

FUNCTION funkxpar# (t#)
'y# = t# - 1.5 * SIN(t#)'Trochoide
'y# = 4 * COS(t#) - COS(4 * t#)'Epizykloide
'y# = SIN(t#)'Kreis
y# = COS(t#) * COS(10 * t#)
'y# = (m + 1) * COS(t#) - COS(t#) * COS(m * t#) + SIN(t#) * SIN(m * t#)
funkxpar# = y#
END FUNCTION

FUNCTION funkypar# (t#)
'y# = 1 - 1.5 * COS(t#)'Trochoide
'y# = 4 * SIN(t#) - SIN(4 * t#)'Epizykloide
'y# = COS(t#)'Kreis
y# = SIN(t#) * SIN(5 * t#)
'y# = (m + 1) * SIN(t#) - SIN(t#) * COS(m * t#) - SIN(m * t#) * COS(t#)
funkypar# = y#
END FUNCTION

SUB kartes (ymin, ymax, xmin, xmax, maxdif, punkt)
strecky = -maxy / (ymax - ymin)
streckx = (xmax - xmin) / maxx
maxdif = ABS(strecky * maxdif)
alt = strecky * (funk(1 * xmin) - ymax)
IF punkt = 0 THEN LINE (0, 0)-(0, alt), 0
FOR i% = 0 TO maxx
alt = wert
wert = strecky * (funk(i% * streckx + xmin) - ymax)
IF punkt = 1 OR ABS(alt - wert) > maxdif THEN
        PSET (i%, wert)
ELSE
        LINE STEP(0, 0)-(i%, wert)
END IF
NEXT i%
END SUB

SUB param (x0, y0, start, ende, schritt, maxdif, punkt)
strecky = -maxy / (ymax - ymin)
streckx = (xmax - xmin) / maxx
maxdif = maxdif * maxdif

pxalt = funkxpar#(1 * start) / streckx
pyalt = funkypar#(1 * start) * strecky
IF punkt = 0 THEN LINE (x0 + pxalt, y0 + pyalt)-(x0 + pxalt, y0 + pyalt), 0
FOR i# = start TO ende STEP schritt
px = funkxpar#(i#) / streckx
py = funkypar#(i#) * strecky
IF punkt = 1 OR (pxalt - px) ^ 2 * streckx ^ 2 + (pyalt - py) ^ 2 / strecky ^ 2 > maxdif THEN
        PSET (x0 + px, y0 + py)
ELSE
        LINE STEP(0, 0)-(x0 + px, y0 + py)
END IF
pxalt = px: pyalt = py
NEXT i#
END SUB

SUB polar (x0, y0, startwinkel, endwinkel, schritt, maxdif, punkt)
strecky = -maxy / (ymax - ymin)
streckx = (xmax - xmin) / maxx
maxdif = maxdif * maxdif

wert# = polfunk#(1 * startwinkel)
pxalt = wert# * COS(startwinkel) / streckx
pyalt = wert# * SIN(startwinkel) * strecky
IF punkt = 0 THEN LINE (x0 + pxalt, y0 + pyalt)-(x0 + pxalt, y0 + pyalt), 0
FOR i# = startwinkel TO endwinkel STEP schritt
wert# = polfunk#(i#)
px = wert# * COS(i#) / streckx
py = wert# * SIN(i#) * strecky
IF punkt = 1 OR (pxalt - px) ^ 2 * streckx ^ 2 + (pyalt - py) ^ 2 / strecky ^ 2 > maxdif THEN
        PSET (x0 + px, y0 + py)
ELSE
        LINE STEP(0, 0)-(x0 + px, y0 + py)
END IF
pxalt = px: pyalt = py
NEXT i#
END SUB

FUNCTION polfunk# (x#)
'y# = 1 / (1 - COS(x#))
'y# = 1 / (1 + 2 * COS(x#) * (1 + (1 / TAN(x#)) ^ 2))
'y# = COS(2 * x#) * x# ^ 2 + SIN(x# - x# ^ 2)
y# = SIN(x#) * 3 * SIN(5 * x#)
'y# = 2 'Kreis
'y# = x# / 10  'Archimedische Spirale
'y# = (6 * SIN(x#) * COS(x#)) / ((SIN(x#)) ^ 3 + (COS(x#)) ^ 3) 'kart. Blatt
'y# = -2 * COS(2 * x#) / COS(x#)'Strophoide
'y# = SQR(2 * COS(2 * x#)) 'Lemniskate
'y# = (1 - COS(x#))'Kardioide
'y# = 2 / x# 'Hyperbolische Spirale
polfunk# = y#
END FUNCTION

SUB zeige (xy, stelle, punkt, farbe, zahl)
strecky = -maxy / (ymax - ymin)
streckx = (xmax - xmin) / maxx
IF xy = 0 THEN
px = (stelle - xmin) / streckx
py = -strecky * ymax
ELSE
px = -xmin / streckx
py = strecky * (stelle - ymax)
END IF

IF punkt = 1 THEN PSET (px, py), farbe

IF zahl = 1 AND px >= 0 AND py >= 0 AND px < maxx AND py < maxy THEN
py = INT(.5 + 30 * py / maxy)
px = INT(.5 + 80 * px / maxx)
text$ = LTRIM$(STR$(stelle))
IF py <= 0 THEN py = 1
IF py > 30 THEN py = 30
IF px <= 0 THEN px = 1
IF px + LEN(text$) > 80 THEN px = 80 - LEN(text$)
LOCATE py, px
PRINT text$
END IF
END SUB

