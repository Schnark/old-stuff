DECLARE SUB daten ()
DECLARE SUB aktzeig ()
DECLARE SUB zeigestr ()
DECLARE SUB neu (nr!)
DIM SHARED aktuell
DIM SHARED max
DIM SHARED strmax
max = 50
strmax = 1
SCREEN 12

TYPE strasse         'Straáe
'spuren AS INTEGER    'Spuren
laenge AS INTEGER    'L„nge in Autos
x AS INTEGER         'Startpunkt
y AS INTEGER         '"        "
richtung AS INTEGER  '0=- 1=|
r2 AS INTEGER        '0=v> 1=^<
END TYPE

DIM SHARED strassen(max) AS strasse
aktuell = 0
neu (0)

ON KEY(1) GOSUB f1
ON KEY(2) GOSUB f2
ON KEY(3) GOSUB f3
ON KEY(11) GOSUB oben
ON KEY(12) GOSUB links
ON KEY(13) GOSUB rechts
ON KEY(14) GOSUB unten

KEY 15, CHR$(0) + CHR$(73)
ON KEY(15) GOSUB bildauf

KEY 16, CHR$(0) + CHR$(81)
ON KEY(16) GOSUB bildab

KEY 17, CHR$(0) + CHR$(82)
ON KEY(17) GOSUB einfg

KEY 18, CHR$(0) + CHR$(83)
ON KEY(18) GOSUB entf

KEY(0) ON

DO
LOOP UNTIL INKEY$ = CHR$(27)
  SCREEN 0
  WIDTH 80, 25
  COLOR 7, 0
  MaxCol = 80
  CLS

daten
END

f1:
strassen(aktuell).richtung = 1 - strassen(aktuell).richtung
zeigestr
RETURN
f2:
strassen(aktuell).r2 = 1 - strassen(aktuell).r2
zeigestr
RETURN
f3:
aktuell = (aktuell + 1) MOD strmax
zeigestr
RETURN
oben:
y = strassen(aktuell).y
IF y > 0 THEN strassen(aktuell).y = y - 1
zeigestr
RETURN
links:
x = strassen(aktuell).x
IF x > 0 THEN strassen(aktuell).x = x - 1
zeigestr
RETURN
rechts:
x = strassen(aktuell).x
IF x < 213 THEN strassen(aktuell).x = x + 1
zeigestr
RETURN
unten:
y = strassen(aktuell).y
IF y < 160 THEN strassen(aktuell).y = y + 1
zeigestr
RETURN
bildauf:
l = strassen(aktuell).laenge
IF l < 213 THEN strassen(aktuell).laenge = l + 1
zeigestr
RETURN
bildab:
l = strassen(aktuell).laenge
IF l > 0 THEN strassen(aktuell).laenge = l - 1
zeigestr
RETURN
einfg:
IF strmax < max THEN strmax = strmax + 1: aktuell = strmax - 1: neu (strmax - 1)
RETURN
entf:
BEEP
RETURN

SUB aktzeig
i = aktuell
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
LINE (3 * px, 3 * py)-(3 * pxneu + 2, 3 * pyneu + 2), 4, BF ' Rechteck
END SUB

SUB daten
CLS
PRINT "Nr"; TAB(7); "x"; TAB(13); "y"; TAB(18); "L„nge"; TAB(27); "R1"; TAB(33); "R2"
FOR i = 0 TO strmax - 1
PRINT i; TAB(7); strassen(i).x; TAB(13); strassen(i).y; TAB(18);
PRINT strassen(i).laenge; TAB(27); strassen(i).richtung; TAB(33); strassen(i).r2
NEXT i
END SUB

SUB neu (nr)
strassen(nr).laenge = 10
strassen(nr).x = 10
strassen(nr).y = 10
strassen(nr).richtung = 0
strassen(nr).r2 = 0
zeigestr
END SUB

SUB zeigestr
CLS
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
LINE (3 * px, 3 * py)-(3 * pxneu + 2, 3 * pyneu + 2), 14, BF ' Rechteck
NEXT i
aktzeig
END SUB

