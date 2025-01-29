CLS
FOR j = 1 TO 100
RANDOMIZE TIMER
z$ = ""
FOR i = 1 TO 9
        DO
        x$ = RIGHT$(STR$(INT(RND * 9) + 1), 1)
        LOOP WHILE INSTR(" " + z$, x$)
        z$ = z$ + x$
NEXT i
zahl& = VAL(z$)
PRINT zahl&
FOR i = 1 TO 7
        z$ = STR$(zahl&)
        zahl& = VAL(RIGHT$(z$, LEN(z$) - 2)) + VAL(LEFT$(z$, 2))
'        PRINT zahl&
NEXT i
'SLEEP
IF zahl& = 45 OR zahl& = 0 THEN SLEEP: END
NEXT j

