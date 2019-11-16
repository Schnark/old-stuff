DECLARE SUB ampschalt ()       'schaltet die Ampeln
DECLARE SUB zeigstr ()         'zeichnet alle Straáen
DECLARE SUB zeigauto (x!, y!, farbe) 'zeichnet ein Auto
DECLARE SUB ausfahrt (n!)      'Auto n f„hrt weg
DECLARE SUB einfahrt ()        'ein Auto erscheint
DECLARE SUB fahren ()          'die Autos fahren
DECLARE SUB zeigen ()          'die Autos werden gezeigt
DECLARE FUNCTION abstand! (n!) 'Abstand des n. Autos zum Vordermann

DIM SHARED farben(15)
farben(0) = 4: farben(1) = 1: farben(2) = 0: farben(3) = 6: farben(4) = 15: farben(5) = 4: farben(6) = 3: farben(7) = 5: farben(8) = 7: farben(9) = 8: farben(10) = 9: farben(11) = 1: farben(12) = 12: farben(13) = 13: farben(14) = 11
RANDOMIZE TIMER

DIM SHARED max        'Autos
DIM SHARED strmax     'Straáen
DIM SHARED kreuzmax   'Kreuzungen
DIM SHARED einmax     'Einfahrten
DIM SHARED ampelmax   'Ampeln

max = 30
nr = 4

SELECT CASE nr
CASE 1
        strmax = 10
        kreuzmax = 1
        einmax = 2
        ampelmax = 2
CASE 2
        strmax = 9
        kreuzmax = 2
        einmax = 2
        ampelmax = 2
CASE 3
        strmax = 12
        kreuzmax = 4
        einmax = 1
        ampelmax = 2
CASE 4
        strmax = 17
        kreuzmax = 6
        einmax = 2
CASE 5
        strmax = 4
        einmax = 2
        ampelmax = 2
END SELECT

DIM SHARED nach(kreuzmax, 3)       '0=N 1=O 2=S 3=W  n„chste Straáe
DIM SHARED wahr(kreuzmax, 3, 3)    ' Wahrscheinlichkeit fr Straáenwechsel
DIM SHARED ein(einmax)             'Einfahrten

SELECT CASE nr
CASE 1
        ein(0) = 0: ein(1) = 5
        RESTORE nr1                'Straáensystem
        nach(0, 1) = 8: nach(0, 3) = 2
        wahr(0, 0, 1) = .3: wahr(0, 0, 3) = .7
CASE 2
        ein(0) = 0: ein(1) = 5
        RESTORE nr2
        nach(0, 1) = 1: nach(0, 2) = 3
        wahr(0, 2, 1) = .7: wahr(0, 2, 2) = .3
        wahr(0, 3, 1) = .5: wahr(0, 3, 2) = .5

        nach(1, 0) = 4: nach(1, 1) = 7: nach(1, 2) = 6
        wahr(1, 0, 0) = .2: wahr(1, 0, 1) = .4: wahr(1, 0, 2) = .4
        wahr(1, 3, 0) = .4: wahr(1, 3, 1) = .3: wahr(1, 3, 2) = .3
CASE 3
        ein(0) = 0
        RESTORE nr3
        nach(0, 1) = 4: nach(0, 2) = 1
        wahr(0, 1, 1) = .2: wahr(0, 1, 2) = .8
        wahr(0, 2, 1) = .8: wahr(0, 2, 2) = .2
        wahr(0, 3, 1) = .4: wahr(0, 3, 2) = .6

        nach(1, 2) = 6: nach(1, 3) = 5
        wahr(1, 3, 2) = .8: wahr(1, 3, 3) = .2

        nach(2, 0) = 3: nach(2, 1) = 2
        wahr(2, 0, 0) = .2: wahr(2, 0, 1) = .8

        nach(3, 1) = 7: nach(3, 2) = 8
        wahr(3, 3, 1) = .7: wahr(3, 3, 2) = .3
