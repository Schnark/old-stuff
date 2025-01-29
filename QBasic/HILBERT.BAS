DECLARE SUB move (g%)
DECLARE SUB turn (g%)
DECLARE SUB rek1 (r%, index%)
DECLARE SUB hil (i%)
DECLARE SUB rek2 (r%, index%)
DEFINT A-Z
DIM SHARED x, y, x1, y1
DIM SHARED phi, size
CLS
INPUT "Stufe (1-6) ", stufe
stufe = stufe + 1
delta = 2
FOR i = 2 TO stufe
delta = delta * 2
NEXT i
delta = delta - 1
size = INT(200 / delta)
delta = INT((delta * size) / 2)
phi = 0
SCREEN 12
x = 150 - delta
y = 100 + delta
hil stufe
SLEEP
SCREEN 0
WIDTH 80, 25

SUB hil (i)
IF i = 0 THEN
 turn 2
ELSE
 IF i > 0 THEN
  r = 1
  index = i - 1
 ELSE
  r = -1
  index = i + 1
 END IF
 rek1 r, index
 rek2 r, index
 rek1 r, index
END IF
END SUB

SUB move (g)
phi = phi MOD 4
SELECT CASE phi
CASE 0: x1 = x + g: y1 = y
CASE 1: x1 = x: y1 = y - g
CASE 2: x1 = x - g: y1 = y
CASE 3: x1 = x: y1 = y + g
END SELECT
LINE (2 * x, 2 * y)-(2 * x1, 2 * y1)
x = x1: y = y1
END SUB

SUB rek1 (r, index)
turn r
hil -index
turn r
END SUB

SUB rek2 (r, index)
move size
hil index
turn -r
move size
turn -r
hil index
move size
END SUB

SUB turn (g)
phi = phi + g
END SUB

