SCREEN 12: CLS : RANDOMIZE 11
WINDOW (-2, -1.5)-(2, 1.5)
INPUT "a=", a: INPUT "b=", b: CLS
x = RND: y = RND
FOR k = 0 TO 10000
x1 = (x - a) / 2: y1 = (y - b) / 2: r = SQR(x1 * x1 + y1 * y1)
IF RND < .5 THEN
        x = SQR(r + x1): y = SQR(r - x1)
        IF y1 < 0 THEN y = -y
ELSE
        x = -SQR(r + x1): y = -SQR(r - x1)
        IF y1 < 0 THEN y = -y
END IF
IF INKEY$ <> "" THEN GOTO ende
IF k > 10 THEN PSET (x, y): PSET (-x, -y)
IF k > 10 AND b = 0 THEN PSET (x, -y): PSET (-x, y)
NEXT k: BEEP: SLEEP
ende:  SCREEN 0
  WIDTH 80, 25
  COLOR 7, 0
  MaxCol = 80
  CLS

