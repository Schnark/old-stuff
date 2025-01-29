DECLARE SUB zeichne ()
DECLARE SUB abbrev ()
DECLARE SUB matrix (u!, v!, w!)
DECLARE SUB zentral ()
DECLARE SUB abbild ()

TYPE strecke
p1 AS INTEGER 'Nr. d. ersten Punktes
p2 AS INTEGER
END TYPE

DIM SHARED pmax, smax
pmax = 9
smax = 16

DIM SHARED strecken(1 TO smax) AS strecke
DIM SHARED sa, sb, sg, ca, cb, cg
DIM SHARED a, b, g
DIM SHARED r, s, t
DIM SHARED aa, pa
DIM SHARED s1, s2 AS INTEGER
DIM SHARED xb(1 TO pmax) AS LONG
DIM SHARED zb(1 TO pmax) AS LONG
DIM w AS INTEGER
DIM x(1 TO pmax), y(1 TO pmax), z(1 TO pmax)

w = 80                                'halbe Kantenl„nge

s1 = 280: s2 = 170                    'Mittelpunkt / Nullpunkt
aa = 350: pa = 5                      'Abstand vom Projektionszentrum / Bildschirm

x(1) = w: y(1) = w: z(1) = -w         'Koordinaten
x(2) = -w: y(2) = w: z(2) = -w
x(3) = -w: y(3) = -w: z(3) = -w
x(4) = w: y(4) = -w: z(4) = -w
FOR i = 5 TO 8
x(i) = x(i - 4)
y(i) = y(i - 4)
z(i) = -z(i - 4)
NEXT i
'FOR i = 9 TO 16
'x(i) = x(i - 8) - 2 * w - 3
'y(i) = y(i - 8) - 2 * w - 3
'z(i) = z(i - 8) - 2 * w - 3
'NEXT i
x(9) = 0: y(9) = 0: z(9) = 2 * w

FOR i = 1 TO smax
READ strecken(i).p1
READ strecken(i).p2
NEXT i

a = 0: b = 0: g = 0
n = 0

SCREEN 9, , 1, 0                    '640*350
akt = 1
ON ERROR GOTO fehler

DO
taste$ = INKEY$
SELECT CASE taste$
CASE CHR$(0) + CHR$(75): a = a + .05
CASE CHR$(0) + CHR$(77): a = a - .05
CASE CHR$(0) + CHR$(72): b = b - .05
CASE CHR$(0) + CHR$(80): b = b + .05
END SELECT

           ' +  -          Drehung
a = a + .05' <-->
           '^  -
b = b + .05'|
           'v +
'g = a + b
abbrev

FOR i = 1 TO pmax
matrix x(i), y(i), z(i)
zentral                      'Zentralansicht
xb(i) = INT(r + .5)
'yb(i) = INT(s + .5)
zb(i) = INT(t + .5)
NEXT i
'aa = aa + 1: pa = pa + 1    'Abstand vom Projektionszentrum / Bildschirm
CLS
abbild

SCREEN 9, , 1 - akt, akt    'Flip
akt = 1 - akt
LOOP UNTIL taste$ = CHR$(27)

SCREEN 0
WIDTH 80, 25
COLOR 7, 0
MaxCol = 80
CLS
END

DATA 1,2  ,2,3,   3,4,  4,1  ,5,6,  6,7,   7,8,   8,5,  1,5,  2,6,  3,7,  4,8
'DATA 9,10 ,10,11,   11,12,  12,9  ,13,14,  14,15,   15,16,   16,13,  9,13,  10,14,  11,15,  12,16
DATA 5,9,   6,9,   7,9,   8,9

fehler: IF ERR = 6 THEN RESUME NEXT

SUB abbild
FOR i = 1 TO pmax
xb(i) = INT(1.2 * (s1 - xb(i)) + .5)
zb(i) = s2 - zb(i)
NEXT i
zeichne
END SUB

SUB abbrev
sa = SIN(a): sb = SIN(b): sg = SIN(g)
ca = COS(a): cb = COS(b): cg = COS(g)
END SUB

SUB matrix (u, v, w)
r = (cg * ca - sg * cb * sa) * u - (cg * sa + sg * cb * ca) * v + sg * sb * w
s = (sg * ca + cg * cb * sa) * u + (cg * cb * ca - sg * sa) * v - cg * sb * w
t = sb * sa * u + sb * ca * v + cb * w
END SUB

SUB zeichne
FOR i = 1 TO smax
LINE (xb(strecken(i).p1), zb(strecken(i).p1))-(xb(strecken(i).p2), zb(strecken(i).p2))
NEXT i
END SUB

SUB zentral
r = r * (aa - pa) / (aa + s)
t = t * (aa - pa) / (aa + s)
END SUB

