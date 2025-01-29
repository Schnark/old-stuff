DECLARE FUNCTION aktiv! (x!, y!)
DECLARE SUB markiere (x!, y!)
DIM SHARED ports(0 TO 15, 0 TO 15)
DIM SHARED akt(0 TO 15, 0 TO 15)
CONST oft = 10
CONST hundert = &H400

FOR y = 0 TO 15
 FOR x = 0 TO 15
  port = hundert + y * 16 + x
  ports(x, y) = INP(port)
 NEXT x
NEXT y

CLS
PRINT HEX$(hundert / 256) + ".."
PRINT
PRINT " 0123456789ABCDEF"
PRINT "0"
PRINT "1"
PRINT "2"
PRINT "3"
PRINT "4"
PRINT "5"
PRINT "6"
PRINT "7"
PRINT "8"
PRINT "9"
PRINT "A"
PRINT "B"
PRINT "C"
PRINT "D"
PRINT "E"
PRINT "F"

DO
 FOR y = 0 TO 15
  FOR x = 0 TO 15
   markiere x, y
  NEXT x
  IF INKEY$ = CHR$(27) THEN END
 NEXT y
LOOP UNTIL 0

FUNCTION aktiv (x, y)
port = hundert + y * 16 + x
a = INP(port)
IF a = ports(x, y) THEN aktiv = 0 ELSE ports(x, y) = a: aktiv = 1: IF akt(x, y) < oft THEN akt(x, y) = akt(x, y) + 1
END FUNCTION

SUB markiere (x, y)
IF aktiv(x, y) = 1 THEN
 IF akt(x, y) >= oft THEN COLOR 1 ELSE COLOR 4
ELSE
 IF akt(x, y) >= oft THEN COLOR 2 ELSE COLOR 15
END IF
LOCATE 4 + y, 2 + x
PRINT "Û"
END SUB

