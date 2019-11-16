DECLARE SUB schreibe (text$, x!, y!)
DECLARE SUB init ()
DIM SHARED buch(ASC(" ") TO ASC("Z"), 1 TO 4 * 129) AS INTEGER
DIM SHARED buch2(ASC("[") TO ASC("~"), 1 TO 4 * 129) AS INTEGER
DIM SHARED feld(1 TO 4 * 129) AS INTEGER
SCREEN 12
init
BEEP: SLEEP
LINE (0, 0)-(640, 480), 1, BF
schreibe "Hallo! Dies ist ein Text zum Testen.", 5, 5
SLEEP
SCREEN 0

SUB init
FOR i = ASC(" ") TO ASC("Z")
PRINT CHR$(i)
GET (0, 0)-(7, 15), feld(1)
FOR j = 1 TO 4 * 129: buch(i, j) = feld(j): NEXT j
CLS
NEXT i
FOR i = ASC("[") TO ASC("~")
PRINT CHR$(i)
GET (0, 0)-(7, 15), feld(1)
FOR j = 1 TO 4 * 129: buch2(i, j) = feld(j): NEXT j
CLS
NEXT i
END SUB

SUB schreibe (text$, x, y)
FOR k = 1 TO LEN(text$)
a$ = MID$(text$, k, 1)
IF a$ >= " " AND a$ <= "Z" THEN
FOR i = 1 TO 4 * 129: feld(i) = buch(ASC(a$), i): NEXT i
ELSEIF a$ >= "[" AND a$ <= "~" THEN
FOR i = 1 TO 4 * 129: feld(i) = buch2(ASC(a$), i): NEXT i
END IF
IF a$ >= " " AND a$ <= "~" THEN
PUT (x - 8 + 8 * k, y), feld(1), OR
END IF
NEXT k
END SUB

