' ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
'< _tobac.bas modul generated by utility                     GladeToBac V3.2.2 >
'< Modul _tobac.bas erzeugt von                                                >
'< Generated at / Generierung am                             2019-06-09, 17:23 >
' -----------------------------------------------------------------------------
'< Main/Haupt Program name: FChooser.bas                                       >
'< Author:  TJF                                                                >
'<  Email:  Thomas{dot)Freiherr(at]gmx[dot}net                                 >
'<    WWW:  github.com/dtjf/GladeToBac                                         >
' -----------------------------------------------------------------------------
'< declare names, signal handlers, load GUI-XML                   do not edit! >
'< deklariert Namen, Signale, laedt GUI-XML                  nicht veraendern! >
' vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv

SCOPE
  VAR er = gtk_check_version_(3, 12, 0)
  IF er THEN
    ?"Fehler/Error (GTK-Version):"
    ?*er
    END 1
  END IF
END SCOPE

TYPE _UI_Data
  AS GtkBuilder PTR XML
  AS GObject PTR _
  WinMain, ButtRem, ButtSave, DiaConfirm, dialog_vbox1, dialog_action_area1,  _
  LabConfName, FileChooser, filechooserdialog_vbox1, filechooserdialog_action_area1,  _
  ChooseSav, ChooseRem
END TYPE
DIM SHARED AS _UI_Data _UI_

_UI_.XML = gtk_builder_new()

SCOPE
DIM AS GError PTR meld
IF 0 = gtk_builder_add_from_file(_UI_.XML, "FChooser.ui", @meld) THEN
  WITH *meld
    ?"Fehler/Error (GTK-Builder):"
    ?*.message
  END WITH
  g_error_free(meld)
  END 2
END IF
END SCOPE

WITH _UI_
  .WinMain = gtk_builder_get_object(.XML, "WinMain")
  .ButtRem = gtk_builder_get_object(.XML, "ButtRem")
  .ButtSave = gtk_builder_get_object(.XML, "ButtSave")
  .DiaConfirm = gtk_builder_get_object(.XML, "DiaConfirm")
  .dialog_vbox1 = gtk_builder_get_object(.XML, "dialog_vbox1")
  .dialog_action_area1 = gtk_builder_get_object(.XML, "dialog_action_area1")
  .LabConfName = gtk_builder_get_object(.XML, "LabConfName")
  .FileChooser = gtk_builder_get_object(.XML, "FileChooser")
  .filechooserdialog_vbox1 = gtk_builder_get_object(.XML, "filechooserdialog_vbox1")
  .filechooserdialog_action_area1 = gtk_builder_get_object(.XML, "filechooserdialog_action_area1")
  .ChooseSav = gtk_builder_get_object(.XML, "ChooseSav")
  .ChooseRem = gtk_builder_get_object(.XML, "ChooseRem")
END WITH

#INCLUDE "ButtRem_clicked_cb.bas"
#INCLUDE "ButtSave_clicked_cb.bas"
