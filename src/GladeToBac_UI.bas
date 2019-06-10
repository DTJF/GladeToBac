DESTRUCTOR UserInt()
  IF Sig2 THEN DELETE Sig2
  IF Sig3 THEN DELETE Sig3
END DESTRUCTOR

'/*
'* prepare GUI or execute command line
'* Vorbereiten des GUI oder Abarbeiten der Kommandozeile
'**********************************************************************/
FUNCTION UserInt.Init() AS INTEGER
' Calc len of filename / Laenge des Dateinamens ermitteln
  VAR p = INSTR(LCASE(COMMAND), SufGla)
  IF p THEN p += 3 ELSE p = INSTR(LCASE(COMMAND), SufUi)
  p = IIF(p, p + 3, 1)

  VAR act_vers = INSTR(p, COMMAND, "-v")
  VAR act_help = INSTR(p, COMMAND, "-h")
  VAR FNam_Xml = LEFT(COMMAND, p - 1)

  IsGui = IIF(p + act_vers + act_help = 1, 1, 0)
  NoGui = IsGui XOR 1
  IF IsGui THEN initGUI()
  RausClr(*__("Wellcome")) : Raus(" " & *__("to") & " ")
  RausBlau(PRO_STR) : Raus("!" & NL & NL)

  IF act_vers THEN
    VAR x = __DATE__
    IF x[2] = ASC("-") THEN x = RIGHT(x, 4) & "-" & LEFT(x, 5)
    VAR t = "compiled: " & x & ", " & __TIME__ & " for "
    IF SLASH = "/" THEN t &= "LINUX." ELSE t &= "win32."
    t &= " (" & __FB_SIGNATURE__ & ")"
    Raus(t & NL) : RETURN FALSE
  ELSEIF act_help THEN
    Raus(HELP_TEXT & NL) : RETURN FALSE
  END IF

  loadLiz()
  Sig2 = NEW SigData(@THIS, "Signals2.def")
  Sig3 = NEW SigData(@THIS, "Signals3.def")
  Load(FNam_Xml)

  IF INSTR(p, COMMAND, "-g") THEN Xml.UiIn = TRUE
  IF INSTR(p, COMMAND, "-G") THEN Xml.UiIn = FALSE
  IF INSTR(p, COMMAND, "-i") THEN Xml.I18N = TRUE
  IF INSTR(p, COMMAND, "-I") THEN Xml.I18N = FALSE
  IF INSTR(p, COMMAND, "-t") THEN Xml.Toba = TRUE
  IF INSTR(p, COMMAND, "-T") THEN Xml.Toba = FALSE

  IF IsGui THEN _set() : RETURN TRUE

  IF Xml.Gla = 0 THEN '                 error on loading GUI-XML-file
    IF INSTR(p, COMMAND, "-G") = 0 THEN
      IF Antwort(*__("Start GUI"), _
                 *__("_Yes"), _
                 *__("_No"), _
                 *__("_Cancel" & NL)) = 1 THEN RETURN TRUE
    END IF
  ELSE
    Xml.Path = S_Path
    IF INSTR(p, COMMAND, "-N") = 0 THEN
      IF INSTR(p, COMMAND, "-n") THEN
        SELECT CASE Antwort(*__("Sketching"), _
                            *__("_Yes"), _
                            *__("_No"), _
                            *__("_Cancel"))
          CASE 1    : Raus(" >> " & *__("Yes") & NL) : GenBas()
          CASE 2    : Raus(" >> " & *__("No") & NL)
          CASE ELSE : Raus(" >> " & *__("Cancel") & NL)
        END SELECT
      ELSE
        GenBas()
      END IF
    END IF
    IF INSTR(p, COMMAND, "-x") THEN GenI18N()
    IF INSTR(p, COMMAND, "-a") THEN Ausmisten()
    IF INSTR(p, COMMAND, "-A") THEN Ausmisten(1)
  END IF
  RausClr(TIME_STAMP & NL)
  RETURN FALSE
END FUNCTION

