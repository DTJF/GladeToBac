Demo Project
============

This folder contains the source code for a demo project, running a
GtkFileChooser in OPEN and SAVE mode. The folder contains the source in
the final state. In order to learn about chronology of the development
process, just create a new folder and follow the below described steps.

# Phase 1: Create UI #

The project starts by creating the user interface file named
`FChooser.ui` in an empty project folder. This file gets created (or
edited) by the application `Glade3`. Make sure that you explizitly set
suffix `.ui` when saving.

# Phase 2: Create FB Files #

Once the UI is functional, you can create matching FreeBASIC source
code. Therefor

- Start `GladeToBac` and open the file `FChooser.ui`.
(You'll get some red warnings about missing files.)

- You may want to set some parameters first. Save them as Projekt
Parameters (<crtl-S>). The data later gets re-loaded together with the
UI file `FChooser.ui`. But note: when there's a file `FChooser.bas`,
then its data has preference.

- Then create the FB source (click `Erzeugen.bas`). Depending on your
parameter setting, a new subfolder named `tobac` may get created,
contianing the file `FChooser_tobac.bas` and further `*.bas` files
containing templates for the callback functions which are defined in
the UI file `FChooser.ui`. If you didn't choose to use the tobac folder,
those files are in the root directory, which contains in any case the
new file `FChooser.bas`.

- This file `FChooser.bas` glues all files together. By compiling it
you'll end up with some error messages that point you to the places
where custom code is necessary. In this demo the code is already
adapted. So in your test folder, copy/paste the code from the original
files.

- When compiler errors are gone, execute and test the new binary.

# Phase 3: Modifying the Code #

It's most likely that you want to modify or optimize your code:

- As long as you modified FB code only, it's sufficient to just compile
the main file `FChooser.bas` and then test the executable.

- In contrast, when you changed the UI file `FChooser.ui`, you may have
to re-run `GladeToBac` before compiling and executing. That's the case
after

* adding or removing a named widget, or
* adding or removing a signals callback function

Widget (namely their GObject PTRs) gets defined in file
`FChooser_tobac.bas`, so don't edit that file.

Each callback gets its own file, named after the entry in the UI file
`FChooser.ui`, suffixed by `.bas`. You have to edit those files in
order to implement the desired functionality. It's recommended to place
them in to the subfolder `tobac`. `GladeToBac` doesn't touch existing
files, but creates a new file outherwise.

Note: When `GladeToBac` creates a callback function, it reads the
matching parameter signature from files `data/Signals[2|3]`. The file
may be outdated, so always check the manually signature (the compiler
can't do that).

Obsolate callback files get listed and optionally deleted.
