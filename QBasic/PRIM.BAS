CLS 0
INPUT "Untere Grenze"; u
INPUT "Obere Grenze"; g
IF u < 2 THEN u = 2
IF u = 2 THEN PRINT (2)
n = 3
IF u / 2 = INT(u / 2) THEN u = u + 1
FOR i = u TO g STEP 2
FOR j = 2 TO INT(SQR(i)) + 1
IF INT(i / j) = i / j THEN GOTO 123
NEXT j
PRINT (i)
n = n + 1
IF n = 23 THEN BEEP 'SOUND 440, 4
IF n = 23 THEN SLEEP
IF n = 23 THEN n = 0
123 : NEXT i
END

