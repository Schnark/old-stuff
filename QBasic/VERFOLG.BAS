t = 0: delta = .1
INPUT "vziel (z. B. 3): ", vziel
INPUT "xfolge (z. B. 0): ", xfolge
INPUT "yfolge (z. B. 150): ", yfolge
INPUT "vfolge (z. B. 3.2): ", vfolge
xziel = 450: yziel = 150
RANDOMIZE TIMER
SCREEN 12
DO
 xziel = 450 + 100 * COS(vziel / 100 * t)
 yziel = 150 + 100 * SIN(vziel / 100 * t)
 'xziel = xziel + (RND - .6) * vziel
 'yziel = yziel + (RND - .45) * vziel
 IF POINT(INT(xziel + .5), INT(yziel + .5)) = 4 THEN farbe% = 1 ELSE farbe% = 4
 PSET (INT(xziel + .5), INT(yziel + .5)), farbe%
 xr = xziel - xfolge
 yr = yziel - yfolge
 l = 10 * SQR(xr / 100 * xr + yr / 100 * yr)
 xfolge = xfolge + xr / l * vfolge * delta
 yfolge = yfolge + yr / l * vfolge * delta
 PSET (INT(xfolge + .5), INT(yfolge + .5)), 2
 t = t + delta
LOOP UNTIL INKEY$ <> "" OR l < .5
SLEEP
SCREEN 0
WIDTH 80, 25

