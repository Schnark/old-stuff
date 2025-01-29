DECLARE SUB hilfe ()
DECLARE SUB egg ()
DECLARE SUB zeige ()
DECLARE SUB speichern ()
DECLARE SUB neu ()
DECLARE SUB abfragen ()
DECLARE SUB getvok ()
DECLARE FUNCTION pruefe! (gr$, dt$, grr$, dtr$)
TYPE vokabel
latvok AS STRING * 20
gram AS STRING * 20
deutsch AS STRING * 50
END TYPE

TYPE vokfach
latvok AS STRING * 20
gram AS STRING * 20
deutsch AS STRING * 50
altfach AS INTEGER
neufach AS INTEGER
END TYPE

DIM SHARED voknr
DIM SHARED fragen(1 TO 15) AS vokfach
DIM SHARED vok AS vokabel
COLOR 0, 15
getvok

DO
CLS
WHILE INKEY$ <> ""
WEND
PRINT "     Abfragen                      (A)"
PRINT "     Letzte Eingabe richtig        (R)"
PRINT "     Letzte Eingabe falsch         (F)"
PRINT "     Anzeige                       (Z)"
PRINT "     Neue Vokabeln                 (N)"
PRINT "     Hilfe                         (H)"
PRINT ""
PRINT "     Ende                          (E)"
taste$ = INKEY$
WHILE taste$ = ""
taste$ = INKEY$
WEND
taste$ = UCASE$(taste$)
CLS
SELECT CASE taste$
CASE "A": abfragen
CASE "R": fragen(voknr - 1).neufach = fragen(voknr - 1).altfach + 1
CASE "F": fragen(voknr - 1).neufach = 1
CASE "N": neu
CASE "Z": zeige
CASE "H": hilfe
CASE "E":
CASE ELSE: BEEP
END SELECT
LOOP UNTIL taste$ = "E"

speichern
COLOR 15, 0
CLS
END

SUB abfragen
DO
  IF fragen(voknr).latvok = STRING$(20, 0) THEN SLEEP: EXIT SUB
  PRINT fragen(voknr).latvok
  LINE INPUT antwort$
  IF antwort$ = "" THEN EXIT SUB
  posi = INSTR(antwort$, " ")
  gr$ = LEFT$(antwort$, posi - 1)
  dt$ = RIGHT$(antwort$, LEN(antwort$) - posi)
  richtig = pruefe(gr$, dt$, fragen(voknr).gram, fragen(voknr).deutsch)
  IF richtig = 1 THEN
    fragen(voknr).neufach = fragen(voknr).altfach + 1
  ELSE
    fragen(voknr).neufach = 1
  END IF
  voknr = voknr + 1
LOOP UNTIL voknr = 16
SLEEP
END SUB

