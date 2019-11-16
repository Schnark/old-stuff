SCREEN 12: CLS
xm = 320: ym = 240
delh = 1.76: delv = 1.32: ac = -.65
n1 = 250: n2 = INT(n1 * delv / delh)
DIM col(8): DATA 0,1,9,10,4,12,6,14
FOR i = 1 TO 8: READ col(i): NEXT i
FOR i = -n1 TO n1: a = ac + i * delh / n1
        FOR j = 0 TO n2: b = j * delv / n2
                u = 4 * (a * a + b * b): v = u - 2 * a + 1 / 4
                IF u + 8 * a + 15 / 4 < 0 THEN l = 0: GOTO weiter
                IF v - SQR(v) + 2 * a - 1 / 2 < 0 THEN l = 0: GOTO weiter
                x = a: y = b: k = 0
                DO
                        z = x: x = x * x - y * y + a: y = 2 * z * y + b
                        s = x * x + y * y: k = k + 1
                LOOP UNTIL s > 100 OR k = 50
                IF k < 40 THEN l = 1 + k MOD 8 ELSE l = 0
                PSET (xm + i, ym - j), col(l)
                PSET (xm + i, ym + j), col(l)
weiter:
                IF INKEY$ <> "" THEN GOTO ende
        NEXT j
NEXT i: a$ = INPUT$(1)
ende:  SCREEN 0
  WIDTH 80, 25
  COLOR 7, 0
  MaxCol = 80
  CLS
END

