DECLARE SUB zkreis (xm!, ym!, r!, f!) '=CIRCLE
DECLARE SUB einst ()                  'Einstellungen
DECLARE SUB zeichne ()                'Zeichnet
DECLARE FUNCTION kurz$ (zahl!)        'Wandelt Zahl in kurzen String um
DECLARE SUB tabelle ()                'Erstellt Tabelle
DECLARE SUB rechne ()                 'Berechnet alle Elemente
DECLARE FUNCTION rechneg! (nr!)       'Berechnet Gerade Nr. nr aus Definition
DECLARE FUNCTION rechnek! (nr!)       '    "     Kreis   "            "
DECLARE FUNCTION rechnep! (nr!)       'Berechnet Punkt Nr. nr aus Definition
DECLARE FUNCTION suche! (art$, name$) 'Sucht name in art (Punkt/Gerade/Kreis)
DECLARE SUB menu ()                   'HauptmenÅ
DECLARE SUB defpunkt ()               'Definiert Punkt
DECLARE SUB defgerade ()              '    "     Gerade
DECLARE SUB defkreis ()               '    "     Kreis

TYPE punkt
pname AS STRING * 3  'Name
x AS SINGLE
y AS SINGLE
w1 AS STRING * 6
w2 AS STRING * 6
art AS INTEGER       '0 x,y: Koordinaten        3 w1,w2: Kreise
                     '1 w1,w2: Geraden          4 w1,w2: Punkte (Mittelpunkt)
                     '2 w1: Gerade, w2: Kreis   5 w1: Kreis (Mittelpunkt)
nr AS INTEGER        'Nr. bei 2 Schnittpunkten
sicht AS INTEGER     '1=sichtbar
END TYPE

TYPE gerade
gname AS STRING * 6     'Name
art AS INTEGER '0 w1,w2: Punkte                     3 w1: Gerade, w2: Punkt (Orthogonale)
               '1 w1: Gerade, a: Abstand            4 w1: Gerade, w2: Punkt, a: Winkel
               '2 w1: Gerade, w2:Punkt (Parallele)  5 w1,w2: Geraden (Winkelhalbierende)
w1 AS STRING * 6
w2 AS STRING * 6
a AS SINGLE
sicht AS INTEGER      '1=sichtbar
END TYPE

TYPE kreis
kname AS STRING * 4   'Name
art AS INTEGER        '0 w1: Mittelpunkt, w2: Punkt  2 Umkreis um w1, w2, w3
                      '1 w1: Mittelpunkt, r: Radius  3 Inkreis zu w1, w2, w3
w1 AS STRING * 3
w2 AS STRING * 3
w3 AS STRING * 3
r AS SINGLE
sicht AS INTEGER      '1=sichtbar
END TYPE

TYPE p2                '(x,y)
x AS SINGLE
y AS SINGLE
END TYPE
TYPE g2                'mx+c
m AS SINGLE
c AS SINGLE
END TYPE
TYPE k2                'M(x,y),r
x AS SINGLE
y AS SINGLE
r AS SINGLE
END TYPE

CONST MAXP = 30       'Maximalanzahlen
CONST MAXG = 20
CONST MAXK = 10

DIM SHARED p, g, k, p2, g2, k2           'aktuelle Stelle bei Def./Berechnung
p = 1: g = 1: k = 1: p2 = 0: g2 = 0: k2 = 0
DIM SHARED pf, gf, kf, hf, af                     'Farben
DIM SHARED xlo, ylo, xru, yru                     'Koordinatengrenzen
pf = 4: gf = 0: kf = 0: hf = 15: af = 7
xlo = -12.8: ylo = 9.6: xru = 12.8: yru = -9.6    '640*480  dx/dy=640/480
                                            
DIM SHARED punkte(1 TO MAXP)  AS punkt
DIM SHARED geraden(1 TO MAXG)  AS gerade
DIM SHARED kreise(1 TO MAXK)  AS kreis

DIM SHARED punkte2(1 TO MAXP) AS p2
DIM SHARED geraden2(1 TO MAXG) AS g2
DIM SHARED kreise2(1 TO MAXK) AS k2

