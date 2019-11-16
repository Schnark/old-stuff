DEFINT A-Z
'_____________UNTERPROGRAMME_________________________________________________
DECLARE SUB fokus (feld%, richtung%)
'Ñndert den Fokus

DECLARE SUB verschiebe (feld%, dx%, dy%)
'Verschiebt feld und Nachkommen

DECLARE SUB aktiviere (fenster%)
'aktiviert fenster

DECLARE SUB echo (schalter%)
'schaltet die Bildschirmaktualisierung ein/aus

DECLARE SUB oeffne (feld%, top%, vor%)
'îffnet ein Dialogfeld; je grî·er top, desto weiter oben liegt es    | nicht
'vor: Vorfahre (nur eine Generation mîglich), -1 deaktiviert andere Fenster

DECLARE SUB schliesse (fenster%)
'schlie·t ein Fenster

DECLARE FUNCTION init% (anzahl%, aufruf%)
'Initialisiert dialogfeld

DECLARE SUB definieren (feld%, nr%, t%, x%, y%, b%, h%, i$)
'defieniert Element

DECLARE SUB aendern (feld%, nr%, art%, neu$)
'éndert das angegebene Element

DECLARE FUNCTION getx$ (feld%, nr%, art%)
'holt Objekt-Eigenschaft


DECLARE SUB laden (datei$)
'lÑdt Schriftdatei


DECLARE SUB deaktiviere ()
'deaktiert alle Fenster

DECLARE SUB allezeichnen (ab%)
'zeichnet alle Fenster ab Lage ab% in richtiger Reihenfolge

DECLARE SUB legenakt (feld%, obun%, akth%)
'regelt Reihenfolge der Aktivierungen

DECLARE SUB legen (feld%, obun%)
'Legt ein Fenster nach oben/unten

DECLARE SUB schiebe (obj AS ANY, feld AS ANY, richt)
'Verschiebt obj, sodass die relativen Koordinaten bezÅglich feld absolut sind
'(wenn richt = 0), sonst zurÅck

DECLARE SUB zeichnex (feld%)
'Zeichnet das gesamte Dialogfeld

DECLARE SUB schreibe (xpos, ypos, text$)
'Schreibt Text

DECLARE SUB zeichne (el AS ANY, akt)
' Zeichnet angegebenes Element

DECLARE FUNCTION gettyp (typ)
'Isoliert Typ aus Typ-Angabe

DECLARE SUB el3d (inout, incol, x, y, breite, hoehe, reccirc, akt, check)
'Zeichnet Element
'             0=nach innen      Startpunkt             0=Rechteck  1=markiert
'             1=nach aussen           Breite   Hoehe   1=Kreis
'             2=flach   Innenfarbe                         1=umrahmt

DECLARE SUB zpfeil (x%, y%, richtung%)
'zeichnet Pfeil

DECLARE SUB zlinie (x%, y%, l%, richtung%)
'zeichnet eine Linie ab (x,y) der LÑnge l; richtung = 0 : senkrecht, sonst w.

DECLARE SUB zscroll (x%, y%, l%, wert!, richtung%, akt%)
'zeichnet einen Scrollbar

DECLARE SUB zframe (x%, y%, hoehe%, breite%, l%)
'zeichnet einen Frame

DECLARE SUB schalt (x, y, breite, hoehe)
'Zeichnet eine (alte) SchaltflÑche


DECLARE FUNCTION eingabe$ (x, y, laenge, vorgabe$)
'Texteingabe mit Editierfunktionen

'_______________________________________________________________________


'_________________KONSTANTEN___________________________________________
CONST schwarz = 0, weiss = 15, hgrau = 7, dgrau = 8
'Farben

CONST maxlen = 20
'Max. LÑnge bei Beschriftungen

CONST button = 0, check = 1, radio = 2, inputx = 3, textx = 4, linie = 5
CONST scroll = 6, frame = 7
CONST dialogfeld = 100
'Typen

CONST AN = 1, AUS = 0, WECHSEL = 2
'fÅr echo

CONST maxx = 640 ', maxy = 480
DIM SHARED maxy
maxy = 480
'Bildschirmma·e

CONST arttyp = 0, artx = 1, arty = 2, artbreite = 3, arthoehe = 4, artinhalt = 5
CONST artsicht = 6, artakt = 7, arttop = 8
'fÅr getx und aendern

CONST flip = 0
IF flip THEN maxy = 350
'ohne Flackern
'______________________________________________________________________


'__________________TYPEN_______________________________________________
TYPE ele3d
typ AS INTEGER                        '+128 : inaktiv, +256: versteckt
x AS INTEGER
y AS INTEGER
breite AS INTEGER
hoehe AS INTEGER
inhalt AS STRING * maxlen
aktnr AS INTEGER
END TYPE

TYPE dialog
anzahl AS INTEGER
position AS INTEGER
lage AS INTEGER
akt AS INTEGER
top AS INTEGER
vorfahre AS INTEGER
aktnr AS INTEGER
END TYPE
'_______________________________________________________________________
DIM SHARED zeichen(0 TO 255) AS STRING * 16

DIM SHARED echovar
DIM SHARED echoab
echovar = AN

DIM SHARED fenstermax
fenstermax = 7
DIM SHARED felder(0 TO fenstermax) AS dialog                 '0: Hintergrund
testdia = init(6, 1)
meldung = init(2, 0)
oben = init(3, 0)
m1 = init(2, 0)
m2 = init(2, 0)
m3 = init(2, 0)
m4 = init(2, 0)

DIM SHARED elemente(1 TO init(0, 2)) AS ele3d

