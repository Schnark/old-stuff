DECLARE SUB trans2d (x1!, y1!, xs!, ys!)
'----------------SUBs--------------------------------------------
DECLARE SUB trans (x1!, y1!, z1!, x2!, y2!, z2!)
  'Verschiebt P1 Richtung P2, sodass y1 positiv
DECLARE SUB schiebe (dx!, dy!, dz!)
DECLARE SUB dreh (achse!)
DECLARE FUNCTION eingabe! (ein$)
DECLARE SUB mult ()
  'Multipliziert alle Punkte mit T, fhrt Transformation durch
DECLARE SUB zeichnen ()
  'zeichnet alle Fl„chen
DECLARE SUB malen (i!)
  'zeichnet Dreieck Nr. i
DECLARE FUNCTION abstand! (i!)
  'berechnet Abstand einer Fl„che zum Ursprung
DECLARE SUB d2 (x!, y!, z!)
  'transformiert (x,y,z) in 2 Dimensionen
'-----------------------------------------------------------------

'---------TYPEN----------
TYPE punkt   '3-dim. Punkt
x AS SINGLE
y AS SINGLE
z AS SINGLE
END TYPE

TYPE flaeche  'Dreieck
p1 AS INTEGER
p2 AS INTEGER
p3 AS INTEGER
farbe   AS INTEGER
END TYPE
'------------------------

'-----KONSTANTEN----------------
CONST maxflaechen = 12
CONST maxpunkte = 8
CONST x0 = 320         'Ursprung d.
CONST y0 = 175         'Bildschirms
CONST MAXx = 640
CONST MAXy = 350
CONST FD = 10000
CONST alpha = 1
CONST k = .5
CONST aa = 350
CONST pa = 5
CONST DD = 5
'CONST xb = 30
'CONST yb = 30
'CONST zb = -10
'----------------------------------

'-------GLOB. VARIABLEN---------------------------------
DIM SHARED T(1 TO 4, 1 TO 4)                  'Transformationsmatrix
DIM SHARED welt(1 TO maxflaechen) AS flaeche  'alle Fl„chen
DIM SHARED punkte(1 TO maxpunkte) AS punkt    'alle Punkte
ON ERROR GOTO fehler
punkte(1).x = 80: punkte(1).y = 80: punkte(1).z = -80         'Koordinaten
punkte(2).x = -80: punkte(2).y = 80: punkte(2).z = -80
punkte(3).x = -80: punkte(3).y = -80: punkte(3).z = -80
punkte(4).x = 80: punkte(4).y = -80: punkte(4).z = -80
FOR i = 5 TO 8
punkte(i).x = punkte(i - 4).x
punkte(i).y = punkte(i - 4).y
punkte(i).z = -punkte(i - 4).z
NEXT i
FOR i = 1 TO 8
'punkte(i).x = punkte(i).x + 90
punkte(i).y = punkte(i).y + 90
'punkte(i).z = punkte(i).z + 90
NEXT i

FOR i = 1 TO maxflaechen           'Fl„chen
READ welt(i).p1
READ welt(i).p2
READ welt(i).p3
READ welt(i).farbe
NEXT i

SCREEN 9, , 1, 0
akt = 1

DO
 a$ = INKEY$
 dreh eingabe(a$)
 mult
 CLS
 zeichnen

 SCREEN 9, , 1 - akt, akt    'Flip
 akt = 1 - akt
LOOP UNTIL a$ = CHR$(27)

SCREEN 0

'       p1    p2  p3   farbe
DATA     1,    2,  3,  1
DATA     3,    4,  1,  1
DATA     4,    8,  5,  4
DATA     5,    1,  4,  4
DATA     1,    5,  6,  2
DATA     6,    2,  1,  2
DATA     3,    7,  6,  14
DATA     6,    2,  3,  14
DATA     3,    4,  8,  15
DATA     8,    7,  3,  15
DATA     5,    6,  7,  6
DATA     7,    8,  5,  6
fehler:
IF ERR = 6 OR ERR = 11 THEN RESUME NEXT ELSE ERROR ERR

FUNCTION abstand (i)    '3 Punkte -> Ebene in Parameterdarstellung
x1 = punkte(welt(i).p1).x         '-> Hesse-Form -> Abstand
y1 = punkte(welt(i).p1).y
z1 = punkte(welt(i).p1).z
x2 = punkte(welt(i).p2).x
y2 = punkte(welt(i).p2).y
z2 = punkte(welt(i).p2).z
x3 = punkte(welt(i).p3).x
y3 = punkte(welt(i).p3).y
z3 = punkte(welt(i).p3).z
bx = x2 - x1: cx = x3 - x1
by = y2 - y1: cy = y3 - y1
bz = z2 - z1: cz = z3 - z1