menu

SUB defgerade
IF g > MAXG THEN EXIT SUB           'alle Geraden definiert
DO
INPUT "Name ", n$
LOOP UNTIL suche("G", n$) = 0       'neuer Name
PRINT "1. durch 2 Punkte"
PRINT "2. Parallele"
PRINT "3. Orthogonale"
PRINT "4. Winkel"
INPUT wahl

SELECT CASE wahl
CASE 1: geraden(g).art = 0
        INPUT "Punkt 1 ", geraden(g).w1: INPUT "Punkt 2 ", geraden(g).w2
CASE 2: INPUT "... zu Gerade ", geraden(g).w1
        PRINT "1. Abstand"
        PRINT "2. durch Punkt"
        INPUT wahl
        geraden(g).art = wahl
        SELECT CASE wahl
        CASE 1: INPUT "Abstand ", geraden(g).a
        CASE 2: INPUT "Punkt ", geraden(g).w2
        END SELECT
CASE 3: INPUT "... zu Gerade ", geraden(g).w1
        INPUT "... durch Punkt ", geraden(g).w2
        geraden(g).art = 3
CASE 4: PRINT "1. Winkel in Grad"
        PRINT "2. Winkel im Bogenma·"
        PRINT "3. Winkelhalbierende"
        INPUT wahl
        SELECT CASE wahl
        CASE 1: INPUT "Winkel in Grad ", w: geraden(g).a = w / 180 * 3.1415926536#
        CASE 2: INPUT "Winkel im Bogenma· ", geraden(g).a
        CASE 3: INPUT "Gerade 1 ", geraden(g).w1: INPUT "Gerade 2 ", geraden(g).w2: geraden(g).art = 5
        END SELECT
        IF wahl <> 3 THEN INPUT "... zu Gerade ", geraden(g).w1: INPUT "... durch Punkt ", geraden(g).w2: geraden(g).art = 4
END SELECT
geraden(g).gname = n$
g = g + 1                'nÑchste Gerade
END SUB

SUB defkreis
IF k > MAXK THEN EXIT SUB
DO
INPUT "Name ", n$
LOOP UNTIL suche("K", n$) = 0
PRINT "1. um Punkt"
PRINT "2. Umkreis"
PRINT "3. Inkreis"
INPUT wahl
kreise(k).art = wahl
SELECT CASE wahl
CASE 1: INPUT "Mittelpunkt ", kreise(k).w1
        PRINT "1. durch Punkt"
        PRINT "2. mit Radius"
        INPUT wahl
        SELECT CASE wahl
        CASE 1: INPUT "Punkt ", kreise(k).w2: kreise(k).art = 0
        CASE 2: INPUT "Radius ", kreise(k).r
        END SELECT
CASE 2, 3: INPUT "Punkt 1 ", kreise(k).w1
        INPUT "Punkt 2 ", kreise(k).w2
        INPUT "Punkt 3 ", kreise(k).w3
END SELECT
kreise(k).kname = n$
k = k + 1
END SUB

SUB defpunkt
IF p > MAXP THEN EXIT SUB
DO
INPUT "Name ", n$
LOOP UNTIL suche("P", n$) = 0
PRINT "1. Koordinaten"
PRINT "2. Schnittpunkt"
PRINT "3. Mittelpunkt"
INPUT wahl
SELECT CASE wahl
CASE 1: punkte(p).art = 0
        INPUT "x ", punkte(p).x: INPUT "y ", punkte(p).y
CASE 2: PRINT "1. Gerade-Gerade"
        PRINT "2. Gerade-Kreis"
        PRINT "3. Kreis-Kreis"
        INPUT wahl
        punkte(p).art = wahl
        SELECT CASE wahl
        CASE 1: INPUT "Gerade 1 ", punkte(p).w1: INPUT "Gerade 2 ", punkte(p).w2
        CASE 2: INPUT "Gerade ", punkte(p).w1: INPUT "Kreis ", punkte(p).w2: INPUT "Schnittpunktnr. ", punkte(p).nr
        CASE 3: INPUT "Kreis 1 ", punkte(p).w1: INPUT "Kreis 2 ", punkte(p).w2: INPUT "Schnittpunktnr. ", punkte(p).nr
        END SELECT