'<<<<<<<<<<<<<<<<   DEFINIEREN    >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
RESTORE testdial
definieren testdia, 0, dialogfeld + 256, 45, 30, 150, 200, "DIALOGFELD"
FOR i = 1 TO felder(testdia).anzahl
READ typ
READ x
READ y
READ breite
READ hoehe
READ inhalt$
definieren testdia, i, typ, x, y, breite, hoehe, inhalt$
IF i <= 4 THEN elemente(felder(testdia).position + i).aktnr = i
NEXT i
felder(testdia).aktnr = 1

RESTORE meldung
definieren meldung, 0, dialogfeld + 256, 50, 70, 90, 90, "MELDUNG"
definieren m1, 0, dialogfeld + 256, 100, 100, 90, 90, "A"
definieren m2, 0, dialogfeld + 256, 110, 110, 90, 90, "B"
definieren m3, 0, dialogfeld + 256, 120, 120, 90, 90, "C"
definieren m4, 0, dialogfeld + 256, 130, 130, 90, 90, "D"
felder(meldung).aktnr = 2
felder(m1).aktnr = 2
felder(m2).aktnr = 2
felder(m3).aktnr = 2
felder(m4).aktnr = 2
FOR i = 1 TO felder(meldung).anzahl
READ typ
READ x
READ y
READ breite
READ hoehe
READ inhalt$
definieren meldung, i, typ, x, y, breite, hoehe, inhalt$
definieren m1, i, typ, x, y, breite, hoehe, inhalt$
definieren m2, i, typ, x, y, breite, hoehe, inhalt$
definieren m3, i, typ, x, y, breite, hoehe, inhalt$
definieren m4, i, typ, x, y, breite, hoehe, inhalt$
NEXT i

definieren oben, 0, dialogfeld + 256, 100, 60, 100, 150, "OBEN"
definieren oben, 1, scroll, 15, 45, 70, 16, "500"
definieren oben, 2, scroll, 20, 65, 16, 80, "10"
definieren oben, 3, frame, 10, 30, 80, 120, "RAHMEN"
felder(oben).aktnr = 2

'<<<<<<<<<<<<<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

laden "NORMAL.FNT"

IF flip THEN SCREEN 9 ELSE SCREEN 12

legen 0, 0
zeichnex 0
'schalt 10, 10, 70, 20

'<<<<<<<<<<<<<<<<<<<<<<<<<   ZEICHNEN     >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

oeffne oben, 1, 0
oeffne testdia, 0, 0

'<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

SLEEP

'<<<<<<<<<<<<<<<<<<<<<<<<<   éNDERN      >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
aendern testdia, 4, arttyp, "128"
SLEEP
echo AUS
aendern testdia, 5, artx, "20"
aendern testdia, 3, artinhalt, "0"
SLEEP
aendern testdia, 6, artinhalt, "RQPOM"
aendern testdia, 0, artinhalt, "FELD"
echo AN
SLEEP
aendern testdia, 3, arttyp, "256"
SLEEP
aendern testdia, 3, artx, "30"
SLEEP
aendern testdia, 3, arttyp, "0"
SLEEP
'<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

oeffne meldung, 0, 0
SLEEP
schliesse meldung
aendern meldung, 1, artinhalt, "NEU"
SLEEP
oeffne meldung, -1, 0
'aendern meldung, 0, arttyp, "128"
SLEEP
aendern testdia, 6, artinhalt, "ABCDEF"
SLEEP
aendern testdia, 0, arty, "150"
SLEEP
schliesse testdia
SLEEP
schliesse meldung
SLEEP
schliesse oben
fenster = 1
Ende = 0
DO
DO: taste$ = INKEY$: LOOP UNTIL taste$ <> ""
SELECT CASE taste$
CASE "x": schliesse fenster
CASE "î": oeffne fenster, -1, 0
CASE "h": oeffne fenster, 1 - VAL(getx$(fenster, 0, arttop)), 0
CASE "a": aktiviere fenster
CASE "c": IF getx$(oben, 0, artsicht) = " 256" THEN oeffne oben, -1, 0 ELSE schliesse oben
CASE "w": fenster = 3 - fenster
CASE "j": verschiebe fenster, -10, 0
CASE "k": verschiebe fenster, 10, 0
CASE "i": verschiebe fenster, 0, -10
CASE "m": verschiebe fenster, 0, 10
CASE "z": aendern oben, 2, artinhalt, STR$(INT(1000 * RND))
CASE "e": echo WECHSEL
CASE "1": IF getx$(m1, 0, artsicht) = " 256" THEN oeffne m1, -1, fenster ELSE schliesse m1
CASE "!": aktiviere m1
CASE "2": IF getx$(m2, 0, artsicht) = " 256" THEN oeffne m2, -1, fenster ELSE schliesse m2
CASE CHR$(34): aktiviere m2
CASE "3": IF getx$(m3, 0, artsicht) = " 256" THEN oeffne m3, -1, fenster ELSE schliesse m3
CASE "ı": aktiviere m3
CASE "4": IF getx$(m4, 0, artsicht) = " 256" THEN oeffne m4, -1, -1 ELSE schliesse m4
CASE "$": aktiviere m4
CASE CHR$(9): fokus testdia, 1: verschiebe testdia, 0, 0
CASE CHR$(0) + CHR$(15): fokus testdia, -1: verschiebe testdia, 0, 0
CASE CHR$(27): Ende = 1
CASE "A" TO "R": aendern fenster, 1, artinhalt, STRING$(5, taste$)
CASE ELSE:  BEEP
END SELECT
DO: taste$ = INKEY$: LOOP UNTIL taste$ = ""
LOOP UNTIL Ende = 1

'<<<<<<<<<<<<<<<<<<   SCHRIFT     >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
'DRAW "C0"                                                 'normal
schreibe 20, 20, "ABCDEFGHIJKLMNOPQR"

'DRAW "S6"                                                 'gro·
'schreibe 20, 50, "ABCDEFGHIJKLMNOPQR"