SUB egg
DIM musik$(0 TO 4)
CLS
t = TIMER
k = 0
WHILE TIMER - t < 1
k = k + 1
WEND
k = k / 13
COLOR 17
PRINT : PRINT
PRINT "  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *"
PRINT
COLOR 20
PRINT "        ЫЫЫЫЫ           ЫЫЫЫЫЫЫЫЫЫ           ЫЫЫЫЫЫЫЫЫЫЫ        ЫЫЫЫЫЫЫЫЫЫЫЫ"
PRINT "      ЫЫЫЫ  ЫЫЫ         ЫЫ        ЫЫ       ЫЫ           ЫЫ      ЫЫ          ЫЫ"
PRINT "    ЫЫЫЫ      ЫЫЫ       ЫЫ         ЫЫ     ЫЫ             ЫЫ     ЫЫ           ЫЫ"
PRINT "  ЫЫЫЫ          ЫЫЫ     ЫЫ          ЫЫ    ЫЫ             ЫЫ     ЫЫ            ЫЫ"
PRINT "ЫЫЫЫ                    ЫЫ         ЫЫ    ЫЫ               ЫЫ    ЫЫ           ЫЫ"
PRINT "  ЫЫЫЫЫ                 ЫЫ        ЫЫ     ЫЫ               ЫЫ    ЫЫ          ЫЫ"
PRINT "      ЫЫЫЫЫ             ЫЫЫЫЫЫЫЫЫЫ      ЫЫ                 ЫЫ   ЫЫЫЫЫЫЫЫЫЫЫЫ"
PRINT "          ЫЫЫЫ          ЫЫ               ЫЫ               ЫЫ    ЫЫЫ"
PRINT "             ЫЫЫЫ       ЫЫ               ЫЫ               ЫЫ    ЫЫЫЫ"
PRINT "                 ЫЫЫ    ЫЫ                ЫЫ             ЫЫ     ЫЫ  ЫЫ"
PRINT "                  ЫЫЫ   ЫЫ                ЫЫ             ЫЫ     ЫЫ    ЫЫ"
PRINT " ЫЫЫЫ           ЫЫЫ     ЫЫ                 ЫЫ       ЫЫ  ЫЫ      ЫЫ      ЫЫ"
PRINT "   ЫЫЫЫ       ЫЫЫ       ЫЫ                 ЫЫ        ЫЫ ЫЫ      ЫЫ       ЫЫ"
PRINT "     ЫЫЫЫ   ЫЫЫ         ЫЫ                  ЫЫ         ЫЫ       ЫЫ        ЫЫ"
PRINT "        ЫЫЫЫЫЫ          ЫЫ                    ЫЫЫЫЫЫЫЫЫ  ЫЫ     ЫЫ         ЫЫ"
PRINT
COLOR 17
PRINT "*  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *  *"
FOR i = 0 TO 33
LOCATE 4 + INT(i / 2), 79 * ((i + 1) MOD 2) + 1, 0
PRINT "*"
NEXT i
COLOR 10
LOCATE 8, 12, 0: PRINT "M"
LOCATE 8, 22, 0: PRINT "I"
LOCATE 8, 31, 0: PRINT "C"
LOCATE 8, 40, 0: PRINT "H"
LOCATE 8, 50, 0: PRINT "A"
LOCATE 8, 62, 0: PRINT "E"
LOCATE 8, 72, 0: PRINT "L"
LOCATE 16, 12, 0: PRINT "M"
LOCATE 16, 28, 0: PRINT "љ"
LOCATE 16, 40, 0: PRINT "L"
LOCATE 16, 50, 0: PRINT "L"
LOCATE 16, 62, 0: PRINT "E"
LOCATE 16, 69, 0: PRINT "R"
nr = 0
musik$(0) = "C L8"
musik$(1) = "C C L4"
musik$(2) = "C"
musik$(3) = "C D"
musik$(4) = "C+ C L1 N0 L4"
PLAY "MB T240 L4 MS O2"
PLAY "X" + VARPTR$(musik$(nr)): nr = (nr + 1) MOD 5
COLOR 14
zeile$ = "SPQR = Senatus Populusque Romanus (Der r”mische Senat und das r”mische Volk)    "
WHILE 1
  LOCATE 24, 1, 0
  PRINT zeile$;
  zeile$ = MID$(zeile$, 2) + LEFT$(zeile$, 1)
  j = 1
  WHILE j < k
    IF INKEY$ <> "" THEN COLOR 0: EXIT SUB
    IF PLAY(0) = 0 THEN PLAY "X" + VARPTR$(musik$(nr)): nr = (nr + 1) MOD 5
    j = j + 1
  WEND
WEND
END SUB

