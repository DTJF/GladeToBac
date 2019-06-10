CONST AS STRING _
      IniBrei = "WindWidth=", _
      IniHoch = "WindHeight=", _
     IniLPath = "LinuxPathName=", _
     IniWPath = "WinPathName=", _
      IniAuth = "AuthorName=", _
      IniMail = "AuthorEmail=", _
      IniSite = "AuthorWebsite=", _
      IniDesc = "ProgramSynopsis=", _
      IniVers = "ProgramVersion=", _
      IniLiz  = "ProgramLicense=", _
      IniTyNa = "TypeName=", _
      IniGVer = "GtkVersion=", _
      IniI18N = "I18N=", _
      IniUiIn = "Glade=", _
      IniToba = "Tobac=", _
      IniMake = "Make=", _
    IniReadMe = "ReadMe=", _
     IniGeany = "Geany=", _
     IniFbIde = "FbIde=", _
    IniFbEdit = "FbEdit=", _
     IniJelly = "Jelly=", _
       IniWin = "Win=", _
        IniRc = "Rc=", _
       IniSuf = ".ini"

CONSTRUCTOR XmlData()
  FOR i AS INTEGER = ASC("A") TO ASC("Z")
    OkC[i] = 1
    OkC[i + 32] = 1
  NEXT
  OkC[ASC("_")] = 1
  FOR i AS INTEGER = ASC("0") TO ASC("9")
    OkC[i] = 2
  NEXT
  OkC[1] = 0
END CONSTRUCTOR

DESTRUCTOR XmlData()
  IF Han THEN DELETE Han
END DESTRUCTOR

SUB XmlData.Init(BYREF F AS STRING, BYVAL U AS UserInt PTR)
  Ui = U
  IF LEN(F) THEN
    WiMa = ""
    Ref = STACK_NEW
    IF Han THEN DELETE Han
    Han = NEW RepData

    VAR e = INSTRREV(F, ".")
    VAR a = INSTRREV(F, SLASH, e - 1) + 1
    Nam = MID(F, a, e - a)
    Suf = LCASE(MID(F, e))
    Path = LEFT(F, a - 2) : IF CHDIR(Path) THEN Path = Ui->S_Path

    Ui->RausClr(*__("Load / analyse") & NL & NL)
    IF LEN(Path) THEN Ui->Folder(Path)
    readIni()
    readBas()
    readXml()
  ELSE
    Bas = FALSE
    Gla = FALSE
    Nam = ""
    Suf = ""
    Path = EXEPATH
    Ui->Folder(Path)
    readIni(1)
    IF SLASH = "/" THEN Path = LPath ELSE Path = WPath
  END IF
END SUB