'DRAW "S4 A3"                                              'senkrecht
'schreibe 20, 70, "ABCDEFGHIJKLMNOPQR"

'DRAW "A0"                                                 'fett
'schreibe 40, 70, "ABCDEFGHIJKLMNOPQR"
'schreibe 41, 70, "ABCDEFGHIJKLMNOPQR"
'schreibe 40, 69, "ABCDEFGHIJKLMNOPQR"
'schreibe 41, 69, "ABCDEFGHIJKLMNOPQR"

schreibe 40, 85, "ABCDEFGHIJKLMNOPQR"                     'unterstrichen
DRAW "bm 40,87 r144"
'<<<<<<<<<<<<<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

DO: a$ = INKEY$: LOOP UNTIL a$ = ""
SLEEP
SCREEN 0
WIDTH 80, 25
COLOR 7, 0

a$ = eingabe$(2, 10, 10, "Text")                       'Texteingabe

CLS
PRINT a$
SLEEP
CLS
testdial:
DATA   0,  10, 35,      70,   20,    "ABC"
DATA   2,  10, 75,      12,   12,    "1"
DATA   1,  10, 95,      12,   12,    "1"
DATA   3,  10, 115,     50,   15,    "HGFDE"
DATA   5,  10, 140,     80,    2,    ""
DATA   4,  10, 145,     50,   15,    "LIKJN"
   
meldung:
DATA   4,  10, 35,      70,   15,    "HINWEIS"
DATA   0,  20, 60,      50,   20,    "OK"
    'Typ    x   y   breite hoehe inhalt
END

SUB aendern (feld, nr, art, neu$)
IF flip THEN SCREEN 9, , 1, 0: PCOPY 0, 1
start = felder(feld).position
nrx = start + nr
t = gettyp(elemente(nrx).typ)
t2 = elemente(start).typ
t2 = t2 - gettyp(t2)
alt = echovar
echo AUS
IF echovar = AUS OR ((elemente(nrx).typ - t >= 256 OR t2 >= 256) AND art <> arttyp) THEN
                                                             'nicht sichtbar
 SELECT CASE art                                             '-> Ñndern
 CASE artinhalt: elemente(nrx).inhalt = neu$
 CASE artx: elemente(nrx).x = VAL(neu$)
 CASE arty: elemente(nrx).y = VAL(neu$)
 CASE artbreite: elemente(nrx).breite = VAL(neu$)
 CASE arthoehe: elemente(nrx).hoehe = VAL(neu$)
 END SELECT
 IF echovar = AUS AND art = arttyp THEN elemente(nrx).typ = t + VAL(neu$)
 GOTO Ende

ELSEIF (elemente(nrx).typ - i >= 256 OR t2 >= 256) AND art = arttyp THEN
                                                   '(noch) nicht sichtbar
 IF VAL(neu$) >= 256 THEN
  elemente(nrx).typ = t + VAL(neu$)    'nicht davor und nicht danach sichtbar
  GOTO Ende
 ELSE
  IF t = dialogfeld THEN
   elemente(nrx).typ = t + VAL(neu$)
   zeichnex feld
  ELSE
   elemente(nrx).typ = t + VAL(neu$)
   schiebe elemente(nrx), elemente(start), 0
   akt = 0: IF felder(feld).aktnr = nr THEN akt = 1
   zeichne elemente(nrx), akt
   schiebe elemente(nrx), elemente(start), 1
  END IF
 END IF
ELSE
 IF t = dialogfeld THEN
  IF art = artinhalt THEN
   elemente(nrx).inhalt = neu$
   IF elemente(nrx).typ - t = 128 THEN farbe = hgrau ELSE farbe = 4
   el3d 0, farbe, elemente(nrx).x, elemente(nrx).y, elemente(nrx).breite, 20, 0, 0, 0
   COLOR 0'DRAW "C0"
   schreibe 10 + elemente(nrx).x, 15 + elemente(nrx).y, neu$
  ELSE
   SELECT CASE art
   CASE arttyp: elemente(nrx).typ = t + VAL(neu$)                     'Ñndern
   CASE artx: elemente(nrx).x = VAL(neu$)
   CASE arty: elemente(nrx).y = VAL(neu$)
   CASE artbreite: elemente(nrx).breite = VAL(neu$)
   CASE arthoehe: elemente(nrx).hoehe = VAL(neu$)
   END SELECT
   allezeichnen 0
   GOTO Ende
   'IF VAL(neu$) >= 256 THEN legen feld, 1
   'FOR i = 0 TO fenstermax
   '  FOR j = 0 TO fenstermax
   '   IF felder(j).lage = i THEN zeichnex j
   '  NEXT j
   'NEXT i
  END IF
 ELSE
  IF art = artinhalt THEN
   schiebe elemente(nrx), elemente(start), 0
   'LINE (elemente(nrx).x, elemente(nrx).y)-(elemente(nrx).x + elemente(nrx).breite, elemente(nrx).y + elemente(nrx).hoehe), hgrau, BF
   elemente(nrx).inhalt = neu$
   akt = 0: IF felder(feld).aktnr = nr THEN akt = 1
   zeichne elemente(nrx), akt
   schiebe elemente(nrx), elemente(start), 1
  ELSE
   schiebe elemente(nrx), elemente(start), 0
   LINE (elemente(nrx).x, elemente(nrx).y)-(elemente(nrx).x + elemente(nrx).breite, elemente(nrx).y + elemente(nrx).hoehe), hgrau, BF
   schiebe elemente(nrx), elemente(start), 1                                         'lîschen
   SELECT CASE art
   CASE arttyp: elemente(nrx).typ = t + VAL(neu$)                     'Ñndern
   CASE artx: elemente(nrx).x = VAL(neu$)
   CASE arty: elemente(nrx).y = VAL(neu$)
   CASE artbreite: elemente(nrx).breite = VAL(neu$)
   CASE arthoehe: elemente(nrx).hoehe = VAL(neu$)
   END SELECT
   schiebe elemente(nrx), elemente(start), 0
   akt = 0: IF felder(feld).aktnr = nr THEN akt = 1
   zeichne elemente(nrx), akt
   schiebe elemente(nrx), elemente(start), 1                                         'neu zeichnen
  END IF
 END IF
