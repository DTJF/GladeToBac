' Object for seach words (Su) and replacements (Er), incl counters
' Objekt zur Speicherung von Suchworten(Su) und deren Ersetzungen(Er)
' Anzahl Suchworte/Ersetzungen wird gezählt.

' Number of search words
' Anzahl der Suchworte
'FUNCTION RepData.Az() AS LONG : RETURN *CAST(LONG PTR, SADD(Su))
FUNCTION RepData.Az() AS LONG : RETURN STACK_ANZ(SADD(Su))
END FUNCTION

' List all elements, output by callback function
' Listet alle Elemente, Ausgabe durch Callback-Funktion
SUB RepData.ForEach(BYVAL Cb AS FUNCTION(BYREF AS STRING, BYVAL AS ZSTRING PTR) AS LONG)
  VAR r = "", a = 6, e = INSTR(a, Su, CHR(2)), t = ""
  WHILE e > a
    VAR l = e - a, s = MID(Su, a, l) : e += 1
    VAR x = INSTR(e, Su, CHR(1)), z = SADD(Er) + VALINT("&h" & MID(Su, e, x - e))
    IF Cb(s, z) THEN EXIT SUB
    a = x + 1 : e = INSTR(a, Su, CHR(2))
  WEND
END SUB

' return text for entry # (# from Er)
' liefert Text zu Element # (aus Er)
FUNCTION RepData.fin(BYREF N AS LONG) AS STRING
  VAR r = "", a = 6, e = INSTR(a, Su, CHR(2)), t = ""
  WHILE e > a
    VAR l = e - a, s = MID(Su, a, l) : e += 1
    VAR x = INSTR(e, Su, CHR(1)), z = SADD(Er) + VALINT("&h" & MID(Su, e, x - e))
    'IF N = *CAST(LONG PTR, z) THEN RETURN s
    IF N = STACK_ANZ(z) THEN RETURN s
    a = x + 1 : e = INSTR(a, Su, CHR(2))
  WEND : RETURN ""
END FUNCTION

' Add new element
' Fuegt neues Element hinzu
FUNCTION RepData.add(BYREF S AS STRING, BYREF E AS STRING, _
                     BYVAL M AS LONG = 0) AS ZSTRING PTR
  IF S = "" THEN RETURN 0
  IF INSTR(S, ANY !"\000\001\002") THEN RETURN @"undefined char (search)"
  VAR c = CHR(1) & S & CHR(2)
  IF INSTR(5, Su, c) THEN IF M = 0 THEN RETURN @"allready defined"
  '*CAST(LONG PTR, SADD(Su)) += 1 : Su &= MID(c, 2) & HEX(LEN(Er)) & CHR(1)
  STACK_ANZ(SADD(Su)) += 1 : Su &= MID(c, 2) & HEX(LEN(Er)) & CHR(1)
  Er &= E & CHR(0) : RETURN 0
END FUNCTION

' Search for word, returns PTR (or list of PTRs) to replacement
' Sucht Wort, liefert PTR (oder Liste) zum Ersetzungstext
FUNCTION RepData.Po_(BYREF T AS STRING, BYVAL M AS LONG = 0) AS STRING
  VAR e = 5, r = "", s = CHR(1) & T & CHR(2), l = LEN(T) + 2
  DO
    VAR a = INSTR(e, Su, s) : IF a = 0 THEN EXIT DO
    VAR p = a + l
    e = INSTR(p, Su, CHR(1)) + 1 : IF 1 >= e THEN EXIT DO
    VAR z = VALINT("&h" & MID(Su, p, e - p))
    r &= MKL(z)
  LOOP UNTIL M = 0 : RETURN r
END FUNCTION

' Search for word, returns replacement
' Sucht Wort, liefert Ersetzungstext
FUNCTION RepData.Rep(BYREF T AS STRING) AS ZSTRING PTR
  VAR p = Po_(T) : RETURN IIF(LEN(p), SADD(Er) + CVL(p), 0)
END FUNCTION
