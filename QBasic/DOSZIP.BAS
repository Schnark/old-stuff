DECLARE SUB liste ()
DECLARE SUB verz ()
DECLARE SUB test ()
DEFINT A-Z
DECLARE SUB toascii (von$, nach$)              'komprimiert Zahlen zu ASCII
DECLARE SUB tonum (von$, nach$)                'dekomprimiert ASCII zu Zahlen
DECLARE FUNCTION bin$ (zahl%)                  '-> BinÑrzahl
DECLARE FUNCTION dec% (b$)                     '-> Dezimalzahl
DECLARE FUNCTION wbuchnr% (wort$)              'sucht im Wîrterbuch
DECLARE SUB kompr (dateivon$, dateinach$)      'komprimiert
DECLARE SUB inwbuch (wort$)                    'fÅgt ins W.-buch ein
DECLARE SUB komprimieren ()
DECLARE SUB dekompr (dateivon$, dateinach$)    'dekomprimiert
DECLARE SUB dekomprimieren ()
ON ERROR GOTO fehler
'!! Fehler bei Dateien mit mehr als 3282 Zeichen? !!

CONST MAXWBUCH = 2047                          'Anzahl der WîrterbucheintrÑge
DIM SHARED wbuch(256 TO MAXWBUCH)  AS STRING   'Wîrterbuch (ohne ASCII)
DIM SHARED imax AS INTEGER                     'aktuelle Anzahl der Wîrter
imax = 255
DIM SHARED stellen                             'Stellenanzahl von BinÑrzahlen
DIM SHARED testdat1$, testdat2$
DIM SHARED TEMPDATEI$                          'Temp-Datei
DIM SHARED TEMPDATEI2$
TEMPDATEI$ = ENVIRON$("TEMP") + "\ZIP.TMP"
TEMPDATEI2$ = ENVIRON$("TEMP") + "\ZIP2.TMP"
COLOR 0, 15
CLS
PRINT "                        Komprimierungsprogramm DOSZIP"
VIEW PRINT 3 TO 25
DO
CLS
DO: wahl$ = INKEY$: LOOP UNTIL wahl$ = ""
PRINT "     K   Komprimieren"
PRINT "     D   Dekomprimieren"
PRINT "     V   Verzeichnis wechseln"
PRINT "     L   Dateiliste erstellen"
PRINT "     T   Test, ob Datei korrekt komprimiert wurde"
PRINT
PRINT "     E   Ende"
PRINT
PRINT
INPUT "--> ", wahl$
wahl$ = UCASE$(wahl$)
SELECT CASE wahl$
CASE "K": komprimieren: SLEEP
CASE "D": dekomprimieren: SLEEP
CASE "V": verz: SLEEP
CASE "L": liste: SLEEP
CASE "T": test: SLEEP
CASE "E":
CASE ELSE: BEEP
END SELECT
LOOP UNTIL wahl$ = "E"
VIEW PRINT
COLOR 15, 0
CLS
END
fehler:
 SELECT CASE ERR
 CASE 53:
          IF wahl$ = "L" THEN
           PRINT "Keine Datei vorhanden"
           RESUME NEXT
          ELSE
           PRINT "Datei existiert nicht!"
           ERROR ERR
          END IF
 CASE 76: PRINT "Verzeichnis existiert nicht!": RESUME NEXT
 CASE ELSE: ERROR ERR
 END SELECT

FUNCTION bin$ (zahl)
o$ = OCT$(zahl)
FOR i = 1 TO LEN(o$)
 SELECT CASE MID$(o$, i, 1)
  CASE "0": b$ = b$ + "000"
  CASE "1": b$ = b$ + "001"
  CASE "2": b$ = b$ + "010"
  CASE "3": b$ = b$ + "011"
  CASE "4": b$ = b$ + "100"
  CASE "5": b$ = b$ + "101"
  CASE "6": b$ = b$ + "110"
  CASE "7": b$ = b$ + "111"
 END SELECT
NEXT i
b$ = STRING$(stellen, "0") + b$
bin$ = RIGHT$(b$, stellen)
END FUNCTION

FUNCTION dec (b$)
d = 0
FOR i = 1 TO stellen
 d = 2 * d + VAL(MID$(b$, i, 1))
NEXT i
dec = d
END FUNCTION

SUB dekompr (dateivon$, dateinach$)
OPEN dateivon$ FOR INPUT AS #1                        'ôffnen
OPEN dateinach$ FOR OUTPUT AS #2
DO
INPUT #1, nr
 IF nr < 256 THEN zeichen$ = CHR$(nr) ELSE zeichen$ = wbuch(nr)  'nachschlagen
 IF zeichenalt$ <> "" THEN inwbuch zeichenalt$ + LEFT$(zeichen$, 1) 'hinzufÅgen
 PRINT #2, zeichen$;
 zeichenalt$ = zeichen$
LOOP UNTIL EOF(1)
END SUB

