DECLARE FUNCTION bino# (n#, k#)
DECLARE SUB sysanz (zahl#, sys!)
DECLARE SUB sechzig (zahl#, stellen!)
DECLARE SUB bruch (zahl#, stellen!)
DECLARE FUNCTION bin$ (zahl#)
DECLARE SUB anzeige (ergeb#, sys!, modus1!, modus2!, dez!)
DECLARE FUNCTION fak# (zahl#)
DECLARE FUNCTION ersetze$ (text$)
DECLARE FUNCTION ggT! (a!, b!)
DECLARE FUNCTION kgV! (a!, b!)
DECLARE FUNCTION param$ (text$, nummer!)
DECLARE FUNCTION klumpen$ (text$)
DECLARE FUNCTION klumpen2$ (text$)
DECLARE FUNCTION leer$ (text$)
DECLARE FUNCTION funkvor! (text$, stelle!)
DECLARE FUNCTION funk$ (name$, para$)
DECLARE FUNCTION klammer$ (rech$)
DECLARE FUNCTION vorber$ (text$)
DECLARE FUNCTION zuzahl! (text$, davor$)
DECLARE FUNCTION nach! (text$, stelle!)
DECLARE FUNCTION berechne$ (rech$)
DECLARE FUNCTION vor! (text$, stelle!)
'ON ERROR GOTO fehler
DIM SHARED v#
DIM SHARED zahl$
DIM SHARED zahlen$(10)

CLS
LOCATE 24, 1
stat$ = "F2: Modus (N) F3: Stellen 7  F4: System 10 F5: Art (N) F7: Winkel (D) F9: >>    "
PRINT stat$
VIEW PRINT 1 TO 22

ON KEY(1) GOSUB eingabe
ON KEY(2) GOSUB modusein
ON KEY(3) GOSUB stellenein
ON KEY(4) GOSUB systemein
ON KEY(5) GOSUB artein
ON KEY(6) GOSUB speicher
ON KEY(7) GOSUB winkel
ON KEY(9) GOSUB weitere
KEY(0) ON

modus = 0
stellen = 7
sys = 10
art = 0

DO
LOOP UNTIL INKEY$ = CHR$(27)
GOTO schluss

eingabe:
        LINE INPUT rech$
        IF rech$ = "" THEN rech$ = alt$
        rech$ = vorber$(rech$)
        alt$ = rech$
        rech$ = klammer$(rech$)
        zahlen$(1) = rech$
        ergeb# = VAL(rech$)
        anzeige ergeb#, sys, modus, art, stellen
        RETURN

modusein:
        INPUT "Modus: 0: Normal, 1: Festkomma, 2: Exponentialdarstellung ", modus
        zeile = CSRLIN
        VIEW PRINT 1 TO 25
        LOCATE 23, 12
        SELECT CASE modus
        CASE 0: stat$ = "N"
        CASE 1: stat$ = "F"
        CASE 2: stat$ = "E"
        END SELECT
        PRINT stat$
        VIEW PRINT 1 TO 22
        LOCATE zeile, 1
        RETURN

stellenein:
        INPUT "Dezimalstellen: ", stellen
        zeile = CSRLIN
        VIEW PRINT 1 TO 25
        LOCATE 23, 26
        PRINT stellen
        VIEW PRINT 1 TO 22
        LOCATE zeile, 1
        RETURN

systemein:
        INPUT "System: ", sys
        zeile = CSRLIN
        VIEW PRINT 1 TO 25
        LOCATE 23, 40
        PRINT sys
        VIEW PRINT 1 TO 22
        LOCATE zeile, 1
        RETURN

artein:
        INPUT "Art: 0: Normal, 1: Bruch, 2: 60-System ", art
        zeile = CSRLIN
        VIEW PRINT 1 TO 25
        LOCATE 23, 53
        SELECT CASE art
        CASE 0: stat$ = "N"
        CASE 1: stat$ = "B"
        CASE 2: stat$ = "¯"
        END SELECT
        PRINT stat$
        VIEW PRINT 1 TO 22
        LOCATE zeile, 1
        RETURN

speicher:
        INPUT "Variable (a-f, m, m+, m-, x, y): ", var$
        SELECT CASE var$
        CASE "a": zahlen$(2) = zahlen$(1)
        CASE "b": zahlen$(3) = zahlen$(1)
        CASE "c": zahlen$(4) = zahlen$(1)
        CASE "d": zahlen$(5) = zahlen$(1)
        CASE "e": zahlen$(6) = zahlen$(1)
        CASE "f": zahlen$(7) = zahlen$(1)
        CASE "m": zahlen$(8) = zahlen$(1)
        CASE "x": zahlen$(9) = zahlen$(1)
        CASE "y": zahlen$(10) = zahlen$(1)
        CASE "m+": zahlen$(8) = STR$(VAL(zahlen$(8)) + VAL(zahlen$(1)))
        CASE "m-": zahlen$(8) = STR$(VAL(zahlen$(8)) - VAL(zahlen$(1)))
        END SELECT
        RETURN

winkel:
        PRINT "Noch keine Funktion"
        INPUT "Altgrad (D) Bogenma· (R) Neugrad (G): ", w$
        SELECT CASE w$
        CASE "d": winkelart = 0
        CASE "r": winkelart = 1
        CASE "g": winkelart = 2
        END SELECT
        zeile = CSRLIN
        VIEW PRINT 1 TO 25
        LOCATE 23, 68
        stat$ = w$
        PRINT stat$
        VIEW PRINT 1 TO 22
        LOCATE zeile, 1
        RETURN

weitere:
        PRINT "F1: Eingabe F6:Speichern ESC:Ende"
        RETURN

fehler: IF ERR = 11 THEN
                PRINT "Division durch Null"
                zahl$ = STR$(3.402823E+38 * SGN(v#))
                RESUME NEXT
        ELSEIF ERR = 5 THEN
                PRINT "Illegale Operation (-/(-1), ln(-1), asin(2), ...)"
                zahl$ = "-3.402823E+38"
                RESUME NEXT
        ELSEIF ERR = 6 THEN
                PRINT "Zahl zu gro·"
                zahl$ = "3.402823E+38"
                RESUME NEXT
        ELSE
                ERROR ERR
        END IF
schluss:

SUB anzeige (ergeb#, sys, modus1, modus2, dez)
'                2,8,10,16     0:normal,1:Bruch,2:60
'                    0:normal,1:fix,2:sci
zahl$ = STR$(ergeb#)
n = INSTR(zahl$, "D")
IF n <> 0 THEN MID$(zahl$, n, 1) = "E"
IF modus1 = 0 THEN
        IF modus2 = 0 THEN
                SELECT CASE sys
                CASE 2:  PRINT bin$(ergeb#)
                CASE 8: format$ = OCT$(ABS(ergeb#))
                        IF ergeb < 0 THEN format$ = "-" + format$
                        PRINT format$
                CASE 10: PRINT zahl$
                CASE 16: format$ = HEX$(ABS(ergeb#))
                        IF ergeb < 0 THEN format$ = "-" + format$
                        PRINT format$
                CASE ELSE: sysanz ergeb#, sys
        END SELECT
        ELSEIF modus2 = 1 THEN
                bruch ergeb#, dez
        ELSEIF modus2 = 2 THEN
                sechzig ergeb#, dez
        END IF
ELSEIF modus1 = 1 THEN
        stellen = INT(LOG(ABS(ergeb#)) / LOG(10)) + 1
        IF stellen <= 0 THEN stellen = 1
        format$ = STRING$(stellen, "#")
        IF dez > 0 THEN format$ = format$ + "." + STRING$(dez, "#")
        PRINT USING format$; ergeb#
ELSEIF modus1 = 2 THEN
        format$ = "##"
        IF dez > 0 THEN format$ = format$ + "." + STRING$(dez, "#")
        format$ = format$ + "^^^^"
        PRINT USING format$; ergeb#
END IF
END SUB

FUNCTION berechne$ (rech$)
rech$ = ersetze$(rech$)
art = 1
WHILE art <> 0
rech$ = klumpen$(rech$)
art = 0
hoch = INSTR(rech$, "^")
nicht = INSTR(rech$, "~")
faku = INSTR(rech$, "!")

mal = INSTR(rech$, "*")
durch = INSTR(rech$, "/")
und = INSTR(rech$, "&")

plus = 0: ende = 0
DO
plus = INSTR(plus + 1, rech$, "+")
IF plus = 0 THEN plus = 1: ende = 1
LOOP WHILE INSTR(" eEdD", MID$(" " + rech$, plus, 1)) AND ende = 0
IF ende = 1 THEN plus = 0

minus = 0: ende = 0
DO
minus = INSTR(minus + 1, rech$, "-")
IF minus = 0 THEN minus = 1: ende = 1
LOOP WHILE INSTR(" eEdD", MID$(" " + rech$, minus, 1)) AND ende = 0
IF ende = 1 THEN minus = 0

oder = INSTR(rech$, "|")

stelle = 0
IF hoch > 0 OR nicht > 0 THEN
        IF nicht = 0 THEN
                art = 1
                stelle = hoch
        ELSEIF hoch = 0 THEN
                art = 2
                stelle = nicht
        ELSEIF nicht < hoch THEN
                art = 2
                stelle = nicht
        ELSE
                art = 1
                stelle = hoch
        END IF
END IF
IF ((art = 1 OR art = 2) AND faku <> 0 AND faku < stelle) OR (art = 0 AND faku <> 0) THEN stelle = faku: art = 9
IF (mal > 0 OR durch > 0) AND stelle = 0 THEN
        IF mal = 0 THEN
                art = 4
                stelle = durch
        ELSEIF durch = 0 THEN
                art = 3
                stelle = mal
        ELSEIF mal < durch THEN
                art = 3
                stelle = mal
        ELSE
                art = 4
                stelle = durch
        END IF
END IF
IF ((art = 3 OR art = 4) AND und <> 0 AND und < stelle) OR (art = 0 AND und <> 0) THEN stelle = und: art = 5

IF (plus > 0 OR minus > 0) AND stelle = 0 THEN
        IF plus = 0 THEN
                art = 7
                stelle = minus
        ELSEIF minus = 0 THEN
                art = 6
                stelle = plus
        ELSEIF plus < minus THEN
                art = 6
                stelle = plus
        ELSE
                art = 7
                stelle = minus
        END IF
END IF
IF ((art = 6 OR art = 7) AND oder <> 0 AND oder < stelle) OR (art = 0 AND oder <> 0) THEN stelle = oder: art = 8

IF art <> 0 THEN
        vs = vor(rech$, stelle)
        ns = nach(rech$, stelle)
        v# = VAL(MID$(rech$, vs))
        n# = VAL(MID$(rech$, stelle + 1))
END IF
SELECT CASE art
CASE 1:
        IF v# < 0 AND n# <> INT(n#) THEN
                PRINT "Negative Zahlen dÅrfen nicht mit Dezimalzahlen potenziert werden!"
                n# = INT(n# + .5)
        END IF
        zahl$ = STR$(v# ^ n#)
CASE 2: zahl$ = STR$(NOT n#)
CASE 3: zahl$ = STR$(v# * n#)
CASE 4:
        IF n# = 0 THEN
                PRINT "Division durch Null!"
                zahl$ = STR$(SGN(v#) * 1.79769313486231D+308)
        ELSE
                zahl$ = STR$(v# / n#)
        END IF
CASE 5: zahl$ = STR$(v# AND n#)
CASE 6: zahl$ = STR$(v# + n#)
CASE 7: zahl$ = STR$(v# - n#)
CASE 8: zahl$ = STR$(v# OR n#)
CASE 9: zahl$ = STR$(fak(v#))
CASE ELSE: berechne$ = rech$
END SELECT
'n = INSTR(zahl$, "D")
'IF n <> 0 THEN MID$(zahl$, n, 1) = "E"
IF stelle <> 0 THEN rech$ = LEFT$(rech$, vs - 1) + LTRIM$(zahl$) + MID$(rech$, stelle + ns + 1)
WEND
END FUNCTION

FUNCTION bin$ (zahl#)
text$ = OCT$(ABS(zahl))
text2$ = ""
FOR i = 1 TO LEN(text$)
SELECT CASE MID$(text$, i, 1)
CASE "0": ziffern$ = "000"
CASE "1": ziffern$ = "001"
CASE "2": ziffern$ = "010"
CASE "3": ziffern$ = "011"
CASE "4": ziffern$ = "100"
CASE "5": ziffern$ = "101"
CASE "6": ziffern$ = "110"
CASE "7": ziffern$ = "111"
END SELECT
text2$ = text2$ + ziffern$
NEXT i
FOR i = 1 TO LEN(text2$) - 1
IF LEFT$(text2$, 1) = "0" THEN text2$ = MID$(text2$, 2)
NEXT i
IF zahl < 0 THEN text2$ = "-" + text2$
bin$ = text2$
END FUNCTION

FUNCTION bino# (n#, k#)
'n!/(k!*(n-k)!)
bino# = fak#(n#) / (fak#(k#) * fak#(n# - k#))
END FUNCTION

SUB bruch (zahl#, stellen)
IF stellen > 5 THEN INPUT "Anzahl der Stellen: ", stellen
genau# = 1 / (10 ^ (stellen + 1))
'PRINT genau#
FOR nenner& = 1 TO 2147483647
zaehler# = zahl# * nenner&
'PRINT zaehler#, "/", nenner&
dif# = ABS(zaehler# - INT(zaehler# + .5))
dif# = dif# / nenner&
'PRINT dif#
IF dif# <= genau# THEN EXIT FOR
NEXT nenner&
IF nenner& < 2147483647 THEN text$ = STR$(INT(zaehler# + .5)) + " /" + STR$(nenner&) ELSE text$ = STR$(zahl#)
PRINT text$
END SUB

FUNCTION ersetze$ (text$)
text$ = text$ + " "
FOR i = LEN(text$) TO 1 STEP -1
stelle = funkvor(text$, i)
IF stelle < i THEN
        var$ = MID$(text$, stelle, i - stelle)
        IF (var$ = "e" OR var$ = "E") AND INSTR("1234567890.", MID$(" " + text$, stelle, 1)) THEN var$ = ""
        SELECT CASE var$
        CASE "i": zahl$ = zahlen$(0)
        CASE "ans": zahl$ = zahlen$(1)
        CASE "a":   zahl$ = zahlen$(2)
        CASE "b":   zahl$ = zahlen$(3)
        CASE "c":   zahl$ = zahlen$(4)
        CASE "d":   zahl$ = zahlen$(5)
        CASE "e":   zahl$ = zahlen$(6)
        CASE "f":   zahl$ = zahlen$(7)
        CASE "m":   zahl$ = zahlen$(8)
        CASE "x":   zahl$ = zahlen$(9)
        CASE "y":   zahl$ = zahlen$(10)
        CASE "pi":  zahl$ = "3.1415926535897932384626433832795"
        CASE "":    zahl$ = "e"
        CASE ELSE:  PRINT var$ + "=": INPUT zahl$
        END SELECT
        text$ = LEFT$(text$, stelle - 1) + zahl$ + MID$(text$, i)
END IF
NEXT i
ersetze$ = leer$(text$)
END FUNCTION

FUNCTION fak# (zahl#)
fake# = 1
FOR i = 1 TO zahl#
fake# = fake# * i
NEXT i
fak# = fake#
END FUNCTION

FUNCTION funk$ (name$, para$)
IF name$ = "sum" OR name$ = "mul" THEN
FOR i = 1 TO LEN(para$)
z$ = MID$(para$, i, 1)
IF z$ = "[" THEN MID$(para$, i, 1) = "("
IF z$ = "]" THEN MID$(para$, i, 1) = ")"
NEXT i
END IF

IF name$ = "log" OR name$ = "kgv" OR name$ = "ggt" OR name$ = "Åber" THEN
        para1$ = LTRIM$(berechne$(param$(para$, 1)))
        para2$ = LTRIM$(berechne$(param$(para$, 2)))
ELSEIF name$ = "if" OR name$ = "sum" OR name$ = "mul" THEN
        para1$ = LTRIM$(berechne$(param$(para$, 1)))
        para2$ = LTRIM$(berechne$(param$(para$, 2)))
        para3$ = param$(para$, 3)
ELSE
para$ = LTRIM$(berechne$(para$))
END IF

SELECT CASE name$
CASE "abs": zahl$ = STR$(ABS(VAL(para$)))
CASE "sgn": zahl$ = STR$(SGN(VAL(para$)))
CASE "sin": zahl$ = STR$(SIN(VAL(para$)))
CASE "cos": zahl$ = STR$(COS(VAL(para$)))
CASE "tan": zahl$ = STR$(TAN(VAL(para$)))
CASE "rand": RANDOMIZE TIMER
        zahl$ = STR$(INT(RND * VAL(para$)) + 1)
CASE "exp": zahl$ = STR$(EXP(VAL(para$)))
CASE "ln":
        IF VAL(para$) <= 0 THEN
                PRINT "Logarithmus nur von positiven Zahlen!"
                zahl$ = "-1.79769313486231D+308"
        ELSE
                zahl$ = STR$(LOG(VAL(para$)))
        END IF
CASE "lg":
        IF VAL(para$) <= 0 THEN
                PRINT "Logarithmus nur von positiven Zahlen!"
                zahl$ = "-1.79769313486231D+308"
        ELSE
                zahl$ = STR$(LOG(VAL(para$)) / LOG(10#))
        END IF
CASE "lb", "ld":
        IF VAL(para$) <= 0 THEN
                PRINT "Logarithmus nur von positiven Zahlen!"
                zahl$ = "-1.79769313486231D+308"
        ELSE
                zahl$ = STR$(LOG(VAL(para$)) / LOG(2#))
        END IF
CASE "log":
        IF VAL(para2$) <= 0 THEN
                PRINT "Logarithmus nur von positiven Zahlen!"
                zahl$ = "-1.79769313486231D+308"
        ELSE
                IF VAL(para1$) <= 0 THEN
                        PRINT "Logarithmus nur zu positiven Basen!"
                        para1$ = "1e-45"
                ELSEIF VAL(para1$) = 1 THEN
                        PRINT "Basis darf nicht 1 sein!"
                        INPUT "Neue Basis: ", para1$
                END IF
                zahl$ = STR$(LOG(VAL(para2$)) / LOG(VAL(para1$)))
        END IF
CASE "int": zahl$ = STR$(INT(VAL(para$)))
CASE "atan": zahl$ = STR$(ATN(VAL(para$)))
CASE "asin": x# = VAL(para$)
        IF x# < -1 THEN PRINT "Argument bei asin muss zwischen -1 und 1 liegen!": x# = -1
        IF x# > 1 THEN PRINT "Argument bei asin muss zwischen -1 und 1 liegen!": x# = 1
        IF x# ^ 2 = 1 THEN
                zahl$ = STR$(1.570796326794897# * SGN(x#))
        ELSE
                zahl$ = STR$(ATN(x# / SQR(1 - x# ^ 2)))
        END IF
CASE "acos": x# = VAL(para$)
        IF x# < -1 THEN PRINT "Argument bei acos muss zwischen -1 und 1 liegen!": x# = -1
        IF x# > 1 THEN PRINT "Argument bei acos muss zwischen -1 und 1 liegen!": x# = 1
        IF x# ^ 2 = 1 THEN
                zahl$ = STR$(1.570796326794897# + 1.570796326794897# * SGN(x#))
        ELSE
                zahl$ = STR$(1.570796326794897# - ATN(x# / SQR(1 - x# ^ 2)))
        END IF
CASE "rnd": zahl$ = STR$(INT(.5# + VAL(para$)))
CASE "ggt": zahl$ = STR$(ggT(VAL(para1$), VAL(para2$)))
CASE "kgv": zahl$ = STR$(kgV(VAL(para1$), VAL(para2$)))
CASE "Åber": zahl$ = STR$(bino#(VAL(para1$), VAL(para2$))) 'n!/(k!*(n-k)!)
CASE "if": IF VAL(para1$) >= 0# THEN zahl$ = para2$ ELSE zahl$ = LTRIM$(berechne$(para3$))
CASE "sum": summe# = 0
            FOR i = VAL(para1$) TO VAL(para2$)
            zahlen$(0) = STR$(i)
            p$ = para3$
            summe# = summe# + VAL(klammer$(para3$))
            para3$ = p$
            NEXT i
            zahl$ = STR$(summe#)
CASE "mul": summe# = 1
            FOR i = VAL(para1$) TO VAL(para2$)
            zahlen$(0) = STR$(i)
            p$ = para3$
            summe# = summe# * VAL(klammer$(para3$))
            para3$ = p$
            NEXT i
            zahl$ = STR$(summe#)
CASE ELSE: anz = 0
           para1$ = ""
           FOR i = 1 TO LEN(para$)
                IF MID$(para$, i, 1) = "," THEN anz = anz + 1
           NEXT i
           FOR i = 1 TO anz + 1
           para1$ = para1$ + "," + LTRIM$(berechne$(param$(para$, i)))
           NEXT i
           PRINT name$ + "(" + MID$(para1$, 2) + ")=": INPUT zahl$
END SELECT
funk$ = zahl$
END FUNCTION

FUNCTION funkvor (text$, stelle)
n = 1
zeichen$ = MID$(" " + text$, 1 + stelle - n, 1)
WHILE INSTR("abcdefghijklmnopqrstuvwxyzÑîÅ", zeichen$)
n = n + 1
zeichen$ = MID$(" " + text$, 1 + stelle - n, 1)
WEND
funkvor = stelle - n + 1
END FUNCTION

FUNCTION ggT (a, b)
IF a < b THEN h = b: b = a: a = h
WHILE b > 0
h = b
b = a MOD b
a = h
WEND
ggT = a
END FUNCTION

FUNCTION kgV (a, b)
kgV = a * b / ggT(a, b)
END FUNCTION

FUNCTION klammer$ (rech$)
zu = 1
WHILE zu > 0
zu = INSTR(rech$, ")")
IF zu > 0 THEN
        auf = INSTR(rech$, "(")
        WHILE auf < zu AND auf > 0
        alt = auf
        auf = INSTR(alt + 1, rech$, "(")
        WEND
        auf = alt
        auf = funkvor(rech$, auf)
        par$ = MID$(rech$, alt + 1, zu - alt - 1)
        IF auf = alt THEN
                zahl$ = LTRIM$(berechne$(par$))
        ELSE
                zahl$ = LTRIM$(funk$(MID$(rech$, auf, alt - auf), par$))
        END IF
        rech$ = LEFT$(rech$, auf - 1) + zahl$ + MID$(rech$, zu + 1)
END IF
WEND
klammer$ = berechne$(rech$)
END FUNCTION

FUNCTION klumpen$ (text$)
vorz = 0
FOR i = 1 TO LEN(text$)
zeichen$ = MID$(text$, i, 1)
IF zeichen$ = "+" OR zeichen$ = "-" THEN
        IF vorz = 0 THEN vorz = i
ELSE
        IF vorz <> 0 THEN
                anz = 0
                FOR j = vorz TO i - 1
                IF MID$(text$, j, 1) = "-" THEN anz = anz + 1
                NEXT j
                IF anz MOD 2 = 0 THEN z$ = "+" ELSE z$ = "-"
                text$ = LEFT$(text$, vorz - 1) + z$ + SPACE$(i - vorz - 1) + MID$(text$, i)
                vorz = 0
        END IF
END IF
NEXT i
klumpen$ = leer$(text$)
END FUNCTION

FUNCTION leer$ (text$)
p = INSTR(text$, " ")
WHILE p <> 0
text$ = LEFT$(text$, p - 1) + MID$(text$, p + 1)
p = INSTR(text$, " ")
WEND
leer$ = text$
END FUNCTION

FUNCTION nach (text$, stelle)
nach = zuzahl(MID$(text$, stelle + 1), MID$(text$, stelle, 1))
END FUNCTION

FUNCTION param$ (text1$, nummer)
text$ = text1$ + ","
anz = 0
kommas = 0
stelle = 0
FOR i = 1 TO LEN(text$)
z$ = MID$(text$, i, 1)
SELECT CASE z$
CASE "(": anz = anz + 1
CASE ")": anz = anz - 1
CASE ",": IF anz = 0 THEN kommas = kommas + 1: alt = stelle: stelle = i
END SELECT
IF kommas = nummer THEN EXIT FOR
NEXT i
param$ = MID$(text$, alt + 1, stelle - alt - 1)
END FUNCTION

SUB sechzig (zahl#, stellen)
genau# = 1 / 10 ^ (stellen + 1)
text$ = STR$(INT(zahl#)) + "¯"
zahl# = zahl# - INT(zahl#)
IF ABS(zahl#) >= genau# THEN
        zahl# = zahl# * 60
        text$ = text$ + STR$(INT(zahl#)) + "'"
        zahl# = zahl# - INT(zahl#)
        IF ABS(zahl# / 60) >= genau# THEN
                zahl# = zahl# * 60
                text$ = text$ + STR$(INT(.5 + zahl#)) + CHR$(34)
        END IF
END IF
PRINT text$
END SUB

SUB sysanz (zahl#, sys)
text$ = ""
vorz$ = ""
IF zahl# < 0 THEN vorz$ = "-"
zahl# = ABS(INT(.5 + zahl#))
WHILE zahl# >= .5
ziffer = zahl# MOD sys
zahl# = INT(zahl# / sys)
IF ziffer >= 9.5 THEN
        z$ = CHR$(ziffer + 55)
ELSE
        z$ = LTRIM$(STR$(ziffer))
END IF
text$ = z$ + text$
WEND
PRINT vorz$ + text$
END SUB

FUNCTION vor (text$, stelle)
n = 1
x = zuzahl(MID$(text$, n), MID$("*" + text$, n, 1))
WHILE x + n < stelle
n = n + 1
x = zuzahl(MID$(text$, n), MID$("*" + text$, n, 1))
WEND
vor = n
END FUNCTION

FUNCTION vorber$ (text$)
rech$ = text$

n = 1
WHILE n <> 0
n = INSTR(rech$, "˝")
IF n <> 0 THEN rech$ = LEFT$(rech$, n - 1) + "^2" + MID$(rech$, n + 1)
WEND

n = 1
WHILE n <> 0
n = INSTR(rech$, "¸")
IF n <> 0 THEN rech$ = LEFT$(rech$, n - 1) + "^3" + MID$(rech$, n + 1)
WEND

n = 1
WHILE n <> 0
n = INSTR(rech$, "%")
IF n <> 0 THEN rech$ = LEFT$(rech$, n - 1) + "/100" + MID$(rech$, n + 1)
WEND

n = 1
WHILE n <> 0
n = INSTR(rech$, " and ")
IF n <> 0 THEN rech$ = LEFT$(rech$, n - 1) + "&" + MID$(rech$, n + 5)
WEND

n = 1
WHILE n <> 0
n = INSTR(rech$, " or ")
IF n <> 0 THEN rech$ = LEFT$(rech$, n - 1) + "|" + MID$(rech$, n + 4)
WEND

n = 1
WHILE n <> 0
n = INSTR(" " + rech$, " not ")
IF n <> 0 THEN rech$ = LEFT$(rech$, n) + "~" + MID$(rech$, n + 4)
WEND

n = 1
WHILE n <> 0
n = INSTR(rech$, "¯")
IF n <> 0 THEN
        IF INSTR("^!&/+*-,|", MID$(rech$ + "*", n + 1, 1)) THEN
                rech$ = LEFT$(rech$, n - 1) + MID$(rech$, n + 1)
        ELSE
                rech$ = LEFT$(rech$, n - 1) + "+" + MID$(rech$, n + 1)
        END IF
END IF
WEND

n = 1
WHILE n <> 0
n = INSTR(rech$, "'")
IF n <> 0 THEN
        IF INSTR("^!&/+*-,|", MID$(rech$ + "*", n + 1, 1)) THEN
                rech$ = LEFT$(rech$, n - 1) + "/60" + MID$(rech$, n + 1)
        ELSE
                rech$ = LEFT$(rech$, n - 1) + "/60+" + MID$(rech$, n + 1)
        END IF
END IF
WEND

n = 1
WHILE n <> 0
n = INSTR(rech$, CHR$(34))
IF n <> 0 THEN
        IF INSTR("^!&/+*-,|", MID$(rech$ + "*", n + 1, 1)) THEN
                rech$ = LEFT$(rech$, n - 1) + "/3600" + MID$(rech$, n + 1)
        ELSE
                rech$ = LEFT$(rech$, n - 1) + "/3600+" + MID$(rech$, n + 1)
        END IF
END IF
WEND

rech$ = leer$(rech$)

anz = 0
FOR n = 1 TO LEN(rech$)
IF MID$(rech$, n, 1) = "(" THEN anz = anz + 1
IF MID$(rech$, n, 1) = ")" THEN anz = anz - 1
NEXT n
IF anz < 0 THEN
        rech$ = STRING$(ABS(anz), "(") + rech$
        BEEP
ELSEIF anz > 0 THEN
        rech$ = rech$ + STRING$(anz, ")")
        BEEP
END IF

n = 1
letzt = 1
WHILE n <> 0
        n = INSTR(letzt, rech$, "sum")
        IF n <> 0 THEN
                auf = 1
                letzt = n + 1
                n = n + 5
                ende = 0
                WHILE n < LEN(rech$) AND ende = 0
                        IF MID$(rech$, n, 1) = "(" THEN
                                auf = auf + 1
                                MID$(rech$, n, 1) = "["
                        ELSEIF MID$(rech$, n, 1) = ")" THEN
                                auf = auf - 1
                                IF auf = 0 THEN
                                        ende = 1
                                ELSE
                                        MID$(rech$, n, 1) = "]"
                                END IF
                        ELSE
                        END IF
                n = n + 1
                WEND
        END IF
WEND

n = 1
letzt = 1
WHILE n <> 0
        n = INSTR(letzt, rech$, "mul")
        IF n <> 0 THEN
                auf = 1
                letzt = n + 1
                n = n + 5
                ende = 0
                WHILE n < LEN(rech$) AND ende = 0
                        IF MID$(rech$, n, 1) = "(" THEN
                                auf = auf + 1
                                MID$(rech$, n, 1) = "["
                        ELSEIF MID$(rech$, n, 1) = ")" THEN
                                auf = auf - 1
                                IF auf = 0 THEN
                                        ende = 1
                                ELSE
                                        MID$(rech$, n, 1) = "]"
                                END IF
                        ELSE
                        END IF
                n = n + 1
                WEND
        END IF
WEND

vorber$ = rech$
END FUNCTION

FUNCTION zuzahl (text$, davor$)
punkt$ = "."
e$ = "eED"
IF INSTR("+-*/^&|~", davor$) THEN vorz$ = "+-" ELSE vorz$ = ""
ziffer$ = "1234567890"
stelle = 1
ende = 0
WHILE ende = 0
zeichen$ = MID$(text$ + " ", stelle, 1)
IF INSTR(ziffer$, zeichen$) THEN
        vorz$ = ""
ELSEIF INSTR(punkt$, zeichen$) THEN
        vorz$ = ""
ELSEIF INSTR(vorz$, zeichen$) THEN
       vorz$ = ""
       max = max + 1
ELSEIF INSTR(e$, zeichen$) THEN
        e$ = ""
        vorz$ = "+-"
        punkt$ = ""
ELSE
        ende = 1
END IF
stelle = stelle + 1
WEND
zuzahl = stelle - 2
END FUNCTION