nx = by * cz - bz * cy
ny = bz * cx - bx * cz
nz = bx * cy - by * cx
na = nx * x1 + ny * y1 + nz * z1
n = SQR(nx ^ 2 + ny ^ 2 + nz ^ 2)
abstand = ABS((nx * xb + ny * yb + nz * zb + na) / n)
END FUNCTION

SUB d2 (x, y, z)
'xbs = x0 + x * FD / (FD - y)
'ybs = y0 - z * FD / (FD - z)
'xbs = x0 + x + COS(alpha) * k * y
'ybs = y0 - z - SIN(alpha) * k * y
'xbs = x0 + x * (aa - pa) / (aa + y)
'ybs = y0 + z * (aa - pa) / (aa + y)
xbs = x0 + DD * x / y
ybs = y0 - DD * z / y
x = xbs
y = ybs
END SUB

SUB dreh (achse)
d = .2
IF achse < 0 THEN achse = -achse: d = -d
SELECT CASE achse
CASE 1 'x
T(1, 1) = 1: T(4, 4) = 1: T(2, 2) = COS(d): T(2, 3) = SIN(d): T(3, 2) = -SIN(d): T(3, 3) = COS(d)
CASE 2 'y
T(1, 1) = COS(d): T(4, 4) = 1: T(2, 2) = 1: T(1, 3) = -SIN(d): T(3, 1) = SIN(d): T(3, 3) = COS(d)
CASE 3 'z
T(1, 1) = COS(d): T(4, 4) = 1: T(2, 2) = COS(d): T(1, 2) = SIN(d): T(2, 1) = -SIN(d): T(3, 3) = 1
CASE ELSE
T(1, 1) = 1: T(4, 4) = 1: T(2, 2) = 1: T(3, 3) = 1: T(1, 3) = 0: T(2, 3) = 0: T(1, 2) = 0: T(3, 1) = 0: T(3, 2) = 0: T(2, 1) = 0
END SELECT
END SUB

FUNCTION eingabe (ein$)
SELECT CASE ein$
CASE CHR$(0) + CHR$(75): e = -3         'links
CASE CHR$(0) + CHR$(77): e = 3          'rechts
CASE CHR$(0) + CHR$(72): schiebe 0, 5, 0'e = 2          'oben
CASE CHR$(0) + CHR$(80): schiebe 0, -2.5, 0'e = -2         'unten
CASE CHR$(0) + CHR$(73): e = -1         'B. oben
CASE CHR$(0) + CHR$(81): e = 1          'B. unten
CASE ELSE: e = 0
END SELECT
eingabe = e
END FUNCTION

SUB malen (i)
x1 = punkte(welt(i).p1).x
y1 = punkte(welt(i).p1).y
z1 = punkte(welt(i).p1).z
x2 = punkte(welt(i).p2).x
y2 = punkte(welt(i).p2).y
z2 = punkte(welt(i).p2).z
x3 = punkte(welt(i).p3).x
y3 = punkte(welt(i).p3).y
z3 = punkte(welt(i).p3).z
farbe = welt(i).farbe

IF y1 > 0 THEN
  IF y2 <= 0 THEN
    IF y3 <= 0 THEN
      trans x2, y2, z2, x1, y1, z1   'y1>0 y2,y3<=0
      trans x3, y3, z3, x1, y1, z1
    ELSE
      x = x2: y = y2: z = z2         'y1,y3>0 y2<=0
      trans x, y, z, x1, y1, z1
      trans x2, y2, z2, x3, y3, z3   '1-_-2-3
      n = 1
    END IF
  ELSE
    IF y3 <= 0 THEN
      x = x3: y = y3: z = z3         'y1,y2>0 y3<=0
      trans x, y, z, x1, y1, z1
      trans x3, y3, z3, x2, y2, z2   '1-_-3-2
      n = 2
    END IF
  END IF