CASE 4
        ein(0) = 0: ein(1) = 1
        RESTORE nr4
        nach(0, 1) = 2: nach(0, 2) = 3
        wahr(0, 3, 1) = .7: wahr(0, 3, 2) = .3
       
        nach(1, 1) = 4: nach(1, 2) = 5
        wahr(1, 3, 1) = .7: wahr(1, 3, 2) = .3
       
        nach(2, 1) = 6: nach(2, 2) = 7
        wahr(2, 3, 1) = .7: wahr(2, 3, 2) = .3
       
        nach(3, 1) = 8: nach(3, 2) = 9
        wahr(3, 3, 1) = .7: wahr(3, 3, 2) = .3
       
        nach(4, 1) = 10: nach(4, 2) = 11
        wahr(4, 3, 1) = .7: wahr(4, 3, 2) = .3
       
        nach(5, 1) = 13: nach(5, 2) = 14
        wahr(5, 3, 1) = .7: wahr(5, 3, 2) = .3
CASE 5
        ein(0) = 0: ein(1) = 2
        RESTORE nr5

END SELECT

nr1: DATA 100,  0,  10, 10,  1, 0     ,2
     DATA  50,  1, 110, 10, 11, 0     ,2
     DATA  50,  0, 110, 60,  3, 1     ,1
     DATA  30,  1,  60, 60,  4, 1     ,2
     DATA  50,  0,  60, 30, 10, 1     ,2

     DATA 150,  0,  10,100,  6, 0     ,0
     DATA  50,  1, 160,100,  7, 1     ,2
     DATA  50,  0, 160, 50, 10, 0     ,2

     DATA  10,  0, 110, 60,  9, 0     ,2
     DATA  60,  1, 120, 60, 10, 1     ,2

'       L„nge, R.,   x,  y, A., r2, Ampel

nr2: DATA  50,  0,  10, 60, 10, 0     ,2
     DATA  55,  0,  60, 60,  2, 0     ,1
     DATA  50,  1, 115, 60,  9, 1     ,2
     DATA  50,  1,  60, 60, 11, 0     ,2
     DATA  50,  1,  63,110, 10, 1     ,1
     DATA  50,  0,  10,110, 11, 0     ,2
     DATA  50,  1,  60,110,  9, 0     ,2
     DATA 105,  0,  60,110,  8, 0     ,0
     DATA 100,  1, 165,110,  9, 1     ,2

nr3: DATA  40,  0,  10,  9, 13, 0     ,2
     DATA  12,  1,  50, 10, 15, 0     ,2
     DATA  26,  0,  50, 23, 16, 0     ,0
     DATA  14,  1,  52, 22, 13, 1     ,2
     DATA  40,  0,  53,  9, 14, 0     ,2
     DATA  40,  0,  93, 11, 13, 1     ,2
     DATA  14,  1,  94,  9,  9, 0     ,2
     DATA  16,  0,  77, 23,  9, 0     ,1
     DATA  21,  1,  77, 24, 11, 0     ,2
     DATA  22,  1,  94, 24, 10, 0     ,2
     DATA  16,  0,  94, 46, 11, 1     ,1
     DATA  68,  0,  78, 46, 12, 1     ,2

nr4: DATA  10,  0,   8,  9, 18, 0     ,2
     DATA  10,  0,   8, 11, 18, 0     ,2
     DATA  10,  0,  19,  9, 19, 0     ,2
     DATA  10,  0,  19, 11, 19, 0     ,2
     DATA  10,  0,  30,  9, 20, 0     ,2
     DATA  10,  0,  30, 11, 20, 0     ,2
     DATA  10,  0,  41,  9, 21, 0     ,2
     DATA  10,  0,  41, 11, 21, 0     ,2
     DATA  10,  0,  52,  9, 22, 0     ,2
     DATA  10,  0,  52, 11, 22, 0     ,2
     DATA  10,  0,  63,  9, 12, 0     ,2
     DATA  10,  0,  63, 11, 12, 0     ,2
     DATA  54,  0,  74,  9, 23, 0     ,2
     DATA  10,  0, 129,  9, 24, 0     ,2
     DATA  10,  0, 129, 11, 24, 0     ,2
     DATA  10,  0, 140,  9, 17, 0     ,2
     DATA  10,  0, 140, 11, 17, 0     ,2