END IF
IF felder(feld).lage < fenstermax THEN allezeichnen felder(feld).lage + 1
Ende:
echo alt
IF flip THEN PCOPY 1, 0: SCREEN 9, , 0, 0
END SUB

SUB aktiviere (fenster)
v = felder(fenster).vorfahre
IF v = -1 THEN
  legenakt fenster, 0, 1
  legen fenster, 0
  aendern fenster, 0, arttyp, "0"
ELSEIF v = 0 THEN
  alt = echovar
  echo AUS
  deaktiviere                       'deaktiviere alle
  legen fenster, 0
  aendern fenster, 0, arttyp, "0"
                                    'aktiviere obersten Nachkommen
  FOR i = 0 TO fenstermax
    FOR j = 0 TO fenstermax
      IF felder(j).akt = i THEN
        IF felder(j).vorfahre = fenster THEN legen j, 0: nach = j
      END IF
    NEXT j
  NEXT i
  IF nach <> 0 THEN aendern nach, 0, arttyp, "0"
  echo alt
  legenakt fenster, 0, 0
ELSE
  alt = echovar
  echo AUS
  legenakt fenster, 0, 0
  aktiviere v
  echo alt
END IF
END SUB

SUB allezeichnen (ab)
'ab = felder(0).lage
FOR i = ab TO fenstermax
  FOR j = 0 TO fenstermax
    IF felder(j).lage = i THEN zeichnex j
  NEXT j
NEXT i
END SUB

SUB deaktiviere
FOR i = 1 TO fenstermax
aendern i, 0, arttyp, STR$(VAL(getx$(i, 0, artsicht)) + 128)
NEXT i
END SUB

SUB definieren (feld, nr, t, x, y, b, h, i$)
nrx = felder(feld).position + nr
elemente(nrx).typ = t
elemente(nrx).x = x
elemente(nrx).y = y
elemente(nrx).breite = b
elemente(nrx).hoehe = h
elemente(nrx).inhalt = i$
END SUB

SUB echo (schalter)
IF echovar = schalter THEN EXIT SUB
IF schalter = WECHSEL THEN schalter = 1 - echovar
echovar = schalter
IF schalter = AN THEN allezeichnen echoab
END SUB

FUNCTION eingabe$ (x, y, laenge, vorgabe$) ', cursor$, blink)
leer$ = STRING$(laenge, " ")                         'Leerzeichen
text$ = vorgabe$                                     'aktueller Text
posi = LEN(text$)
IF posi = laenge THEN posi = posi - 1                'Cursorposition (am Ende)
' 1 2 3 4
'|T|e|x|t|
'001122334
fertig = 0                                           'noch nicht fertig
einf = 1                                             'EinfÅgemodus
WHILE INKEY$ = "": WEND

DO
IF nichts = 0 THEN                                   'bei énderung
LOCATE y, x
PRINT leer$                                          'lîschen
LOCATE y, x
PRINT text$                                          'neu schreiben
LOCATE y, x + posi, 1, 7 * einf + 1, 8               'Cursor setzen
ELSE
nichts = 0
END IF
taste$ = INKEY$                                      'Taste lesen
SELECT CASE taste$
CASE "": nichts = 1                                  'keine Eingabe
CASE CHR$(9): nichts = 1                             'Tabulator ignorieren
CASE CHR$(27): text$ = vorgabe$: fertig = 1          'ESC: Vorgabe Åbernehmen
CASE CHR$(8):                                        'lîschen
   IF posi > 0 THEN l$ = LEFT$(text$, posi - 1) ELSE l$ = ""   'linker Teil
   IF posi < LEN(text$) THEN r$ = RIGHT$(text$, LEN(text$) - posi) ELSE r$ = ""
   text$ = l$ + r$                                             'rechter Teil
   posi = posi - 1                                             'nach links
   IF posi < 0 THEN posi = 0
CASE CHR$(0) + CHR$(71): posi = 0                              'POS1
CASE CHR$(0) + CHR$(75): IF posi > 0 THEN posi = posi - 1      'Links
CASE CHR$(0) + CHR$(77): IF posi < LEN(text$) THEN posi = posi + 1
                                                               'Rechts
CASE CHR$(0) + CHR$(79): posi = LEN(text$)                     'ENDE
CASE CHR$(0) + CHR$(82): einf = 1 - einf                       'EINFG
CASE CHR$(0) + CHR$(83):                                       'ENTF
   l$ = LEFT$(text$, posi)                                     'links & rechts
   IF posi < LEN(text$) - 1 THEN r$ = RIGHT$(text$, LEN(text$) - posi - 1) ELSE r$ = ""
   text$ = l$ + r$
CASE CHR$(13): fertig = 1                                      'Eingabe
CASE ELSE
   IF LEN(taste$) = 2 THEN GOTO auscase                        'Sondertaste
   IF LEN(text$) < laenge OR (einf = 0 AND LEN(text$) = laenge AND posi <> laenge) THEN
      l$ = LEFT$(text$, posi)                              'Eingabe mîglich
      r$ = RIGHT$(text$, LEN(text$) - posi)                'links & rechts
      IF einf = 0 AND r$ <> "" THEN r$ = RIGHT$(r$, LEN(r$) - 1)
      text$ = l$ + taste$ + r$
      posi = posi + 1
   END IF