'/*
'* transfer values to GUI
'* Werte in Oberflaeche eintragen
'**********************************************************************/
SUB UserInt.initGUI()
    TextView = GTK_TEXT_VIEW(GUI.TeVMessage)
    Buffer = gtk_text_view_get_Buffer(TextView)
    ComBox = GTK_COMBO_BOX(GUI.ComLiz)

  ' set mono font / setzt den Zeichensatz auf Mono
    VAR pf = pango_font_description_from_string("monospace 10")
    gtk_widget_modify_font(GTK_WIDGET(GUI.TeVMessage), pf)
    pango_font_description_free(pf)

  'Buffer auf nicht editierbar schalten
    gtk_text_view_set_editable(TextView, FALSE)

   ' define some text sytles / einige Textstile definieren
    gtk_text_buffer_create_tag(Buffer, "blue_fg", "foreground", "blue", NULL)
    gtk_text_buffer_create_tag(Buffer, "red_fg", "foreground", "red", NULL)
    gtk_text_buffer_create_tag(Buffer, "bold", "weight", PANGO_WEIGHT_BOLD, NULL)

    VAR win = GTK_WINDOW(GUI.WinMain)
    gtk_window_set_title(win, PRO_STR & ": " & *__("no XML file"))
    gtk_window_get_size(win, @Brei, @Hoch)

    VAR logo = readIcon()
    gtk_window_set_icon(win, logo)

    VAR about = GTK_ABOUT_DIALOG(GUI.WinAbout)
    gtk_about_dialog_set_program_name(about, PROJ_NAME)
    gtk_about_dialog_set_version(about, "Version " & PROJ_VERS)
    gtk_about_dialog_set_logo(about, logo)
END SUB

'/*
'* Including icon into binary, returning GdkPixbuf PTR
'* liest Icon in das Kompilat, liefert PTR auf GdkPixbuf
'**********************************************************************/
FUNCTION UserInt.readIcon() AS GdkPixbuf PTR
  DIM icon AS UBYTE PTR
  DIM icon_len AS UINTEGER
#IF __FB_DEBUG__
  ASM jmp .LT_END_OF_FILE_ICON_DEBUG_JMP
#ELSE
  ASM .section .data
#ENDIF
  ASM .LT_START_OF_FILE_ICON:
  ASM __icon__start = .
  ASM .incbin PROJ_ICON
  ASM __icon__len = . - __icon__start
  ASM .LT_END_OF_FILE_ICON:
#IF __FB_DEBUG__
  ASM .LT_END_OF_FILE_ICON_DEBUG_JMP:
#ELSE
  ASM .section .text
  ASM .balign 16
#ENDIF
  ASM .LT_SKIP_FILE_ICON:
  ASM mov dword PTR [icon], offset .LT_START_OF_FILE_ICON
  ASM mov dword PTR [icon_len], offset __icon__len
  RETURN gdk_pixbuf_new_from_inline(icon_len, icon, 0, 0)
END FUNCTION

'/*
'* load a GUI-XML-file and parameters from .ini and .bas
'* Laden einer GUI-XML Datei und deren Parameter aus .ini und .bas
'**********************************************************************/
SUB UserInt.Load(BYREF F AS STRING)
  IF IsGui THEN IF LEN(F) THEN _Get()
  Xml.Init(F, @THIS)
  IF IsGui THEN _set()
END SUB

'/*
'* message on directory change, may be error
'* Meldung beim Wechseln auf anderes Verzeichnes, ggf. Fehler
'**********************************************************************/
FUNCTION UserInt.Folder(BYREF T AS STRING) AS INTEGER
  VAR n = "" : IF IsGui THEN n = Filename2utf8(T) ELSE n = T
  IF CHDIR(T) THEN _
    Raus(*__("Cannot open folder") & " ") : RausRot(n & NL) : RETURN 1
    Raus(*__("Folder") & " ") : RausBlau(n & NL) : RETURN 0
END FUNCTION

'/*
'* message on file open, may be error
'* Meldung beim Öffnen einer Datei, ggf. Fehler
'**********************************************************************/
FUNCTION UserInt.No(BYVAL M AS INTEGER, BYREF T AS STRING) AS INTEGER
  IF M THEN
    RausRot(Filename2utf8(T)) : Raus(*__(" >> Cannot open file") & "!" & NL)
  ELSE
    RausBlau(Filename2utf8(T))
  END IF : RETURN M
END FUNCTION