nr5: DATA  75,  0,  10, 10,  1, 0     ,1
     DATA  85,  0,  86, 10,  4, 0     ,2
     DATA  87,  0, 172, 12,  3, 1     ,1
     DATA  77,  0,  86, 12,  4, 1     ,2

TYPE auto            'Auto
ort AS INTEGER       'Stelle auf Staáe
v AS SINGLE          'aktuelle Geschwindigkeit
vsoll AS INTEGER     'gewnschte G.
amax AS SINGLE       '"maximale" Beschleunigung
strnr AS INTEGER     'Straáe
END TYPE

TYPE strasse         'Straáe
vrel AS SINGLE       'Zustand (schnell/langsam befahrbar)
spuren AS INTEGER    'Spuren
laenge AS INTEGER    'L„nge in Autos
x AS INTEGER         'Startpunkt
y AS INTEGER         '"        "
richtung AS INTEGER  '0=- 1=|
anschluss AS INTEGER 'n„chste Straáe oder strmax
r2 AS INTEGER        '0=v> 1=^<
ampelnr AS INTEGER   'Ampelnummer am Ende der Straáe
END TYPE

TYPE ampel
zeitrot AS INTEGER   'L„nge von Rot
zeitgruen AS INTEGER 'L„nge von Grn
zustand AS INTEGER   '0=Rot, 1=Grn
dauer AS INTEGER     'Dauer des aktuellen Zustands
END TYPE

DIM SHARED autos(max) AS auto              'alle Autos
DIM SHARED strassen(strmax) AS strasse     'alle Straáen
DIM SHARED ampeln(ampelmax) AS ampel       'alle Ampeln

SCREEN 12 '640*480
CLS
LINE (0, 0)-(640, 480), 10, BF 'grner Hintergrund

FOR i = 0 TO strmax - 1       'alle Straáen
strassen(i).spuren = 1        'haben eine Spur
strassen(i).vrel = RND + .5   'und einen Zustand von 0,5 bis 1,5
READ strassen(i).laenge '= INT(RND * 110) + 100 'alle eine L„nge von 100 bis 210
READ strassen(i).richtung '= INT(RND * 2)
READ strassen(i).x '= INT(RND * 100)
READ strassen(i).y '= INT(RND * 100)
READ strassen(i).anschluss '= INT(RND * (strmax + 1))
READ strassen(i).r2 '= INT(RND * 2)
READ strassen(i).ampelnr
NEXT i

ampeln(0).zeitrot = 150: ampeln(0).zeitgruen = 50
ampeln(0).zustand = 0: ampeln(0).dauer = 0

'ampeln(1).zeitrot = 50: ampeln(1).zeitgruen = 100
'ampeln(1).zustand = 1: ampeln(0).dauer = 0

FOR i = 0 TO max - 1     'alle Autos
autos(i).strnr = 0       'sind auf der ersten Straáe
autos(i).ort = 0         'auáerhalb
NEXT i

einfahrt                 'ein Auto f„hrt auf eine Straáe

DO
zeigen                   'die Straáen mit den Autos erscheinen am Bildschirm
fahren                   'die Autos fahren
taste$ = INKEY$
IF taste$ = " " THEN einfahrt               'bei der Leertaste kommt ein Auto
IF taste$ = "a" THEN autos(0).v = 0: autos(0).amax = 0 'erstes Auto bremsen
IF taste$ = "b" THEN autos(0).amax = 10 * RND + 5      'erstes Auto losfahren
IF taste$ = "c" THEN autos(0).v = 10 * autos(0).v      '"         " schnell
LOOP UNTIL taste$ = CHR$(27)      'bei ESC beenden
  SCREEN 0
  WIDTH 80, 25
  COLOR 7, 0
  MaxCol = 80
  CLS

