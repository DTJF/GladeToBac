' ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
'< Signal handler generated by utility                       GladeToBac V3.2.2 >
'< Signal-Modul erzeugt von                                                    >
'< Generated at / Generierung am                             2019-06-09, 12:48 >
' -----------------------------------------------------------------------------
'< Main/Haupt Program name: FChooser.bas                                       >
' -----------------------------------------------------------------------------
'< callback SUB/FUNCTION                                          insert code! >
'< Ereignis Unterprogramm/Funktion                        Quelltext einfuegen! >
' vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
SUB ButtRem_clicked_cb CDECL ALIAS "ButtRem_clicked_cb" ( _
  BYVAL button AS GtkButton PTR, _
  BYVAL user_data AS gpointer) EXPORT

' place your source code here / eigenen Quelltext hier einfuegen
'#ERROR GladeToBac: Quelltext einfügen!

  gtk_widget_hide(GTK_WIDGET(_UI_.ChooseSav))

  VAR chooser = GTK_FILE_CHOOSER(user_data)
  VAR wind = GTK_WINDOW(user_data)
  VAR butt = GTK_WIDGET(_UI_.ChooseRem)
  gtk_file_chooser_set_action(chooser, GTK_FILE_CHOOSER_ACTION_OPEN)
  gtk_window_set_title(wind, "choose a file to remove")
  gtk_widget_grab_default(butt)
  gtk_widget_show(butt)

  VAR res = gtk_dialog_run(GTK_DIALOG(user_data))
  gtk_widget_hide(GTK_WIDGET(user_data))

  IF res = -3 THEN ' = GTK_RESPONSE_ACCEPT
#IFDEF __FB_PCOS__
    VAR n = gtk_file_chooser_get_filename(chooser)
    VAR filename = g_filename_to_utf8(n, -1, NULL, NULL, NULL)
    g_free(n)
#ELSE
    VAR filename = gtk_file_chooser_get_filename(chooser)
#ENDIF
    IF filename THEN
      gtk_label_set_text(GTK_LABEL(_UI_.LabConfName), filename)
      IF 1 = gtk_dialog_run(GTK_DIALOG(_UI_.DiaConfirm)) THEN KILL(*filename)
      gtk_widget_hide(GTK_WIDGET(_UI_.DiaConfirm))
      g_free(filename)
    END IF
  END IF

END SUB