'/*
'* Text output on console or TextView
'* Textausgabe auf Konsole oder TextView (GUI)
'**********************************************************************/
SUB UserInt.RausClr(BYREF T AS STRING)
  IF NoGui THEN COLOR 14, 0 : PRINT NL & DosTXT(T); : EXIT SUB
  ' notebook init / Karteireiter setzen
  gtk_notebook_set_current_page(GTK_NOTEBOOK(GUI.NotMain), 1)
  gtk_text_buffer_set_text(Buffer, "", 0)
  gtk_text_buffer_get_iter_at_offset(Buffer, @Iter, 0)
  gtk_text_buffer_insert_with_tags_by_name(Buffer, @Iter, T, -1, "bold", NULL)
END SUB

SUB UserInt.Scrol(BYVAL Mo AS INTEGER = 0)
  DIM AS GtkTextIter It
  IF Mo THEN
    gtk_text_buffer_get_start_iter(Buffer, @It)
  ELSE
    gtk_text_buffer_get_end_iter(Buffer, @It)
  END IF
  gtk_text_view_scroll_to_iter(TextView, @It, 0, FALSE, 0, 0)
END SUB

SUB UserInt.Raus(BYREF T AS STRING, BYVAL Mo AS INTEGER = 0)
  IF NoGui THEN COLOR LOWORD(Farb), HIWORD(Farb): PRINT dosTxt(T); : EXIT SUB
  gtk_text_buffer_insert(Buffer, @Iter, T, -1)
  Scrol(Mo)
END SUB

SUB UserInt.RausRot(BYREF T AS STRING, BYVAL Mo AS INTEGER = 0)
  IF NoGui THEN COLOR 12, 0: PRINT dosTxt(T); : EXIT SUB
  gtk_text_buffer_insert_with_tags_by_name(Buffer, @Iter, T, -1, "red_fg", NULL)
  Scrol(Mo)
END SUB

SUB UserInt.RausBlau(BYREF T AS STRING, BYVAL Mo AS INTEGER = 0)
  IF NoGui THEN COLOR 11, 0: PRINT dosTxt(T); : EXIT SUB
  gtk_text_buffer_insert_with_tags_by_name(Buffer, @Iter, T, -1, "blue_fg", NULL)
  Scrol(Mo)
END SUB

'/*
'*  if needed: converting UTF-8 for DOS output (for console window)
'*  Wenn nötig: UTF-8 in DOS-ANSI konvertieren (fuer DOS-Konsole)
'**********************************************************************/
FUNCTION UserInt.dosTxt(BYREF T AS STRING) AS STRING
  IF SLASH = "/" THEN RETURN T
  CONST ConvUTF = "äöüßÄÖÜ", _
        ConvDOS = !"\132\148\129\225\142\153\154"
  VAR p = 0, i = 0
  WHILE i < LEN(T)
    IF T[i] = ASC(ConvUTF) THEN
      i += 1 : p = INSTR(ConvUTF, MID(T, i, 2))
      IF p THEN
        p = p SHR 1 + 1
        T = MID(T, 1, i - 1) + MID(ConvDOS, p, 1) + MID(T, i + 2)
      END IF
    END IF : i += 1
  WEND : RETURN T
END FUNCTION

