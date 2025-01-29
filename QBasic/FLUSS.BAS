INPUT "Wassergeschw. (Mitte, m/s): ", vf
INPUT "Geschw. d. Hundes (m/s): ", v
INPUT "x-Pos. Hund (m, -ca. 60): ", x
INPUT "x-Pos. Herr (m, -ca. 60): ", h
SCREEN 12
CIRCLE (10 * x, 10), 3, 4
CIRCLE (10 * h, 330), 3, 4
LINE (0, 20)-(639, 20), 2
LINE (0, 320)-(639, 320), 2
FOR i = 1 TO 300
PSET (10 * (vf - 4 * vf / 30 / 30 * (i / 10 - 15) * (i / 10 - 15)), i + 20), 1
NEXT i
y = -15: t = 0: delta = .05
DO
 p = vf - 4 * vf / 30 / 30 * y * y
 norm = SQR((h - x) * (h - x) + (15 - y) * (15 - y))
 x = x + (h - x) * v * delta / norm + p * delta
 y = y + (15 - y) * v * delta / norm
 PSET (10 * x, 170 + 10 * y), 4
 t = t + delta
LOOP UNTIL y > 15 OR x > 80
SLEEP
SCREEN 0
WIDTH 80, 25

