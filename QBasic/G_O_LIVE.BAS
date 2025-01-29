DECLARE SUB zufall (start&, z!)
DEFINT A-Z
DECLARE SUB initspec (motiv%)
DECLARE SUB neu ()
DECLARE SUB init (nr, zeile$)
DECLARE FUNCTION umgeb (x, y)
DECLARE SUB anzeige ()
CONST maxx = 55
CONST maxy = 35

CONST WASCHFRAU = 0
CONST KATZE = 1
CONST UHR = 2
CONST GLEITER = 3
CONST KANONE = 4
CONST BECHER = 5
CONST BIENENSTOCK = 6
CONST RPent = 7
'CONST 8 = 8
CONST PULSAR = 9
CONST KANONE2 = 10
CONST GLEIT4 = 11
CONST RAUMSCHIFF = 12
CONST RAUMSCHIFF2 = 13
CONST RAUMSCHIFF3 = 14
CONST RAUMSCHIFF4 = 15
CONST OFEN = 16
CONST KUH = 17
CONST HONIG = 18

DIM SHARED feld(0 TO maxy + 1, 0 TO maxx + 1)
'DIM SHARED tick
DIM t AS LONG
't = TIMER
't = 66453
't = 67189
'initspec KANONE
'zufall TIMER, 1
'zufall t, .3
'init 9, "          ********"
'init 9, "          **********"
init 12, "          ****************"
DO
anzeige
neu
'tick = tick + 1
LOOP UNTIL INKEY$ = CHR$(27)
'PRINT t

SUB anzeige
CLS
FOR i = 1 TO maxy STEP 2
        FOR j = 1 TO maxx
                a = feld(i, j): IF i < maxy THEN b = feld(i + 1, j) ELSE b = 0
                IF a = 1 THEN
                        IF b = 1 THEN
                         LOCATE (i + 1) / 2, j: PRINT "Û"
                        ELSE
                         LOCATE (i + 1) / 2, j: PRINT "ß"
                        END IF
                ELSE
                        IF b = 1 THEN
                         LOCATE (i + 1) / 2, j: PRINT "Ü"
                        END IF
                END IF
        NEXT j
NEXT i
'LOCATE 25, 70
'PRINT tick
END SUB

SUB init (nr, zeile$)
l = LEN(zeile$)
FOR i = 1 TO maxx
IF i > l THEN EXIT SUB
IF MID$(zeile$, i, 1) = "*" THEN feld(nr, i) = 1
NEXT i
END SUB

SUB initspec (motiv)
SELECT CASE motiv
CASE WASCHFRAU
init 3, "   *"
init 4, "   **    *     *     *     *"
init 5, "   ***  * *   * *   * *   * *"
init 6, "   **    *     *     *     *"
init 7, "   *"
CASE KATZE
init 1, "   *  *"
init 2, "   ****"
init 3, "  *    *"
init 4, "  * ** *"
init 5, "  *    *"
init 6, "   ****"
CASE UHR
init 1, " *"
init 2, "  **"
init 3, "**"
init 4, "  *"
CASE GLEITER
init 1, " *"
init 2, "  *"
init 3, "***"
CASE KANONE
init 1, "                           *"
init 2, "                           * *"
init 3, "          *                 * *"
init 4, "          **                *  *   **"
init 5, "     **    **               * *    **"
init 6, " **  **    ***             * *"
init 7, " **  **    **              *"
init 8, "          **"
init 9, "          *"
CASE BECHER
init 2, "  ** **"
init 3, "  ** **"
init 4, "   * *"
init 5, " * * * *"
init 6, " * * * *"
init 7, " **   **"
CASE BIENENSTOCK
init 7, "                                   **"
init 8, "  * ** ** ** ** ** ** ** ** ** ** * *"
init 9, " * * ** ** ** ** ** ** ** ** ** **"
init 10, "  *"
CASE RPent
init 20, "                  *"
init 21, "                 ***"
init 22, "                 *"
CASE 8
init 3, "  ***"
init 4, "  ***"
init 5, "  ***"
init 6, "     ***"
init 7, "     ***"
init 8, "     ***"
CASE PULSAR
init 8, "  ***** *****"
CASE KANONE2
init 1, "            **"
init 2, "           *"
init 3, "          *             *"
init 4, " *        *            **"
init 5, "**        *               **"
init 6, "           *              ***      *"
init 7, "            **            **      **"
init 8, "                       **"
init 9, "                        *"
CASE GLEIT4
init 3, "    ****"
init 5, "  ********"
init 7, "************"
init 9, "  ********"
init 11, "    ****"
CASE RAUMSCHIFF
init 1, "   *"
init 2, "    *"
init 3, "*   *"
init 4, " ****"
CASE RAUMSCHIFF2
init 1, "    *"
init 2, "     *"
init 3, "*    *"
init 4, " *****"
CASE RAUMSCHIFF3
init 1, "     *"
init 2, "      *"
init 3, "*     *"
init 4, " ******"
CASE RAUMSCHIFF4
init 3, "     ******"
init 4, "    *     *"
init 5, "          *"
init 6, "         *"
init 8, "           *"
init 9, "            *"
init 10, "*           *"
init 11, " ************"
init 15, "     ******"
init 16, "    *     *"
init 17, "          *"
init 18, "         *"
CASE OFEN
init 2, ""
init 3, "  *"
init 4, " ***"
init 5, "    *"
init 6, "     *"
init 7, "      *"
init 8, "       *"
init 9, "        *"
init 10, "         *"
init 11, "          *"
init 12, "           *"
init 13, "            *"
init 14, "             *"
init 15, "              *"
init 16, "               *"
init 17, "                *"
init 18, "                 *"
init 19, "                  *"
init 20, "                   *"
init 21, "                    *"
init 22, "                     *"
init 23, "                      *"
init 24, "                       *"
init 25, "                      **"
CASE KUH
init 4, " **       **  **  **  **  **  **  **  **   ** "
init 5, " **    * ***  **  **  **  **  **  **  **  *  *"
init 6, "     ** *                                 *  ***"
init 7, "     **  ********************************* **   *"
init 8, "     ** *                                 *  ***"
init 9, " **    * ***  **  **  **  **  **  **  **  *  *"
init 10, " **       **  **  **  **  **  **  **  **   ** "
CASE HONIG
init 6, "      ***"
init 7, "     *   *"
init 8, "    *     *"
init 9, "     *   *"
init 10, "      ***"
END SELECT
END SUB

SUB neu
FOR i = 1 TO maxy
 FOR j = 1 TO maxx
  a = feld(i, j)
  IF a = 1 THEN
   b = umgeb(i, j)
   IF b < 3 OR b > 4 THEN feld(i, j) = 2
  ELSE
   IF umgeb(i, j) = 3 THEN feld(i, j) = -1
  END IF
 NEXT j
NEXT i
FOR i = 1 TO maxy
FOR j = 1 TO maxx
a = feld(i, j)
IF a = -1 THEN feld(i, j) = 1
IF a = 2 THEN feld(i, j) = 0
NEXT j
NEXT i
END SUB

FUNCTION umgeb (x, y)
FOR i = -1 TO 1
        FOR j = -1 TO 1
                IF feld(x + i, y + j) >= 1 THEN s = s + 1
        NEXT j
NEXT i
umgeb = s
END FUNCTION

SUB zufall (start&, z!)
RANDOMIZE start&
FOR i = INT(maxx / 2) - 5 TO INT(maxx / 2) + 5
FOR j = INT(maxy / 2) - 5 TO INT(maxy / 2) + 5
IF RND < z! THEN feld(j, i) = 1
NEXT j
NEXT i
END SUB