'/*
'* load licence names and show in GUI
'* Lizenznamen lesen und im GUI anzeigen
'**********************************************************************/
SUB UserInt.loadLiz()
  IF Folder(OrdData) THEN _
    IF Folder(".." & SLASH & OrdData) THEN _
      IF Folder(EXEPATH & SLASH & OrdData) THEN _
        Raus("0 " & *__("licenses found") & "!" & NL & NL) : EXIT SUB
  OrdData = CURDIR
  DIM AS GtkListStore PTR listo
  VAR n = DIR("*" & SufLiz), i = 0, t = ""
  IF IsGui THEN
    VAR cell = gtk_cell_renderer_text_new()
    VAR layo = GTK_CELL_LAYOUT(GUI.ComLiz)
    gtk_cell_layout_pack_start(layo, cell, TRUE)
    gtk_cell_layout_set_attributes(layo, cell, "text", 0, NULL)
    listo = GTK_LIST_STORE(GUI.ComboLiSto)
    gtk_list_store_insert_with_values(listo, NULL, i, 0, *__("User defined"), -1)
  END IF

  WHILE LEN(n)
    VAR fnr = FREEFILE
    IF 0 = No(OPEN (n FOR INPUT AS #fnr), n) THEN
      LINE INPUT #fnr, t
      CLOSE #fnr
      i += 1
      var r = Liz.add(t, MKL(i) & n)
      Raus(" >> " & t & NL)
      IF IsGui THEN
        gtk_list_store_insert_with_values(listo, NULL, i, 0, t, -1)
      END IF
    END IF : n = DIR()
  WEND
  Raus(Liz.Az() & " " & *__("licenses found") & "!" & NL & NL)

  'IF NoGui THEN EXIT SUB

'sort the list
  'VAR model = gtk_combo_box_get_model(ComBox)
  'SoMo = gtk_tree_model_sort_new_with_model(model)
  'gtk_tree_sortable_set_sort_column_id(GTK_TREE_SORTABLE(SoMo), 0, GTK_SORT_ASCENDING)
  'gtk_combo_box_set_model(ComBox, SoMo)
END SUB

'/*
'* Sets GUI entries / buttons
'* schreibt Texte in Entrys, setzt Buttons
'**********************************************************************/
SUB UserInt._set()
  WITH GUI
    ' sets entrys / setzt Entry-Felder
    entry_set_text(  .EntName, Xml.Auth)
    entry_set_text( .EntEmail, Xml.Mail)
    entry_set_text(   .EntWeb, Xml.Site)
    entry_set_text(   .EntSyn, Xml.Desc)
    entry_set_text(   .EntVer, Xml.Vers)
    entry_set_text(.EntGtkVer, Xml.GVer)
    entry_set_text(  .EntTyNa, Xml.TyNa)

    VAR s = Liz.Rep(Xml.PLiz), p = IIF(s, PEEK(LONG, s), 0)
    gtk_combo_box_set_active(GTK_COMBO_BOX(.ComLiz), p)

    gtk_toggle_button_set_active(GTK_TOGGLE_BUTTON(  .CheI18N), Xml.I18N)
    gtk_toggle_button_set_active(GTK_TOGGLE_BUTTON( .CheGlaIn), Xml.UiIn)
    gtk_toggle_button_set_active(GTK_TOGGLE_BUTTON( .CheTobac), Xml.Toba)

    gtk_toggle_button_set_active(GTK_TOGGLE_BUTTON(  .CheMake), Make)
    gtk_toggle_button_set_active(GTK_TOGGLE_BUTTON(.CheReadMe), ReadMe)
    gtk_toggle_button_set_active(GTK_TOGGLE_BUTTON( .CheGeany), Geany)
    gtk_toggle_button_set_active(GTK_TOGGLE_BUTTON( .CheFbIde), FbIde)
    gtk_toggle_button_set_active(GTK_TOGGLE_BUTTON(.CheFbEdit), FbEdit)
    gtk_toggle_button_set_active(GTK_TOGGLE_BUTTON( .CheJelly), Jelly)
    gtk_toggle_button_set_active(GTK_TOGGLE_BUTTON(   .CheWin), Win)
    gtk_toggle_button_set_active(GTK_TOGGLE_BUTTON(    .CheRc), Rc)
    IF Win = 0 THEN gtk_widget_set_sensitive(GTK_WIDGET(.CheRc), 0)

    VAR f = Xml.Gla
    gtk_widget_set_sensitive(GTK_WIDGET(.MnuSave), f)
    gtk_widget_set_sensitive(GTK_WIDGET(.MnuMist), f)
    gtk_widget_set_sensitive(GTK_WIDGET( .MnuBas), f)
    gtk_widget_set_sensitive(GTK_WIDGET(.MnuI18N), f)
    gtk_widget_set_sensitive(GTK_WIDGET( .MnuPro), f)
    gtk_widget_set_sensitive(GTK_WIDGET( .TobBas), f)
    gtk_widget_set_sensitive(GTK_WIDGET(.TobI18N), f)

    VAR n = "New_File" : IF Xml.Gla THEN n = Filename2utf8(Xml.Nam)
    IF Xml.Bas THEN
      label_set_markup(.LabNeuPro, "<span color=""gray"">" & n & SufBas & "</span>")
    ELSE
      label_set_markup(.LabNeuPro, "<b>" & n & SufBas & "</b>")
    END IF
    label_set_markup(     .LabTob, "<b>" & n & SufTobac & "</b>")

    VAR win = GTK_WINDOW(.WinMain)
    gtk_window_set_title(win, PRO_STR & ": " & n & Xml.Suf)

    VAR scr = gdk_screen_get_default() ' ToDo: decoration, max size
    VAR w = gdk_screen_get_width(scr)
    VAR h = gdk_screen_get_height(scr)
    Brei = MIN(MAX(Brei, 580), w)
    Hoch = MIN(MAX(Hoch, 480), h)
    gtk_window_resize(win, Brei, Hoch)
  END WITH
END SUB

'/*
'*  translating filename to UTF8
'*  wandelt Dateiname in UTF8 zur Anzeige
'**********************************************************************/
FUNCTION UserInt.Filename2utf8(BYREF File AS STRING) AS STRING
  DIM AS gsize bytes_written
  VAR p = g_filename_to_utf8(File, -1, NULL, @bytes_written, NULL)
  IF p = 0 ORELSE bytes_written = 0 THEN RETURN *__("Unknown file name")
  DIM AS STRING r = *p : g_free(p) : RETURN r
END FUNCTION

'/*
'*  asks a question and waits for response (modal)
'*  Frage _OUT_eben und modal auf Antwort warten
'**********************************************************************/
FUNCTION UserInt.Antwort(BYREF F AS STRING, _
                         BYREF B1 AS STRING, _
                         BYREF B2 AS STRING, _
                         BYREF B3 AS STRING) AS INTEGER
  IF NoGui THEN
    VAR r = "", t = F + "? " + B1 + " | " + B2 + " | " + B3
    VAR a = 1, e = INSTR(t, "_")
    WHILE e
      Raus(MID(t, a, e - a)) : RausRot(MID(t, e + 1, 1))
      r &= LCASE(MID(t, e + 1, 1))
      a = e + 2 : e = INSTR(a, t, "_")
    WEND
    WHILE LEN(INKEY) : WEND ' empty keybord buffer / Tastaturpuffer leeren
    Raus(MID(t, a))
    DO
      SLEEP : a = INSTR(r, LCASE(INKEY))
    LOOP UNTIL a : RETURN a
  ELSE ' show dialob box / Dialogbox anzeigen
    VAR parent = gtk_window(GUI.WinMain)
    VAR dialog = gtk_dialog_new_with_buttons(F & "?", parent, _
                   GTK_DIALOG_MODAL OR GTK_DIALOG_DESTROY_WITH_PARENT, _
                   B1, 1, B2, 2, B3, 3, NULL)
    gtk_window_set_position(GTK_WINDOW(dialog), GTK_WIN_POS_MOUSE)
    VAR Antw = gtk_dialog_run(GTK_DIALOG(dialog))
    gtk_widget_destroy(dialog) : RETURN Antw
  END IF
END FUNCTION

'/*
'* setting text in entry/label field
'* schreibt Text in Entry/Label
'**********************************************************************/
SUB UserInt.entry_set_text(BYREF W AS GObject PTR, BYREF T AS STRING)
  IF LEN(T) THEN gtk_entry_set_text(GTK_ENTRY(W), T) : EXIT SUB
  gtk_entry_set_text(GTK_ENTRY(W), "")
END SUB
SUB UserInt.label_set_markup(BYREF W AS GObject PTR, BYREF T AS STRING)
  IF LEN(T) THEN gtk_label_set_markup(GTK_LABEL(W), T) : EXIT SUB
  gtk_label_set_text(GTK_LABEL(W), "")
END SUB

'/*
'*  reads buttons from UI
'*  liest die Schalter aus der Benutzeroberflaeche
'**********************************************************************/
SUB UserInt._Get()
  WITH GUI
    Xml.Auth = *gtk_entry_get_text(GTK_ENTRY(.EntName))
    Xml.Mail = *gtk_entry_get_text(GTK_ENTRY(.EntEmail))
    Xml.Site = *gtk_entry_get_text(GTK_ENTRY(.EntWeb))
    Xml.Desc = *gtk_entry_get_text(GTK_ENTRY(.EntSyn))
    Xml.Vers = *gtk_entry_get_text(GTK_ENTRY(.EntVer))
    Xml.TyNa = *gtk_entry_get_text(GTK_ENTRY(.EntTyNa))

    VAR n = gtk_combo_box_get_active(GTK_COMBO_BOX(.ComLiz))
    Xml.PLiz = Liz.fin(n)
    VAR v = *gtk_entry_get_text(GTK_ENTRY(.EntGtkVer))
    IF LEN(v) THEN Xml.GVer = Xml.GtkVersStr(v, ".") ELSE Xml.GVer = ""
    Xml.I18N = gtk_toggle_button_get_active(GTK_TOGGLE_BUTTON(.CheI18N))
    Xml.UiIn = gtk_toggle_button_get_active(GTK_TOGGLE_BUTTON(.CheGlaIn))
    Xml.Toba = gtk_toggle_button_get_active(GTK_TOGGLE_BUTTON(.CheTobac))

    Make   = gtk_toggle_button_get_active(GTK_TOGGLE_BUTTON(.CheMake))
    ReadMe = gtk_toggle_button_get_active(GTK_TOGGLE_BUTTON(.CheReadMe))
    Geany  = gtk_toggle_button_get_active(GTK_TOGGLE_BUTTON(.CheGeany))
    FbIde  = gtk_toggle_button_get_active(GTK_TOGGLE_BUTTON(.CheFbIde))
    FbEdit = gtk_toggle_button_get_active(GTK_TOGGLE_BUTTON(.CheFbEdit))
    Jelly  = gtk_toggle_button_get_active(GTK_TOGGLE_BUTTON(.CheJelly))
    Win    = gtk_toggle_button_get_active(GTK_TOGGLE_BUTTON(.CheWin))
    Rc     = gtk_toggle_button_get_active(GTK_TOGGLE_BUTTON(.CheRc))
  END WITH
END SUB

'/*
'*  cleaning up of signal handlers
'*  Ausmisten veralteter Signal-Module
'**********************************************************************/
SUB UserInt.Ausmisten(BYVAL Mo AS INTEGER = 0)
  RausClr(*__("Clean up") & NL & NL)
  Raus(*__("Marking") & ": " & NL)
  VAR z = Xml.clearHandler(1), m = IIF(Mo, 3, 2)
  SELECT CASE AS CONST z
    CASE 0 '                               nothing to do / nichts zu tun
      Raus(*__("there are") & " ") : RausRot(STR(0))
      Raus(" " & *__("files deprecated") & "!")
    CASE 1'         delete one single file / eine einzige Datei loeschen
      Raus(*__("there is") & " ") : RausRot(STR(z))
      Raus(" " & *__("file deprecated") & ":" + NL)
      z = Xml.clearHandler(m)
    CASE ELSE
      Raus(*__("there are") & " ") : RausRot(STR(z))
      Raus(" " & *__("files deprecated") & "!")
      SELECT CASE Antwort(*__("To do"), _
                          *__("Delete _All"), _
                          *__("Delete _Single"), _
                          *__("_No deleting"))
        CASE 1
          Raus(" >> " & *__("Delete all") & NL) : z = Xml.clearHandler(3)
        CASE 2
          Raus(" >> " & *__("Delete single") & NL) : z = Xml.clearHandler(m)
        CASE ELSE
          Raus(" >> " & *__("No deleting") & NL) ' Cancel / Abbruch
      END SELECT
  END SELECT
END SUB

FUNCTION checkHandlerFile(BYREF S AS STRING, BYVAL Z AS ZSTRING PTR) AS LONG
  IF NOT FILEEXISTS(S & SufBas) THEN HandlerCode(S)
  RETURN FALSE
END FUNCTION

'/*
'*  Checking input and generating program coding / declarations
'*  Eingaben pruefen und Programmcode bzw. Deklarationen erzeugen
'**********************************************************************/
SUB UserInt.GenBas()
  WITH Xml
    RausClr(*__("Sketching bas files") & NL & NL)
    IF IsGui THEN _Get()
    .Jahr = FORMAT(NOW, FormJa)

    VAR p = .Path
    Folder(p)
    IF NOT FILEEXISTS(.Nam & SufBas) THEN BasCode()
    IF .Toba THEN MKDIR(OrdTobac) : Folder(p & SLASH & OrdTobac)
    TobacCode()
    .Han->ForEach(@checkHandlerFile)
  END WITH : Raus(*__("Done") & "!" & NL)
END SUB

'/*
'*  runs xgettext for I18N
'*  fuehrt xgettext aus fuer Internationalisierung
'**********************************************************************/
SUB UserInt.xget(BYREF C AS STRING, BYREF E AS STRING, BYREF J AS STRING)
  RausBlau("xgettext(" & E & ")") : Raus(" >> ")
  IF SHELL(C & J & E) THEN
    IF IsGui THEN RausRot(*__("Error: Can't run") & "!" & NL)
  ELSE
    Raus(*__("Done") & "!" & NL)
    IF FILEEXISTS(Xml.Nam & ".pot") THEN J = "--join-existing "
  END IF
END SUB

'/*
'*  generates .pot file for I18N
'*  schreibt .pot Datei fuer Internationalisierung
'**********************************************************************/
SUB UserInt.GenI18N()
  IF IsGui THEN _Get()
  RausClr(*__("Generating") & " .pot " & *__("file for I18N") & NL & NL)
  WITH Xml
    VAR n = .Path & SLASH & .Nam & SufPot
    IF FILEEXISTS(n) THEN _
       IF KILL(n) THEN _
         RausRot(*__("Error: Can't write to") & ": " & n & "!" & NL) : EXIT SUB

    n = .Nam & SufPot
    VAR c = "xgettext "
    VAR g = "--output=" & n & " " _
            "--no-wrap " _
            "--from-code=utf-8 "
    VAR f = "--package-name=""" & .Nam & """ " _
            "--package-version=""" & .Vers & """ " _
            "--msgid-bugs-address=""" & .Mail & """ " _
            "--copyright-holder=""" & .Auth & """ "
    VAR o = "--keyword= " _
            "--keyword=__ " _
            "--keyword=N_ " _
            "--keyword=Q_:1g " _
            "--keyword=C_:1c,2 " _
            "--keyword=NC_:1c,2 " _
            "--keyword=gettext " _
            "--keyword=dgettext:2 " _
            "--keyword=dcgettext:2 " _
            "--keyword=ngettext:1,2 " _
            "--keyword=dngettext:2,3" _
            "--keyword=dcngettext:2,3" _
            "--keyword=gettext_noop " _
            "--keyword=pgettext:1c,2 " _
            "--keyword=dpgettext:2c,3 " _
            "--keyword=dcpgettext:2c,3 " _
            "--keyword=npgettext:1c,2,3 " _
            "--keyword=dnpgettext:2c,3,4" _
            "--keyword=dcnpgettext:2c,3,4 " _
            "--language=awk "
    VAR j = "--force-po "
    VAR p = *IIF(IsGui, @.Path, @S_Path), pt = p & SLASH & OrdTobac
    IF .Toba ANDALSO 0 = CHDIR(pt) THEN
      Raus(*__("Folder") & " ") : RausBlau(pt & NL)
      xget(c & g & o, "*" & SufBas, j)
      FILECOPY(n, ".." & SLASH & n)
      KILL(n)
    END IF
    Folder(p)
    xget(c & g & o, "*" & SufBi, j)
    xget(c & g & o, "*" & SufBas, j)
    o = "--language=Glade "
    xget(c & g & f & o, "*" & .Suf, j)
  END WITH
END SUB

'/*
'*  Checking input and generating program coding / declarations
'*  Eingaben pruefen und Programmcode bzw. Deklarationen erzeugen
'**********************************************************************/
SUB UserInt.GenProj()
  WITH Xml
    RausClr(*__("Creating project files") & NL & NL)
    _Get()
    Folder(Xml.Path)
    IF Make THEN IF NOT FILEEXISTS(NamMkf) THEN MakeCode()
    IF ReadMe THEN IF NOT FILEEXISTS(NamRdm & SufRdm) THEN ReadMeCode()
    IF Geany THEN IF NOT FILEEXISTS(Xml.Nam & SufGea) THEN GeanyCode()
    IF FbIde THEN IF NOT FILEEXISTS(Xml.Nam & SufIde) THEN FbIdeCode()
    IF FbEdit THEN IF NOT FILEEXISTS(Xml.Nam & SufEdi) THEN FbEditCode()
    IF Jelly THEN  IF NOT FILEEXISTS(Xml.Nam & SufJel) THEN JellyCode()
    IF Win THEN IF NOT FILEEXISTS(Xml.Nam & SufWin) THEN WinRcCode()
  END WITH : Raus(*__("Done") & "!" & NL)
END SUB

