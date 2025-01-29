DECLARE SUB neu (nr!)
DECLARE SUB status (art!)
DECLARE SUB verschiebe (nummer!, attrib!, wert)
DECLARE SUB position (nr)
DECLARE SUB zeige (nr)
DECLARE SUB bild ()
DECLARE SUB spiel (nr%)
CONST ESC = 27
TYPE ton
        hoehe AS STRING * 1
        art AS STRING * 1
        punkt AS STRING * 1
        okt AS STRING * 1
        vorz AS STRING * 1
        laenge AS STRING * 1
END TYPE
CLS
PRINT "NUM-Taste ausschalten."
PRINT "Tasten auf Ziffernblock verwenden."
DO
INPUT "Wie viele Noten(<155)", ende
LOOP UNTIL ende < 155
DIM SHARED note(ende) AS ton

note(1).hoehe = "P"
note(1).art = " "
note(1).punkt = " "
note(1).okt = "1"
note(1).vorz = " "
note(1).laenge = "2"

letzt = 1
nummer = 1
attrib = 2
CLS
bild
zeige (1)

KEY 15, CHR$(0) + CHR$(82)
KEY 16, CHR$(0) + CHR$(83)
   
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
    ON KEY(2) GOSUB PauseHandlerxyzb
    KEY(2) ON
    ON KEY(3) GOSUB PauseHandlerxyzc
    KEY(3) ON
    ON KEY(4) GOSUB PauseHandlerxyzd
    KEY(4) ON
    ON KEY(9) GOSUB PauseHandlerxyza
    KEY(9) ON
    ON KEY(15) GOSUB PauseHandlerein
    KEY(15) ON
    ON KEY(16) GOSUB PauseHandlerent
    KEY(16) ON
   
    DO
   taste$ = INKEY$
   SELECT CASE attrib
        CASE 1: IF INSTR("<._ ", taste$) > 1 THEN note(nummer).art = taste$
        CASE 2: IF INSTR("<CDEFGAHP", taste$) > 1 THEN note(nummer).hoehe = taste$
        CASE 3: IF INSTR("<#+- ", taste$) > 1 THEN note(nummer).vorz = taste$
        CASE 4: IF INSTR("<. ", taste$) > 1 THEN note(nummer).punkt = taste$
        CASE 5: IF INSTR("<123456789", taste$) > 1 THEN note(nummer).laenge = taste$
        CASE 6: IF INSTR("<0123456", taste$) > 1 THEN note(nummer).okt = taste$
    END SELECT
    IF taste$ >= " " THEN zeige (nummer)
    LOOP UNTIL taste$ = CHR$(ESC)
    GOTO ende

PauseHandler:
LOCATE attrib + 7 * INT(nummer / 78) + 1, 1
IF nummer = 77 * 2 + 1 THEN LOCATE attrib + 15, 1
PRINT " "
attrib = ((attrib - 1) MOD 6 + 6) MOD 6
IF attrib = 0 THEN attrib = 6
LOCATE attrib + 7 * INT(nummer / 78) + 1, 1
IF nummer = 77 * 2 + 1 THEN LOCATE attrib + 15, 1
PRINT ">"
 status attrib
 RETURN

PauseHandlerx:
position nummer
PRINT " "
nummer = nummer - 1
IF nummer = 0 THEN nummer = 1
position nummer
PRINT "^"
IF nummer = 77 OR nummer = 154 THEN verschiebe nummer, attrib, -1
RETURN

PauseHandlery:
position nummer
PRINT " "
nummer = nummer + 1
IF nummer = ende + 1 THEN nummer = ende
position nummer
PRINT "^"
IF nummer = 78 OR nummer = 155 THEN verschiebe nummer, attrib, 1
IF nummer > letzt THEN letzt = nummer: neu nummer
RETURN

PauseHandlerxy:
LOCATE attrib + 7 * INT(nummer / 78) + 1, 1
IF nummer = 77 * 2 + 1 THEN LOCATE attrib + 15, 1
PRINT " "
attrib = (attrib + 1) MOD 6
IF attrib = 0 THEN attrib = 6
LOCATE attrib + 7 * INT(nummer / 78) + 1, 1
IF nummer = 77 * 2 + 1 THEN LOCATE attrib + 15, 1
PRINT ">"
status attrib
        RETURN

PauseHandlerxyz:
      spiel (nummer)
        RETURN

PauseHandlerxyzb:
         FOR j = 1 TO nummer
                spiel (j)
         NEXT j
        RETURN

PauseHandlerxyzc:
         FOR j = 1 TO letzt
                spiel (j)
         NEXT j
        RETURN

PauseHandlerxyza:
  SELECT CASE stat
  CASE 0: text$ = " aktueller Ton:F1, bis hierher:F2, weit. Funk.:F9"
  CASE 1: text$ = " ganz. St.:F3, Tempo:F4, Ende:Esc, weit. Funk.:F9"
  CASE 2: text$ = " einfÅgen:EINFG, entfernen:ENTF,   weit. Funk.:F9"
  END SELECT
  stat = (stat + 1) MOD 3
  LOCATE 23, 30
   PRINT text$
   RETURN

PauseHandlerxyzd:
LOCATE 23, 1
INPUT ; "Tempo(32-255):", tempo
status attrib
IF tempo < 32 THEN tempo = 32
IF tempo > 255 THEN tempo = 255
tmp$ = "T" + STR$(tempo)
PLAY "X" + VARPTR$(tmp$)
LOCATE 1, 26
PRINT STR$(tempo) + " "
RETURN

