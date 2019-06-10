'/*
'*  create a simple readme (readme.txt), remake from Glade2FB (Galeon)
'*  erzeugt readme.txt
'**********************************************************************/
SUB ReadMeCode()
  WITH _UI_.Xml
    IF FILEEXISTS(NamRdm & SufRdm) THEN EXIT SUB
    _OUT_  = NL
    _OUT_ &= "  " & .Nam & " - " & .Desc & NL
    _OUT_ &= "  Copyright (C) " & .Jahr & " " & .Auth & NL
    IF LEN(.Mail) THEN _OUT_ &= "    Email: " & .Mail & NL
    IF LEN(.Site) THEN _OUT_ &= "  Website: " & .Site & NL
    _OUT_ &= NL & NL & *__("License") & ":" & NL & NL
    LizenseCode("  ")
    _OUT_ &= NL & *__("Description") & ":" & NL & NL
    DescriptionCode("  ")
    _OUT_ &= NL & NL
    write_code(NamRdm & SufRdm)
  END WITH
END SUB

'/*
'*  create the Geany project file (*.geany)
'*  erzeugt Geany-Projekt-Datei (fuer Vers 0.19.1)
'**********************************************************************/
SUB GeanyCode()
  WITH _UI_.Xml
    IF FILEEXISTS(.Nam & SufGea) THEN EXIT SUB
    VAR p = .Path, r = "./" & .Nam
    IF SLASH = "\" THEN '       double SLASH / SLASH verdoppeln fuer win
      VAR i = INSTR(p, SLASH)
      WHILE i
        p = LEFT(p, i) & MID(p, i)
        i = INSTR(i + 2, p, SLASH)
      WEND
      r = .Nam & ".exe"
    END IF

    _OUT_  = NL
    _OUT_ &= "[indentation]" & NL
    _OUT_ &= "indent_width=2" & NL
    _OUT_ &= "indent_type=0" & NL
    _OUT_ &= "indent_hard_tab_width=2" & NL
    _OUT_ &= "detect_indent=false" & NL
    _OUT_ &= "indent_mode=2" & NL
    _OUT_ &= NL
    _OUT_ &= "[project]" & NL
    _OUT_ &= "name=" & .Nam & NL
    _OUT_ &= "base_path=" & p & NL
    _OUT_ &= "make_in_base_path=true" & NL
    _OUT_ &= "description=" & .Desc & NL
    _OUT_ &= "run_cmd=""" & r & """" & NL
    _OUT_ &= NL
    _OUT_ &= "[long line marker]" & NL
    _OUT_ &= "long_line_behaviour=1" & NL
    _OUT_ &= "long_line_column=72" & NL
    _OUT_ &= NL
    _OUT_ &= "[files]" & NL
    _OUT_ &= "current_page=0" & NL
    p &= SLASH : IF SLASH <> "/" THEN p &= SLASH
    _OUT_ &= "FILE_NAME_0=0;FreeBasic;0;16;1;1;1;" & p & .Nam & ".bas;0;2" & NL

' do we need _tobac.bas here?
    'IF .Toba THEN p &= OrdTobac & SLASH : IF SLASH <> "/" THEN p &= SLASH
    'p & = .Nam & SufTobac
    '_OUT_ &= "FILE_NAME_1=0;FreeBasic;0;16;1;1;1;" & p & ";0;2" & NL

' do we need signal handlers here?
    '.Han.ForEach(@codingGladeFiles)
    '_OUT_ &= "FILE_NAME_XXX=0;FreeBasic;0;16;1;1;1;" & p & S & ".bas;0;2" & NL

    _OUT_ &= NL
    _OUT_ &= "[build-menu]" & NL
    _OUT_ &= "EX_00_LB=" & *__("_Run project") & NL
    _OUT_ &= "EX_00_CM=""" & r & """" & NL
    _OUT_ &= "EX_00_WD=%p" & NL
    _OUT_ &= "FreeBasicFT_00_LB=" & *__("_Compile project") & NL
    _OUT_ &= "FreeBasicFT_00_CM=fbc -exx -w all """ & .Nam & ".bas""" & NL
    _OUT_ &= "FreeBasicFT_00_WD=%p" & NL
    _OUT_ &= "filetypes=FreeBasic;" & NL
    write_code(.Nam & SufGea)
  END WITH