'/*
'* find a keyword in the .bas context, set value
'* finden eines Schluesselwortes in .bas Datei, Wert setzen
'**********************************************************************/
SUB XmlData.findBas(BYREF T AS STRING, BYREF W AS STRING, BYREF V AS STRING)
  VAR a = INSTR(T, W) : IF a = 0 THEN EXIT SUB
  a += LEN(W) : V = MID(T, a, INSTR(a, T, """") - a)
END SUB

'/*
'*  reads version from *.bas file
'*  liest die Version aus der *.bas-Datei
'**********************************************************************/
SUB XmlData.readBas()
  VAR n = Nam & SufBas
  WITH *Ui
    VAR fnr = FREEFILE
    IF .No(OPEN(n FOR INPUT AS #fnr), n) THEN Bas = FALSE : EXIT SUB
    VAR z = "", r = ""
    WHILE NOT EOF(fnr)
      LINE INPUT #fnr, z
      IF z = tobac_C_end THEN EXIT WHILE
      r &= z & NL
    WEND
    Bas = TRUE
    findBas(r, BasAuth, Auth)
    findBas(r, BasMail, Mail)
    findBas(r, BasSite, Site)
    findBas(r, BasDesc, Desc)
    findBas(r, BasVers, Vers)
    findBas(r, BasYear, Jahr) ' not shown in GUI
    '.GVer gets read from GUI-XML-file!
    I18N = IIF(INSTR(r, BasI18N), 1, 0) ' gettext(i18n) support
    findBas(r, BasLiz, PLiz)

    VAR e = 0, l = LEN(BasIncl)
    WHILE NOT EOF(fnr)
      LINE INPUT #fnr, z
      IF LEFT(z, l) = BasIncl THEN
        IF INSTR(l, z, Nam & SufTobac) THEN
          IF MID(z, l + 1, LEN(OrdTobac)) = OrdTobac THEN ToBa = 1 : EXIT WHILE
        END IF
      END IF
    WEND
    l = LEN(BasUnre)
    WHILE NOT EOF(fnr)
      LINE INPUT #fnr, z
      IF LEFT(z, l) = BasUnre THEN
        e = INSTR(l, z, ")") - 1
        n = MID(z, l + 1, e - l)
        e = INSTR(n, ".")
        IF e THEN TyNa = LEFT(n, e - 1) ELSE TyNa = ""
        EXIT WHILE
      END IF
    WEND : CLOSE #fnr
    Bas = TRUE
    .Raus(" >> " & *__("Read") & "!" & NL)

    IF .NoGui THEN
      .Raus(BasYear) : .RausBlau(Jahr) : .Raus("""" & NL)
      .Raus(BasAuth) : .RausBlau(Auth) : .Raus("""" & NL)
      .Raus(BasMail) : .RausBlau(Mail) : .Raus("""" & NL)
      .Raus(BasSite) : .RausBlau(Site) : .Raus("""" & NL)
      .Raus(BasDesc) : .RausBlau(Desc) : .Raus("""" & NL)
      .Raus(BasVers) : .RausBlau(Vers) : .Raus("""" & NL)
      .Raus(BasLiz)  : .RausBlau(PLiz) : .Raus("""" & NL)
      .Raus(*__("      TYPE name") & " = ") : .RausBlau(TyNa & NL)
      .Raus(*__("   GTK-Version") & " >= ") : .RausBlau(GVer & NL)
      .Raus(*__("     I18N support") & " ")
      .RausBlau(*IIF(I18N, __("on"), __("off")) & NL)
    END IF
  END WITH
END SUB

SUB XmlData.findUin(BYREF Z AS STRING, BYREF W AS STRING, BYREF V AS LONG)
  VAR a = INSTR(Z, W) : IF a = 0 THEN EXIT SUB
  a += LEN(W)
  V = VALINT(MID(Z, a))
END SUB

SUB XmlData.findStr(BYREF Z AS STRING, BYREF W AS STRING, BYREF V AS STRING)
  VAR a = INSTR(Z, W) : IF a = 0 THEN EXIT SUB
  a += LEN(W)
  V = MID(Z, a, INSTR(a, Z, ANY CHR(13, 10)) - a)
END SUB

#MACRO findBool(Z, W, V)
 SCOPE
   VAR a = INSTR(Z, W)
   V = IIF(a, IIF(1 = VALINT(MID(Z, a + LEN(W))), 1, 0), V)
 END SCOPE
#ENDMACRO

'/*
'*  reades parameters from ini-file into GUI
'*  liest die Parameter aus dem ini-Datei und schreibt in GUI
'**********************************************************************/
SUB XmlData.readIni(BYVAL Mo AS INTEGER = 0)
  VAR n = PROJ_NAME & IniSuf
  WITH *Ui
    VAR fnr = FREEFILE
    IF .No(OPEN(n FOR INPUT AS #fnr), n) THEN '             no .ini-file
      IF Mo < 1 THEN EXIT SUB

      .Raus(*__("Setting default values") & "!" & NL)
      Auth = ""
      Mail = ""
      Site = ""
      Desc = ""
      Vers = "0.0"
      TyNa = ""
      GVer = ""
      PLiz = ""

      Toba = TRUE
      I18N = TRUE
      UiIn = FALSE

      .Make   = FALSE
      .ReadMe = FALSE
      .Geany  = FALSE
      .FbIde  = FALSE
      .FbEdit = FALSE
      .Jelly  = FALSE
      .Win    = FALSE
      .Rc     = FALSE

      IF SLASH = "/" THEN LPath = .S_Path ELSE WPath = .S_Path
      saveIni()
      EXIT SUB
    END IF

    VAR p = "", r = p
    WHILE NOT EOF(fnr) '                                  read .ini-file
      LINE INPUT #fnr, n
      p &= n & NL
    WEND : CLOSE #fnr

    findStr(p, IniAuth, Auth) '        set values from .ini-file, if any
    findStr(p, IniMail, Mail)
    findStr(p, IniSite, Site)
    findStr(p, IniDesc, Desc)
    findStr(p, IniVers, Vers)
    findStr(p, IniTyNa, TyNa)
    findStr(p, IniGVer, GVer) : IF LEN(GVer) THEN GVer = GtkVersStr(GVer, ".")
    findStr(p,  IniLiz, PLiz)

    findBool(p, IniToba, Toba)
    findBool(p, IniI18N, I18N)
    findBool(p, IniUiIn, UiIn)

    findBool(p,   IniMake, .Make)
    findBool(p, IniReadMe, .ReadMe)
    findBool(p,  IniGeany, .Geany)
    findBool(p,  IniFbIde, .FbIde)
    findBool(p, IniFbEdit, .FbEdit)
    findBool(p,  IniJelly, .Jelly)
    findBool(p,    IniWin, .Win)
    findBool(p,     IniRc, .Rc)

    findUin(p,  IniBrei, .Brei)
    findUin(p,  IniHoch, .Hoch)
    findStr(p, IniLPath, LPath)
    findStr(p, IniWPath, WPath)
    .Raus(" >> " & *__("Read") & "!" & NL)
  END WITH
END SUB

'/*
'*  writes parameters from UI into ini-file
'*  schreibt die Parameter aus dem GUI in die ini-Datei
'**********************************************************************/
SUB XmlData.saveIni()
  WITH *Ui
    VAR n = PROJ_NAME & IniSuf, fnr = FREEFILE
    IF 0 = .No(OPEN(n FOR OUTPUT AS #fnr), n) THEN
      IF SLASH = "/" THEN LPath = Path ELSE WPath = Path
      PRINT #fnr,  IniLPath & LPath
      PRINT #fnr,  IniWPath & WPath
      PRINT #fnr,   IniBrei & .Brei
      PRINT #fnr,   IniHoch & .Hoch

      PRINT #fnr,   IniAuth & Auth
      PRINT #fnr,   IniMail & Mail
      PRINT #fnr,   IniSite & Site
      PRINT #fnr,   IniDesc & Desc
      PRINT #fnr,   IniVers & Vers
      PRINT #fnr,   IniTyNa & TyNa
      PRINT #fnr,   IniGVer & GVer
      PRINT #fnr,   IniI18N & I18N
      PRINT #fnr,    IniLiz & PLiz

      PRINT #fnr,   IniUiIn & UiIn
      PRINT #fnr,   IniToba & Toba

      PRINT #fnr,   IniMake & .Make
      PRINT #fnr, IniReadMe & .ReadMe
      PRINT #fnr,  IniGeany & .Geany
      PRINT #fnr,  IniFbIde & .FbIde
      PRINT #fnr, IniFbEdit & .FbEdit
      PRINT #fnr,  IniJelly & .Jelly
      PRINT #fnr,    IniWin & .Win
      PRINT #fnr,     IniRc & .Rc
      CLOSE #fnr
      .Raus(" >> " & *__("Written") & "!" & NL)
    END IF
  END WITH
END SUB

'/*
'*  calculates a version# from STRING T
'*  berechnet eine Versionsnummer aus dem STRING T
'**********************************************************************/
FUNCTION XmlData.GtkVers(BYREF T AS STRING) AS UINTEGER
  DIM AS INTEGER v(3), a = 1
  FOR i AS INTEGER = 0 TO 3
    VAR l = INSTR(a, T, ANY !" .\t") - a
    v(i) = VALINT(MID(T, a, l)) AND &hFF
    IF l > 0 THEN a += l + 1 ELSE EXIT FOR
  NEXT
  IF v(0) < 2 THEN
    v(0) = 2 : v(1) = 8 : v(2) = 0 : v(3) = 0
  ELSEIF v(0) = 2 THEN
    IF v(1) < 8 THEN v(1) = 8 : v(2) = 0 : v(3) = 0
  END IF : RETURN v(0) SHL 24 + v(1) SHL 16 + v(2) SHL 8 + v(3)
END FUNCTION

'/*
'*  generates a checked version STRING from a version STRING
'*  erzeugt einen ueberprueften VersionsSTRING aus dem STRING T
'*  (mit C Stellen und Separator S)
'**********************************************************************/
FUNCTION XmlData.GtkVersStr(BYREF T AS STRING, BYREF S AS STRING, _
                            BYVAL C AS INTEGER = 0) AS STRING
  VAR v = MKI(GtkVers(T)), r = STR(v[3])
  IF v[2] ORELSE C > 1 THEN r &= S & v[2]
  IF v[1] ORELSE C > 2 THEN r &= S & v[1]
  IF v[0] ORELSE C > 3 THEN r &= S & v[0]
  RETURN r
END FUNCTION

FUNCTION XmlData.findVal(BYREF zeile AS STRING, BYREF wort AS STRING) AS STRING
  VAR a = INSTR(zeile, wort) : IF a = 0 THEN RETURN "" ' no >wort< found
  a += LEN(wort): RETURN MID(zeile, a, INSTR(a, zeile, """") - a)
END FUNCTION

SUB XmlData.DataDa(BYREF T AS STRING, BYVAL N AS INTEGER, _
                   BYREF Z AS STRING, BYREF F AS STRING)
  WITH *Ui
    .Raus(T & ": ") : IF N = 0 THEN .Raus(STR(N) & NL) : EXIT SUB
    IF F = "b" THEN .RausBlau(STR(N)) ELSE .RausRot(STR(N))
    .Raus(Z & NL)
  END WITH
END SUB

SUB XmlData.FileDa(BYREF N AS STRING, BYREF E AS STRING, BYVAL M AS INTEGER = 0)
  WITH *Ui
    VAR a = .Filename2utf8(N & E)
    IF FILEEXISTS(N & E) ANDALSO M = 0 THEN
      .Raus(*__("    existing: ")) : .RausBlau(a & NL)
    ELSE
      .Raus(*__("to be writen: ")) : .RausRot(a & NL)
    END IF
  END WITH
END SUB

'/*
'*  checks id, if userdefined or Glade-automatic
'*  prueft ob Glade-ID (=n) handvergeben wurde
'**********************************************************************/
FUNCTION XmlData.UserName (BYREF W AS STRING, BYREF N AS STRING) AS INTEGER
  VAR pw = LEN(W) - 1, pn = LEN(N) - 1
  WHILE pn >= 0 ' Zahl am Ende ueberlesen
    IF OkC[N[pn]] <> 2 THEN EXIT WHILE
    pn -= 1
  WEND
  WHILE pn >= 0 ' vergleichen
    IF (N[pn] - W[pw]) AND 31 THEN EXIT WHILE
    pn -= 1 : pw -= 1 : IF pw < 0 THEN EXIT WHILE
  WEND : IF pn < 0 THEN RETURN FALSE ELSE RETURN TRUE
END FUNCTION

SUB XmlData.checkHandlerName(BYREF S AS STRING, BYVAL Mo AS INTEGER = 0)
  VAR p = 1, l = 0, le = NL & "  "
  FOR i AS INTEGER = 0 TO LEN(S) - 1
    IF S[i] = 1 THEN
      IF l > 0 THEN
        Ui->Raus(MID(S, p, l) & le)
      ELSEIF l < 0 THEN
        Ui->RausRot(MID(S, p, -l) & le)
      ELSE
        Ui->Raus(le)
      END IF : l = 0 : p = i + 2
    ELSEIF OkC[S[i]] = 1 ORELSE _
          (OkC[S[i]] = 2 ANDALSO l <> 0) THEN
      IF l >= 0 THEN l += 1 : CONTINUE FOR
      IF Mo THEN CONTINUE FOR
      Ui->RausRot(MID(S, p, -l))
      p = i + 1
      l = 1
    ELSE
      IF Mo THEN _OUT_ &= CHR(1) & S : EXIT SUB
      IF l <= 0 THEN l -= 1 : CONTINUE FOR
      Ui->Raus(MID(S, p, l))
      p = i + 1
      l = -1
    END IF ': p = i + 1
  NEXT
  IF Mo ORELSE l = 0 THEN EXIT SUB
  IF l > 0 THEN Ui->Raus(MID(S, p, l) & NL) ELSE Ui->RausRot(MID(S, p, -l) & NL)
END SUB

'/*
'*  specifing, loading and analysing glade XML file
'*  Auswählen, Einlesen und Auswerten der glade XML-Datei
'**********************************************************************/
SUB XmlData.readXml()
  IF LEN(Nam) = 0 THEN EXIT SUB
  VAR n = Nam & Suf
  WITH *Ui
    VAR fnr = FREEFILE, a = 0
    IF .No(OPEN (n FOR INPUT AS #fnr), n) THEN '                open XML
      Nam = *__("New_file")
      Suf = SufUi
      Gla = FALSE
      EXIT SUB
    END IF

    _OUT_ = ""
    .Sig = .Sig2 '                               default GTK-2.x signals
    VAR zeile = "", cuwi = "", mawi = 1
    VAR wids = *IIF(Suf = SufGla, @"<widget", @"<object") & " class="""
    VAR p = Path & SLASH : IF Toba THEN p &= OrdTobac & SLASH
    WHILE NOT EOF(fnr)
      LINE INPUT #fnr, zeile
      n = findVal(zeile, "<requires lib=""")
      IF n = "gtk+" THEN
        IF LEN(GVer) = 0 THEN CONTINUE WHILE
        n = findVal(zeile, "version=""")
        VAR v = GTKVers(n) > GTKVers(GVer)
        IF v THEN GVer = GTKVersStr(n, ".")
        .Sig = IIF(GTKVers(Gver) >= GTKVers("3.0"), .Sig3, .Sig2)
        CONTINUE WHILE
      END IF
'                     Check for user defined signal / nach Signal suchen
      n = findVal(zeile, "<signal name=""")
      IF LEN(n) THEN
        VAR h = findVal(zeile, "handler=""")
        IF LEFT(h, 4) <> "gtk_" THEN
          VAR x = Han->add(h, .Sig->Find(cuwi, n))
          IF x THEN
            IF ASC(*x) <> ASC("a") THEN .RausRot(*x) '     Fehlermeldung
          ELSE
            IF FILEEXISTS(p & h & SufBas) THEN a += 1
            checkHandlerName(h, 1)
          END IF
        END IF : CONTINUE WHILE
      END IF
'          Check for user defined name / nach manueller Benennung suchen
      VAR wid_type = findVal(zeile, wids)
      IF LEN(wid_type) THEN
        cuwi = wid_type
        n = findVal(zeile, "id=""")
        .Sig->checkMinus(n)
        IF mawi ANDALSO wid_type = "GtkWindow" THEN
          mawi = 0 : WiMa = n
        ELSEIF UserName(wid_type, n) THEN
          STACK_ADD(Ref, n)
        END IF
      END IF
    WEND : CLOSE #fnr : Gla = TRUE
    .Raus(" >> " & *__("Read") & "!" & NL)

    .Raus(NL & *__("RESULTS") & ":" & NL)
    .Raus(*__(" GTK version") & ": " & GVer & NL)
    .Raus(*__("nam. Widgets") & ": " & STACK_ANZ(SADD(Ref)) - (mawi = 0) & NL)
    .Raus(*__("Callbacks   ") & ": " & Han->az() & NL)

    IF LEN(_OUT_) THEN '             forbidden names / ungueltige Namen?
      .RausRot(NL & *__("This handler names cannot be used in fbc / gas") & ":")
      checkHandlerName(_OUT_)
      .RausRot(*__("Rename properly before further operation!") & NL & NL)
    END IF

    .Folder(p)
    DataDa(*__("    existing"), a, _
           " (" & *__("staying unchanged") & ")", "b")
    DataDa(*__("         new"), Han->az() - a, _
           " (" & *__("to be written") & ")", "r")
    DataDa(*__("  deprecated"), clearHandler(0), _
           " (" & *__("may be cleaned up") & ")", "r")
' Programmrahmen von GladeToBac
    FileDa(Nam, SufTobac, 1) '                    _tobac immer schreiben
    IF Toba THEN .Folder(Path)
    FileDa(Nam, SufBas)

    IF   .Make THEN FileDa(NamMkf, "")
    IF .ReadMe THEN FileDa(NamRdm, SufRdm)
    IF  .Geany THEN FileDa(Nam, SufGea)
    IF  .FbIde THEN FileDa(Nam, SufIde)
    IF .FbEdit THEN FileDa(Nam, SufEdi)
    IF  .Jelly THEN FileDa(Nam, SufJel)
    IF    .Win THEN FileDa(Nam, SufWin)

    .Raus(*__("Done") & "!" & NL)
  END WITH
END SUB

'/*
'*  check for deprecated moduls in folder, delete if required
'*  Prueft, ob veraltete Module im Ordner vorhanden, loescht ggf.
'**********************************************************************/
FUNCTION XmlData.clearHandler(BYVAL Modus AS INTEGER) AS INTEGER
  WITH *Ui
    VAR z = 0, p = *IIF(.IsGui, @.Xml.Path, @.S_Path) & SLASH
    IF Toba THEN p &= OrdTobac & SLASH
    VAR n = DIR(p & "*" & SufBas)
    WHILE LEN(n)
      IF LEFT(n, LEN(Nam)) <> Nam THEN
        IF 0 = LEN(Han->Po_(LEFT(n, LEN(n) - 4))) THEN
          z += 1
          SELECT CASE AS CONST Modus
          CASE 0 '    just count, no output / nur zaehlen, keine Ausgabe
          CASE 1 '         show files to be killed / Dateinamen anzeigen
            .RausBlau(n & NL)
          CASE 2 '          confirm and kill / Loeschen mit Bestaetigung
            .RausRot(n)
            SELECT CASE .Antwort(" " & *__("delete"), _
                                 *__("_Yes"), _
                                 *__("_No"), _
                                 *__("_Cancel"))
            CASE 1
              .Raus(" >> " & *__("Yes"))
              IF KILL(p & n) THEN .RausRot(" >> " & *__("Error: can't kill") & "!" & NL) _
                             ELSE .Raus(" >> " & *__("Deleted") & "!" & NL)
            CASE 2
              .Raus(" >> " & *__("No") & NL)
            CASE ELSE
              .Raus(" >> " & *__("Cancel") & NL) : EXIT WHILE
            END SELECT
          CASE 3 '       kill without confirm / Loeschen ohne Bestaetigung
            .RausRot(n)
            IF KILL(p & n) THEN .RausRot(" >> " & *__("ERROR") & "!" & NL) _
                           ELSE .Raus(" >> " & *__("Deleted") & "!" & NL)
          END SELECT
        END IF
      END IF
      n = DIR()
    WEND : RETURN z
  END WITH
END FUNCTION