END SELECT
auscase:
LOOP UNTIL fertig = 1
LOCATE 1, 1, 0
eingabe$ = text$
END FUNCTION

SUB el3d (inout, incol, x, y, breite, hoehe, reccirc, akt, check)

IF akt = 1 THEN                                   'wenn aktiv, dann umrahmen
 IF reccirc = 0 THEN
  LINE (x - 1, y - 1)-(x + breite + 1, y + hoehe + 1), schwarz, BF
 ELSE
  CIRCLE (x + INT(breite / 2), y + INT(hoehe / 2)), INT(breite / 2) + 1, schwarz
 END IF
END IF

IF reccirc = 1 THEN GOTO kreis                                         'rund?

ol = weiss                                                        'Randfarben
ur = schwarz
iur = dgrau
IF inout = 0 THEN ol = dgrau: ur = weiss: iur = hgrau
IF inout = 2 THEN ol = incol: ur = incol: iur = incol

LINE (x, y)-(x + breite - 1, y), ol                           'oben und links
LINE (x, y + 1)-(x, y + hoehe - 1), ol

LINE (x + breite, y)-(x + breite, y + hoehe), ur            'unten und rechts
LINE (x, y + hoehe)-(x + breite - 1, y + hoehe), ur
                                                               'innen u. + r.
LINE (x + 1, y + hoehe - 1)-(x + breite - 1, y + hoehe - 1), iur
LINE (x + breite - 1, y + 1)-(x + breite - 1, y + hoehe - 1), iur

LINE (x + 1, y + 1)-(x + breite - 2, y + hoehe - 2), incol, BF         'innen

IF inout = 0 THEN
 LINE (x + 1, y + 1)-(x + breite - 2, y + 1), schwarz          'innen o. + l.
 LINE (x + 1, y + 2)-(x + 1, y + hoehe - 2), schwarz
END IF

IF check = 1 THEN                                         'Checkbox markiert?
 'LINE (x + 3, y + 3)-(x + 9, y + 9), schwarz  'Kreuz
 'LINE (x + 4, y + 3)-(x + 9, y + 8), schwarz
 'LINE (x + 3, y + 4)-(x + 8, y + 9), schwarz
 'LINE (x + 9, y + 3)-(x + 3, y + 9), schwarz
 'LINE (x + 8, y + 3)-(x + 3, y + 8), schwarz
 'LINE (x + 9, y + 4)-(x + 4, y + 9), schwarz

 LINE (x + 3, y + 5)-STEP(0, 2), schwarz       'Haken
 LINE (x + 4, y + 6)-STEP(0, 2), schwarz
 LINE (x + 5, y + 7)-STEP(0, 2), schwarz
 LINE (x + 6, y + 6)-STEP(0, 2), schwarz
 LINE (x + 7, y + 5)-STEP(0, 2), schwarz
 LINE (x + 8, y + 4)-STEP(0, 2), schwarz
 LINE (x + 9, y + 3)-STEP(0, 2), schwarz
END IF

GOTO weiter

kreis:
 xm = x + INT(breite / 2): ym = y + INT(hoehe / 2): r = INT(breite / 2)
 CIRCLE (xm, ym), r, dgrau, .61, 3.75
 CIRCLE (xm, ym), r, weiss, 3.75, .61
 CIRCLE (xm, ym), r - 1, schwarz, .61, 3.75
 CIRCLE (xm, ym), r - 1, hgrau, 3.75, .61
 CIRCLE (xm, ym), r - 2, incol
 PAINT (xm, ym), incol, incol

 IF check = 1 THEN                                 'Punkt
  LINE (x + 4, y + 4)-(x + 7, y + 7), schwarz, BF
  PSET (x + 3, y + 5), dgrau: PSET (x + 3, y + 6), dgrau
  PSET (x + 8, y + 5), dgrau: PSET (x + 8, y + 6), dgrau
  PSET (x + 5, y + 3), dgrau: PSET (x + 6, y + 3), dgrau
  PSET (x + 5, y + 8), dgrau: PSET (x + 6, y + 8), dgrau
 END IF
weiter:
END SUB

SUB fokus (feld, richtung)
aktnr = felder(feld).aktnr
start = felder(feld).position
element = start + aktnr
aktnr = elemente(element).aktnr + richtung
max = 0
FOR i = start + 1 TO start + felder(feld).anzahl
 IF elemente(i).aktnr > max THEN max = elemente(i).aktnr
NEXT i
aktnr = aktnr MOD max
IF aktnr = 0 THEN aktnr = max
FOR i = start + 1 TO start + felder(feld).anzahl
 IF elemente(i).aktnr = aktnr THEN EXIT FOR
NEXT i
felder(feld).aktnr = i - start
END SUB

FUNCTION gettyp (typ)
gettyp = typ MOD 128
END FUNCTION

FUNCTION getx$ (feld, nr, art)
nrx = felder(feld).position + nr
 SELECT CASE art
 CASE arttyp: getx$ = STR$(gettyp(elemente(nrx).typ))
 CASE artakt: getx$ = STR$((elemente(nrx).typ - gettyp(elemente(nrx).typ)) MOD 256)
 CASE artsicht: getx$ = STR$(256 * INT((elemente(nrx).typ - gettyp(elemente(nrx).typ)) / 256))
 CASE artinhalt: getx$ = elemente(nrx).inhalt
 CASE artx: getx$ = STR$(elemente(nrx).x)
 CASE arty: getx$ = STR$(elemente(nrx).y)
 CASE artbreite: getx$ = STR$(elemente(nrx).breite)
 CASE arthoehe: getx$ = STR$(elemente(nrx).hoehe)
 CASE arttop: getx$ = STR$(felder(feld).top)
 END SELECT
END FUNCTION

