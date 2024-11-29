###This script will take an annotated sound file, extract the 
#non-blank tiers, and save them to disk.
#
###This script expects a collection file, that contains a sound file 
#together with a TextGrid.
#
#See the section below, "Change these variables", to specify its execution
#
#Note that since the files are saved according to word name (the label of
#the interval), it is important that the word tier be an orthographic 
#representation, since not all IPA characters will be legal characters for file names. 
#This is an admitted limitation of this script.

clearinfo

#####Change these variables######################################

#If equals 1, then you don't have to change anything else in this file
#If equals 0, change the variables below before the full line of #hastags
#   and the script will run without asking the user for interaction
interactive = 0

#These will be overwritten if interactive is 1
wd$ = ""
inFile$ = wd$ + "sampleData/consonants.Collection"
outDir$ = wd$ + "sampleOutput/"

#This is the number of the tier containing the word names.
#The labels therein will be used to create file names 
wordTier = 1

#save text grid. 
#      Values can be:
#		"Collection" (to save sound and text together in one file)
#		"sep" (for separate wav and TextGrid files)
#		"" (don't extract TextGrid)
saveTG$ = ""

########################################################################
###Don't change the variables below unless you want to modify the script

if interactive == 1
	#appendInfoLine: "Interactive"

	inFile$ = chooseReadFile$: "Choose a Praat .Collection file"
	@getParentDir: inFile$	
	wd$ = getParentDir.result$ 
	outDir$ = wd$

	beginPause: "Which tier?"
		comment: "Enter the number of the tier the word labels are on"
		positive: "Tier_number", 1
		comment: "How do you want to save the file(s)?"
		choice: "Pick one", 1
			option: "Together in a .Collection file"
			option: "Separate wav and TextGrid files"
			option: "Only the wav file"
	clicked = endPause: "Continue", 1

	wordTier = tier_number

	saveTG = pick_one
	if saveTG == 1
		saveTG$ = "Collection"
	elif saveTG == 2
		saveTG$ = "sep"
	elif saveTG == 3
		saveTG$ = ""
	endif

endif

#Trying more robust selection technique#####################
#Although, on second thought, this might be a total non-issue
#Get number of objects in the window before opening
select all
numSelPre = numberOfSelected()
#appendInfoLine: "Number selected before opening: ", numSelPre

#Open file(s)
Read from file: inFile$

select all
numSelPost = numberOfSelected()
#appendInfoLine: "Number selected after opening: ", numSelPost

numOpened = numSelPost - numSelPre
#appendInfoLine: "Number of files opened: ", numOpened

#now we can reverse loop through the last objects 
#opened and get info for them

#require two objects
if numOpened < 2 or numOpened > 2
	exit "Wrong number of files in the Collection. We were expecting one Sound file, and one TextGrid."
endif

#Get last object number
select all
lastSel = selected(-1)
#loop backwards through objects, finding the sound
#and textgrid objects. If we don't end up with one
#of each, abort
soundObj$ = ""
textObj$ = ""
for fi to numOpened
	selectObject: lastSel
	#get the name and type
	seldObj$ = selected()
	#appendInfoLine: seldObj$
	obType$ = extractWord$(seldObj$, "") 
	obName$ = extractLine$(seldObj$, " ")
	#appendInfoLine: "Object name: ", obName$, "Object type: ", obType$

	if obType$ == "Sound"
		soundObj$ = seldObj$
	elif obType$ == "TextGrid"
		textObj$ = seldObj$
	endif

	#decrement the object number, we're looping backwards
	lastSel -= 1
endfor

#appendInfoLine: "Sound object: ", soundObj$, "Text object: ", textObj$

#Check if blank string 
if !(textObj$ <> "") or !(soundObj$ <> "")
	exit "This script requires one wav file and one text grid file (or one Collection file containing these two objects)"
endif
###############################################################################

#now start the real work
selectObject: textObj$
numWords = Get number of intervals: wordTier

for w from 1 to numWords
	selectObject: textObj$
	lab$ = Get label of interval: wordTier, w
	if lab$ <> ""
		beg = Get starting point: wordTier, w
		end = Get end point: wordTier, w

		selectObject: soundObj$
		soundPart = Extract part: beg, end, "rectangular", 1.0, 0
		selectObject: soundPart
		Rename: lab$

		if saveTG$ <> ""
			selectObject: textObj$
			textPart = Extract part: beg, end, 0
			selectObject: textPart
			Rename: lab$
		endif

		#newSoundPart$ = "Sound " + lab$
		selectObject: soundPart

		if saveTG$ == "Collection"
			newTextPart$ = "TextGrid " + lab$
			plusObject: textPart
			Save as binary file: outDir$ + lab$ + ".Collection"
		elif saveTG$ == "sep"
			Save as WAV file: outDir$ + lab$ + ".wav"
			selectObject: textPart
			Save as text file: outDir$ + lab$ + ".TextGrid"
		else
			Save as WAV file: outDir$ + lab$ + ".wav"
		endif


		removeObject: soundPart

		if saveTG$ <> ""
			removeObject: textPart
		endif
	endif 
endfor

removeObject: textObj$
removeObject: soundObj$

if interactive
	beginPause: "Done" 
		comment: "Done!"
	endPause: "Ok", 1
else
	appendInfoLine: "Done!"
endif

#Returns a string "0" if no parent directory found
procedure getParentDir: .fil$

	#Search for last forward or backward slash
	.reg$ = "/|\\"
	.rightSlashIndex = rindex_regex(.fil$, .reg$)

	#appendInfoLine: "Input: ", .fil$, "Index: ",  .rightSlashIndex
	if .rightSlashIndex == 0
		.result$ = "0"
	else
		.result$ = left$(.fil$, .rightSlashIndex)
	endif

endproc