DEFSNG A-Z
SUB dekomprimieren
CLS
INPUT "Komprimierte Datei: ", d1$
INPUT "Dekomprimierte Datei: ", d2$
IF INSTR(d1$, ".") = 0 THEN d1$ = d1$ + ".zip"
IF LEFT$(d2$, 1) = "." THEN d2$ = LEFT$(d1$, LEN(d1$) - 4) + d2$ 'Eingabe als
tonum d1$, TEMPDATEI$                                            ' ".ext"
CLOSE
dekompr TEMPDATEI$, d2$
CLOSE
KILL TEMPDATEI$
END SUB

DEFINT A-Z
SUB inwbuch (wort$)
IF imax < MAXWBUCH THEN   'wenn Platz
 imax = imax + 1
 wbuch(imax) = wort$      'Wort in Wîrterbuch
END IF
END SUB

SUB kompr (dateivon$, dateinach$)
OPEN dateivon$ FOR INPUT AS #1                        'ôffnen
OPEN dateinach$ FOR OUTPUT AS #2

DO
 zeichen$ = INPUT$(1, #1)                              '1 Zeichen lesen
 kette$ = kette$ + zeichen$                            'an Kette anhÑngen
 nr = wbuchnr(kette$)                                  'nachschlagen
 IF nr = -1 OR EOF(1) THEN                             'nich gefunden o. Ende
  PRINT #2, wbuchnr(LEFT$(kette$, LEN(kette$) - 1))
                                                      'alte Kette in Datei
  inwbuch kette$                                      'neue Kette in W.-buch
  kette$ = RIGHT$(kette$, 1)                          'weiter
 END IF
LOOP UNTIL EOF(1)
PRINT #2, wbuchnr(kette$)
END SUB

DEFSNG A-Z
SUB komprimieren
CLS
INPUT "Ausgangsdatei: ", d1$
INPUT "komprimierte Datei: ", d2$
IF d2$ = "" THEN d2$ = LEFT$(d1$, LEN(d1$) - 4)
IF 0 = INSTR(d2$, ".") THEN d2$ = d2$ + ".zip"
kompr d1$, TEMPDATEI$
CLOSE
toascii TEMPDATEI$, d2$
CLOSE
KILL TEMPDATEI$
testdat1$ = d1$
testdat2$ = d2$
INPUT "Soll getestet werden, ob die Datei wieder hergestellt werden kann? ", w$
IF UCASE$(w$) = "J" THEN test
END SUB

DEFINT A-Z
SUB liste
CLS
INPUT "Suche nach: ", suche$
FILES suche$
END SUB

SUB test
CLS
tonum testdat2$, TEMPDATEI$
CLOSE
dekompr TEMPDATEI$, TEMPDATEI2$
CLOSE
KILL TEMPDATEI$
SHELL ("FC " + testdat1$ + " " + TEMPDATEI2$ + " |MORE")
KILL TEMPDATEI2$
END SUB

SUB toascii (von$, nach$)
OPEN von$ FOR INPUT AS #1
OPEN nach$ FOR OUTPUT AS #2
z$ = ""
DO
 stellen = INT(LOG(255 + l) / LOG(2)) + 1
 INPUT #1, nr
 l = l + 1
 z$ = z$ + bin$(nr)
 IF LEN(z$) >= 8 THEN
  DO
   n$ = LEFT$(z$, 8)
   z$ = MID$(z$, 9)
   PRINT #2, CHR$(dec(STRING$(stellen - 8, "0") + n$));
'  s = s + 1
  LOOP UNTIL LEN(z$) < 8
 END IF
LOOP UNTIL EOF(1)
IF z$ <> "" THEN
 z$ = LEFT$(STRING$(stellen - 8, "0") + z$ + STRING$(stellen, "0"), stellen)
 PRINT #2, CHR$(dec(z$));
's = s + 1
END IF
CLOSE
'PRINT "Gelesen: "; l, "Geschrieben: "; s
END SUB

SUB tonum (von$, nach$)
OPEN von$ FOR BINARY AS #1
OPEN nach$ FOR OUTPUT AS #2
z$ = ""
DO
 stellen = INT(LOG(255 + s) / LOG(2)) + 1
 n$ = INPUT$(1, #1)
 IF n$ = "" THEN EXIT DO
'l = l + 1
 z$ = z$ + RIGHT$(bin$(ASC(n$)), 8)
 IF LEN(z$) >= stellen THEN
  n$ = LEFT$(z$, stellen)
  z$ = MID$(z$, stellen + 1)
  PRINT #2, dec(n$)
  s = s + 1
  stellen = INT(LOG(255 + s) / LOG(2)) + 1
 END IF
LOOP UNTIL EOF(1)
CLOSE
'PRINT "Gelesen: "; l, "Geschrieben: "; s
END SUB

SUB verz
CLS
INPUT "Verzeichnis: ", v$
CHDIR v$
PRINT "Aktuelles Verzeichnis: "
SHELL "CD"
END SUB

FUNCTION wbuchnr (wort$)
nr = -1                                    '-1 = nicht im Wîrterbuch
IF LEN(wort$) = 1 THEN nr = ASC(wort$)     'ASCII-Zeichen: 0-255
i = 255
WHILE nr = -1 AND i < imax
i = i + 1
IF wbuch(i) = wort$ THEN nr = i            'Zeichenkombinationen im W.-buch
WEND
wbuchnr = nr
END FUNCTION

