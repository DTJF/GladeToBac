The Data folder
===============

This folder contains data used at run-time. `GladeToBac` loads the
files at start-up using the path `data/`, so the binary should get
placed in the root folder of the project.

- Files with suffix `.lic` contain license text. Feel free to add your
favorite one.

- Files named `Signals[2|3].def` contain the signatures for the callback
functions (signal handlers). The number stands for the GTK version.
Feel free to keep them up-to date.

- Picture files (`png` and `xpm`) can get compiled in to the binary, in
order to get the logo shown at the desktop.