PauseHandlerein:
IF letzt < ende THEN
FOR j = letzt + 1 TO nummer + 1 STEP -1
note(j) = note(j - 1)
NEXT j
note(nummer).hoehe = "P"
note(nummer).art = " "
note(nummer).punkt = " "
note(nummer).okt = "1"
note(nummer).vorz = " "
note(nummer).laenge = "2"
letzt = letzt + 1
FOR j = nummer TO letzt
zeige (j)
NEXT j
END IF
RETURN

PauseHandlerent:
IF letzt > 1 THEN
 FOR j = nummer TO letzt - 1
  note(j) = note(j + 1)
 NEXT j
note(letzt).hoehe = " "
note(letzt).art = " "
note(letzt).punkt = " "
note(letzt).okt = " "
note(letzt).vorz = " "
note(letzt).laenge = " "
 FOR j = nummer TO letzt
zeige (j)
NEXT j
letzt = letzt - 1
IF nummer - 1 = letzt THEN GOSUB PauseHandlerx
END IF
RETURN

ende: ' FOR i = 1 TO 3
    'PLAY "T175O2MLL3N0G.L5FEMNL3DEMLC<G>MNMLD.L5EDL3MNCGAGFAMLL2EMN"
    'NEXT i
    'PLAY "G"
    'PRINT "Beethoven"
    'PLAY "O2L3F#F#GAAGF#E"
    'PRINT "Mozart"
    'PLAY "O2T255MSL4EEEEEEMLL5FEDEMSL4B-B-B-B-B-B->L5MLC<B-AB-"
    'PLAY "L4MSGGBBFFA-A-EEBBFFA-A-"
    'PRINT "Tonleiter"
    'Tonleiter$ = "CDEFGAB"
   ' PLAY "L16"
    'FOR i% = 0 TO 6
     '  PLAY "O" + STR$(i%)
      'PLAY "X" + VARPTR$(Tonleiter$)
    'NEXT i%
    'PRINT "Borodin"
    'ton$ = "T240O2L3MLEF#MNGMLGFEF#MNBMLBMNBMLGFMNEMLF#MNGMLGFEL2MNBL3F#"
    'PLAY "X" + VARPTR$(ton$)
    'PLAY "T255ML"
    'FOR i = 1 TO 84
    'ton$ = "N" + STR$(i)
   ' PLAY "X" + VARPTR$(ton$)
    'NEXT i
    'INPUT ton$
    'PLAY "X" + VARPTR$(ton$)

SUB bild
PLAY "T255"
PRINT "                 Tempo: 255 Viertelnoten pro Minute             "
PRINT " A "
PRINT ">T "
PRINT " V "
PRINT " P "
PRINT " L "
PRINT " O "
PRINT "   ^"
PRINT " A "
PRINT " T "
PRINT " V "
PRINT " P "
PRINT " L "
PRINT " O "
PRINT ""
PRINT " A "
PRINT " T "
PRINT " V "
PRINT " P "
PRINT " L "
PRINT " O "
PRINT ""
PRINT "Noten:C,D,E,F,G,A,H Pause:P | aktueller Ton:F1, bis hierher:F2, weit. Funk.:F9"
END SUB

SUB neu (nr)
note(nr).hoehe = "P"
note(nr).art = " "
note(nr).punkt = " "
note(nr).okt = "1"
note(nr).vorz = " "
note(nr).laenge = "2"
zeige nr
END SUB

SUB position (nr)
x = nr MOD 77
y = INT((nr - 1) / 77)
IF x = 0 THEN x = 77
LOCATE 7 * y + 8, 3 + x
END SUB

SUB spiel (nr%)
wort$ = "O" + note(nr%).okt + "L" + note(nr%).laenge + "M"
SELECT CASE note(nr%).art
CASE "_": a$ = "L"
CASE ".": a$ = "S"
CASE ELSE: a$ = "N"
END SELECT
SELECT CASE note(nr%).hoehe
CASE "P": h$ = "N0"
CASE "H": h$ = "B"
CASE ELSE: h$ = note(nr%).hoehe
END SELECT
wort$ = wort$ + a$ + h$ + note(nr%).vorz + note(nr%).punkt
PLAY "X" + VARPTR$(wort$)
END SUB

SUB status (art)
SELECT CASE art
CASE 1: stat$ = "legato:_ staccato:. normal: "
CASE 2: stat$ = "Noten:C,D,E,F,G,A,H Pause:P "
CASE 3: stat$ = "Kreuz:# o. +  b:- normal:   "
CASE 4: stat$ = "punktiert:. normal:         "
CASE 5: stat$ = "LÑnge:1-9                   "
CASE 6: stat$ = "Oktave:0-6                  "
END SELECT
LOCATE 23, 1
PRINT stat$
END SUB

SUB verschiebe (nummer, attrib, wert)
LOCATE attrib + 7 * INT((nummer - wert) / 78) + 1, 1
IF nummer = 155 THEN LOCATE attrib + 8, 1
IF nummer = 154 THEN LOCATE attrib + 15, 1
PRINT " "
LOCATE attrib + 7 * INT(nummer / 78) + 1, 1
IF nummer = 77 * 2 + 1 THEN LOCATE attrib + 15, 1
PRINT ">"
END SUB

SUB zeige (nr)
x = nr MOD 77
y = INT((nr - 1) / 77)
IF x = 0 THEN x = 77
FOR i = 1 TO 6
LOCATE 1 + i + 7 * y, 3 + x
SELECT CASE i
CASE 1: PRINT note(nr).art
CASE 2: PRINT note(nr).hoehe
CASE 3: PRINT note(nr).vorz
CASE 4: PRINT note(nr).punkt
CASE 5: PRINT note(nr).laenge
CASE 6: PRINT note(nr).okt
END SELECT
NEXT i
END SUB

