CLS
FOR j = 1 TO 9
        FOR k = 1 TO 9
                IF j <> k THEN
                        z$ = ""
                        FOR i = 1 TO 9
                                IF i <> k AND i <> j THEN z$ = z$ + RIGHT$(STR$(i), 1)
                        NEXT i
                        z$ = LEFT$(z$, 6) + RIGHT$(STR$(j), 1) + RIGHT$(STR$(k), 1) + RIGHT$(z$, 1)
                        zahl& = VAL(z$)
                        s$ = z$
                        FOR i = 1 TO 7
                                z$ = STR$(zahl&)
                                zahl& = VAL(RIGHT$(z$, LEN(z$) - 2)) + VAL(LEFT$(z$, 2))
                        NEXT i
                        IF zahl& = 45 OR zahl& = 36 THEN PRINT s$: END
                END IF
        NEXT k
NEXT j