FUNCTION init (anzahl, aufruf)
STATIC posi, nr
IF aufruf = 1 THEN posi = 1: nr = 1
IF aufruf = 2 THEN init = posi - 1: EXIT FUNCTION
felder(nr).position = posi
felder(nr).anzahl = anzahl
felder(nr).lage = nr - 1
posi = posi + 1 + anzahl
nr = nr + 1
init = nr - 1
END FUNCTION

SUB laden (datei$)
DIM z AS STRING * 1
OPEN datei$ FOR BINARY AS #1
FOR i = 0 TO 255
zz$ = ""
FOR j = 1 TO 16
GET #1, 16 * i + j, z
zz$ = zz$ + z
NEXT j
zeichen(i) = zz$
NEXT i
CLOSE #1
END SUB

SUB legen (feld, obun)
IF obun = 0 THEN 'nach oben
  hoeher = 0
  FOR i = 0 TO fenstermax
    IF felder(i).lage > felder(feld).lage THEN
       IF felder(i).top <= felder(feld).top THEN
          felder(i).lage = felder(i).lage - 1
       ELSE
          hoeher = hoeher + 1
       END IF
    ELSE
       IF felder(i).top > felder(feld).top THEN
          hoeher = hoeher + 1
          felder(i).lage = felder(i).lage + 1
       END IF
    END IF
  NEXT i
  felder(feld).lage = fenstermax - hoeher
ELSE 'nach unten
  FOR i = 0 TO fenstermax
    IF felder(i).lage < felder(feld).lage THEN felder(i).lage = felder(i).lage + 1
  NEXT i
  felder(feld).lage = 0
END IF
END SUB

SUB legenakt (feld, obun, akth)
IF obun = 0 THEN 'nach oben
  hoeher = 0
  FOR i = 1 TO fenstermax
    IF felder(i).akt > felder(feld).akt THEN
       IF akth = 1 THEN 'aktive Fenster bleiben hîher
          IF getx$(i, 0, artakt) <> " 0" THEN felder(i).akt = felder(i).akt - 1
       ELSE
          felder(i).akt = felder(i).akt - 1
       END IF
    END IF
  NEXT i
  felder(feld).akt = fenstermax - hoeher
ELSE 'nach unten
  FOR i = 0 TO fenstermax
    IF felder(i).akt < felder(feld).akt THEN felder(i).akt = felder(i).akt + 1
  NEXT i
  felder(feld).akt = 0
END IF
END SUB

SUB oeffne (feld, top, vor)
alt = echovar
echo AUS
IF top <> -1 THEN felder(feld).top = top
felder(feld).vorfahre = vor
legen feld, 0
aendern feld, 0, arttyp, "0"
aktiviere feld
echo alt
END SUB

SUB schalt (x, y, breite, hoehe)
LINE (x + 3, y + 3)-(x + breite - 3, y + hoehe - 3), 7, BF

LINE (x + 1, y)-(x + breite - 1, y), 0
LINE (x + 1, y + hoehe)-(x + breite - 1, y + hoehe), 0
LINE (x, y + 1)-(x, y + hoehe - 1), 0
LINE (x + breite, y + 1)-(x + breite, y + hoehe - 1), 0

LINE (x + 2, y + 1)-(x + breite - 2, y + 1), 15        'x+1
LINE (x + 2, y + 2)-(x + breite - 3, y + 2), 15    'x+1
'LINE (x + 1, y + 3)-(x + 1, y + hoehe - 2), 15
LINE (x + 2, y + 3)-(x + 2, y + hoehe - 2), 15

LINE (x + breite - 1, y + 1)-(x + breite - 1, y + hoehe - 1), 8
LINE (x + breite - 2, y + 2)-(x + breite - 2, y + hoehe - 1), 8
LINE (x + 3, y + hoehe - 2)-(x + breite - 1, y + hoehe - 2), 8
LINE (x + 2, y + hoehe - 1)-(x + breite - 1, y + hoehe - 1), 8
END SUB

SUB schiebe (obj AS ele3d, feld AS ele3d, richt)
IF richt = 0 THEN
 obj.x = obj.x + feld.x
 obj.y = obj.y + feld.y
ELSE
 obj.x = obj.x - feld.x
 obj.y = obj.y - feld.y
END IF
END SUB

SUB schliesse (fenster)
'lege fenster,1
alt = echovar
echo AUS
v = felder(fenster).vorfahre
felder(fenster).vorfahre = 0
aktiv = VAL(getx$(fenster, 0, artakt))
FOR i = 1 TO fenstermax
  IF felder(i).vorfahre = fenster THEN 'schliesse i
    felder(i).vorfahre = 0
    aendern i, 0, arttyp, "256"' STR$(VAL(getx$(i, 0, artakt)) + 256)
    legenakt i, 1, 0
  END IF
NEXT i
aendern fenster, 0, arttyp, "256"' STR$(VAL(getx$(fenster, 0, artakt)) + 256)
legenakt fenster, 1, 0

IF v > 0 AND aktiv = 0 THEN aktiviere v: aktiv = 1
IF v = -1 AND aktiv = 0 THEN
  FOR i = 1 TO fenstermax
  IF getx$(i, 0, artakt) = " 0" AND getx$(i, 0, artsicht) = " 0" THEN aktiv = 1
  NEXT i
END IF
IF aktiv = 0 THEN
  FOR i = 1 TO fenstermax
  IF felder(i).akt = fenstermax THEN aktiviere i
  NEXT i
END IF
echo alt
END SUB

SUB schreibe (xpos, ypos, text$)
'spalte = INT(xpos / maxx * 80 + .9)   'Grafikkoordinaten ->
'zeile = INT(ypos / maxy * 30)         'Textkoordinaten
'IF spalte = 0 THEN spalte = 1
'IF zeile = 0 THEN zeile = 1
'LOCATE zeile, spalte
'PRINT text$

