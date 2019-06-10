' coding utf8

Info on GladeToBac version 3:


Description:

GladeToBac (= GLADE TO BAsiC) is a FreeBasic code sketcher.
GladeToBac helps to do rapid application development (RAD) of
graphic user interface (GUI) applications. GladeToBac supports the
Gimp Tool Kit (GTK+), a free library that is available for different
platforms (e.g. windows or unix/linux). E.g. use the program Glade3
to design the UI and save it as GUI-file (*.ui/*.glade). Load this
file into GladeToBac and generate some cross platform FreeBasic
source code to show and handle the GUI-widgets as a BASIC-program on
platforms like WIN32 and Unix/Linux.


Author:

Thomas{dot}Freiherr[ at ]gmx[ dot ]net
and others, see end of document.


License:

GladeToBac is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

GladeToBac is distributed in the hope that it will be useful, but
WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

GladeToBac is provided under the GNU GENERAL PUBLIC LICENSE V3,
please refer to: http://gplv3.fsf.org/


Software requirements:

Freebasic (> 0.20)
  (http://www.freebasic.net)
Glade3
  (http://sourceforge.net/project/showfiles.php?group_id=98754)
GTK+ >= 2.16
  (http://sourceforge.net/project/showfiles.php?group_id=98754)
optional:
IDE like Geany
  (http://www.geany.org/Download/Releases)
gettext for I18N
  (http://www.gnu.org/software/gettext/)


Short introduction:

Prparation:
Download GladeToBacX.Y.Z.zip and unpack. (‘X.Y.Z’ = version#)
Install (move) headers (*.bi) from /inc/* in folder */freebasic/inc/.

A) Make a new program (let us call it APPLICATION):
1.) Create folder APPLICATION.
2.) Glade3: design the GUI and save it as APPLICATION.ui in folder.
3.) GladeToBac: edit and choose your parameters.
4.) GladeToBac: Load APPLICATION.ui and press 'Code sketching' button.
5.) After step 4 there is an APPLICATION.bas-file in the folder. Fill in
    your source code into the file.
6.) Depending on your signals (Glade3) there are some x_x_x.bas
	files in the folder or in the subfolder tobac. Fill in your
	source code into the file.
7.) Finaly compile APPLICATION.bas with fbc (FreeBasic-Compiler).

B) Optimize an existing program:
1.) Start Glade3 to optimize the GUI and save as APPLICATION.ui.
2.) Start GladeToBac and load APPLICATION.ui. Press 'Code sketching'
    button. You may press 'Clear up' button if required.
3.) Fill in source code into new x_x_x.bas-files, generated in step 2.
4.) Compile APPLICATION.bas with fbc.

In some cases steps B2 and B3 can be omitted. You should use them when:
* new signals are added or existing where renamed
* the option 'generate _gui.bas' is choosen
* Widgets/Object have been renamed or added

There is no risk to use these steps without need.

C) Create .pot-file (I18N - Internationalissation)
1.) GladeToBac: load file APPLICATION.ui
2.) GladeToBac: run 'File->I18N' (file APPLICATION.pot will get created)


Details:

Glade3 saves the GUI-file as a *.glade file for use with libglade2-0
or as a *.ui files for use with GtkBuilder. GtkBuilder is the modern
way and offers some additional features. GladeToBac can generate
source code for both variants.

The GtkBuilder bindings are not included in original FreeBasic
bindings (gtk/gtk.bi). You need the advanced binding included in
these package, called GTK-2.22.0_TJF.bi. This file also includes
bindings for atk-1.32.0, cairo-1.10.0, gdk-2.90.1, glib-2.27.0 and
pango-1.28.3.

