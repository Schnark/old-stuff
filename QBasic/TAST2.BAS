DECLARE SUB zeichen (ein$)

CONST ESC = 27, DEL = 127, TABU = 9, RET = 13, RUECK = 8

CONST F1 = 59, F2 = 60, F3 = 61, F4 = 62, F5 = 63, F6 = 64, F7 = 65, F8 = 66, F9 = 67, F10 = 68, F11 = 133, F12 = 134
CONST SF1 = 84, SF2 = 85, SF3 = 86, SF4 = 87, SF5 = 88, SF6 = 89, SF7 = 90, SF8 = 91, SF9 = 92, SF10 = 93, SF11 = 135, SF12 = 136
CONST CF1 = 94, CF2 = 95, CF3 = 96, CF4 = 97, CF5 = 98, CF6 = 99, CF7 = 100, CF8 = 101, CF9 = 102, CF10 = 103, CF11 = 137, CF12 = 138
CONST AF1 = 104, AF2 = 105, AF3 = 106, AF4 = 107, AF5 = 108, AF6 = 109, AF7 = 110, AF8 = 111, AF9 = 112, AF10 = 113, AF11 = 139, AF12 = 140
CONST LINKS = 75, RECHTS = 77, OBEN = 72, UNTEN = 80
CONST SLINKS = 115, SRECHTS = 116
CONST EINF = 82, POS1 = 71, BILDAUF = 73, ENTF = 83, ENDE = 79, BILDAB = 81
CONST SPOS1 = 119, SBAUF = 132, SENDE = 117, SBAB = 118
'1-58,69,70,76,78,114,120-131,141-

CLS
PRINT "kein TastaturpufferÅberlauf"
DO
  DO
    a$ = INKEY$
    ein$ = ein$ + a$
  LOOP UNTIL a$ = ""
  b$ = LEFT$(ein$, 1)
  ein$ = MID$(ein$, 2)
  IF b$ = CHR$(0) THEN b$ = b$ + LEFT$(ein$, 1): ein$ = MID$(ein$, 2)
  IF b$ <> "" THEN zeichen b$
  SLEEP 1
  IF b$ = CHR$(27) THEN schluss = 1
LOOP UNTIL schluss = 1

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

SUB zeichen (ein$)
IF LEN(ein$) = 1 THEN
 e = ASC(ein$)
 SELECT CASE e
  CASE 32 TO 126, 128 TO 255: aus$ = STR$(e) + ": " + ein$
  CASE ESC: aus$ = " 27: ESC"
  CASE DEL: aus$ = " 127: DEL"
  CASE TABU: aus$ = " 9: TAB"
  CASE RET: aus$ = " 13: RET"
  CASE RUECK: aus$ = " 8: RöCK"
  CASE ELSE: aus$ = STR$(e)
 END SELECT
ELSE
 e = ASC(RIGHT$(ein$, 1))
 SELECT CASE e
  CASE F1 TO F10: aus$ = " 0 +" + STR$(e) + ": F" + LTRIM$(STR$(e - 58))
  CASE F11: aus$ = " 0 + 133: F11"
  CASE F12: aus$ = " 0 + 134: F12"
  CASE SF1 TO SF10: aus$ = " 0 +" + STR$(e) + ": Shift + F" + LTRIM$(STR$(e - 83))
  CASE SF11: aus$ = " 0 + 135: Shift + F11"
  CASE SF12: aus$ = " 0 + 136: Shift + F12"
  CASE CF1 TO CF10: aus$ = " 0 +" + STR$(e) + ": Strg + F" + LTRIM$(STR$(e - 93))
  CASE CF11: aus$ = " 0 + 137: Strg + F11"
  CASE CF12: aus$ = " 0 + 138: Strg + F12"
  CASE AF1 TO AF10: aus$ = " 0 +" + STR$(e) + ": Alt + F" + LTRIM$(STR$(e - 103))
  CASE AF11: aus$ = " 0 + 139: Alt + F11"
  CASE AF12: aus$ = " 0 + 140: Alt + F12"
  CASE OBEN: aus$ = " 0 + 72: OBEN"
  CASE UNTEN: aus$ = " 0 + 80: UNTEN"
  CASE LINKS: aus$ = " 0 + 75: LINKS"
  CASE SLINKS: aus$ = " 0 + 115: Strg + LINKS"
  CASE RECHTS: aus$ = " 0 + 77: RECHTS"
  CASE SRECHTS: aus$ = " 0 + 116: Strg + RECHTS"
  CASE EINF: aus$ = " 0 + 82: EINF"
  CASE POS1: aus$ = " 0 + 71: POS1"
  CASE SPOS1: aus$ = " 0 + 119: Strg + POS1"
  CASE BILDAUF: aus$ = " 0 + 73: Bild ^"
  CASE SBAUF: aus$ = " 0 + 132: Strg + Bild ^"
  CASE ENTF: aus$ = " 0 + 83: ENTF"
  CASE ENDE: aus$ = " 0 + 79: ENDE"
  CASE SENDE: aus$ = " 0 + 117: Strg + ENDE"
  CASE BILDAB: aus$ = " 0 + 81: Bild v"
  CASE SBAB: aus$ = " 0 + 118: Strg + Bild v"
  CASE ELSE: aus$ = " 0 +" + STR$(e)
 END SELECT
END IF
PRINT aus$
END SUB