SUB getvok
DIM vokspeich(1 TO 15) AS vokabel
OPEN "LATEIN1.VKB" FOR RANDOM AS #1 LEN = LEN(vok)
len1 = LOF(1) / 90
CLOSE #1
OPEN "LATEIN2.VKB" FOR RANDOM AS #1 LEN = LEN(vok)
len2 = LOF(1) / 90
CLOSE #1
OPEN "LATEIN3.VKB" FOR RANDOM AS #1 LEN = LEN(vok)
len3 = LOF(1) / 90
CLOSE #1
OPEN "LATEIN4.VKB" FOR RANDOM AS #1 LEN = LEN(vok)
len4 = LOF(1) / 90
CLOSE #1
OPEN "LATEIN5.VKB" FOR RANDOM AS #1 LEN = LEN(vok)
len5 = LOF(1) / 90
CLOSE #1
IF len1 > 10 THEN vok1 = len1 - 3
IF len2 > 15 THEN vok2 = 7
IF len3 > 20 THEN vok3 = 10
IF len4 > 25 THEN vok4 = 12
IF len5 > 30 THEN vok5 = 15
vokanz = vok1 + vok2 + vok3 + vok4 + vok5
dif = 15 - vokanz
IF dif > 0 THEN
 IF dif + vok1 <= len1 THEN
  vok1 = vok1 + dif
 ELSE
  vok1 = len1
  dif = 15 - (vokanz - vok1 + len1)
  IF dif + vok2 <= len2 THEN vok2 = vok2 + dif ELSE vok2 = len2
 END IF
ELSEIF dif < 0 THEN
 fak = 15 / vokanz
 vok1 = INT(vok1 * fak)
 vok2 = INT(vok2 * fak)
 vok3 = INT(vok3 * fak)
 vok4 = INT(vok4 * fak)
 vok5 = INT(vok5 * fak)
END IF

voknr = 1
j = 0
OPEN "LATEIN1.VKB" FOR RANDOM AS #1 LEN = LEN(vok)
FOR i = 1 TO vok1
GET #1, i, vokspeich(i + j)
NEXT i
j = vok1
CLOSE #1
OPEN "LATEIN2.VKB" FOR RANDOM AS #1 LEN = LEN(vok)
FOR i = 1 TO vok2
GET #1, i, vokspeich(i + j)
NEXT i
j = j + vok2
CLOSE #1
OPEN "LATEIN3.VKB" FOR RANDOM AS #1 LEN = LEN(vok)
FOR i = 1 TO vok3
GET #1, i, vokspeich(i + j)
NEXT i
j = vok3 + j
CLOSE #1
OPEN "LATEIN4.VKB" FOR RANDOM AS #1 LEN = LEN(vok)
FOR i = 1 TO vok4
GET #1, i, vokspeich(i + j)
NEXT i
j = vok4 + j
CLOSE #1
OPEN "LATEIN5.VKB" FOR RANDOM AS #1 LEN = LEN(vok)
FOR i = 1 TO vok5
GET #1, i, vokspeich(i + j)
NEXT i
CLOSE #1
RANDOMIZE TIMER

FOR i = 1 TO j + vok5
 DO
  nr = INT(RND * j) + 1
 LOOP WHILE vokspeich(nr).latvok = STRING$(20, 0)
 fragen(i).latvok = vokspeich(nr).latvok
 fragen(i).gram = vokspeich(nr).gram
 fragen(i).deutsch = vokspeich(nr).deutsch
 vokspeich(nr).latvok = STRING$(20, 0)

 IF nr <= vok1 THEN
  fach = 1
 ELSEIF nr <= vok1 + vok2 THEN
  fach = 2
 ELSE
  IF nr <= vok1 + vok2 + vok3 THEN
   fach = 3
  ELSEIF nr <= vok1 + vok2 + vok3 + vok4 THEN
   fach = 4
  ELSE
   fach = 5
  END IF
 END IF
 fragen(i).altfach = fach
NEXT i
END SUB

