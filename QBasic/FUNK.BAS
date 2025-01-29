DECLARE FUNCTION ableitung$ (funktion$)
DECLARE FUNCTION ablkette$ (aussen$, innen$)
DECLARE FUNCTION ablmult$ (funk1$, funk2$)
DECLARE FUNCTION abladd$ (funk1$, funk2$)
DECLARE FUNCTION abl$ (funk$)
DECLARE FUNCTION normal$ (funk$)
DECLARE SUB anzeige (funktion$)
DECLARE FUNCTION funkvor! (text$, stelle!)
DECLARE FUNCTION funknach! (text$, stelle!)
DECLARE FUNCTION kette$ (aussen$, innen$)
DECLARE FUNCTION mult$ (vor$, nach$)
DECLARE FUNCTION add$ (vor$, nach$)
PRINT "h(n)=x^n       n"
PRINT "p(n)=n^x       0 sin  3 asin 6 sinh  9 asinh 12 ln"
PRINT "c(n)=n         1 cos  4 acos 7 cosh 10 acosh 13 abs"
PRINT "r=1/x          2 tan  5 atan 8 tanh 11 atanh 14 sgn"
PRINT "f(n)"
PRINT "føg  f#g (*)  f&g (+)"
INPUT funk$
f$ = funk$
anzeige funk$
anzeige ableitung$(f$)

FUNCTION abl$ (funk$)
SELECT CASE LEFT$(funk$, 1)
CASE "h": abl$ = "(c(" + MID$(funk$, 3) + "*h(" + STR$(VAL(MID$(funk$, 3)) - 1) + ")"
CASE "p": abl$ = "(c(" + STR$(LOG(VAL(MID$(funk$, 3)))) + "*" + funk$ + ")"
CASE "c": abl$ = "c(0)"
CASE "r": abl$ = "(c(-1)*h(-2))"
CASE "f"
        SELECT CASE VAL(MID$(funk$, 3, LEN(funk$) - 3))
        CASE 0: abl$ = "f(1)"
        CASE 1: abl$ = "(c(-1)*f(0))"
 '       CASE 2: abl$ = "(tan x)"
 '       CASE 3: abl$ = "(asin x)"
 '       CASE 4: abl$ = "(acos x)"
 '       CASE 5: abl$ = "(atan x)"
 '       CASE 6: abl$ = "(sinh x)"
 '       CASE 7: abl$ = "(cosh x)"
 '       CASE 8: abl$ = "(tanh x)"
 '       CASE 9: abl$ = "(asinh x)"
 '       CASE 10: abl$ = "(acosh x)"
 '       CASE 11: abl$ = "(atanh x)"
        CASE 12: abl$ = "r"
        CASE 13: abl$ = "f(14)"
        CASE 14: abl$ = "c(0)"
        END SELECT
CASE ELSE: abl$ = funk$
END SELECT
END FUNCTION

FUNCTION abladd$ (funk1$, funk2$)
abladd$ = abl$(funk1$) + "+" + abl$(funk2$)
END FUNCTION

FUNCTION ableitung$ (funktion$)
ende = 0
WHILE ende = 0
kett = INSTR(funktion$, "ø")
mal = INSTR(funktion$, "#")
plus = INSTR(funktion$, "&")

IF kett > 0 THEN
davor = funkvor(funktion$, kett)
danach = funknach(funktion$, kett)
funktion$ = LEFT$(funktion$, davor - 1) + ablkette$(MID$(funktion$, davor, kett - davor), MID$(funktion$, kett + 1, danach - kett)) + MID$(funktion$, danach + 1)
ELSEIF mal > 0 THEN
davor = funkvor(funktion$, mal)
danach = funknach(funktion$, mal)
funktion$ = LEFT$(funktion$, davor - 1) + ablmult$(MID$(funktion$, davor, mal - davor), MID$(funktion$, mal + 1, danach - mal)) + MID$(funktion$, danach + 1)
ELSEIF plus > 0 THEN
davor = funkvor(funktion$, plus)
danach = funknach(funktion$, plus)
funktion$ = LEFT$(funktion$, davor - 1) + abladd$(MID$(funktion$, davor, plus - davor), MID$(funktion$, plus + 1, danach - plus)) + MID$(funktion$, danach + 1)
ELSE
ende = 1
END IF
WEND

FOR i = 1 TO LEN(funktion$)
z$ = MID$(funktion$, i, 1)
IF z$ = "~" THEN z$ = "ø"
IF z$ = "*" THEN z$ = "#"
IF z$ = "+" THEN z$ = "&"
MID$(funktion$, i, 1) = z$
NEXT i
ableitung$ = funktion$
END FUNCTION

FUNCTION ablkette$ (aussen$, innen$)
ablkette$ = abl$(innen$) + "*" + abl$(aussen$) + "~" + innen$
END FUNCTION

