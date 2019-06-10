#DEFINE TRI ANY !" \t\n\f\v"

'/*
'*  reades and convertes the Signals.def file (C into FB)
'*  Liest und konvertiert die Signals.def Datei (C into FB)
'**********************************************************************/
CONSTRUCTOR SigData(BYVAL Ui AS UserInt PTR, BYREF F AS STRING)
  VAR fnr = FREEFILE
  WITH *Ui
    IF 0 = .No(OPEN(F FOR BINARY ACCESS READ LOCK WRITE AS #fnr), F) THEN
      VAR fl = 0
      DO
        VAR na = readName(fnr) : IF LEN(na) = 0 THEN EXIT DO
        VAR ty = readTyp(fnr)
        VAR pa = readPar(fnr)
        VAR p = Sig.add(na, ty & !"\t" & pa, 1)
        IF p THEN .RausRot(NL & *p) : .Raus(" " & na) : fl += 1
      LOOP UNTIL EOF(fnr) : CLOSE #fnr
      IF fl THEN .Raus(NL)
      .Raus(" >> " & Sig.az() & " " & *__("definitions found") & "!" & NL)
    END IF
  END WITH
END CONSTRUCTOR

'/*
'*  reades the name of a signal definition
'*  liest den Namen einer Signaldefinition
'**********************************************************************/
FUNCTION SigData.readName(BYVAL Fnr AS LONG) AS STRING
  DIM AS UBYTE z
  VAR s = "The """, p = 0, ls = LEN(s)
  DO
    IF EOF(Fnr) THEN RETURN ""
    GET #Fnr, , z
    p = IIF(s[p] <> z, 0, p + 1)
  LOOP UNTIL p >= ls
  VAR n = ""
  DO
    IF EOF(Fnr) THEN RETURN ""
    GET #Fnr, , z
    IF z <> ASC("""") THEN n += CHR(z) ELSE EXIT DO
  LOOP : s = " signal" : ls = LEN(s) : p = 0
  DO
    IF EOF(Fnr) THEN RETURN ""
    GET #Fnr, , z
    p = IIF(s[p] <> z, 0, p + 1)
  LOOP UNTIL p >= ls : CheckMinus(n) : RETURN n
END FUNCTION

'/*
'*  convertes a C-type into FB
'*  Konvertiert einen C-Variablentyp in einen FB-Typ
'**********************************************************************/
FUNCTION SigData.readTyp(BYVAL Fnr AS LONG) AS STRING
  DIM AS UBYTE z
  VAR a = "", n = "", s = " user_function", p = 0, ls = LEN(s)
  DO
    IF EOF(Fnr) THEN RETURN ""
    GET #Fnr, , z
    SELECT CASE AS CONST z
    CASE ASC(!"\t"), ASC(!"\n"), ASC(!"\f"), ASC(!"\v") : z = ASC(" ")
    CASE ASC("*") : z = ASC(" ") : a &= " PTR"
    CASE ASC("-") : z = ASC("_") : n &= "_"
    CASE ASC("0") TO ASC("9"), ASC("_"), ASC("A") TO ASC("Z"), ASC("a") TO ASC("z")
      n &= CHR(z)
    END SELECT
    p += IIF(s[p] <> z, 0, 1)
  LOOP UNTIL p >= ls : n = LEFT(n, LEN(n) - ls + 1)
  IF n = "void" THEN RETURN ""
  CheckMinus(n) : RETURN n & a
END FUNCTION

'/*
'*  reades a C-parameter definition
'*  Liest eine C-Parameterdefinition
'**********************************************************************/
FUNCTION SigData.readPar(BYVAL Fnr AS LONG) AS STRING
  DIM AS UBYTE z
  DO
    IF EOF(Fnr) THEN RETURN ""
    GET #Fnr, , z
  LOOP UNTIL z = ASC("(")
  VAR r = "", s = "", t = "", fl = -1
  WHILE NOT EOF(Fnr)
    GET #Fnr, , z
    SELECT CASE AS CONST z
    CASE ASC(!"\t"), ASC(!"\n"), ASC(!"\f"), ASC(!"\v"), ASC(!" ")
      IF fl = 0 THEN fl = 1
    CASE ASC("*")
      fl = 1 : s &= " PTR"
    CASE ASC(")"), ASC(",")
      fl = INSTRREV(t, " ")
      IF fl THEN
        r &= LEFT(t, fl - 1) & s & !"\t" & MID(t, fl + 1)
      ELSE
        r &= t & !"\tuser_data"
      END IF : IF z = ASC(",") THEN r &= !"\t" ELSE RETURN r
      s = "" : t = "" : fl = -1
    CASE ASC("0") TO ASC("9"), ASC("-"), ASC("_"), _
         ASC("A") TO ASC("Z"), ASC("a") TO ASC("z")
      IF z = ASC("-") THEN z = ASC("_")
      IF fl = 1 THEN t &= " " & CHR(z) ELSE t += CHR(z)
      fl = 0
    END SELECT
  WEND : RETURN ""
END FUNCTION

'/*
'*  replace '-' by '_'
'*  Ersetzt '-' durch '_'
'**********************************************************************/
SUB SigData.CheckMinus(BYREF N AS STRING)
  FOR i AS LONG = 0 TO LEN(N) - 1
    IF N[i] = ASC("-") THEN N[i] = ASC("_")
  NEXT
END SUB

'/*
'*  finds the matching signal definition for W=widget and N=signal name
'*  Findet die passende Signaldefinition
'**********************************************************************/
FUNCTION SigData.Find(BYREF W AS STRING, BYREF N AS STRING) AS STRING
  CheckMinus(N) : VAR r = Sig.Po_(N, 1)
  SELECT CASE AS CONST LEN(r)
  CASE 0 : RETURN MKL(0)
  CASE 4 : RETURN r
  END SELECT
  IF W = "GtkCheckButton" THEN W = "GtkToggleButton"
  FOR i AS LONG = 1 TO LEN(r) STEP 4 '      find matching signal-type
    VAR j = CVL(MID(r, i, 4))
    VAR a = INSTR(j, Sig.Er, TRI) + 3, e = INSTR(a, Sig.Er, TRI) - 1, lw = LEN(W)
    IF e > a THEN
      DO
        e -= 1 : lw -= 1 : IF e < a ORELSE lw < 3 THEN RETURN MID(r, i, 4)
      LOOP UNTIL Sig.Er[e] <> W[lw]
    END IF
  NEXT : RETURN MKL(0) '                   nothing found, return default
END FUNCTION

'/*
'*  generates a FB parameter list from a stored parameter definition
'*  Erzeugt eine FB Parameterliste aus einer gespeicherten Definition
'**********************************************************************/
FUNCTION SigData.genParList(BYREF P AS STRING, BYREF T AS STRING) AS STRING
  VAR a1 = 1, r = ""
  DO
    VAR e1 = INSTR(a1, P, !"\t")
    VAR a2 = e1 + 1
    VAR e2 = INSTR(a2, P, !"\t")
    r &= T & MID(P, a2, e2 - a2) & " AS " & MID(P, a1, e1 - a1)
    IF e2 THEN r &= "," ELSE EXIT DO
    a1 = e2 + 1
  LOOP : RETURN "(" & r & ")"
END FUNCTION

'/*
'*  generates the FB source for the signal handlers
'*  Erzeugt die FB-Quelltext fuer die Signal-Handler (Callbacks))
'**********************************************************************/
FUNCTION SigData.GenHandler(BYREF T AS STRING) AS STRING
  VAR fl = CVL(*_UI_.Xml.Han->Rep(T)), pl = ""
  IF fl THEN
    VAR e = INSTR(fl + 1, _UI_.Sig->Sig.Er, !"\0")
    pl = MID(_UI_.Sig->Sig.Er, fl, e - fl)
  ELSE
    pl = !"\tGtkWidget PTR\twidget\tgpointer\tuser_data" ' standard
  END IF

  VAR n = T : CheckMinus(n)
  VAR p = INSTR(pl, !"\t") - 1, r = *IIF(p <= 0, @"SUB ", @"FUNCTION ")
  r &= n & " CDECL ALIAS """ & n & """ "
  r &= genParList(MID(pl, p + 2), " _" & NL & "  BYVAL ")
  IF p > 0 THEN r &= " AS " & LEFT(pl, p)
  r &= " EXPORT"
  IF 0 = fl THEN r &= " ' Standard-Parameterliste"
  r &= NL & NL
  r &= "' place your source code here / eigenen Quelltext hier einfuegen" & NL
  r &= BasErr & NL & NL
  IF p > 0 THEN
    r &= "RETURN 0 ' your value here!" & NL & NL & "END FUNCTION"
  ELSE
    r &= "END SUB"
  END IF : RETURN r & NL
END FUNCTION