GladeToBac reads the GUI-file (*.ui/*.glade) and generates some new
files with basic source code in the folder of the GUI-file and in
the tobac subfolder. There are comments in the source code (thanks
to Mr. Siebke!). Without errors, the following files should be
generated:

APPLICATION.bas
APPLICATION_tobac.bas (in subfolder, depending on parameters)
APPLICATION_gui.bas (optional, subfolder)
x_x_x.bas (some files, subfolder).
As well as some project files for different IDE in the folder,
depending on your parameters.

Most of these files will be generated once at the first run of
GladeToBac. You can edit these files as needed. GladeToBac will not
overwrite them. If you need a new version of a file, rename or kill
it before the next run of GladeToBac. But there are two exeption
(*_tobac.bas and *_glad.bas), see below.


GladeToBac GUI:

After starting GladeToBac you will see a GUI with menu, toolbar and
a notebook with with two labels.

The tab 'Output' is to show messages on the action done by
GladeToBac, like a protokol.

The tab 'Parameters' is to set the actions GladeToBac should do and
to set texts for the file generation.

Parameters specified in the area 'New project' (or 'APPLICATION.bas'
after loading an GUI-XML-flie) will be used when generating a new
'APPLICATION.bas'- file, if 'APPLICATION.bas' doesn't exist when
executing 'Generate files'. Checking 'tobac folder' instructs
GladeToBac to create and use a subfolder named 'tobac', to reduce
the number of files in the main folder. In the subfolder will be
stored: the callbacks 'x_x_x.bas', the 'APPLICATION_tobac.bas' file
and if need be the 'APPLICATION_gui.bas' file. Checking 'I18N'
instructs GladeToBac to generate code that includes the bindings for
the gettext tools 'libintl.bi' and initializes them.

The parameters in the area 'New project_tobac.bas' will be used at
every call of the function 'Code sketching'. Checking 'GUI in
source' instructs GladeToBac to generate the file
APPLICATION_gui.bas and integrate it in the source. In this case the
binary can run without the GUI-XML-file. In the entry 'GTK-version'
a version of GTK can be specified (2.8 or above). GladeToBac
generates code in the APPLICATION_tobac.bas file that checks the GTK
version. If the version is less than specified your program stops
and returns 1.

The checked files in the area 'Project files' will be generated in
the main folder (where the GUI-XML-file is located). Existing files
wouldn't be changed.


File descriptions:

data/*.lic:

There are some text files in the data folder with suffix '.lic',
containing short forms of different license texts. The first line
contains the name of the licence. This name will be red on
GladeToBac startup and filled into the combobox in the 'New project'
area. The context of the licence starts at the second line. The
choosen licence will be filled into files 'APPLICATION.bas',
'readme.txt' and 'make'. The line width should be <= 74 characters.

data/Signales.def

This file (readable text) contains the definitions of the signal
handlers (callbacks). Depending on its function, a callback can be a
procedure (SUB) or a function and does have different parameter
lists. Since version 2.2.2 GladeToBac can generate matching callback
frames for all signals defined in GTK-2.22.0, reading the
definitions from this file. New signal definitions for further GTK+
versions can be added easily by copying and paste the original text
from the documentation into this file.

APPLICATION.desc (optional):

This file contains a detailed description of the project. The
context will be written to the files 'APPLICATION.bas' and
'readme.txt', if the file exists in the main folder. The line width
should be <= 65 characters.

APPLICATION.ui (or APPLICATION.glade):

GUI-XML-file generated by Glade3, describing the GUI. The GladeToBac
activities are based on this file.

APPLICATION.bas:

This file will be generated at the first run of GladeToBac. This is
the main source file to be compiled at the end. It includes the
parts of the source in the correct order, initializes the GUI,
starts the GUI-loop for user action and dereferences the GUI for
ending the program.

You can and should fill this file with your source code. But be
carefull: if you edit the original part of this file, you should
know what you are doing!

x_x_x.bas:

The files x_x_x.bas are used to connect the callbacks to your
program logic. Add your code for reaction to a user operation at the
GUI.

E.g. the menu help in the GUI file is names 'mnu_help' and the user
activates this menu item, the SUB 'on_mnu_help_activate' will be
called in your program.

GladeToBac will create one x_x_x.bas file for each signal in the
GUI-file. The name of the generated file is similar to the name of
the signal handler. After creation this file will not be changed or
overwritten.

If you delete a signal in the GUI-XML-file, the x_x_x.bas file is
not needed any more. Use function 'clear up' to identify and delete
deprecated x_x_x.bas files.

If you forget to edit one of the *.bas files, the source code is
prepared to remind you by printing 'GladeToBac: insert code'. Edit
the marked file and replace the line '#EXPORT GladeToBac: insert
code' by your source code.

The project files:

These files helps to start with different IDEs. I can't explain them
in detail here. (ReadMe.txt, makefile, *.Geany, *.fbp, *.jfp, *.rc)

The other files are used internaly. They will be generated at every
call of 'Code sketching', overwriting the last version without
warning. Do not edit!

APPLICATION.pot (optional for I18N):

This file gets created by xgettext when executing 'File->I18N'
('xgettext' has te be installed first). The file contain all
translateble texts, extracted from the FreeBasic source (*.bas) in
the folders

  */APPLICATION/tobac (when choosen)
  */APPLICATION/

and from the GUI-XML-files (*.ui or *.glade) in the folder

  */APPLICATION/.

The .pot-file is used for translations with poedit (a 'gettext'
tool). From this file a translator generate new texts in foreign
languages and saves them in an 'APPLICATION.mo'-file which is loaded
by the libintl at runtime (ie for German
'/APPLICATION/locale/de/LC_MESSAGES/APPLICATION.mo' is used). For
each language an subfolder will be generated in 'locale'. GTK+ loads
the desired .mo file regarding the 'LANG' environment variable.

APPLICATION_tobac.bas:

This file binds the GUI to the source code. It will be generated on
every run of GladeToBac. This file is to load the GUI-file and
reference it, is to reference some objects/widgets as global basic
varianbles or TYPE-variables and to include the callback files.

Widget references will be done, if the widget name is different from
the Glade3 default name. See source code for detail.

APPLICATION_gui.bas (optional):

If the button 'GUI in source code' is checked, GladeToBac will
generate this file, that includes the GUI-file into binary. In that
case just one file has to be shipped. Otherwise the GUI-file will be
loaded at runtime.

During development a separate GUI-file is more easy to handle. It is
recommended to insert GUI-file only in final release.


Starting in console:

GladeToBac either can run with GUI or as a console program in text
mode. When passing a GUI-file name GladeToBac tries to run in text
mode. On error, the GUI will start. Get information about the
parameters by running './GladeToBac -h' or 'GladeToBac.exe -h'.

Examples:

./GladeToBac -h
Show help text in console mode.

./GladeToBac test/HalloWelt.glade
Load, analyze and sketch file 'HalloWelt.glade' in console mode.

./GladeToBac test/HalloWelt.ui -N -a
Load and analyze file 'HalloWelt.ui' and kill deprecated *.bas files
(console mode).

./GladeToBac test/HalloWelt.ui -N -p
Load and analyse file 'HalloWelt.ui', generate .pot file for I18N
(*.bas-files won't get changed).

For WIN32 only:

to use this function, fbc compiling has to be done with option "-s
console" (=default), to get the COMMAND-string.


Some more How-To's:

D) Start a new project with description:
1.) steps A1 and A2, see short introduction
2.) generate text file APPLICATION.desc in main folder
3.) steps A3 and others, see short introduction