FUNCTION ablmult$ (funk1$, funk2$)
ablmult$ = abl$(funk1$) + "*" + funk2$ + "+" + funk1$ + "*" + abl$(funk2$)
END FUNCTION

FUNCTION add$ (vor$, nach$)
vor$ = normal$(vor$)
nach$ = normal$(nach$)
add$ = vor$ + "+" + nach$
END FUNCTION

SUB anzeige (funktion$)
ende = 0
WHILE ende = 0
kett = INSTR(funktion$, "ø")
mal = INSTR(funktion$, "#")
plus = INSTR(funktion$, "&")

IF kett > 0 THEN
davor = funkvor(funktion$, kett)
danach = funknach(funktion$, kett)
funktion$ = LEFT$(funktion$, davor - 1) + kette$(MID$(funktion$, davor, kett - davor), MID$(funktion$, kett + 1, danach - kett)) + MID$(funktion$, danach + 1)
ELSEIF mal > 0 THEN
davor = funkvor(funktion$, mal)
danach = funknach(funktion$, mal)
funktion$ = LEFT$(funktion$, davor - 1) + mult$(MID$(funktion$, davor, mal - davor), MID$(funktion$, mal + 1, danach - mal)) + MID$(funktion$, danach + 1)
ELSEIF plus > 0 THEN
davor = funkvor(funktion$, plus)
danach = funknach(funktion$, plus)
funktion$ = LEFT$(funktion$, davor - 1) + add$(MID$(funktion$, davor, plus - davor), MID$(funktion$, plus + 1, danach - plus)) + MID$(funktion$, danach + 1)
ELSE
ende = 1
END IF
WEND
PRINT funktion$
END SUB

FUNCTION funknach (text$, stelle)
i = stelle + 1
ende = 0
anz = 0
WHILE i <= LEN(text$) AND ende = 0
z$ = MID$(text$, i, 1)
IF z$ = "(" THEN
        anz = anz + 1
ELSEIF z$ = ")" THEN
        anz = anz - 1
ELSEIF INSTR("ø&#", z$) AND anz = 0 THEN
        ende = 1
END IF
i = i + 1
WEND
IF ende = 0 THEN funknach = i - 1 ELSE funknach = i - 2
END FUNCTION

FUNCTION funkvor (text$, stelle)
i = stelle - 1
ende = 0
anz = 0
WHILE i > 0 AND ende = 0
z$ = MID$(text$, i, 1)
IF z$ = "(" THEN
        anz = anz - 1
        IF anz < 0 THEN ende = 1
ELSEIF z$ = ")" THEN
        anz = anz + 1
ELSEIF INSTR("ø&#", z$) AND anz = 0 THEN
        ende = 1
END IF
i = i - 1
WEND
IF ende = 1 THEN funkvor = i + 2 ELSE funkvor = i + 1
END FUNCTION

FUNCTION kette$ (aussen$, innen$)
aussen$ = normal$(aussen$)
innen$ = normal$(innen$)
length = LEN(aussen$)
FOR i = length TO 1 STEP -1
IF MID$(aussen$, i, 1) = "x" THEN aussen$ = LEFT$(aussen$, i - 1) + innen$ + MID$(aussen$, i + 1)
NEXT i
kette$ = aussen$
END FUNCTION

FUNCTION mult$ (vor$, nach$)
vor$ = normal$(vor$)
nach$ = normal$(nach$)
mult$ = vor$ + "*" + nach$
END FUNCTION

FUNCTION normal$ (funk$)
SELECT CASE LEFT$(funk$, 1)
CASE "h": normal$ = "(x^" + MID$(funk$, 3)
CASE "p": normal$ = "(" + MID$(funk$, 3, LEN(funk$) - 3) + "^x)"
CASE "c": normal$ = MID$(funk$, 3, LEN(funk$) - 3)
CASE "r": normal$ = "(1/x)"
CASE "f"
        SELECT CASE VAL(MID$(funk$, 3, LEN(funk$) - 3))
        CASE 0: normal$ = "(sin x)"
        CASE 1: normal$ = "(cos x)"
        CASE 2: normal$ = "(tan x)"
        CASE 3: normal$ = "(asin x)"
        CASE 4: normal$ = "(acos x)"
        CASE 5: normal$ = "(atan x)"
        CASE 6: normal$ = "(sinh x)"
        CASE 7: normal$ = "(cosh x)"
        CASE 8: normal$ = "(tanh x)"
        CASE 9: normal$ = "(asinh x)"
        CASE 10: normal$ = "(acosh x)"
        CASE 11: normal$ = "(atanh x)"
        CASE 12: normal$ = "(ln x)"
        CASE 13: normal$ = "(abs x)"
        CASE 14: normal$ = "(sgn x)"
        END SELECT
CASE ELSE: normal$ = funk$
END SELECT
END FUNCTION

