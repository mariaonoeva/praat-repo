clearinfo

askedForMoney = 1 

# child$ = "Alison"
# child$ = "Dan"
child$ = "Colin"

willLoan = 0 

if askedForMoney 
	if child$ == "Alison"
		willLoan = 1
	elif child$ == "Colin"
		willLoan = 1
# else = "in all other cases"
	else 
		willLoan = 0
	endif
endif

appendInfoLine: willLoan