SUB hilfe
CLS
DO
PRINT " Hilfe zu (Ende mit X):"
PRINT
PRINT "      Abfragen                      (A)"
PRINT "      Letzte Eingabe richtig        (R)"
PRINT "      Letzte Eingabe falsch         (F)"
PRINT "      Anzeige                       (Z)"
PRINT "      Neue Vokabeln                 (N)"
PRINT "      Hilfe                         (H)"
PRINT ""
PRINT "      Ende                          (E)"
PRINT
PRINT " Allgemeines:"
PRINT
PRINT " Das Programm simuliert einen Vokabelkasten mit 5 F„chern."
PRINT " Gewusste Vokabeln kommen in das n„chste Fach, nicht gewusste"
PRINT " kommen wieder in Fach 1."
PRINT " Das 6. Fach enth„lt alle sicher gewussten Vokabeln, die nicht "
PRINT " mehr abgefragt werden."
PRINT " Die Dateien LATEINx.VKB (x steht fЃr 1-6) mЃssen im selben Verzeichnis"
PRINT " wie das Programm LATEIN.BAS und der Interpreter QBASIC.EXE stehen."
PRINT
PRINT
PRINT " ё 2003 by Michael MЃller"
taste$ = INKEY$
WHILE taste$ = ""
taste$ = INKEY$
WEND
taste$ = UCASE$(taste$)
CLS
SELECT CASE taste$
CASE "A":
PRINT " Fr„gt Vokabeln ab (max. 15 pro Sitzung)."
PRINT " Pause mit <Enter> als Eingabe."
PRINT " Bei der Eingabe muss zuerst die Grammatik (Stammformen, Genitiv, ...)"
PRINT " eingegeben werden (ohne Leerzeichen und exakt in der gespeicherten Form)."
PRINT " Dann folgt ein Leerzeichen und die deutschen Bedeutungen. Aus jeder Gruppe,"
PRINT " die mit Strichpunkten bei der Neueingabe angegeben werden, muss mindestens "
PRINT " eine Bedeutung gewusst werden. Die Reihenfolge ist beliebig."
CASE "R":
PRINT " Markiert die zu letzt abgefragte Vokabel als richtig (z. B. bei"
PRINT " Rechtschreibfehlern). "
CASE "F":
PRINT " Markiert die zu letzt abgefragte Vokabel als nicht gewusst."
CASE "N":
PRINT " Dient der Eingabe neuer Vokabeln."
PRINT " Ende der Eingabe mit <Enter> bei lateinischer Vokabel."
PRINT " Grammatik und deutsche Bedeutung ohne Leerzeichen angeben, "
PRINT " statt dessen Unterstrich (_) verwenden."
PRINT " Siehe auch Abfragen"
CASE "Z":
PRINT " Schreibt alle Vokabeln aus einem Fach an den Bildschirm."
CASE "E":
PRINT " Beendet das Programm."
PRINT " Alle Ver„nderungen werden automatisch abgespeichert."
CASE "M": egg
CASE "X":
CASE "H"
PRINT " Bietet Hilfe und ein etwas verstecktes Osterei :-)."
PRINT " Kleiner Tipp: Einen Buchstaben im Alphabet mag ich besonders."
CASE ELSE: BEEP
END SELECT
IF INSTR("ARFZNHE", taste$) THEN SLEEP
IF taste$ <> "X" THEN
 DO
  taste$ = INKEY$
 LOOP UNTIL taste$ = ""
END IF
LOOP UNTIL taste$ = "X"
CLS
END SUB

SUB neu
WHILE 1
LINE INPUT "Vokabel: ", lat$
IF lat$ = "" THEN EXIT SUB
vok.latvok = lat$
LINE INPUT "Formen: ", vok.gram
LINE INPUT "љbersetzung: ", vok.deutsch
OPEN "LATEIN1.VKB" FOR RANDOM AS #1 LEN = LEN(vok)
anz = INT(LOF(1) / 90 + .5)
PUT #1, anz + 1, vok
CLOSE #1
WEND
END SUB

