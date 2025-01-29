DECLARE SUB Regeln ()
CLS
Regeln
CONST ESC = 27
WHILE farbanz < 2 OR farbanz > 15
INPUT "Wie viele Farben (>1; <16)"; farbanz
WEND
anz = 100
WHILE anz > 20
INPUT "Wie viele Versuche (<21)"; anz
WEND
CLS
vers = 1
farbe = 1
posi = 1
DIM raten(3)
RANDOMIZE TIMER
FOR i = 0 TO 3
raten(i) = INT(RND * (farbanz)) + 1
NEXT i
DIM a(3)
DIM b(3)
DIM c(3)
FOR i = 1 TO farbanz
COLOR i
LOCATE i, 2
PRINT "*"
NEXT i
LOCATE 1, 1
COLOR 15
PRINT ">"
LOCATE 2, 6
PRINT "^"
WHILE schwarz < 4 AND vers <= anz
schwarz = 0
weiss = 0
x = 3
IF vers < 10 THEN x = x + 1
LOCATE vers, x
PRINT vers
    ON KEY(11) GOSUB PauseHandler
    KEY(11) ON
    ON KEY(12) GOSUB PauseHandlerx
    KEY(12) ON
    ON KEY(13) GOSUB PauseHandlery
    KEY(13) ON
    ON KEY(14) GOSUB PauseHandlerxy
    KEY(14) ON
    ON KEY(1) GOSUB PauseHandlerxyz
    KEY(1) ON
zurueck:    WHILE INKEY$ <> CHR$(ESC)
    WEND
    GOTO weiterx
PauseHandler:
LOCATE farbe, 1
PRINT " "
farbe = ((farbe - 1) MOD farbanz + farbanz) MOD farbanz
IF farbe = 0 THEN farbe = farbanz
LOCATE farbe, 1
PRINT ">"
        RETURN
PauseHandlerx:
LOCATE vers + 1, 5 + posi
PRINT " "
posi = (posi + 3) MOD 4
IF posi = 0 THEN posi = 4
LOCATE vers + 1, 5 + posi
PRINT "^"
        RETURN
PauseHandlery:
LOCATE vers + 1, 5 + posi
PRINT " "
posi = (posi + 1) MOD 4
IF posi = 0 THEN posi = 4
LOCATE vers + 1, 5 + posi
PRINT "^"
        RETURN
PauseHandlerxy:
LOCATE farbe, 1
PRINT " "
farbe = (farbe + 1) MOD farbanz
IF farbe = 0 THEN farbe = farbanz
LOCATE farbe, 1
PRINT ">"
        RETURN
PauseHandlerxyz:
a(posi - 1) = farbe
LOCATE vers, 5 + posi
COLOR farbe
PRINT "*"
COLOR 15
LOCATE vers + 1, 5 + posi
PRINT " "
posi = (posi + 1) MOD 4
IF posi = 0 THEN posi = 4
LOCATE vers + 1, 5 + posi
PRINT "^"
        RETURN
weiterx: FOR i = 0 TO 3
IF a(i) = 0 THEN GOTO zurueck
NEXT i
vers = vers + 1
FOR i = 0 TO 3
IF a(i) = raten(i) THEN b(i) = 2: c(i) = 1
NEXT i
FOR i = 0 TO 3
        IF b(i) = 0 THEN
                FOR j = 0 TO 3
                        IF a(i) = raten(j) AND c(j) = 0 THEN
                                b(i) = 1: c(j) = 1: EXIT FOR
                        END IF
                NEXT j
        END IF
NEXT i
FOR i = 0 TO 3
SELECT CASE b(i)
CASE 1: weiss = weiss + 1
b(i) = 0
CASE 2: schwarz = schwarz + 1
b(i) = 0
END SELECT
a(i) = 0
c(i) = 0
NEXT i
Zeile = vers
LOCATE Zeile - 1, 12
IF weiss > 0 THEN FOR i = 1 TO weiss: sp = POS(0) + 1: PRINT CHR$(248): LOCATE CSRLIN - 1, sp: NEXT i
 COLOR 0, 15: IF schwarz > 0 THEN FOR i = 1 TO schwarz: sp = POS(0) + 1: PRINT CHR$(248): LOCATE CSRLIN - 1, sp: NEXT i
COLOR 15, 0
LOCATE vers, posi + 5
PRINT " "
LOCATE vers + 1, 6
posi = 1
IF schwarz < 4 AND vers <= anz THEN PRINT "^"
WEND
LOCATE 22, 1
ausg$ = "ERGEBNIS: "
IF schwarz = 4 THEN ausg$ = ausg$ + "RICHTIG  " ELSE ausg$ = ausg$ + "FALSCH   "
ausg$ = ausg$ + "        VERSUCHE:"
ausg$ = ausg$ + STR$(vers - 1)
ausg$ = ausg$ + " von "
ausg$ = ausg$ + STR$(anz)
PRINT ausg$
FOR i = 0 TO 3
LOCATE 22, 20 + i
COLOR raten(i)
PRINT "*"
NEXT i
COLOR 15

SUB Regeln
CLS
PRINT "                           MASTERMIND - REGELN"
PRINT " "
PRINT "Farbe wÑhlen:       NACH-OBEN-/NACH-UNTEN-TASTE    |(Tasten des"
PRINT "Position wÑhlen:    NACH-LINKS-/NACH-RECHTS-TASTE  | Nummernblocks)"
PRINT "          (Beide Pfeile kommen bei öberschreitung des Randes"
PRINT "                an der anderen Seite wieder heraus)"
PRINT ""
PRINT "Farbstecker setzen: F1"
PRINT "Eingabe beenden:    ESC-TASTE"
PRINT ""
PRINT "Schwarze Punkte: Richtige Position, richtige Farbe"
PRINT "Wei·e Punkte:    Richtige Farbe, aber falsche Position"
PRINT ""
PRINT ""
PRINT "-Abbrechen mit Strg+Pause"
PRINT "-Neues Spiel mit AusfÅhren>Start"
PRINT "-Beenden mit Datei>Beenden"
PRINT ""
PRINT ""
PRINT ""
PRINT ""
PRINT "                              Taste drÅcken"
SLEEP
CLS
END SUB