E) Edit an existing project, change to actual GladeToBac version:
1.) Rename the project folder (e.g. Old_*)
2.) Make new project folder
3.) Copy GUI-file into folder
4.) Follow A3 to A7 into short introduction
5.) Copy source code from *.bas files in old folder into new *.bas-files
6.) compile

F) Change project from libglade to GtkBuilder:
1.) Rename APPLICATION.bas (e.g. APPLICATION.bas~)
2.) Glade3.6.7: load *.glade file, save as *.ui
3.) GladeToBac: choose parameters, load file APPLICATION.ui and sketch code
4.) Copy source code from APPLICATION.bas~ into new APPLICATION.bas
5.) Change references in source code from GtkWidget to GObject
6.) compile

G) Change project from global VARs to TYPE:
1.) Rename file APPLICATION.bas (e.g. APPLICATION.bas~)
2.) GladeToBac: define TYPE-Name (e.g. _GUI_)
3.) GladeToBac: choose parameters, load file APPLICATION.ui and sketch code
4.) Copy source code from APPLICATION.bas~ into new APPLICATION.bas
5.) Rename references in source code from NAME to _GUI_.NAME
6.) compile

T) Change to 'tobac' folder usage:
1.) GladeToBac: check 'tobac folder'
2.) GladeToBac: load file APPLICATION.ui (or .glade) and sketch code
3.) move callbacks from main folder into subfolder tobac (overwrite)
4.) delete 'APPLICATION_tobac.bas' (and 'APPLICATION_gui.bas) in main
    folder
5.) compile