END SUB

'/*
'*  create create the FBIde project file (*.fbide.fbp), remake from Glade2FB (Galeon)
'*  erzeugt FBIde-Projekt-Datei (Galeon)
'**********************************************************************/
SUB FbIdeCode()
  WITH _UI_
    IF FILEEXISTS(.Xml.Nam & SufIde) THEN EXIT SUB
    _OUT_  = "[General]" & !"\r\n"
    _OUT_ &= "Name=" & .Xml.Nam & !"\r\n"
    _OUT_ &= "Type=1" & !"\r\n"
    _OUT_ &= "Lang=" & !"\r\n"
    _OUT_ &= "Output=" & .Xml.Nam & ".exe" & !"\r\n"
    _OUT_ &= "OptionalParam=" & !"\r\n"
    _OUT_ &= "MainModule=" & .Xml.Nam & ".bas" & !"\r\n"
    IF .Win THEN
      _OUT_ &= "ItemCount=2" & !"\r\n"
    ELSE
      _OUT_ &= "ItemCount=3" & !"\r\n"
    END IF
    _OUT_ &= "FolderCount=0" & !"\r\n"
    _OUT_ &= "[Item_0]" & !"\r\n"
    _OUT_ &= "Path=" & !"\r\n"
    _OUT_ &= "File=" & .Xml.Nam & ".bas" & !"\r\n"
    _OUT_ &= "Compile=1" & !"\r\n"
    _OUT_ &= "[Item_1]" & !"\r\n"
    _OUT_ &= "Path=" & !"\r\n"
    _OUT_ &= "File=" & .Xml.Nam & ".bi" & !"\r\n"
    _OUT_ &= "Compile=1" & !"\r\n"
    IF .Win THEN
      _OUT_ &= "[Item_2]" & !"\r\n"
      _OUT_ &= "Path=" & !"\r\n"
      _OUT_ &= "File=" & .Xml.Nam & ".rc" & !"\r\n"
      _OUT_ &= "Compile=1" & !"\r\n"
    END IF
    _OUT_ &= !"\r\n"
    write_code(.Xml.Nam & SufIde)
  END WITH
END SUB

'/*
'*  create FbEdit project file (*.fbp too!), remake from Glade2FB (Galeon)
'*  erzeugt FbEdit-Projekt-Datei (Galeon)
'**********************************************************************/
SUB FbEditCode()
  WITH _UI_.Xml
    IF FILEEXISTS(.Nam & SufEdi) THEN EXIT SUB
    _OUT_  = "[Project]" & !"\r\n"
    _OUT_ &= "Version=3" & !"\r\n"
    _OUT_ &= "Description=" & .Desc & !"\r\n"
    _OUT_ &= "Api=fb (FreeBASIC)" & !"\r\n"
    _OUT_ &= "[Make]" & !"\r\n"
    _OUT_ &= "Current=1" & !"\r\n"
    _OUT_ &= "1=Windows GUI,fbc -s gui" & !"\r\n"
    _OUT_ &= "Recompile=2" & !"\r\n"
    _OUT_ &= "Module=Module Build,fbc -c" & !"\r\n"
    _OUT_ &= "[TabOrder]" & !"\r\n"
    _OUT_ &= "TabOrder=1,2" & !"\r\n"
    _OUT_ &= "[File]" & !"\r\n"
    _OUT_ &= "1=" & .Nam & ".bas" & !"\r\n"
    _OUT_ &= "2=" & .Nam & ".bi" & !"\r\n"
    IF _UI_.Win THEN _OUT_ &= "3=" & .Nam & ".rc" & !"\r\n"
    _OUT_ &= "[BreakPoint]" & !"\r\n"
    _OUT_ &= "1=" & !"\r\n"
    _OUT_ &= "2=" & !"\r\n"
    _OUT_ &= "[FileInfo]" & !"\r\n"
    _OUT_ &= "1=0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0" & !"\r\n"
    _OUT_ &= "2=0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0" & !"\r\n"
    _OUT_ &= "3=0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0" & !"\r\n"
    write_code(.Nam & SufEdi)
  END WITH
END SUB

