######################################################
######################################################
# Formant reading script, Daniel Riggs, 2016
#
# This script will open every .wav file and .TextGrid
# in a folder, and record values for F1 and F2 from 
# the midpoint of every non-blank interval.
#
# This script expects that in the same folder as this
# script, there is another folder called "data", that 
# contains .wav files and .TextGrid files with the same
# name. It will create a folder "output", and make a 
# value-separated spreadsheet (default is tabs).
# The setup should be like this:
# 
# formantScript/
#     thisScript.praat
#     formantSettings.tsv
#     data/
#        sound1.wav
#        sound1.TextGrid
#        sound2.wav
#        sound2.TextGrid
#
# 
# CHANGE THESE VARIABLES IF NECESSARY:
# This is the number of the tier in the TextGrids 
# that contains the intervals you want.
tierNum = 1
#
# Set to zero if you want it to automatically erase
# an old spreadsheet
askBeforeDelete = 1
#
# These are the default formant settings. You can 
# change them if you wish
timeStepDefault = 0
numFormantsDefault = 5
maxFormantDefault = 5500
windowLengthDefault = 0.025
preEmphasisDefault = 50
#
# You can change the formant settings for any single 
# file as well by adding it to "formantSettings.tsv"
# It's a tab-separated spreadsheet. Open it to see an
# example. Note that it uses the object name to 
# determine if the specific settings should be used
# (this is the name of the Object in the Praat window
# when you open the sound file). If it's not saved
# as a tab-separated file after editing this will 
# cause errors.
#
# This will use tabs to separate columns in the output
# file. If you'd rather use commas, put a hashtag in
# front of this line, and delete the hashtag in front
# of the line that uses a comma
sep$ = tab$
#sep$ = ","
#
#####################################################
#### Don't change anything below unless you want to 
#### alter how the script works
#####################################################
clearinfo

# Will use the directory containing the script
wd$ = "./"

# input directory
inDir$ = wd$ + "data/"
# I know I'll want only wav files
inDirWavs$ = inDir$ + "*.wav"

# make sure inDir$ exists
if not fileReadable: inDir$
	exitScript: "The input folder doesn't exist"
endif

settingsPath$ = wd$ + "formantSettings.tsv"
# if it doesn't exist, print a 
# warning. We won't stop the script,
# because maybe we don't need a settings file
if fileReadable: settingsPath$
	# set up a variable so we can quickly make sure
	# the Table exists later in the script
	settingsExist = 1
else
	appendInfoLine: "WARNING: Settings file not found"
	settingsExist = 0
endif

# out file
outDir$ = wd$ + "output/"
outPath$ = outDir$ + "formantResults.tsv"

# if the output folder doesn't exist, create it.
# This won't throw an error if it already exists.
createDirectory: outDir$

# see if our spreadsheet exists
if askBeforeDelete and fileReadable: outPath$
	pauseScript: "The data spreadsheet exists, overwrite it?"
endif
deleteFile: outPath$


###### Write spreadsheet header to new file

header$ = "fileName" + sep$
	...+ "intervalNumber" + sep$
	...+ "label" + sep$
	...+ "midPoint" + sep$
	...+ "f1" + sep$
	...+ "f2" + sep$
	...+ "numFormants" + sep$
	...+ "maxFormant" + newline$

appendFile: outPath$, header$

###### Read in settings file
if settingsExist
	settings = Read Table from tab-separated file: settingsPath$
endif

###### Get a list of wav files in the input directory
wavList = Create Strings as file list: "wavList", inDirWavs$

numFiles = Get number of strings
for fileNum from 1 to numFiles

	selectObject: wavList
	wavName$ = Get string: fileNum
	appendInfoLine: wavName$

	wavPath$ = inDir$ + wavName$
	appendInfoLine: wavPath$

	wav = Read from file: wavPath$
	# get object name
	objName$ = selected$: "Sound"

	if settingsExist
		selectObject: settings
		# see if we have an entry for this object
		# in the "objectName" column.
		# Search column returns the row number if yes,
		# 0 if no. I of course found this out by opening
		# the table and tinkering with it.
		rowNum = Search column: "objectName", objName$	
		
		# if we have an entry, set the formant
		# values using the values in the table.
		if rowNum > 0
			#Remember that this table returns strings
			numFormants$ = Get value: rowNum, "numFormants"

			# Better hope there are no extra spaces
			# in the cell for the settings file, or this
			# will fail
			numFormants = number: numFormants$
			
			maxFormant$ = Get value: rowNum, "maxFormant"
			maxFormant = number: maxFormant$
		else
			# If no entry, be sure to reset to defaults, otherwise
			# we'll still have the values from the last time we
			# went through the loop
			numFormants = numFormantsDefault
			maxFormant = maxFormantDefault
		endif
	endif

	#Right now we aren't changing these via settings,
	# so they don't need to be in the conditional
	timeStep = timeStepDefault
	windowLength = windowLengthDefault
	preEmphasis = preEmphasisDefault

	# create a formant object
	selectObject: wav
	formantObj = To Formant (burg): timeStep, 
					...numFormants, 
					...maxFormant, 
					...windowLength,
					...preEmphasis

	# create text grid path, open TextGrid
	tgPath$ = inDir$ + objName$ + ".TextGrid"
	tg = Read from file: tgPath$

	numIntervals = Get number of intervals: tierNum

	# We had made a variable intNum, now
	# we'll use that as the counter variable
	for intNum from 1 to numIntervals

		###### Get F1 and F2 from midpoint

		selectObject: tg

		#Get its label
		label$ = Get label of interval: tierNum, intNum 

		# If not blank
		if label$ <> ""

			beg = Get starting point: tierNum, intNum
			end = Get end point: tierNum, intNum
			midPoint = beg + ((end - beg) / 2)

			selectObject: formantObj
			# First argument is formant number
			f1 = Get value at time: 1, midPoint, "Hertz", "Linear"
			f2 = Get value at time: 2, midPoint, "Hertz", "Linear"

			# Format the values and convert to string, 
			# to make it easier to write to the spreadsheet
			f1$ = fixed$: f1, 0
			f2$ = fixed$: f2, 0

			dataRow$ = wavName$ + sep$
				...+ (string$:intNum) + sep$
				...+ label$ + sep$
				...+ (string$:midPoint) + sep$
				...+ f1$ + sep$
				...+ f2$ + sep$
				...+ (string$:numFormants) + sep$
				...+ (string$:maxFormant) + newline$

			appendFile: outPath$, dataRow$
		endif
	endfor

	removeObject: wav
	removeObject: tg
	removeObject: formantObj

endfor

if settingsExist
	removeObject: settings
endif

removeObject: wavList

exitScript: "No errors! Check the spreadsheet"