CASE 3: PRINT "1. Strecke"
        PRINT "2. Kreis"
'       PRINT "3. Dreieck"
        INPUT wahl
        punkte(p).art = wahl + 3
        SELECT CASE wahl
        CASE 1: INPUT "Punkt 1 ", punkte(p).w1: INPUT "Punkt 2 ", punkte(p).w2
        CASE 2: INPUT "Kreis ", punkte(p).w1
        END SELECT
END SELECT
punkte(p).pname = n$
p = p + 1
END SUB

SUB einst
PRINT "1. Standart"
PRINT "2. Koordinaten"
PRINT "3. Farben"
PRINT "4. richtiges VerhÑltnis"
INPUT wahl
SELECT CASE wahl
CASE 1
pf = 4: gf = 0: kf = 0: hf = 15: af = 7
xlo = -12.8: ylo = 9.6: xru = 12.8: yru = -9.6    '640*480  dx/dy=640/480
CASE 2
INPUT "x-Koordinate oben links:   ", xlo
INPUT "y-Koordinate oben links:   ", ylo
INPUT "x-Koordinate unten rechts: ", xru
INPUT "y-Koordinate unten rechts: ", yru
CASE 3
FOR i = 0 TO 15
COLOR i, 0
IF i = 0 THEN COLOR 0, 15
PRINT "--"; LTRIM$(STR$(i)); "-";
NEXT i
COLOR 7
PRINT
INPUT "Hintergrundfarbe: ", hf
INPUT "Achsenfarbe:      ", af
INPUT "Punktfarbe:       ", pf
INPUT "Geradenfarbe:     ", gf
INPUT "Kreisfarbe:       ", kf
CASE 4
d = xru - xlo
d = 480 / 640 * d
dy = ylo - yru
ylo = ylo / dy * d: yru = yru / dy * d
END SELECT
END SUB

FUNCTION kurz$ (zahl)
text$ = LTRIM$(STR$(zahl))
IF LEN(text$) <= 7 THEN
ELSE
        IF INSTR(text$, "E") THEN
                text$ = LEFT$(text$, 3) + RIGHT$(text$, 4)
        ELSE
                IF INSTR(text$, ".") THEN
                        IF INSTR(text$, ".") <= 8 THEN
                                text$ = LEFT$(text$, 7)
                                IF RIGHT$(text$, 1) = "." THEN text$ = LEFT$(text$, 6)
                        ELSE
                                text$ = RIGHT$(text$, 6) + "?"
                        END IF
                ELSE
                        text$ = RIGHT$(text$, 6) + "?"
                END IF
        END IF
END IF
kurz$ = text$
END FUNCTION

SUB menu
WHILE 1
CLS
PRINT "1. Punkte definieren"
PRINT "2. Geraden definieren"
PRINT "3. Kreise definieren"
PRINT "4. Punkte Ñndern"
PRINT "5. Zeigen/Verstecken"
PRINT "6. Zeichnen"
PRINT "7. Tabelle"
PRINT "8. Einstellungen"
PRINT "9. Ende"
INPUT wahl

SELECT CASE wahl
CASE 1: defpunkt
        erg = rechnep(p - 1)
        IF erg = 1 THEN PRINT "Nicht definiert!": p = p - 1: punkte(p).pname = "" ELSE punkte(p - 1).sicht = 1
        'nicht definiert -->                    Def. ungÅltig, Name ungÅltig
CASE 2: defgerade
        erg = rechneg(g - 1)
        IF erg = 1 THEN PRINT "Nicht definiert!": g = g - 1: geraden(g).gname = "" ELSE geraden(g - 1).sicht = 1
        'nicht definiert -->                    Def. ungÅltig, Name ungÅltig
CASE 3: defkreis
        erg = rechnek(k - 1)
        IF erg = 1 THEN PRINT "Nicht definiert!": k = k - 1: kreise(k).kname = "" ELSE kreise(k - 1).sicht = 1
        'nicht definiert -->                    Def. ungÅltig, Name ungÅltig