'/*
'*  create the JellyFB project file (*.jfp), remake from Glade2FB (Galeon)
'*  erzeugt Jelly-Projekt-Datei (Galeon)
'**********************************************************************/
SUB JellyCode()
  WITH _UI_.Xml
    IF FILEEXISTS(.Nam & SufJel) THEN EXIT SUB
    _OUT_  = "IDEmaximize= 1" & !"\r\n"
    _OUT_ &= "KeywordCase=FREEBASIC (MIXED CASE)" & !"\r\n"
    _OUT_ &= "Resolution= 1024, 768" & !"\r\n"
    _OUT_ &= "CommandLine=" & !"\r\n"
    _OUT_ &= "CompilerOptions=" & !"\r\n"
    _OUT_ &= "ActiveFile=" & .Nam & ".bas, 1, 1, 1" & !"\r\n"
    _OUT_ &= "Filename=" & .Nam & ".bi, 1, 1, 1" & !"\r\n"
    IF _UI_.Win THEN _OUT_ &= "Filename=" & .Nam & ".rc, 1, 1, 1" & !"\r\n"
    _OUT_ &= "Compiler= 0" & !"\r\n"
    _OUT_ &= "PrimaryFile=" & !"\r\n"
    _OUT_ &= "LoadAllFunctions= 0" & !"\r\n"
    _OUT_ &= "AutoCloseFunctionList= 0" & !"\r\n"
    _OUT_ &= "UnSortFunctionList= 0" & !"\r\n\r\n"
    write_code(.Nam & SufJel)
  END WITH
END SUB

'/*
'*  create the Win32 RC file (*.rc), remake from Glade2FB (Galeon)
'*  erzeugt  Win32 RC Datei (Galeon)
'**********************************************************************/
SUB WinRcCode()
  WITH _UI_.Xml
    IF FILEEXISTS(.Nam & SufWin) THEN EXIT SUB
    _OUT_  = "#define IDR_VERSION 1" & !"\r\n"
    _OUT_ &= "#define IDI_PROGICON 100" & !"\r\n"
    _OUT_ &= !"\r\n"
    _OUT_ &= "IDR_VERSION VERSIONINFO" & !"\r\n"
    _OUT_ &= "FILEVERSION 1,0,0,0" & !"\r\n"
    _OUT_ &= "PRODUCTVERSION 1,0,0,0" & !"\r\n"
    _OUT_ &= "FILEOS 0x00000004" & !"\r\n"
    _OUT_ &= "FILETYPE 0x00000001" & !"\r\n"
    _OUT_ &= "BEGIN" & !"\r\n"
    _OUT_ &= "  BLOCK ""StringFileInfo""" & !"\r\n"
    _OUT_ &= "  BEGIN" & !"\r\n"
    _OUT_ &= "    BLOCK ""040904E4""" & !"\r\n"
    _OUT_ &= "    BEGIN" & !"\r\n"
    _OUT_ &= "      VALUE ""FileVersion"", """ & .Vers & !"\\0""" & !"\r\n" ' ToDo:
    _OUT_ &= "      VALUE ""ProductVersion"", """ & .Vers & !"\\0""" & !"\r\n"
    _OUT_ &= "      VALUE ""CompanyName"", """ & .Auth & !"\\0""" & !"\r\n"
    _OUT_ &= "      VALUE ""FileDescription"", """ & .Nam & !"\\0""" & !"\r\n"
    _OUT_ &= "      VALUE ""InternalName"", """ & .Nam & !"\\0""" & !"\r\n"
    _OUT_ &= "      VALUE ""LegalCopyright"", ""Copyright (c) " & .Jahr & " " & .Auth & !"\\0""" & !"\r\n"
    _OUT_ &= "      VALUE ""OriginalFilename"", """ & .Nam & !".exe\\0""" & !"\r\n"
    _OUT_ &= "      VALUE ""ProductName"", """ & .Nam & !"\\0""" & !"\r\n"
    _OUT_ &= "    END" & !"\r\n"
    _OUT_ &= "  END" & !"\r\n"
    _OUT_ &= "  BLOCK ""VarFileInfo""" & !"\r\n"
    _OUT_ &= "  BEGIN" & !"\r\n"
    _OUT_ &= "    VALUE ""Translation"", 0x0409, 0x04E4" & !"\r\n"
    _OUT_ &= "  END" & !"\r\n"
    _OUT_ &= "END" & !"\r\n"
    IF _UI_.Rc THEN
      _OUT_ &= "" & !"\r\n" & "IDI_PROGICON ICON DISCARDABLE """ _
                                              & .Nam & ".ico""" & !"\r\n"
    END IF
    write_code(.Nam & SufWin)
  END WITH
