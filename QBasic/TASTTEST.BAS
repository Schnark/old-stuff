CLS
PRINT "kein TasturpufferÅberlauf"
DO
  DO
    a$ = INKEY$
    ein$ = ein$ + a$
  LOOP UNTIL a$ = ""
  b$ = LEFT$(ein$, 1)
  ein$ = MID$(ein$, 2)
  IF b$ = CHR$(0) THEN PRINT "0+"; : b$ = LEFT$(ein$, 1): ein$ = MID$(ein$, 2)
  IF b$ <> "" THEN PRINT ASC(b$)
  SLEEP 1
  IF b$ = CHR$(27) THEN ende = 1
LOOP UNTIL ende = 1

DEF SEG = 0
DO
  status = PEEK(&H417)
  IF status <> alt THEN
    a$ = "00" + OCT$(status)
    b$ = ""
    DO
      SELECT CASE LEFT$(a$, 1)
      CASE "0": b$ = b$ + "000"
      CASE "1": b$ = b$ + "001"
      CASE "2": b$ = b$ + "010"
      CASE "3": b$ = b$ + "011"
      CASE "4": b$ = b$ + "100"
      CASE "5": b$ = b$ + "101"
      CASE "6": b$ = b$ + "110"
      CASE "7": b$ = b$ + "111"
      END SELECT
      a$ = MID$(a$, 2)
    LOOP UNTIL a$ = ""
    PRINT RIGHT$(b$, 8)
'8      7       6       5       4       3       2       1
'Einf   Caps    Num     Rollen  Alt     Strg    Shift r Shift l
  END IF
  alt = status
LOOP UNTIL INKEY$ = CHR$(27)