FUNCTION pruefe (gr$, dt$, grr$, dtr$)
erg = 1
IF gr$ <> RTRIM$(grr$) THEN COLOR 4: erg = 0
PRINT RTRIM$(grr$);
COLOR 0

dtrn$ = RTRIM$(dtr$)
DO
 posi = INSTR(dtrn$, ";")
 IF posi = 0 THEN
  ende = 1
  bed$ = dtrn$
 ELSE
  bed$ = LEFT$(dtrn$, posi - 1)
  dtrn$ = RIGHT$(dtrn$, LEN(dtrn$) - posi)
 END IF
 erg2 = 0
 ende2 = 0
 DO
  posi = INSTR(bed$, ",")
  IF posi = 0 THEN
   ende2 = 1
   bed1$ = bed$
  ELSE
   bed1$ = LEFT$(bed$, posi - 1)
   bed$ = RIGHT$(bed$, LEN(bed$) - posi)
  END IF
  IF INSTR(dt$, bed1$) THEN erg2 = 1
 LOOP UNTIL ende2 = 1
 IF erg2 = 0 THEN erg = 0: COLOR 4
LOOP UNTIL ende = 1
PRINT " " + RTRIM$(dtr$)
COLOR 0
pruefe = erg
END FUNCTION

SUB speichern
FOR nr = 1 TO 5
 OPEN "LATEIN" + LTRIM$(STR$(nr)) + ".VKB" FOR RANDOM AS #1 LEN = LEN(vok)
' KILL "LATEIN.VKB"
 OPEN "LATEIN.VKB" FOR RANDOM AS #2 LEN = LEN(vok)
 FOR j = 1 TO INT(LOF(1) / 90 + .5)
  GET #1, , vok
  nicht = 0
  FOR i = 1 TO 15
   IF vok.latvok = fragen(i).latvok AND fragen(i).neufach <> 0 THEN nicht = 1: EXIT FOR
  NEXT i
  IF nicht = 0 THEN PUT #2, , vok
 NEXT j
 CLOSE #1, #2
 KILL "LATEIN" + LTRIM$(STR$(nr)) + ".VKB"
 NAME "LATEIN.VKB" AS "LATEIN" + LTRIM$(STR$(nr)) + ".VKB"
NEXT nr

FOR i = 1 TO 15
IF fragen(i).latvok = STRING$(20, 0) THEN EXIT SUB
vok.latvok = fragen(i).latvok
vok.gram = fragen(i).gram
vok.deutsch = fragen(i).deutsch
fachn = fragen(i).neufach
IF fachn <> 0 THEN
OPEN "LATEIN" + LTRIM$(STR$(fachn)) + ".VKB" FOR RANDOM AS #1 LEN = LEN(vok)
anz = INT(LOF(1) / 90 + .5)
PUT #1, anz + 1, vok
CLOSE #1
END IF
NEXT i
END SUB

SUB zeige
DIM voka AS vokabel
CLS
INPUT "Welches Fach (1-5, 0 fЃr alt)? ", fach
CLS
name$ = "LATEIN" + LTRIM$(STR$(fach)) + ".VKB"
IF fach = 0 THEN name$ = "LATEIN6.VKB"
OPEN name$ FOR RANDOM AS #1 LEN = LEN(vok)
anz = LOF(1) / 90
FOR i = 1 TO anz
GET #1, , voka
PRINT RTRIM$(voka.latvok); TAB(15); RTRIM$(voka.gram); TAB(35); RTRIM$(voka.deutsch)
IF i MOD 10 = 0 THEN PRINT
IF i MOD 20 = 0 THEN
 PRINT "                        --Taste--"
 SLEEP
 CLS
END IF
NEXT i
IF anz = 0 THEN PRINT "Keine Vokabeln vorhanden!" ELSE PRINT : PRINT anz; " Vokabeln vorhanden."
CLOSE (1)
SLEEP
CLS
END SUB

