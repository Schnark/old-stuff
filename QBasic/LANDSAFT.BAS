DEFINT A-Z
DIM a(0 TO 128, 0 TO 128)
DEF fnrnd (x) = INT(x * RND) + 1
d = 30: m = 0
RANDOMIZE TIMER
INPUT "Stufe (1-7): ", n

a(0, 0) = fnrnd(30) - 10        'Startwerte
a(128, 0) = fnrnd(30) - 40
a(0, 128) = fnrnd(60) + 50
a(128, 128) = fnrnd(60) - 10

schritt = 128
FOR i = 1 TO n
 schritt = schritt / 2
 y = 0
 DO
  x = schritt
  DO
   a(x, y) = (a(x - schritt, y) + a(x + schritt, y)) / 2 - schritt / 2 + fnrnd(schritt)
   x = x + 2 * schritt
  LOOP UNTIL x = 128 + schritt
  y = y + 2 * schritt
 LOOP UNTIL y > 128
 x = 0
 DO
  y = schritt
  DO
   a(x, y) = (a(x, y - schritt) + a(x, y + schritt)) / 2 - schritt / 2 + 2 * fnrnd(schritt)
   y = y + 2 * schritt
  LOOP UNTIL y > 128
  x = x + schritt
 LOOP UNTIL x > 128
NEXT i

'Maximum und Minimum
h = 0
FOR i = 0 TO 128
 FOR j = 0 TO 128
  IF a(i, j) > h THEN h = a(i, j): xm = i: ym = j
 NEXT j
NEXT i
s = 50
FOR i = 0 TO 128
 FOR j = 0 TO 128
  IF a(i, j) < s THEN s = a(i, j)
 NEXT j
NEXT i
weiter:
hh = h: ss = s
PRINT "Tiefster Punkt:"; s
PRINT "H”chster Punkt:"; h
INPUT "Seeh”he: ", s
INPUT "Schneegrenze: ", h

SCREEN 12
y = 0
DO
 x = 0
 DO
  IF a(x, y) > h THEN COLOR 7 ELSE COLOR 2
  IF a(x, y) < s + 1 AND a(x, y) > s THEN COLOR 4
  IF a(x, y) <= s THEN COLOR 8
  LINE (4 * x + y + m, 350 - d - y - a(x, y))-(4 * (x + schritt) + y + m, 350 - d - y - a(x + schritt, y))
  x = x + schritt
 LOOP UNTIL x = 128
 y = y + schritt
LOOP UNTIL y > 128

x = 0
DO
 y = 0
 DO
  IF a(x, y) > h THEN COLOR 7 ELSE COLOR 2
  IF a(x, y) < s + 1 AND a(x, y) > s THEN COLOR 4
  IF a(x, y) <= s THEN COLOR 8
  LINE (4 * x + y + m, 350 - d - y - a(x, y))-(4 * x + schritt + y + m, 350 - d - y - schritt - a(x, schritt + y))
  y = y + schritt
 LOOP UNTIL y = 128
 x = x + schritt
LOOP UNTIL x > 128

x = schritt
COLOR 1

DO
 y = schritt
 DO
  IF a(x, y) <= s THEN
   FOR i = -schritt / 2 TO schritt / 2
    LINE (4 * x + y - 2 * schritt + i + m, 350 - d - y - s - i)-(4 * x + y + 2 * scritt + i + m, 350 - d - y - s - i)
   NEXT i
  END IF
  y = y + schritt
 LOOP UNTIL y > 128 - schritt
 x = x + schritt
LOOP UNTIL x > 128 - schritt

ON ERROR GOTO fehler
x = xm: y = ym
COLOR 1
DO
 m = a(x, y)
 FOR i = -1 TO 1
  FOR j = -1 TO 1
   IF a(x + i, y + j) < m THEN
    m = a(x + i, y + j): schritt = i: h = j
   ELSE
    schritt = 1: h = -1
   END IF
  NEXT j
 NEXT i
 LINE (4 * x + y, 350 - d - y - a(x, y))-(4 * (x + schritt) + y + h, 350 - d - y - a(x + schritt, y + h))
 x = x + schritt: y = y + h
LOOP UNTIL a(x, y) <= s + 4

SLEEP
SCREEN 0
WIDTH 80, 25
h = hh: s = ss
INPUT "Andere H”hen <j,n>"; ant$
IF ant$ = "j" THEN GOTO weiter
CLS
END
fehler:
IF ERR <> 9 THEN ERROR ERR
IF x = 0 THEN x = 1
IF y = 0 THEN y = 1
IF x = 128 THEN x = 127
IF y = 128 THEN y = 127
RESUME