FUNCTION abstand (n)
nr = autos(n).strnr                 'Staáennummer
lang = strassen(nr).laenge + 1      'L„nge der Straáe mit dem Auto
stelle = autos(n).ort               'Ort auf Straáe
difmin = lang - stelle              'Startwert (Abstand zu Rand)
FOR i = 0 TO max - 1                'bei allen Autos
IF autos(i).strnr = nr THEN         'auf der gleichen Straáe
        dif = autos(i).ort - stelle 'wird der Abstand bestimmt
        IF dif > 0 THEN IF dif < difmin THEN difmin = dif
END IF                              'ist es davor und n„her als die anderen
NEXT i                              'kann dies der kleinste Abstand sein
IF difmin = lang - stelle THEN difmin = 75 + difmin' + 100'wenn der Wert gleich dem Startwert
abstand = difmin - 1 'vom Abstand wird die Auto- |  ist, ist er beliebig groá
END FUNCTION                     'l„nge abgezogen

SUB ampschalt
FOR i = 0 TO ampelmax - 1
        zeit = ampeln(i).dauer
        IF ampeln(i).zustand = 0 THEN
                zeitmax = ampeln(i).zeitrot
        ELSE
                zeitmax = ampeln(i).zeitgruen
        END IF
        IF zeit = zeitmax THEN zeit = -1
        ampeln(i).dauer = zeit + 1
        IF zeit = -1 THEN ampeln(i).zustand = 1 - ampeln(i).zustand
NEXT i
END SUB

SUB ausfahrt (n)
nr = autos(n).strnr
weiter = strassen(nr).anschluss
IF weiter < strmax THEN                            'bei Anschluss
        naechste = weiter                          'Anschluss
ELSEIF weiter > strmax THEN
        weiter = weiter - strmax - 1               'Nummer der Kreuzung
        r1 = strassen(nr).richtung
        r2 = strassen(nr).r2
        r = r1 * r2 + r2
        IF r1 = 0 AND r2 = 0 THEN r = 3            'Herkunftsrichtung
        z = RND                                    'Zufallszahl
        s = 0                                      'Summe
        FOR i = 0 TO 3
        s = s + wahr(weiter, r, i)                 '"   "
        IF z < s THEN EXIT FOR                     'Aufteilung
        NEXT i
        IF i = 4 THEN i = 3
        naechste = nach(weiter, i)                 'neue Straáe
ELSE
        naechste = -2
        autos(n).ort = 0                           'Auto n ist nicht mehr
                                                   'auf der Straáe
        einfahrt
END IF

ampnr = strassen(nr).ampelnr                       'Ampelnr. der Straáe
IF ampnr < ampelmax THEN
        IF ampeln(ampnr).zustand = 0 THEN 'wenn rot
                naechste = -1                      'anhalten
        ELSE
        FOR i = 0 TO max - 1                       'bei allen Autos
        IF autos(i).strnr = naechste THEN          'auf der Anschlussstraáe
           IF autos(i).ort = 1 THEN naechste = -1  'wenn Anfang besetzt nicht
        END IF
        NEXT i                                     'weiterfahren
        END IF
END IF

IF naechste > -1 THEN
        autos(n).strnr = naechste
        autos(n).ort = 1                           'ganz vorne
ELSEIF naechste = -1 THEN
       a = abstand(n)
       IF a >= 80 THEN
                autos(n).ort = strassen(nr).laenge         'ganz hinten
       ELSE
                autos(n).ort = autos(n).ort + a - 1
       END IF
END IF
END SUB

SUB einfahrt
FOR i = 0 TO max - 1
IF autos(i).ort = 0 THEN EXIT FOR      'das erste freie Auto bekommt
NEXT i
autos(i).ort = 1                       'den Platz am Anfang der Straáe
autos(i).v = RND * 30 + 20             'eine G. von 20 bis 50
autos(i).vsoll = INT(RND * 30) + 20    'eine Sollg. von 20 bis 50
autos(i).amax = 10 * RND + 5           'eine Beschl. von 5 bis 15
autos(i).strnr = ein(INT(RND * einmax))'eine Straáe aller m”glichen Einfahrten
END SUB

