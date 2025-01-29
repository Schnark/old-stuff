DECLARE SUB zeige ()
DECLARE SUB bewege (dx!, dy!)
DIM SHARED max
max = 16
DIM SHARED maus(max, max)
DIM SHARED x, y

DIM SHARED Box%(1 TO 210)

SCREEN 12'640*480
FOR i = 0 TO max
maus(i, i) = 5
maus(max - i, i) = 5
NEXT i
x = 320: y = 240
zeige
x1 = x - max / 2
y1 = y - max / 2
x2 = x1 + 16
y2 = y1 + 16
GET (x1, y1)-(x2, y2), Box%

LINE (110, 70)-(190, 120), , B
LINE (0, 0)-(320, 200), 3, , &HFF00
DO
DO
taste$ = INKEY$
LOOP UNTIL taste$ <> ""
IF ASC(taste$) = 0 THEN
SELECT CASE ASC(RIGHT$(taste$, 1))
CASE 75: bewege -1, 0
CASE 77: bewege 1, 0
CASE 72: bewege 0, -1
CASE 80: bewege 0, 1
END SELECT
END IF
LOOP UNTIL taste$ = CHR$(27)
  SCREEN 0
  WIDTH 80, 25
  COLOR 7, 0
  MaxCol = 80
  CLS
END

SUB bewege (dx, dy)
x1 = x - max / 2 + i
y1 = y - max / 2 + j
PUT (x1, y1), Box%, XOR
x = x + dx: y = y + dy
x1 = x - max / 2 + i
y1 = y - max / 2 + j
PUT (x1, y1), Box%
END SUB

SUB zeige
FOR i = 0 TO max
        FOR j = 0 TO max
                x1 = x - max / 2 + i
                y1 = y - max / 2 + j
                IF maus(i, j) THEN PSET (x1, y1), maus(i, j)
        NEXT j
NEXT i
END SUB

