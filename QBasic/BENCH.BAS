SLEEP
CLS
d = TIMER
FOR i = 0 TO 100
  FOR j = 0 TO 100
    x = SIN(i) + COS(j)
  NEXT j
NEXT i
s = TIMER
PRINT s - d
OPEN "bench.dat" FOR APPEND AS 1
PRINT #1, s - d
CLOSE 1