U) Change to usage of older GTK versions:
1.) Rename file APPLICATION.bas (e.g. APPLICATION.bas~)
2.) GladeToBac: choose GTK old Versions
3.) GladeToBac: load APPLICATION.ui (or *.glade) and sketch code
4.) Copy source code from APPLICATION.bas~ into new APPLICATION.bas
5.) compile
Note: in some cases the *.ui file needs GTK version > 2.16 (see
messages after program start in console).

X) New project with I18N support:
1.) Follow steps A 1-7 and take care of:
  A2) Glade3: mark texts as 'translatable' (default)
  A3) GladeToBac: choose 'Parameter->I18N'
  A5) generate translatable texts in APPLICATION.bas with funktion
      gettext (shortcut '__', ie replace '?"Test"' by '?*__("Test")')
  A6) use gettext in x_x_x.bas files as well.
2.) GladeToBac: load APPLICATION.ui and run 'File->I18N'
3.) Generate new folder */APPLICATION/locale/de/LC_MESSAGES
4.) Copy APPLICATION.pot (step 2) in new folder (step 3) and rename it
    to 'APPLICATION.po'
5.) poedit: load '*/APPLICATION/locale/de/LC_MESSAGES/APPLICATION.po',
    translate and save (creates 'APPLICATION.mo' file)
6.) Try out (for original version LANG=C)
    win: SET LANG=de_DE.UTF-8 & APPLICATION.exe
    LINUX: LANG=de_DE.UTF-8 ./APPLICATION

Y) Add I18N (in existing project):
1.) Extend first GladeToBac code-block in APPLICATION.bas to (and save):
  ' ---------------------------------------------------------------------
  '<  GladeToBac:            general init / Allgemeine Initialisierungen >
      #DEFINE __TJF_GTK_OLD__ '     for old versions / alte GTK+ Version >
      #INCLUDE "gtk/GTK-2.22.0_TJF.bi" '   GTK+library / GTK+ Bibliothek >
      gtk_init(@__FB_ARGC__, @__FB_ARGV__) '     start GKT / GTK starten >
      #INCLUDE "gtk/glib/INTL-0.18_TJF.bi" '        load lib / Lib laden >
      bindtextdomain(PROG_NAME, EXEPATH & "/locale") '       path / Pfad >
      bind_textdomain_codeset(PROG_NAME, "UTF-8") 'ncoding / Zeichensatz >
      textdomain(PROG_NAME) '                       Filename / Dateiname >
  '<  GladeToBac:                                  end block / Blockende >
  ' vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
2.) Glade3: mark texts as 'translatable' (default)
3.) generate translatable texts in APPLICATION.bas with function gettext
    (shortcut '__', ie replace '?"Test"' by '?*__("Test")')
4.) use gettext in callback (x_x_x.bas) files as well.
5.) Continue with steps Z 1-5

Z) Make I18N-texts up-to-date (in existing project):
1.) GladeToBac: load file APPLICATION.ui and run 'File->I18N'
2.) poedit: load '*/APPLICATION/locale/de/LC_MESSAGES/APPLICATION.po'
3.) poedit: run 'catalog->actualise from pot file' (or similar),
    choose '*/APPLICATION/APPLICATION.pot' (confirm info window)
4.) translate new texts and save (replaces old APPLICATION.mo)
6.) Try out (for original version LANG=C)
    win: SET LANG=de_DE.UTF-8 & APPLICATION.exe
    LINUX: LANG=de_DE.UTF-8 ./APPLICATION


Finally let's point out: GladeToBac was used to code GladeToBac, as
you easily can see in the source code.

So you may use the file in the 'src' folder of this .zip-file as an
example for usage.

Good luck!

PS:
Donations are welcome (IBAN: AT16 1937 0310 1013 4371; BIC: DRESATWX)