END SUB

'/*
'*  create the makefile (makefile), remake from Glade2FB (Galeon)
'*  erzeugt makefile (Galeon)
'**********************************************************************/
SUB MakeCode()
  IF FILEEXISTS(NamMkf) THEN EXIT SUB
  WITH _UI_.Xml
    _OUT_  = "#" & NL
    _OUT_ &= "# " & .Nam & " - " & .Desc & NL
    _OUT_ &= "# Copyright (C) " & .Jahr & " " & .Auth & NL
    IF   LEN(.Mail) THEN _OUT_ &= "# Email: " & .Mail & NL
    IF LEN(.Site) THEN _OUT_ &= "# Website: " & .Site & NL
    _OUT_ &= "#" & NL
    LizenseCode("# ")
    _OUT_ &= "#" & NL
    _OUT_ &= NL & NL
    _OUT_ &= !"# Note:" & NL
    _OUT_ &= !"# Set TARGET to dos, w32, linux, or cygwin -- if not defined, it will" & NL
    _OUT_ &= !"# be the same as HOST, if the later could be guessed" & NL
    _OUT_ &= NL
    _OUT_ &= !"Name = " & .Nam & NL
    _OUT_ &= !"progversion = " & .Vers & NL
    _OUT_ &= !"srcdir = $(VPATH)" & NL
    _OUT_ &= !"prefix = /usr/local" & NL
    _OUT_ &= !"exec_prefix = $(prefix)" & NL
    _OUT_ &= !"bindir = $(exec_prefix)/bin" & NL
    _OUT_ &= !"libdir = $(exec_prefix)/lib" & NL
    _OUT_ &= !"datarootdir = $(prefix)/share" & NL
    _OUT_ &= !"datadir = $(datarootdir)" & NL
    _OUT_ &= !"docdir = $(datarootdir)/doc/$(Name)" & NL
    _OUT_ &= !"menudir = $(datadir)/applications" & NL
    _OUT_ &= !"icondir = $(datadir)/pixmaps" & NL
    _OUT_ &= !"SHELL = /bin/sh" & NL
    _OUT_ &= !"DISTNAME = $(Name)-$(progversion)" & NL
    _OUT_ &= !"INSTALL = install" & NL
    _OUT_ &= !"INSTALL_PROGRAM = $(INSTALL) -p -m 755" & NL
    _OUT_ &= !"INSTALL_DATA = $(INSTALL) -p -m 644" & NL
    _OUT_ &= !"MKDIR_P = mkdir -p" & NL
    _OUT_ &= NL
    _OUT_ &= !"HOST :=" & NL
    _OUT_ &= !"ifeq ($(OS),Windows_NT)" & NL
    _OUT_ &= !"\tifeq ($(OSTYPE),cygwin)" & NL
    _OUT_ &= !"\t\tHOST := cygwin" & NL
    _OUT_ &= !"\telse" & NL
    _OUT_ &= !"\t\tHOST := w32" & NL
    _OUT_ &= !"\tendif" & NL
    _OUT_ &= !"else" & NL
    _OUT_ &= !"\tifdef WINDIR" & NL
    _OUT_ &= !"\t\tHOST := w32" & NL
    _OUT_ &= !"\telse" & NL
    _OUT_ &= !"\t\tifdef windir" & NL
    _OUT_ &= !"\t\t\tHOST := w32" & NL
    _OUT_ &= !"\t\telse" & NL
    _OUT_ &= !"\t\t\tifdef HOME" & NL
    _OUT_ &= !"\t\t\t\tHOST := linux" & NL
    _OUT_ &= !"\t\t\tendif" & NL
    _OUT_ &= !"\t\tendif" & NL
    _OUT_ &= !"\tendif" & NL
    _OUT_ &= !"endif" & NL
    _OUT_ &= NL
    _OUT_ &= !"ifndef TARGET" & NL
    _OUT_ &= !"\tifndef HOST" & NL
    _OUT_ &= !"\t\tCHECKHOST_MSG := $(error Error: TARGET not defined and HOST couldn't be guessed)" & NL
    _OUT_ &= !"\telse" & NL
    _OUT_ &= !"\t\tCHECKHOST_MSG :=" & NL
    _OUT_ &= !"\tendif" & NL
    _OUT_ &= !"\tTARGET := $(HOST)" & NL
    _OUT_ &= !"endif" & NL
    _OUT_ &= NL
    _OUT_ &= !"OBJPATH = ." & NL
    _OUT_ &= NL
    _OUT_ &= !"FBC = fbc" & NL
    _OUT_ &= NL
    _OUT_ &= !"MAIN := " & .Nam & NL
    _OUT_ &= NL
    _OUT_ &= !"SRCS := $(MAIN).bas" & NL
    _OUT_ &= NL
    _OUT_ &= !"HDRS := $(wildcard *.bi)" & NL
    _OUT_ &= NL
    _OUT_ &= !"DATS := $(MAIN).UiIne" & NL
    _OUT_ &= NL
    _OUT_ &= !"DOCS := Makefile" & NL
    IF _UI_.ReadMe THEN _OUT_ &= !"DOCS += README" & NL
    _OUT_ &= NL
    IF _UI_.Win THEN
      _OUT_ &= !"W32EXTS := $(MAIN).rc" & NL
      IF _UI_.Rc THEN _OUT_ &= !"W32EXTS += $(MAIN).ico" & NL
    ELSE
      _OUT_ &= !"W32EXTS := " & NL
    END IF
    IF _UI_.FbIde THEN _OUT_ &= !"W32EXTS += $(MAIN).fbide.fbp" & NL
    IF _UI_.FbEdit THEN
      _OUT_ &= !"W32EXTS += $(MAIN).fbp" & NL
    END IF
    IF _UI_.Jelly THEN _OUT_ &= !"W32EXTS += $(MAIN).jfp" & NL
    _OUT_ &= !"LINEXTS := " & NL
    _OUT_ &= !"EXTS := $(W32EXTS) $(LINEXTS)" & NL
    IF _UI_.Geany THEN _OUT_ &= !"EXTS += $(MAIN).geany" & NL
    _OUT_ &= NL
    _OUT_ &= !"FBCFLAGS = -w all -exx" & NL
    _OUT_ &= NL
    _OUT_ &= !"FBCFLAGS_ALL = -export $(FBCFLAGS)" & NL
    _OUT_ &= NL
    _OUT_ &= !"DEFS =" & NL
    _OUT_ &= NL
    _OUT_ &= !"RCS =" & NL
    _OUT_ &= NL
    _OUT_ &= !"ifeq ($(TARGET),w32)" & NL
    _OUT_ &= !"  FBCFLAGS += -s gui" & NL
    _OUT_ &= !"  RCS += $(MAIN).rc" & NL
    _OUT_ &= !"  APP := $(MAIN).exe" & NL
    _OUT_ &= !"  HOSTEXTS := $(W32EXTS)" & NL
    _OUT_ &= !"elseifeq ($(TARGET),cygwin)" & NL
    _OUT_ &= !"  FBCFLAGS += -s gui" & NL
    _OUT_ &= !"  RCS += $(MAIN).rc" & NL
    _OUT_ &= !"  APP := $(MAIN).exe" & NL
    _OUT_ &= !"  HOSTEXTS := $(W32EXTS)" & NL
    _OUT_ &= !"else" & NL
    _OUT_ &= !"  APP := $(MAIN)" & NL
    _OUT_ &= !"  HOSTEXTS := $(LINEXTS)" & NL
    _OUT_ &= !"endif" & NL
    _OUT_ &= NL
    _OUT_ &= !"ifdef DEBUG" & NL
    _OUT_ &= !"  FBCFLAGS += -g" & NL
    _OUT_ &= !"endif" & NL
    _OUT_ &= NL
    _OUT_ &= !"OBJS = $(patsubst %.bas,$(OBJPATH)/%.o,$(SRCS))" & NL
    _OUT_ &= NL
    _OUT_ &= !"##########################" & NL
    _OUT_ &= NL
    _OUT_ &= !".SUFFIXES:" & NL
    _OUT_ &= !".SUFFIXES: .bas" & NL
    _OUT_ &= NL
    _OUT_ &= !"VPATH = ." & NL
    _OUT_ &= NL
    _OUT_ &= !"%.o : %.bas" & NL
    _OUT_ &= !"\t$(FBC) $(FBCFLAGS_ALL) -m $(MAIN) $(DEFS) -c $< -o $@" & NL
    _OUT_ &= NL
    _OUT_ &= !"##########################" & NL
    _OUT_ &= NL
    _OUT_ &= !"all : $(APP)" & NL
    _OUT_ &= NL
    _OUT_ &= !"$(APP) : $(OBJS)" & NL
    _OUT_ &= !"\t$(FBC) $(FBCFLAGS_ALL) $(OBJS) $(RCS) -x $(APP)" & NL
    _OUT_ &= NL
    _OUT_ &= .Nam & ".o : " & .Nam & ".bi" & NL
    _OUT_ &= NL
    _OUT_ &= !".PHONY : clean" & NL
    _OUT_ &= !"clean-objs :" & NL
    _OUT_ &= !"\t-rm -f $(OBJS) $(MAIN).obj" & NL
    _OUT_ &= NL
    _OUT_ &= !"clean : clean-objs" & NL
    _OUT_ &= !"\t-rm -f $(APP)" & NL
    _OUT_ &= NL
    _OUT_ &= !"distclean : clean" & NL
    _OUT_ &= !"\t-rm -f *.gz *.bz2 *.zip" & NL
    _OUT_ &= NL
    _OUT_ &= !"##########################" & NL
    _OUT_ &= NL
    _OUT_ &= !"install : all $(DATS)" & NL
    _OUT_ &= !"\ttest -z ""$(DESTDIR)$(bindir)"" || $(MKDIR_P) ""$(DESTDIR)$(bindir)""" & NL
    _OUT_ &= !"\t$(INSTALL_PROGRAM) $(srcdir)/$(APP) ""$(DESTDIR)$(bindir)/$(APP)""" & NL
    _OUT_ &= !"\ttest -z ""$(DESTDIR)$(datadir)/$(Name)"" || $(MKDIR_P) ""$(DESTDIR)$(datadir)/$(Name)""" & NL
    _OUT_ &= !"\t$(INSTALL_DATA) $(srcdir)/$(MAIN).UiIne ""$(DESTDIR)$(datadir)/$(Name)/$(MAIN).UiIne""" & NL
    _OUT_ &= NL
    _OUT_ &= !"uninstall :" & NL
    _OUT_ &= !"\t-rm -f $(DESTDIR)$(bindir)/$(Name)" & NL
    _OUT_ &= !"\t-rm -f -r $(DESTDIR)$(datadir)/$(Name)" & NL
    _OUT_ &= NL
    _OUT_ &= !"dist-gz : $(SRCS) $(HDRS) $(DATS) $(DOCS) $(EXTS)" & NL
    _OUT_ &= !"\tln -sf $(srcdir) $(DISTNAME)" & NL
    _OUT_ &= !"\ttar -czvf $(DISTNAME).tar.gz \\" & NL
    _OUT_ &= !"\t  $(DISTNAME)/*.bas \\" & NL
    _OUT_ &= !"\t  $(DISTNAME)/*.bi \\" & NL
    _OUT_ &= !"\t  $(addprefix $(DISTNAME)/,$(DATS)) \\" & NL
    _OUT_ &= !"\t  $(addprefix $(DISTNAME)/,$(DOCS)) \\" & NL
    _OUT_ &= !"\t  $(addprefix $(DISTNAME)/,$(EXTS))" & NL
    _OUT_ &= !"\trm -f $(DISTNAME)" & NL
    _OUT_ &= NL
    _OUT_ &= !"dist-bz2 : $(SRCS) $(HDRS) $(DATS) $(DOCS) $(EXTS)" & NL
    _OUT_ &= !"\tln -sf $(srcdir) $(DISTNAME)" & NL
    _OUT_ &= !"\ttar -cvf $(DISTNAME).tar \\" & NL
    _OUT_ &= !"\t  $(DISTNAME)/*.bas \\" & NL
    _OUT_ &= !"\t  $(DISTNAME)/*.bi \\" & NL
    _OUT_ &= !"\t  $(addprefix $(DISTNAME)/,$(DATS)) \\" & NL
    _OUT_ &= !"\t  $(addprefix $(DISTNAME)/,$(DOCS)) \\" & NL
    _OUT_ &= !"\t  $(addprefix $(DISTNAME)/,$(EXTS))" & NL
    _OUT_ &= !"\trm -f $(DISTNAME)" & NL
    _OUT_ &= !"\tbzip2 -v -9 $(DISTNAME).tar" & NL
    _OUT_ &= NL
    _OUT_ &= !"dist-zip : $(SRCS) $(HDRS) $(DATS) $(DOCS) $(EXTS) $(LIBS)" & NL
    _OUT_ &= !"\tln -sf $(srcdir) $(DISTNAME)" & NL
    _OUT_ &= !"\tzip -v -9 -r $(DISTNAME).zip \\" & NL
    _OUT_ &= !"\t  $(DISTNAME)/*.bas \\" & NL
    _OUT_ &= !"\t  $(DISTNAME)/*.bi \\" & NL
    _OUT_ &= !"\t  $(addprefix $(DISTNAME)/,$(DATS)) \\" & NL
    _OUT_ &= !"\t  $(addprefix $(DISTNAME)/,$(DOCS)) \\" & NL
    _OUT_ &= !"\t  $(addprefix $(DISTNAME)/,$(EXTS))" & NL
    _OUT_ &= !"\trm -f $(DISTNAME)" & NL
    _OUT_ &= NL
    _OUT_ &= !"dist-gz-bin : $(APP) $(DATS) $(DOCS) $(HOSTLIBS)" & NL
    _OUT_ &= !"\tln -sf $(srcdir) $(DISTNAME)" & NL
    _OUT_ &= !"\ttar -cvzf $(DISTNAME)_$(HOST).tar.gz \\" & NL
    _OUT_ &= !"\t  $(DISTNAME)/$(APP) \\" & NL
    _OUT_ &= !"\t  $(addprefix $(DISTNAME)/,$(DATS)) \\" & NL
    _OUT_ &= !"\t  $(addprefix $(DISTNAME)/,$(DOCS))" & NL
    _OUT_ &= !"\trm -f $(DISTNAME)" & NL
    _OUT_ &= NL
    _OUT_ &= !"dist-bz2-bin : $(APP) $(DATS) $(DOCS) $(HOSTLIBS)" & NL
    _OUT_ &= !"\tln -sf $(srcdir) $(DISTNAME)" & NL
    _OUT_ &= !"\ttar -cvf $(DISTNAME).tar \\" & NL
    _OUT_ &= !"\t  $(DISTNAME)/$(APP) \\" & NL
    _OUT_ &= !"\t  $(addprefix $(DISTNAME)/,$(DATS)) \\" & NL
    _OUT_ &= !"\t  $(addprefix $(DISTNAME)/,$(DOCS))" & NL
    _OUT_ &= !"\trm -f $(DISTNAME)" & NL
    _OUT_ &= !"\tbzip2 -v -9 $(DISTNAME).tar" & NL
    _OUT_ &= NL
    _OUT_ &= !"dist-zip-bin : $(APP) $(DATS) $(DOCS)" & NL
    _OUT_ &= !"\tln -sf $(srcdir) $(DISTNAME)" & NL
    _OUT_ &= !"\tzip -v -9 -r $(DISTNAME)_$(HOST).zip \\" & NL
    _OUT_ &= !"\t  $(DISTNAME)/$(APP) \\" & NL
    _OUT_ &= !"\t  $(addprefix $(DISTNAME)/,$(DATS)) \\" & NL
    _OUT_ &= !"\t  $(addprefix $(DISTNAME)/,$(DOCS))" & NL
    _OUT_ &= !"\trm -f $(DISTNAME)" & NL
    _OUT_ &= NL
    _OUT_ &= !"dist : dist-gz" & NL
    _OUT_ &= NL
    _OUT_ &= !"dist-all : dist-gz dist-bz2 dist-zip dist-gz-bin dist-bz2-bin dist-zip-bin" & NL
    _OUT_ &= NL
    write_code(NamMkf)
  END WITH
END SUB
