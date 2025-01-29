DECLARE FUNCTION abfr% (t$)
DECLARE FUNCTION abfrage% (t$)
ON TIMER(60) GOSUB Zeit
CLS
RANDOMIZE TIMER
INPUT "Mit Ton bei Fehler"; antw$
SLEEP 1
CLS
SLEEP
z1 = TIMER
TIMER ON
DO
zurueck: taste = INT(RND * 223) + 32
tasten$ = CHR$(taste)
SELECT CASE tasten$
CASE " " TO CHR$(34), "$" TO "&", "(" TO ")", "," TO ":", "=", "?", "A" TO "Z", "a" TO "z", "", "„", "Ž", "”", "™", "š", "á", "õ"
        IF antw$ = "n" THEN
        sek = abfr(tasten$)
        ELSE sek = abfrage(tasten$)
        END IF
CASE ELSE
GOTO zurueck
END SELECT
PRINT sek
sekges = sekges + sek
n = n + 1
LOOP UNTIL sek > 3 AND sekges > 60
sekges2 = TIMER - z1
sekges2 = sekges2 - sek
sekges = sekges - sek
n = n - 1
PRINT "Durchschnitt:", sekges / n
PRINT n, "Anschl„ge in", sekges, "Sekunden"
PRINT 60 * n / sekges, "Anschl„ge pro Minute"
PRINT
PRINT "Durchschnitt:", sekges2 / n
PRINT n, "Anschl„ge in", sekges2, "Sekunden"
PRINT 60 * n / sekges2, "Anschl„ge pro Minute"
END
Zeit:
BEEP
RETURN

FUNCTION abfr% (t$)
PRINT t$
t1 = TIMER
DO
LOOP UNTIL INKEY$ = t$
abfr = TIMER - t1
END FUNCTION

FUNCTION abfrage% (t$)
PRINT t$
t1 = TIMER
DO
IF INKEY$ = t$ THEN
        EXIT DO
ELSEIF INKEY$ >= " " THEN
        BEEP
END IF
LOOP
abfrage = TIMER - t1
END FUNCTION