CASE 4: INPUT "Punkt ", p$
        nr = suche("P", p$)
        IF nr = 0 THEN
                PRINT p$; " existiert nicht!"   'nicht definiert
        ELSEIF punkte(nr).art <> 0 THEN
                PRINT "Falsch definiert"        'nicht mit Koordinaten def.
        ELSE
                INPUT "x ", x: INPUT "y ", y
                punkte(nr).x = x
                punkte(nr).y = y
                rechne
        END IF
CASE 5: INPUT "P)unkt G)erade K)reis ", a$
        INPUT "Name ", n$
        nr = suche(a$, n$)
        IF nr = 0 THEN
                PRINT n$; " existiert nicht!"
        ELSE
                SELECT CASE a$
                CASE "p", "P": punkte(nr).sicht = 1 - punkte(nr).sicht
                CASE "g", "G": geraden(nr).sicht = 1 - geraden(nr).sicht
                CASE "k", "K": kreise(nr).sicht = 1 - kreise(nr).sicht
                END SELECT
        END IF
CASE 6: zeichne
CASE 7: tabelle
CASE 8: einst
CASE 9: END
END SELECT
SLEEP 1
WEND
END SUB

SUB rechne
p2 = 0: g2 = 0: k2 = 0
pi = 1: gi = 1: ki = 1
DO
  DO
    IF pi < p THEN erg = rechnep(pi) ELSE erg = 1
    pi = pi + 1
  LOOP UNTIL erg = 1
  pi = pi - 1
  DO
    IF gi < g THEN erg = rechneg(gi) ELSE erg = 1
    gi = gi + 1
  LOOP UNTIL erg = 1
  gi = gi - 1
  DO
    IF ki < k THEN erg = rechnek(ki) ELSE erg = 1
    ki = ki + 1
  LOOP UNTIL erg = 1
  ki = ki - 1
LOOP UNTIL pi >= p - 1 AND gi >= g - 1 AND ki >= k - 1
END SUB

FUNCTION rechneg (nr)
erg = 0
SELECT CASE geraden(nr).art
CASE 0: nr1 = suche("P", geraden(nr).w1): nr2 = suche("P", geraden(nr).w2)
        IF nr1 * nr2 = 0 OR nr1 >= p2 OR nr2 >= p2 THEN
                erg = 1
        ELSE
                g2 = nr + 1
                x1 = punkte2(nr1).x: x2 = punkte2(nr2).x
                y1 = punkte2(nr1).y: y2 = punkte2(nr2).y
                IF x1 = x2 THEN m = 3E+38 ELSE m = (y2 - y1) / (x2 - x1)
                c = y1 - m * x1
                geraden2(nr).m = m: geraden2(nr).c = c
        END IF
