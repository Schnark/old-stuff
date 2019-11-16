DECLARE FUNCTION plus! (a!, b!)
DECLARE FUNCTION minus! (a!, b!)
DECLARE SUB zeige (text$)
COMMON SHARED spar1$, spar2$
COMMON SHARED zpar1, zpar2
COMMON SHARED name$, prog$
COMMON SHARED serg$, zerg
COMMON SHARED zeile

COMMON a, b

SELECT CASE name$
CASE "plus": zerg = plus(zpar1, zpar2)
CASE "minus": zerg = minus(zpar1, zpar2)
CASE "zeige": zeige (spar1$)
END SELECT
CHAIN prog$

FUNCTION minus (a, b)
minus = a - b
END FUNCTION

FUNCTION plus (a, b)
plus = a + b
END FUNCTION

SUB zeige (text$)
PRINT text$
END SUB

