DECLARE SUB lauf (ric!, dreh!)
DECLARE SUB bild ()
DECLARE SUB wahl (nr!, dreh!)
DECLARE SUB block (x!, y!)
DECLARE SUB zeigen (nr!)
CLS
DIM SHARED drehen$
DIM SHARED dreh
dreh = 0
INPUT "Drehen <j/n>"; drehen$
CLS
COLOR 15
DIM SHARED a(3)
DIM SHARED x
DIM SHARED y
DIM SHARED lab(4, 4)
FOR i = 0 TO 3: a(i) = 1: NEXT i
RANDOMIZE TIMER
x = INT(RND * 3) + 1
SELECT CASE x
CASE 1: RESTORE 1
CASE 2: RESTORE 2
CASE 3: RESTORE 3
END SELECT
FOR i = 0 TO 4
FOR j = 0 TO 4
READ lab(i, j)
NEXT j
NEXT i
1 : DATA 13,2, 6,5, 0,13, 5,14, 7,3, 13,4, 11,12, 10,8, 9,6, 5,10, 1,1, 4,11, 7
2 : DATA 9,12, 6,2, 6,8, 12,14, 0,13, 4,12, 11,12, 10,5, 9,9, 6,13, 4,7, 1,4, 7
3 : DATA 12,6, 5,6, 3,3, 4,7, 8,7, 13,2, 9,11, 6,8, 9,14, 9,10, 4,7, 4,11, 7
x = 4
y = 4
zeigen lab(4, 4)
COLOR 0
block 15, 8
COLOR 15
block 1, 1
block 1, 15
block 15, 1
block 15, 15
IF drehen$ = "j" THEN LOCATE 5, 30: PRINT "^"
CONST ESC = 27
'ON ERROR GOTO fehler
ON KEY(11) GOSUB PauseHandler1
KEY(11) ON
ON KEY(12) GOSUB PauseHandler2
KEY(12) ON
ON KEY(13) GOSUB PauseHandler3
KEY(13) ON
ON KEY(14) GOSUB PauseHandler4
KEY(14) ON
WHILE INKEY$ <> CHR$(ESC)
WEND
GOTO ende
'fehler: SELECT CASE ERR
'CASE 9: GOTO ende: RESUME
'CASE ELSE: END
'END SELECT
PauseHandler1: 'nach oben
IF a(0) = 1 THEN lauf 0, dreh: IF x > 0 OR y > 0 THEN wahl lab(x, y), dreh ELSE GOTO ende
RETURN
PauseHandler2: 'nach links
IF a(1) = 1 THEN lauf 3, dreh: dreh = (dreh + 3) MOD 4: IF x > 0 OR y > 0 THEN wahl lab(x, y), dreh ELSE GOTO ende
RETURN
PauseHandler3: 'nach rechts
IF a(2) = 1 THEN lauf 1, dreh: dreh = (dreh + 1) MOD 4: IF x > 0 OR y > 0 THEN wahl lab(x, y), dreh ELSE GOTO ende
RETURN
PauseHandler4: 'nach unten
IF a(3) = 1 THEN lauf 2, dreh: dreh = (dreh + 2) MOD 4: IF x > 0 OR y > 0 THEN wahl lab(x, y), dreh ELSE GOTO ende
RETURN
ende:
CLS
bild
END

SUB bild
FOR i = 0 TO 4
        FOR j = 0 TO 4
                SELECT CASE lab(i, j)
                        CASE 0: x = 186
                        CASE 1: x = 205
                        CASE 2: x = 186
                        CASE 3: x = 205
                        CASE 4: x = 187
                        CASE 5: x = 201
                        CASE 6: x = 200
                        CASE 7: x = 188
                        CASE 8: x = 203
                        CASE 9: x = 204
                        CASE 10: x = 202
                        CASE 11: x = 185
                        CASE 12: x = 186
                        CASE 13: x = 205
                        CASE 14: x = 206
                END SELECT
                LOCATE j + 1, i + 1
                PRINT CHR$(x)
        NEXT j
NEXT i
END SUB

SUB block (xx, yy)
FOR i = 0 TO 6
LOCATE xx + i, yy
PRINT "*******"
NEXT i
END SUB

SUB lauf (ric, dreh)
IF drehen$ = "j" THEN ric = (ric + dreh) MOD 4
SELECT CASE ric
CASE 0: y = y - 1
CASE 1: x = x + 1
CASE 2: y = y + 1
CASE 3: x = x - 1
END SELECT
END SUB

SUB wahl (nr, dreh)
COLOR 0
block 1, 8
block 8, 1
block 8, 15
block 15, 8
COLOR 15
IF drehen$ = "j" THEN
        SELECT CASE nr
                CASE IS < 12: xx = 4 * INT(nr / 4)
                        yy = nr MOD 4
                        z = (yy + dreh) MOD 4
                        nrx = z + xx
                CASE 12, 13: xx = dreh MOD 2
                        yy = (nr + xx - 12) MOD 2
                        nrx = yy + 12
                CASE 14: nrx = nr
        END SELECT
        LOCATE 5, 30
        SELECT CASE dreh
                CASE 0: PRINT "^"
                CASE 1: PRINT "<"
                CASE 2: PRINT "v"
                CASE 3: PRINT ">"
        END SELECT
ELSE
        nrx = nr
END IF
zeigen nrx
END SUB

SUB zeigen (nr)
FOR i = 0 TO 3: a(i) = 0: NEXT i
SELECT CASE nr
CASE 0: a(0) = 1
CASE 1: a(1) = 1
CASE 2: a(3) = 1
CASE 3: a(2) = 1
CASE 4: a(1) = 1: a(3) = 1
CASE 5: a(2) = 1: a(3) = 1
CASE 6: a(0) = 1: a(2) = 1
CASE 7: a(0) = 1: a(1) = 1
CASE 8: a(1) = 1: a(2) = 1: a(3) = 1
CASE 9: a(0) = 1: a(2) = 1: a(3) = 1
CASE 10: a(0) = 1: a(1) = 1: a(2) = 1
CASE 11: a(0) = 1: a(1) = 1: a(3) = 1
CASE 12: a(0) = 1: a(3) = 1
CASE 13: a(1) = 1: a(2) = 1
CASE 14: a(0) = 1: a(1) = 1: a(2) = 1: a(3) = 1
END SELECT
IF a(0) = 0 THEN block 1, 8
IF a(1) = 0 THEN block 8, 1
IF a(2) = 0 THEN block 8, 15
IF a(3) = 0 THEN block 15, 8
END SUB