CASE 1: nr1 = suche("G", geraden(nr).w1)
        IF nr1 = 0 OR nr1 >= g2 THEN
                erg = 1
        ELSE
                g2 = nr + 1
                geraden2(nr).m = geraden2(nr1).m
                c = geraden(nr).a / SIN(3.1415926536# / 2 - ATN(geraden2(nr1).m))
                geraden2(nr).c = c + geraden2(nr1).c
        END IF
CASE 2: nr1 = suche("G", geraden(nr).w1): nr2 = suche("P", geraden(nr).w2)
        IF nr1 * nr2 = 0 OR nr1 >= g2 OR nr2 >= p2 THEN
                erg = 1
        ELSE
                g2 = nr + 1
                geraden2(nr).m = geraden2(nr1).m
                c = punkte2(nr2).y - geraden2(nr1).m * punkte2(nr2).x
                geraden2(nr).c = c
        END IF
CASE 3: nr1 = suche("G", geraden(nr).w1): nr2 = suche("P", geraden(nr).w2)
        IF nr1 * nr2 = 0 OR nr1 >= g2 OR nr2 >= p2 THEN
                erg = 1
        ELSE
                g2 = nr + 1
                geraden2(nr).m = -1 / geraden2(nr1).m
                geraden2(nr).c = punkte2(nr2).y - geraden2(nr).m * punkte2(nr2).x
        END IF
CASE 4: nr1 = suche("G", geraden(nr).w1): nr2 = suche("P", geraden(nr).w2)
        IF nr1 * nr2 = 0 OR nr1 >= g2 OR nr2 >= p2 THEN
                erg = 1
        ELSE
                winkel = geraden(nr).a + ATN(geraden2(nr1).m)
                m = TAN(winkel)
                geraden2(nr).m = m
                geraden2(nr).c = punkte2(nr2).y - punkte2(nr2).x * m
                g2 = nr + 1
        END IF
CASE 5: nr1 = suche("G", geraden(nr).w1): nr2 = suche("G", geraden(nr).w2)
        IF nr1 * nr2 = 0 OR nr1 >= g2 OR nr2 >= g2 THEN
                erg = 1
        ELSE
               winkel = ATN(geraden2(nr2).m) - ATN(geraden2(nr1).m)
               m = TAN(ATN(geraden2(nr1).m) + winkel / 2)
               geraden2(nr).m = m
               m1 = geraden2(nr1).m: c1 = geraden2(nr1).c
               x = (geraden2(nr2).c - c1) / (m1 - geraden2(nr2).m)
               y = m1 * x + c1
               geraden2(nr).c = y - x * m
               g2 = nr + 1
        END IF
END SELECT
rechneg = erg
END FUNCTION

FUNCTION rechnek (nr)
erg = 0
SELECT CASE kreise(nr).art
CASE 0: nr1 = suche("P", kreise(nr).w1)
        nr2 = suche("P", kreise(nr).w2)
        IF nr1 * nr2 = 0 OR nr1 >= p2 OR nr2 >= p2 THEN
        erg = 1
        ELSE
        k2 = nr + 1
        kreise2(nr).x = punkte2(nr1).x: kreise2(nr).y = punkte2(nr1).y
        kreise2(nr).r = SQR((punkte2(nr1).x - punkte2(nr2).x) ^ 2 + (punkte2(nr1).y - punkte2(nr2).y) ^ 2)
        END IF

CASE 1: nr1 = suche("P", kreise(nr).w1)
        IF nr1 = 0 OR nr1 >= p2 THEN
        erg = 1
        ELSE
        k2 = nr + 1
        kreise2(nr).x = punkte2(nr1).x: kreise2(nr).y = punkte2(nr1).y
        kreise2(nr).r = kreise(nr).r
        END IF
CASE 2:
        nr1 = suche("P", kreise(nr).w1)
        nr2 = suche("P", kreise(nr).w2)
        nr3 = suche("P", kreise(nr).w3)
        IF nr1 * nr2 * nr3 = 0 OR nr1 >= p2 OR nr2 >= p2 OR nr2 >= p2 THEN
        erg = 1
        ELSE
        BEEP: k2 = nr + 1
        END IF
CASE 3:
        nr1 = suche("P", kreise(nr).w1)
        nr2 = suche("P", kreise(nr).w2)
        nr3 = suche("P", kreise(nr).w3)
        IF nr1 * nr2 * nr3 = 0 OR nr1 >= p2 OR nr2 >= p2 OR nr2 >= p2 THEN
        erg = 1
        ELSE
        BEEP: k2 = nr + 1
        END IF
END SELECT
rechnek = erg
END FUNCTION

FUNCTION rechnep (nr)
erg = 0
SELECT CASE punkte(nr).art
CASE 0: punkte2(nr).x = punkte(nr).x: punkte2(nr).y = punkte(nr).y: p2 = nr + 1
CASE 1: nr1 = suche("G", punkte(nr).w1): nr2 = suche("G", punkte(nr).w2)
        IF nr1 * nr2 = 0 OR nr1 >= g2 OR nr2 >= g2 THEN
                erg = 1
        ELSE
                m1 = geraden2(nr1).m: m2 = geraden2(nr2).m
                c1 = geraden2(nr1).c: c2 = geraden2(nr2).c
                IF m1 = m2 THEN
                PRINT "Parallele --> kein Schnittpunkt"
                ELSE
                punkte2(nr).x = (c2 - c1) / (m1 - m2)
                punkte2(nr).y = m1 * punkte2(nr).x + c1
                p2 = nr + 1
                END IF
        END IF
CASE 2: nr1 = suche("G", punkte(nr).w1): nr2 = suche("K", punkte(nr).w2)
        IF nr1 * nr2 = 0 OR nr1 >= g2 OR nr2 >= k2 THEN
                erg = 1
        ELSE
                m = geraden2(nr1).m: cc = geraden2(nr1).c
                mx = kreise2(nr2).x: my = kreise2(nr2).y: r = kreise2(nr2).r
                '(x-mx)˝+(m*x+cc-my)˝=r˝
                a = (1 + m * m): b = (2 * (cc - my) * m - 2 * mx): c = (cc - my) ^ 2 + mx * mx - r * r
                d = b * b - 4 * a * c
                IF d > 0 THEN
                        d = (punkte(nr).nr - 1.5) * 2 * SQR(d)
                ELSEIF d < 0 THEN
                        d = 0: PRINT punkte(nr).pname; ": Kein Schnittpunkt!"
                END IF
                punkte2(nr).x = (-b + d) / (2 * a)
                punkte2(nr).y = punkte2(nr).x * m + cc
                p2 = nr + 1
        END IF
CASE 3: nr1 = suche("K", punkte(nr).w1): nr2 = suche("K", punkte(nr).w2)
        IF nr1 * nr2 = 0 OR nr1 >= k2 OR nr2 >= k2 THEN
                erg = 1
        ELSE
                mx1 = kreise2(nr1).x: my1 = kreise2(nr1).y: r1 = kreise2(nr1).r
                mx2 = kreise2(nr2).x: my2 = kreise2(nr2).y: r2 = kreise2(nr2).r
                '(x-mx1)˝+(y-my1)˝=r1˝
                '(x-mx2)˝+(y-my2)˝=r2˝
                'x˝-2*mx1*x+mx1˝+y˝-2*my1*y+my1˝=r1˝
                'x˝-2*mx2*x+mx2˝+y˝-2*my2*y+my2˝=r2˝
                '2*(mx2-mx1)*x+2*(my2-my1)*y+mx1˝-mx2˝+my1˝-my2˝+r2˝-r1˝=0
                '2*   dx    *x+2*    dy   *y+               c1          =0
                'y=x*(-2*dx)/(2*dy)-c1/(2*dy)
                'y=x*         c2  +    c3
                '(1+c2˝)*x˝+(2*c2*c3-2*mx1-2*my1*c2)*x+mx1˝+c3˝-2*my1*c3+my1˝=r1˝
                dx = mx2 - mx1: dy = my2 - my1
                c1 = mx1 * mx1 - mx2 * mx2 + my1 * my1 - my2 * my2 + r2 * r2 - r1 * r1
                c2 = (-2 * dx) / (2 * dy): c3 = -c1 / (2 * dy)
                a = 1 + c2 * c2: b = 2 * c2 * c3 - 2 * mx1 - 2 * my1 * c2: c = mx1 * mx1 + my1 * my1 - r1 * r1 + c3 * c3 - 2 * my1 * c3
                d = b * b - 4 * a * c
                IF d > 0 THEN
                        d = (punkte(nr).nr - 1.5) * 2 * SQR(d)
                ELSEIF d < 0 THEN
                        d = 0: PRINT punkte(nr).pname; ": Kein Schnittpunkt!"
                END IF
                punkte2(nr).x = (-b + d) / (2 * a)
                punkte2(nr).y = punkte2(nr).x * c2 + c3
                p2 = nr + 1
        END IF
CASE 4: nr1 = suche("P", punkte(nr).w1): nr2 = suche("P", punkte(nr).w2)
        IF nr1 * nr2 = 0 OR nr1 >= p2 OR nr2 >= p2 THEN
                erg = 1
        ELSE
                p2 = nr + 1
                punkte2(nr).x = (punkte2(nr1).x + punkte2(nr2).x) / 2
                punkte2(nr).y = (punkte2(nr1).y + punkte2(nr2).y) / 2
        END IF
CASE 5: nr1 = suche("K", punkte(nr).w1)
        IF nr1 = 0 OR nr1 >= k2 THEN
        erg = 1
        ELSE
        p2 = nr + 1
        punkte2(nr).x = kreise2(nr1).x
        punkte2(nr).y = kreise2(nr1).y
        END IF
END SELECT
rechnep = erg
END FUNCTION

FUNCTION suche (art$, name1$)
nr = 0
name$ = RTRIM$(name1$)
SELECT CASE art$
CASE "p", "P": FOR i = 1 TO MAXP
               IF name$ = RTRIM$(punkte(i).pname) THEN nr = i: EXIT FOR
               NEXT i
CASE "g", "G": FOR i = 1 TO MAXG
               IF name$ = RTRIM$(geraden(i).gname) THEN nr = i: EXIT FOR
               NEXT i
CASE "k", "K": FOR i = 1 TO MAXK
               IF name$ = RTRIM$(kreise(i).kname) THEN nr = i: EXIT FOR
               NEXT i
END SELECT
suche = nr
END FUNCTION

SUB tabelle
'         1    1    2    2    3    3    4    4    5    5    6    6    7    7    8    8    9    9
'1   5    0    5    0    5    0    5    0    5    0    5    0    5    0    5    0    5    0    5
'Punkte x       y        Geraden m       c        Kreise  x       y       r
'ABC    1234.56 1234.56  ABCDEF  1234.56 1234.56  ABCD    1234.56 1234.56 1234.56
CLS
PRINT "Punkte x       y        Geraden m       c        Kreise  x       y       r"
FOR i = 1 TO p - 1
IF punkte(i).sicht = 1 THEN
PRINT punkte(i).pname; TAB(8); kurz$(punkte2(i).x); TAB(16); kurz$(punkte2(i).y)
END IF
NEXT i
LOCATE 2, 1
FOR i = 1 TO g - 1
IF geraden(i).sicht = 1 THEN
LOCATE CSRLIN, 25
PRINT geraden(i).gname; TAB(33); kurz$(geraden2(i).m); TAB(41); kurz$(geraden2(i).c)
END IF
NEXT i
LOCATE 2, 1
FOR i = 1 TO k - 1
IF kreise(i).sicht = 1 THEN
LOCATE CSRLIN, 50
PRINT kreise(i).kname; TAB(58); kurz$(kreise2(i).x); TAB(66); kurz$(kreise2(i).y); TAB(74); kurz$(kreise2(i).r)
END IF
NEXT i
SLEEP
END SUB

SUB zeichne
SCREEN 12
WINDOW (xlo, ylo)-(xru, yru)
LINE (xlo, ylo)-(xru, yru), hf, BF
LINE (xlo, 0)-(xru, 0), af
LINE (0, ylo)-(0, yru), af
FOR i = 1 TO g - 1
IF geraden(i).sicht = 1 THEN
LINE (xlo, xlo * geraden2(i).m + geraden2(i).c)-(xru, xru * geraden2(i).m + geraden2(i).c), gf
END IF
NEXT i

FOR i = 1 TO k - 1
IF kreise(i).sicht = 1 THEN
'CIRCLE (kreise2(i).x, kreise2(i).y), kreise2(i).r, kf', , , 480 / 640 * (xlo - xru) / (yru - ylo)
zkreis kreise2(i).x, kreise2(i).y, kreise2(i).r, kf
END IF
NEXT i

FOR i = 1 TO p - 1
IF punkte(i).sicht = 1 THEN
PSET (punkte2(i).x, punkte2(i).y), pf
END IF
NEXT i
SLEEP
WINDOW
SCREEN 0
WIDTH 80, 25
END SUB

SUB zkreis (xm, ym, r, f)
FOR i = 0 TO 6.3 STEP .1 / (xru - xlo)
 x = xm + COS(i) * r
 y = ym + SIN(i) * r
 PSET (x, y), f
NEXT
END SUB

