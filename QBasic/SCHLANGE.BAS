DECLARE SUB setzen (k%)
DECLARE SUB start ()
DEFINT A-Z
CONST g = 10000
DIM SHARED feld(0 TO g - 1, 1 TO 2)
DIM SHARED a, b
RANDOMIZE TIMER
start
farbe = 15
SCREEN 12
FOR i = 0 TO g - 1
PSET (feld(i, 1), feld(i, 2)), farbe
NEXT i
z1 = 0
z2 = g - 1' g - 2
z3 = 0' g - 1
DO
PSET (feld(z1, 1), feld(z1, 2)), 0
z1 = (z1 + 1) MOD g
IF z1 = 0 THEN farbe = 1 + INT(15 * RND)
setzen z2
feld(z3, 1) = feld(z2, 1) + a
feld(z3, 2) = feld(z2, 2) + b
PSET (feld(z3, 1), feld(z3, 2)), farbe
z2 = (z2 + 1) MOD g
z3 = (z3 + 1) MOD g
LOOP UNTIL INKEY$ = CHR$(27)
SCREEN 0
WIDTH 80, 25

SUB setzen (k)
DO
 a = INT(5 * RND) - 2
LOOP UNTIL feld(k, 1) + a < 640 AND feld(k, 1) + a > 0
DO
 b = INT(3 * RND) - 1
LOOP UNTIL feld(k, 2) + b < 480 AND feld(k, 2) + b > 0
END SUB

SUB start
feld(0, 1) = 320 + INT(160 * RND)
feld(0, 2) = 170 + INT(85 * RND)
i = 0
DO
setzen i
i = i + 1
feld(i, 1) = feld(i - 1, 1) + a
feld(i, 2) = feld(i - 1, 2) + b
LOOP UNTIL i = g - 1'-2?
END SUB