This project has been inspired by:

'******************************************************************************
'*  Program name: glade2bas
'*
'*  Version:      1.0
'*
'*  Author:       Copyright (c) 2007 Klaus Siebke
'*                Siebke Unternehmensberatung
'*                URL http://www.siebke.com
'*
'*  Description:
'*  -----------
'*
'*  This program generates FreeBasic coding from a glade xml file.
'*  With this utility it is very easy to create your own GUI application.
'*  A Basic shell program is created and you only have to add the
'*  processing logic.
'*
'*  Used components:
'*  ---------------
'*
'*  FreeBasic
'*  Gtk
'*  glade (for graphical GUI design)
'*
'*  As program editor I recommend geany 0.12 or higher with FreeBasic
'*  syntax highlighting and compile/run "out of the box"
'*
'*
'*  License:
'*  -------
'*
'*  Program provided under GNU GENERAL PUBLIC LICENSE. Pls. refer to:
'*  http://gplv3.fsf.org/
'*
'*  Short summary:
'*  Permission to use, copy, modify, distribute and sell this software
'*  and its documentation for any purpose is hereby granted without fee,
'*  provided that the above copyright notice appear in all copies and
'*  that both that copyright notice and this permission notice appear
'*  in supporting documentation.
'*  It is provided "as is" without express or implied warranty.
'*
'******************************************************************************
'*  Programmname: glade2bas
'*
'*  Version:      1.0
'*
'*  Autor:        Copyright (c) 2007 Klaus Siebke
'*                Siebke Unternehmensberatung
'*                URL http://www.siebke.com
'*
'*  Beschreibung:
'*  ------------
'*
'*  Dieses Programm erzeugt FreeBasic Programmcode aus einer glade xml Datei.
'*  Damit wird es zum Kinderspiel eigene GUI-Anwendungen zu erstellen.
'*  Sie muessen nur noch die gewuenschte Ablauflogik im generierten Programm-
'*  rahmen ergaenzen.
'*
'*  Verwendete Komponenten:
'*  ----------------------
'*
'*  FreeBasis
'*  Gtk
'*  glade (fuer den grafischen GUI-Entwurf/Erstellung der xml-Datei)
'*
'*  Als Editor empfehle ich geany 0.12 oder ein hoeheres Release mit FreeBasic
'*  Syntax-Hervorhebung und Kompilieren/Ausfuehren direkt aus dem Editor
'*
'*  Lizenz:
'*  ------
'*
'*  Das Programm steht unter der GNU GENERAL PUBLIC LICENSE. Vgl. hierzu:
'*  http://gplv3.fsf.org/
'*
'*  Kurze Zusammenfassung:
'*  Sie erhalten die Erlaubnis, dieses Programm und die zugehoerige Dokumentation
'*  fuer beliebige Zwecke kostenlos zu benutzen, zu kopieren, zu veraendern,
'*  weiterzugeben oder zu verkaufen, unter der Voraussetzung, dass Sie diese
'*  Lizenzbestimmung und diesen Text auch in Ihre daraus erstellten Programme bzw.
'*  Dokumentationen uebernehmen.
'*  Dieses Werk wird Ihnen so ueberlassen "wie es ist", auf eigene Gefahr und ohne
'*  jegliche Gewaehrleistung.
'*
'*****************************************************************************

and

/'
 ' Glade to FreeBASIC Generator - Generate FreeBASIC sources from Glade Files
 ' Copyright (C) 2009 Arnel A. Borja
 ' E-mail: galeon@ymail.com
 ' Website: http://www.galeon.exofire.net
 '
 ' Glade to FreeBASIC Generator is free software: you can redistribute it and/or
 ' modify it under the terms of the GNU General Public License as published by
 ' the Free Software Foundation, either version 3 of the License, or (at your
 ' option) any later version.
 '
 ' Glade to FreeBASIC Generator is distributed in the hope that it will be
 ' useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
 ' MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General
 ' Public License for more details.
 '
 ' You should have received a copy of the GNU General Public License along with
 ' Glade to FreeBASIC Generator.  If not, see <http://www.gnu.org/licenses/>.
 '/
