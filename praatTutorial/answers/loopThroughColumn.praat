###### Print the text of every row
###### in the subjectNames column

###### This expects that the table
###### loopThroughColumn.tsv is open
###### in Praat

clearinfo

#set up some variables
objName$ = "loopThroughColumn"

#column we're going to print
colName$ = "subjectNames"

#select the Table
tabName$ = "Table " + objName$
selectObject: tabName$

# get number of rows, so we know
# how long to loop
numRows = Get number of rows

for rowNum from 1 to numRows
	rowVal$ = Get value: rowNum, colName$
	appendInfoLine: rowVal$
endfor
