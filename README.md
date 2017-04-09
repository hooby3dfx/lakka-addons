# lakka-addons

A few useful helper utilities that add functionality/automation to Lakka.

Copy them to a directory (such as /storage) and set them as executable (chmod +x).

## autostart.sh:
Example OpenELEC/LibreELEC "autostart" script that will run on system start. 

Must go in /storage/.config. Does not need to be executable.

## btautopair.sh:
Script that can be run on system startup, manually, or through some trigger to put the bluetooth interface into pairing mode for a couple minutes.

Will automatically pair with any input class devices that are found in pairing mode.

Note: requires the utility "empty" to interact with the bluetoothctl interactive cli.