FOR k = 1 TO LEN(text$)
kette$ = zeichen(ASC(MID$(text$, k, 1)))
FOR i = -12 TO 3
 zz = ASC(MID$(kette$, 13 + i, 1))
 FOR j = 8 TO 1 STEP -1
  bit = zz MOD 2: zz = INT(zz / 2)
  IF bit = 1 THEN PSET (xpos + 8 * k - 8 + j, ypos + i)
 NEXT j
NEXT i
NEXT k


'stelle$ = "BM" + STR$(xpos) + "," + STR$(ypos)
'DRAW "X" + VARPTR$(stelle$)

'FOR i = 1 TO LEN(text$)
'SELECT CASE MID$(text$, i, 1)
'CASE "A": DRAW "M+3,-9 M+3,+9 BM-2,-4 L3 BM +7,+4"    'A
'CASE "B": DRAW "U8 R3 F2 G2 NL3 F2 G2 L3 BR8"         'B
'CASE "C": DRAW "BM+6,-9 L3 G3 D3 F3 R3 BR2"           'C
'CASE "D": DRAW "U9 R3 F3 D3 G3 L3 BR8"                'D
'CASE "E": DRAW "U9 NR5 BD4 NR3 BD5 R5 BR3"            'E
'CASE "F": DRAW "U9 NR5 BD4 NR3 BD5 BR8"               'F
'CASE "G": DRAW "BM+6,-9 L3 G3 D3 F3 R3 U3 L2 BR4 BD3" 'G
'CASE "H": DRAW "U9 BD4 R6 BU4 D9 BR2"                 'H
'CASE "I": DRAW "BR3 NU9 BR5"                          'I
'CASE "J": DRAW "BR6 BU2 NU7 G2 L2 H2 BR8 BD2"         'J
'CASE "K": DRAW "U9 BD5 NE5 BE1 F5 BR2"                'K
'CASE "L": DRAW "NU9 R5 BR3"                           'L
'CASE "M": DRAW "U9 F3 E3 D9 BR2"                      'M
'CASE "N": DRAW "U9 M+6,+9 NU9 BR2"                    'N
'CASE "O": DRAW "BU2 U5 E2 R2 F2 D5 G2 L2 NH2 BR6"     'O
'CASE "P": DRAW "U9 R3 F2 D1 G2 L3 BD4 BR8"            'P
'CASE "Q": DRAW "BU2 U5 E2 R2 F2 D5 G2 L2 NH2 BR4 NH3 BR2"  'Q
'CASE "R": DRAW "U9 R2 F2 D1 G2 L2 F4 BR4"             'R
'CASE ELSE:
'END SELECT
'NEXT i
END SUB

SUB verschiebe (feld, dx, dy)
alt = echovar
echo AUS
aendern feld, 0, artx, STR$(VAL(getx$(feld, 0, artx)) + dx)
aendern feld, 0, arty, STR$(VAL(getx$(feld, 0, arty)) + dy)
FOR i = 1 TO fenstermax
  IF felder(i).vorfahre = feld THEN
    aendern i, 0, artx, STR$(VAL(getx$(i, 0, artx)) + dx)
    aendern i, 0, arty, STR$(VAL(getx$(i, 0, arty)) + dy)
  END IF
NEXT i
echo alt
END SUB

SUB zeichne (el AS ele3d, akt)
IF el.typ >= 256 THEN EXIT SUB                         'wenn nicht sichtbar
t = gettyp(el.typ)
zeichnen = 1: beschriften = 1
SELECT CASE t
CASE button
        io = 1
        IF akt >= 2 THEN io = 0
        ifa = hgrau
        rk = 0
        ak = 0
        IF akt = 1 OR akt = 3 THEN ak = 1
        ck = 0
CASE check
        io = 0
        IF el.typ >= 128 THEN ifa = hgrau ELSE ifa = weiss
        rk = 0
        ak = 0
        IF akt = 1 OR akt = 3 THEN ak = 1
        ck = VAL(el.inhalt)
        beschriften = 0
CASE radio
        io = 0
        IF el.typ >= 128 THEN ifa = hgrau ELSE ifa = weiss
        rk = 1
        ak = 0
        IF akt = 1 OR akt = 3 THEN ak = 1
        ck = VAL(el.inhalt)
        beschriften = 0
CASE inputx
        io = 0
        IF el.typ >= 128 THEN ifa = hgrau ELSE ifa = weiss
        rk = 0
        ak = 0
        IF akt = 1 OR akt = 3 THEN ak = 1
        ck = 0
CASE textx
        io = 2
        ifa = hgrau
        rk = 0
        ak = 0
        ck = 0
CASE linie
        IF el.breite = 2 THEN                       'senkrechte Linie
         zlinie el.x, el.y, el.hoehe, 0
        ELSE                                        'waagerechte Linie
         zlinie el.x, el.y, el.breite, 1
        END IF
        zeichnen = 0: beschriften = 0
CASE scroll
        IF akt = 1 OR akt = 3 THEN ak = 1
        x = el.x: y = el.y
        IF el.breite = 16 THEN                      'senkrechter Scroll-Bar
         zscroll x, y, el.hoehe, VAL(el.inhalt) / 1000, 0, ak
        ELSE                                        'waagerechter Scroll-Bar
         zscroll x, y, el.breite, VAL(el.inhalt) / 1000, 1, ak
        END IF
        zeichnen = 0: beschriften = 0
CASE frame
        zframe el.x, el.y, el.hoehe, el.breite, LEN(RTRIM$(el.inhalt))
        IF el.typ - t = 128 THEN COLOR 8 ELSE COLOR 0'DRAW "C8" ELSE DRAW "C0"
        schreibe el.x + 10, el.y + 4, RTRIM$(el.inhalt)
        zeichnen = 0: beschriften = 0
