DEFINT A-Z
DECLARE SUB links (x, y)
DECLARE SUB rechts (x, y)
DECLARE SUB zeige (x, y)
DECLARE SUB versteck (x, y)
DECLARE SUB bewege (dx, dy, x, y)
DIM SHARED maus(-8 TO 7, -8 TO 7)
DIM SHARED hgrund(-8 TO 7, -8 TO 7)
DIM SHARED sicht
SCREEN 9, , sicht, sicht        '640*350
FOR i = -8 TO 7
        FOR j = -8 TO 7
                maus(i, j) = 17
                'IF i = j THEN maus(i, j) = 5
                'IF i + j = -1 THEN maus(i, j) = 5
        NEXT j
NEXT i
FOR i = -7 TO 0: maus(i, -7) = 0: maus(-7, i) = 0: NEXT i
FOR i = -6 TO -1: maus(i, -7 - i) = 0: NEXT i
FOR i = -1 TO 6: maus(i, i - 3) = 0: NEXT i
FOR i = -4 TO 3: maus(i, i + 3) = 0: NEXT i
maus(5, 4) = 0: maus(4, 5) = 0
FOR i = -6 TO -2
FOR j = -6 TO -2
IF i + j <= -8 THEN maus(i, j) = 15
NEXT j
NEXT i
FOR i = -4 TO 3
FOR j = 1 TO 5
maus(i, i + j - 3) = 15
NEXT j
NEXT i
maus(4, 2) = 15: maus(4, 3) = 15: maus(4, 4) = 15: maus(5, 3) = 15
'     -8 -7 -6 -5 -4 -3 -2 -1  0  1  2  3  4  5  6  7
'      -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -
'-8  |
'-7  |    +  +  +  +  +  +  +  +
'-6  |    +  .  .  .  .  .  +
'-5  |    +  .  .  .  .  +
'-4  |    +  .  .  .  .  .  +
'-3  |    +  .  .  .  .  .  .  +
'-2  |    +  .  +  .  .  .  .  .  +
'-1  |    +  +     +  .  .  .  .  .  +
' 0  |    +           +  .  .  .  .  .  +
' 1  |                   +  .  .  .  .  .  +
' 2  |                      +  .  .  .  .  .  +
' 3  |                         +  .  .  .  .  .  +
' 4  |                            +  .  .  .  +
' 5  |                               +  .  +
' 6  |                                  +
' 7  |                                 

x = 320: y = 175
LINE (0, 0)-(640, 350), 15, BF
CIRCLE (106, 100), 75, 1
LINE (138, 35)-(288, 165), 1, B
PAINT (160, 100), 2, 1

zeige x, y

DO
  DO
    a$ = INKEY$
    ein$ = ein$ + a$
  LOOP UNTIL a$ = ""
 
  DO WHILE ein$ <> ""
    B$ = LEFT$(ein$, 1)
    ein$ = MID$(ein$, 2)
    IF B$ = CHR$(0) THEN s = 1: B$ = LEFT$(ein$, 1): ein$ = MID$(ein$, 2)
    IF B$ = CHR$(27) THEN ende = 1
    IF s = 1 THEN
      SELECT CASE ASC(B$)
        CASE 75: dx = dx - 1
        CASE 77: dx = dx + 1
        CASE 72: dy = dy - 1
        CASE 80: dy = dy + 1
        CASE 133: l = l + 1
        CASE 134: r = r + 1
      END SELECT
      s = 0
    END IF
  LOOP
  IF dx <> 0 OR dy <> 0 THEN bewege dx, dy, x, y
  dx = 0: dy = 0
  IF l <> 0 THEN links x, y
  IF r <> 0 THEN rechts x, y
  l = 0: r = 0
LOOP UNTIL ende = 1

SCREEN 0

SUB bewege (dx, dy, x, y)
PCOPY sicht, 1 - sicht
SCREEN 9, , 1 - sicht, sicht
versteck x, y
x = x + dx: y = y + dy
zeige x, y
SCREEN 9, , sicht, 1 - sicht
sicht = 1 - sicht
END SUB

SUB links (x, y)
PCOPY sicht, 1 - sicht
SCREEN 9, , 1 - sicht, sicht
versteck x, y
CIRCLE (x - 7, y - 7), 5, 1
zeige x, y
SCREEN 9, , sicht, 1 - sicht
sicht = 1 - sicht
END SUB

SUB rechts (x, y)
PCOPY sicht, 1 - sicht
SCREEN 9, , 1 - sicht, sicht
versteck x, y
CIRCLE (x - 7, y - 7), 5, 2
zeige x, y
SCREEN 9, , sicht, 1 - sicht
sicht = 1 - sicht
END SUB

SUB versteck (x, y)
FOR i = -8 TO 7
        FOR j = -8 TO 7
                PSET (x + i, y + j), hgrund(i, j)
        NEXT j
NEXT i
END SUB

SUB zeige (x, y)
FOR i = -8 TO 7
        FOR j = -8 TO 7
                hgrund(i, j) = POINT(i + x, j + y)
                farbe = maus(i, j)
                IF farbe < 17 THEN PSET (i + x, j + y), farbe
        NEXT j
NEXT i
END SUB