ELSE
  IF y2 <= 0 THEN
    IF y3 <= 0 THEN EXIT SUB         'y1,y2,y3<=0
    trans x1, y1, z1, x3, y3, z3     'y3>0 y1,y2<=0
    trans x2, y2, z2, x3, y3, z3
  ELSE
    IF y3 <= 0 THEN
      trans x1, y1, z1, x2, y2, z2   'y2>0 y1,y3<=0
      trans x3, y3, z3, x2, y2, z2
    ELSE
      x = x1: y = y1: z = z1         'y2,y3>0 y1<=0
      trans x, y, z, x2, y2, z2
      trans x1, y1, z1, x3, y3, z3   '1-3-2-_
      n = 3
    END IF
  END IF
END IF
d2 x1, y1, z1
d2 x2, y2, z2
d2 x3, y3, z3
d2 sx, sy, sz

IF n > 0 THEN
  d2 x, y, z
  SELECT CASE n
  CASE 1
    LINE (x1, y1)-(x, y), farbe
    LINE (x, y)-(x2, y2), farbe
    LINE (x2, y2)-(x3, y3), farbe
    LINE (x3, y3)-(x1, y1), farbe
  CASE 2
    LINE (x1, y1)-(x, y), farbe
    LINE (x, y)-(x3, y3), farbe
    LINE (x3, y3)-(x2, y2), farbe
    LINE (x2, y2)-(x1, y1), farbe
  CASE 3
    LINE (x1, y1)-(x3, y3), farbe
    LINE (x3, y3)-(x2, y2), farbe
    LINE (x2, y2)-(x, y), farbe
    LINE (x, y)-(x1, y1), farbe
  END SELECT
ELSE
  LINE (x1, y1)-(x2, y2), farbe
  LINE (x2, y2)-(x3, y3), farbe
  LINE (x3, y3)-(x1, y1), farbe
END IF
sx = (x1 + x2 + x3) / 3: sy = (y1 + y2 + y3) / 3
IF sx < 0 OR sx > MAXx OR sy < 0 OR sy > MAXy THEN trans2d x1, y1, sx, sy
'CIRCLE (sx, sy), 2, farbe
PAINT (sx, sy), farbe, farbe
END SUB

SUB mult
FOR i = 1 TO maxpunkte
x = punkte(i).x: y = punkte(i).y: z = punkte(i).z
punkte(i).x = x * T(1, 1) + y * T(2, 1) + z * T(3, 1) + T(4, 1)
punkte(i).y = x * T(1, 2) + y * T(2, 2) + z * T(3, 2) + T(4, 2)
punkte(i).z = x * T(1, 3) + y * T(2, 3) + z * T(3, 3) + T(4, 3)
NEXT i
END SUB

SUB schiebe (dx, dy, dz)
FOR i = 1 TO maxpunkte
 punkte(i).x = punkte(i).x + dx
 punkte(i).y = punkte(i).y + dy
 punkte(i).z = punkte(i).z + dz
NEXT i
END SUB

SUB trans (x1, y1, z1, x2, y2, z2)
dif = DD / 100
IF dif >= y2 THEN dif = dif / 3
x = (dif - y1) * (x2 - x1) / (y2 - y1) + x1
y = dif
z = (dif - z) * (z2 - z1) / (y2 - y1) + z1
x1 = x: y1 = y: z1 = z
END SUB

SUB trans2d (x1, y1, xs, ys)
IF xs < 0 THEN xsneu = 1
IF xs > MAXx THEN xsneu = MAXx - 1
IF xsneu <> 0 THEN ysneu = (ys - y1) * (xsneu - xs) / (xs - x1) + y1
IF ys < 0 THEN ysneu = 1
IF ys > MAXy THEN ysneu = MAXy - 1
IF ysneu <> 0 THEN xsneu = (xs - x1) * (ysneu - ys) / (ys - y1) + x1
xs = xsneu
ys = ysneu
END SUB

SUB zeichnen
DIM d(1 TO maxflaechen)
max = 0
FOR i = 1 TO maxflaechen
d(i) = abstand(i)              'Abstand aller Fl„chen vom Ursprung=Betrachter
IF d(i) > max THEN max = d(i)  'gr”áter Abstand
NEXT i
neumax = 0
FOR i = 1 TO maxflaechen
  FOR j = 1 TO maxflaechen
    IF d(j) = max THEN malen j: d(j) = 0: max = max + 1 'Maximum gefunden ->
                                                        'zeichnen, nur 1 pro
                                                        'Durchlauf
    IF d(j) > neumax THEN neumax = d(j)         'neues Maximum
  NEXT j
  max = neumax
  neumax = 0
NEXT i
END SUB