CASE dialogfeld
        IF el.typ - gettyp(el.typ) = 128 THEN farbe = hgrau ELSE farbe = 4
        el3d 0, farbe, el.x, el.y, el.breite, 20, 0, 0, 0         'Titelleiste
        el3d 1, hgrau, el.x, 20 + el.y, el.breite, el.hoehe, 0, 0, 0
        COLOR 0'DRAW "C0"
        schreibe 10 + el.x, 15 + el.y, el.inhalt
        zeichnen = 0: beschriften = 0
END SELECT

IF zeichnen = 1 THEN
  x = el.x: y = el.y: b = el.breite: h = el.hoehe
  el3d io, ifa, x, y, b, h, rk, ak, ck
END IF

IF beschriften = 1 THEN
  IF el.typ - t = 128 THEN COLOR 8 ELSE COLOR 0'DRAW "C8" ELSE DRAW "C0"
  schreibe el.x + 4, el.hoehe + el.y - 3, RTRIM$(el.inhalt)
END IF
END SUB

SUB zeichnex (feld)
IF feld = 0 THEN LINE (0, 0)-(maxx, maxy), 1, BF: EXIT SUB: legen 0, 0: EXIT SUB
t = elemente(felder(feld).position).typ
IF t - gettyp(t) >= 256 THEN EXIT SUB
zeichne elemente(felder(feld).position), 0
FOR i = 1 + felder(feld).position TO felder(feld).position + felder(feld).anzahl
 schiebe elemente(i), elemente(felder(feld).position), 0
 akt = 0: IF felder(feld).aktnr = i - felder(feld).position THEN akt = 1
 zeichne elemente(i), akt
 schiebe elemente(i), elemente(felder(feld).position), 1
NEXT i
'legen feld, 0
END SUB

SUB zframe (x, y, hoehe, breite, l)
zlinie x, y, hoehe, 0
zlinie x, y + hoehe, breite, 1
zlinie x + breite, y, hoehe, 0
zlinie x, y, breite, 1
LINE (x + 8, y)-(x + 11 + 8 * l, y + 1), hgrau, BF
END SUB

SUB zlinie (x, y, l, richtung)
IF richtung = 0 THEN           'senkrecht
   LINE (x, y)-(x, y + l), dgrau
   LINE (x + 1, y)-(x + 1, y + l), weiss
ELSE                           'waagerecht
   LINE (x, y)-(x + l, y), dgrau
   LINE (x, y + 1)-(x + l, y + 1), weiss
END IF
END SUB

SUB zpfeil (x, y, richtung)
SELECT CASE richtung
CASE 1 '^
        LINE (x + 7, y + 5)-(x + 9, y + 11), schwarz, BF
        PSET (x + 8, y + 4), schwarz
        PSET (x + 5, y + 7), schwarz
        PSET (x + 6, y + 6), schwarz
        PSET (x + 6, y + 7), schwarz
        PSET (x + 10, y + 6), schwarz
        PSET (x + 10, y + 7), schwarz
        PSET (x + 11, y + 7), schwarz
CASE 2 '>
        LINE (x + 11, y + 7)-(x + 5, y + 9), schwarz, BF
        PSET (x + 12, y + 8), schwarz
        PSET (x + 9, y + 5), schwarz
        PSET (x + 10, y + 6), schwarz
        PSET (x + 9, y + 6), schwarz
        PSET (x + 10, y + 10), schwarz
        PSET (x + 9, y + 10), schwarz
        PSET (x + 9, y + 11), schwarz
CASE 3 'v
        LINE (x + 7, y + 11)-(x + 9, y + 5), schwarz, BF
        PSET (x + 8, y + 12), schwarz
        PSET (x + 5, y + 9), schwarz
        PSET (x + 6, y + 10), schwarz
        PSET (x + 6, y + 9), schwarz
        PSET (x + 10, y + 10), schwarz
        PSET (x + 10, y + 9), schwarz
        PSET (x + 11, y + 9), schwarz
CASE 4 '<
        LINE (x + 5, y + 7)-(x + 11, y + 9), schwarz, BF
        PSET (x + 4, y + 8), schwarz
        PSET (x + 7, y + 5), schwarz
        PSET (x + 6, y + 6), schwarz
        PSET (x + 7, y + 6), schwarz
        PSET (x + 6, y + 10), schwarz
        PSET (x + 7, y + 10), schwarz
        PSET (x + 7, y + 11), schwarz
END SELECT
'   1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6
'1
'2
'3
'4                *
'5              * * *
'6            * * * * *
'7          * * * * * * *
'8              * * *
'9              * * *
'0              * * *
'1              * * *
'2
'3
'4
'5
'6
END SUB

SUB zscroll (x, y, l, wert!, richtung, akt)
el3d 1, hgrau, x, y, 16, 16, 0, 0, 0                            'SchaltflÑche

IF richtung = 0 THEN                                            'senkrecht
  el3d 1, hgrau, x, y + l - 16, 16, 16, 0, 0, 0                 'SchaltflÑche
  zpfeil x, y, 1
  zpfeil x, y + l - 16, 3
  el3d 0, dgrau, x, y + 17, 16, l - 34, 0, 0, 0                 'Leiste
  el3d 1, hgrau, x, y + 17 + wert! * (l - 50), 16, 16, 0, akt, 0  'Schieber

ELSE                                                            'waagerecht
  el3d 1, hgrau, x + l - 16, y, 16, 16, 0, 0, 0                 'SchaltflÑche
  zpfeil x, y, 4
  zpfeil x + l - 16, y, 2
  el3d 0, dgrau, x + 17, y, l - 34, 16, 0, 0, 0                 'Leiste
  el3d 1, hgrau, x + 17 + wert! * (l - 50), y, 16, 16, 0, akt, 0  'Schieber
END IF
END SUB

