DECLARE SUB aufruf (n$, unit$, z)  'Name d. SUB/FUNC, Name d. Unit, Zeile
COMMON SHARED spar1$, spar2$       'Stringparameter
COMMON SHARED zpar1, zpar2         'Zahlenparameter
COMMON SHARED name$, prog$         'Name d. SUB/FUNC, Name d. Programms
COMMON SHARED serg$, zerg          'Ergebnis (String, Zahl)
COMMON SHARED zeile                'n„chste Zeile

COMMON a, b

SELECT CASE zeile
CASE 1: GOTO 1
CASE 2: GOTO 2
CASE ELSE: prog$ = "test.bas"      'Name des Programms
END SELECT

CLS
a = 5
b = 7
zpar1 = a
zpar2 = b
aufruf "plus", "unit.bas", 1
1 : spar1$ = STR$(a) + "+" + STR$(b) + "=" + STR$(zerg)
aufruf "zeige", "unit.bas", 2
2 : END

SUB aufruf (n$, unit$, z)
name$ = n$
zeile = z
CHAIN unit$
END SUB

