DEFINT A-Z
DECLARE SUB RGB (farbe, r, g, b)
SCREEN 12
LINE (0, 0)-(640, 480), 1, BF

FOR gruen = 0 TO 63 STEP 5
FOR rot = 0 TO 63 STEP 5
FOR blau = 0 TO 63 STEP 5
RGB 1, rot, gruen, blau
LOCATE 1, 1: PRINT rot, gruen, blau
FOR i = 1 TO 100: NEXT
NEXT blau
NEXT rot
NEXT gruen


BEEP
SCREEN 9
FOR j = 0 TO 63
PALETTE 1, j
LINE (0, 0)-(640, 480), 1, BF
SLEEP
NEXT j
END

SUB RGB (farbe, r, g, b)
PALETTE farbe, r + 256 * g + 65536 * b
END SUB

