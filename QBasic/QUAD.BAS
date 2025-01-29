SCREEN 12: CLS
RANDOMIZE 11: pi = 4 * ATN(1): kmax = 40000
WINDOW (-3.2, -2.4)-(3.2, 2.4): CLS
INPUT t1
INPUT t2
INPUT t3: CLS
t = t1: l = 1: GOSUB aus
t = t2: l = 2: GOSUB aus
t = t3: l = 3: GOSUB aus
e(1) = 1: f(1) = 0: e(2) = -1
f(2) = 0: e(3) = 0: f(3) = -1
q1 = 1 / 3: q2 = 2 / 3: x = 0: y = 0
FOR k = 1 TO kmax: r = RND
IF INKEY$ <> "" THEN END
l = 1 + INT(3 * RND)
z = x: x = a(l) * x + b(l) * y + e(l): y = c(l) * z + d(l) * y + f(l)
IF k > 16 THEN PSET (x, y)
NEXT k: a$ = INPUT$(1)
END
aus:
SELECT CASE t
CASE 0
        a(l) = 1 / 2: b(l) = 0: c(l) = 0: d(l) = 1 / 2
CASE 1
        a(l) = 0: b(l) = -1 / 2: c(l) = 1 / 2: d(l) = 0
CASE 2
        a(l) = -1 / 2: b(l) = 0: c(l) = 0: d(l) = -1 / 2
CASE 3
        a(l) = 0: b(l) = 1 / 2: c(l) = -1 / 2: d(l) = 0
CASE 4
        a(l) = -1 / 2: b(l) = 0: c(l) = 0: d(l) = 1 / 2
CASE 5
        a(l) = 0: b(l) = 1 / 2: c(l) = 1 / 2: d(l) = 0
CASE 6
        a(l) = 1 / 2: b(l) = 0: c(l) = 0: d(l) = -1 / 2
CASE 7
        a(l) = 0: b(l) = -1 / 2: c(l) = -1 / 2: d(l) = 0
END SELECT
RETURN

