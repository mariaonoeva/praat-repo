# A drawing script created by Masha Onoeva (15.11.2024)

# You need two files, they must have the same name: 
# - sound file
# - texgrid file 

# This script works, when SOUND file is selected in the Praat window 

Erase all
Black
18

# Sound MUST be selected
name$ = selected$ ("Sound")

# drawing textgrid
selectObject: "TextGrid" + " " + name$
Select inner viewport: 1, 11, 3, 6
Draw: 0, 0, "no", "no", "yes"

# drawing sound
selectObject: "Sound" + " " + name$
Select inner viewport: 1, 11, 3, 3.5
Draw: 0, 0, 0, 0, "no", "curve"

# making and drawing spectogram 
To Spectrogram: 0.005, 5000, 0.002, 20, "Gaussian"
Select inner viewport: 1, 11, 3.5, 5
Paint: 0, 0, 0, 0, 100, "yes", 50, 6, 0, "no"
Draw inner box
Marks right every: 1, 5000, "yes", "yes", "no"

# making and drawing pitch 
# it is necessary to adjust pitch hight
selectObject: "Sound" + " " + name$
To Pitch (ac): 0, 75, 15, "no", 0.03, 0.45, 0.01, 0.35, 0.14, 800
# Uncomment interpolate, if necessary 
# Interpolate
White
Line width: 10
Draw: 0, 0, 0, 800, "no"
Blue
Line width: 5
Draw: 0, 0, 0, 800, "no"
Line width: 1
Marks left every: 1, 800, "yes", "yes", "no"
Text left: "yes", "Pitch (Hz)"
Text right: "yes", "Frequency (Hz)"

# saving 
Select inner viewport: 1, 11, 3.5, 6


# path MUST be updated to your local path
Save as PDF file: "enter/path/here/" + name$ + ".pdf"

# I wrote it for Mac, Windows adjustments are required, e.g., 
## it is not possible to save as pdf, select EPS there
## some pitch updates as well



