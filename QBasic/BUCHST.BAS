DECLARE FUNCTION laenge! (text$, f%)
DECLARE SUB schreibe (xpos%, ypos%, text$, f%, u%)
DIM SHARED ll(32 TO 128)
DIM SHARED bs$(32 TO 128)
FOR i = 32 TO 128: ll(i) = 8: NEXT i
bs$(65) = "M+3,-9 M+3,+9 BM-4,-4 R3 BM +3,+4"   'A
bs$(66) = "U9 R4 F2 G2 NL4 F2 D1 G2 L4 BR8"     'B
bs$(67) = "BM+6,-9 L3 G3 D3 F3 R3 BR2"          'C
bs$(68) = "U9 R3 F3 D3 G3 L3 BR8"               'D
bs$(69) = "U9 NR5 BD4 NR3 BD5 R5 BR3"           'E
bs$(70) = "U9 NR5 BD4 NR3 BD5 BR8"              'F
bs$(71) = "BM+6,-9 L3 G3 D3 F3 R3 U3 L2 BR4 BD3"'G
bs$(72) = "U9 BD4 R6 BU4 D9 BR2"                'H
bs$(73) = "BR3 NU9 BR5"                         'I
bs$(74) = "BR6 BU2 NU7 G2 L2 H2 BR8 BD2"        'J
bs$(75) = "U9 BD5 NE5 BE1 F5 BR2"               'K
bs$(76) = "NU9 R5 BR3"                          'L
bs$(77) = "U9 F3 E3 D9 BR2"                     'M
bs$(78) = "U9 M+6,+9 NU9 BR2"                   'N
bs$(79) = "BU2 U5 E2 R2 F2 D5 G2 L2 NH2 BR6"    'O
bs$(80) = "U9 R3 F2 D1 G2 L3 BD4 BR8"           'P
bs$(81) = "BU2 U5 E2 R2 F2 D5 G2 L2 NH2 BR4 NH3 BR2" 'Q
bs$(82) = "U9 R2 F2 D1 G2 L2 F4 BR4"             'R
SCREEN 12
LINE (0, 0)-(300, 300), 15, BF
DRAW "C0"                                  'normal
schreibe 20, 20, "ABCDEFGHIJKLMNOPQR", 0, 0

DRAW "S6"                                  'groá
schreibe 20, 50, "ABCDEFGHIJKLMNOPQR", 0, 0

DRAW "S4 A3"                               'senkrecht
schreibe 20, 70, "ABCDEFGHIJKLMNOPQR", 0, 0

DRAW "A0"                                  'fett
schreibe 40, 70, "ABCDEFGHIJKLMNOPQR", 1, 0

schreibe 40, 85, "ABCDEFGHIJKLMNOPQR", 0, 1    'unterstrichen
SLEEP
SCREEN 0
WIDTH 80, 25

FUNCTION laenge (text$, f%)
l = 0
FOR i = 1 TO LEN(text$)
l = l + ll(ASC(MID$(text$, i, 1)))
NEXT i
IF f% = 1 THEN l = l + LEN(text$)
laenge = l
END FUNCTION

SUB schreibe (xpos%, ypos%, text$, f%, u%)
FOR j = 0 TO f%
 stelle$ = "BM" + STR$(xpos%) + "," + STR$(ypos%)
 DRAW "X" + VARPTR$(stelle$)
 FOR i = 1 TO LEN(text$)
  DRAW "X" + VARPTR$(bs$(ASC(MID$(text$, i, 1))))
  IF f% = 1 THEN DRAW "BR1"
 NEXT i
xpos% = xpos% + 1
NEXT j
IF u% = 1 THEN
 DRAW "X" + VARPTR$(stelle$)
 l$ = "R" + STR$(laenge(text$, f%))
 DRAW "BD2"
 DRAW "X" + VARPTR$(l$)
END IF
END SUB