SUB fahren
DIM autosneuv(max)        'neue G.
DIM autosneuort(max)      'neuer Ort

ampschalt                                        'Ampelschaltung
FOR i = 0 TO max - 1                             'alle Autos
IF autos(i).ort > 0 THEN                         'auf der Straáe
d = abstand(i)                                   'Abstand
vdif = autos(i).vsoll - autos(i).v               'Unterschied zur Sollg.
ortdif = d - (autos(i).v / 100) ^ 2              '"         " zum Sollabstand
a = (2 * vdif + 4 * ortdif) / 16 * autos(i).amax 'Beschl. abh. v. "  "
v = autos(i).v + a                               'beschleunigen
v = v * (RND * .2 + .9)                          'zuf„llige Ver„nderung
IF d - INT(.5 + v / 16) < .5 THEN v = 0          'Vollbr. bei Auffahrunfall
IF v < 0 THEN v = 0                              'G. positiv
autosneuv(i) = v
weg = INT(.5 + v / 100)                           '0.1   /  3.6      /  4
                                   'Rechenzeit (s)    km/h->m/s Autol„nge (m)
IF v < 10 THEN weg = INT(d / 2 + .5)             'Aufrcken wenn hinter anderem Auto
autosneuort(i) = weg + autos(i).ort              'fahren
ELSE
autosneuort(i) = 0                               'bleibt weg
END IF
NEXT i
FOR i = 0 TO max - 1
IF autosneuort(i) > strassen(autos(i).strnr).laenge THEN 'wenn von Straáe weg
        ausfahrt (i)                                     'wegfahren
ELSE
        autos(i).v = autosneuv(i)                'neue Daten
        autos(i).ort = autosneuort(i)
END IF
NEXT i
END SUB

SUB zeigauto (x, y, farbe)
LINE (x * 3, y * 3)-(x * 3 + 2, y * 3 + 2), farbe, BF  'Rechteck, 3*3
END SUB

SUB zeigen
zeigstr                                'Straáen malen
FOR i = 0 TO max - 1                   'Autos malen
stelle = autos(i).ort
IF stelle <> 0 THEN                            'wenn Auto auf Strasse
        nr = autos(i).strnr
        IF strassen(nr).r2 = 1 THEN stelle = -stelle   'andere Richtung
        IF strassen(nr).richtung = 0 THEN      'wenn waagerecht
                px = strassen(nr).x + stelle   'Bewegung in x-Richtung
                py = strassen(nr).y            'von Start aus
        ELSE                                   'wenn senkrecht
                px = strassen(nr).x            'von Start aus
                py = strassen(nr).y + stelle   'Bewegung in y-Richtung
        END IF
        zeigauto px, py, farben(i MOD 15)       'zeichnen
END IF
NEXT i
END SUB

SUB zeigstr
FOR i = 0 TO strmax - 1                         'alle Straáen
px = strassen(i).x
py = strassen(i).y
lang = strassen(i).laenge
IF strassen(i).r2 = 1 THEN lang = -lang         'Kommentare siehe zeigen
IF strassen(i).richtung = 0 THEN
        pxneu = px + lang
        pyneu = py
ELSE
        pxneu = px
        pyneu = py + lang
END IF
LINE (3 * px, 3 * py)-(3 * pxneu + 2, 3 * pyneu + 2), 14, BF 'gelbes Rechteck
ampnr = strassen(i).ampelnr                     'Ampelnr.
IF ampnr < ampelmax THEN                        'bei Ampel
        z = ampeln(ampnr).zustand               'Rot/Grn
        IF z = 0 THEN farbe = 4 ELSE farbe = 2
        CIRCLE STEP(0, 0), 3, farbe'(3 * pxneu + 2, 3 * pyneu + 2), 3, farbe
        PAINT STEP(0, 0), farbe, farbe
END IF
NEXT i
END SUB

