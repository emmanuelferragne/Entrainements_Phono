form Choisir l'experience
	comment Choisir l'experience
	optionmenu cond : 3
	option a
	option av
	option i
	
	comment Entrez le login
	sentence myID
endform

programName$ = chooseReadFile$: "sélectionner le script"

demo Select inner viewport: 0, 100, 0, 100
demo Axes: 0, 100, 0, 100

@theTime
debut = heure

demo Black
demo Times
demo Font size: 32
demo Line width... 2
demo Text: 50, "centre", 100, "half", "INSTRUCTIONS"
demo Font size: 18
demo Text: 50, "centre", 80, "half", "In this experiment you will be hearing sequences of two words."
demo Text: 50, "centre", 75, "half", "Your task is to decide whether these words are same or different."
demo Text: 50, "centre", 70, "half", ""
demo Text: 50, "centre", 60, "half", ""
demo Text: 50, "centre", 55, "half", "You can play the words again by pressing the SPACE BAR"
demo Text: 50, "centre", 50, "half", "If your answer is right, Correct :-) will be displayed and the next sequence will be played."
demo Text: 50, "centre", 45, "half", "If your answer is wrong, Try again :-( will be displayed" 
demo Text: 50, "centre", 40, "half", "and the same sequence will be re-played before you can give the correct answer."
demo Text: 50, "centre", 30, "half", ""
demo Text: 50, "centre", 20, "half", "The experiment consists of 240 trials."
demo Text: 40, "centre", 5, "half", "When you've finished reading these instructions, please click on START to begin the experiment." 
demo Paint rectangle: "{60, 60, 60}", 80, 95, 0, 10
demo Text: 87.5,  "centre", 5, "half", "START" 
		
while demoWaitForInput()
	if demoClickedIn(80, 95, 0, 10)
		demo Draw rectangle: 80, 95, 0, 10
		@myTimer(0.5)
		goto NEXT
	endif
endwhile

label NEXT
demo Erase all


demo Erase all

logName$ = "AX_" + "'cond$'" + "'myID$'" + ".txt"
appendFileLine: logName$, "#", date$(), "#", myID$, "#", programName$, newline$, "Sound Files", tab$, "Response", tab$, "FirstResponse", tab$, "Result", tab$, "Response Time", tab$, "NbErreurs", tab$, "nbRepetitions"


stimFileName$ = "ListeAX_"+"'cond$'"+".txt"
Read Table from tab-separated file... 'stimFileName$'
Randomize rows
stringName$ = selected$("Table")
nbStrings = Get number of rows
totalErreurs = 0
compteur = 0

for stim from 1 to nbStrings

!Mettre une pause tous les 10 items...
	if stim <>1 and (stim - 1) mod (nbStrings/3) = 0 and (nbStrings - stim) > 10
		demo Erase all
		demo Font size: 24
		demo Text: 50, "centre", 50, "half", "Vous pouvez faire une pause."
		demo Font size: 18
		itemsFaits = stim - 1
		demo Text: 95, "centre", 95, "half", "'itemsFaits'/'nbStrings'"
		demo Text: 60, "centre", 5, "half", "Click CONTINUE to continue the experiment." 
		demo Paint rectangle: "{60, 60, 60}", 80, 95, 0, 10
		demo Text: 87.5,  "centre", 5, "half", "CONTINUE" 
		while demoWaitForInput()
			if demoClickedIn(80, 95, 0, 10)
				demo Draw rectangle: 80, 95, 0, 10
				@myTimer(0.5)
				goto SUITE
			endif
		endwhile
	label SUITE
	demo Erase all
	endif

demo Font size: 24
demo Text: 50, "centre", 95, "half", "Same or different word?"
demo Font size: 18
demo Paint rectangle: "{50,50,50}", 20, 40, 40, 60
demo Text: 30, "centre", 50, "half", "SAME"
demo Paint rectangle: "{50,50,50}", 60, 80, 40, 60
demo Text: 70, "centre", 50, "half", "DIFFERENT"

demo Text: 95, "centre", 95, "half", "'stim'/'nbStrings'" 

	select Table 'stringName$'
	
	sound1$ = Get value... stim STIM1
	vowel1$ = left$("'sound1$'",1)
	sound2$ = Get value... stim STIM2
	vowel2$ = left$("'sound2$'",1)

	goodResponse$ = Get value... stim REPONSE
	
	Read from file... Stimuli\'sound1$'.wav
	soundID1 = selected ("Sound")
	Read from file... Stimuli\'sound2$'.wav
	
	result = 0
	compteErreurs = 0
	spaceBar = 0
	nbRep = 0
	
while result = 0
	nbRep = nbRep + 1

	label SOUND
	item = 'soundID1'
	while item <= 'soundID1' + 1
		selectObject: 'item'
		@myTimer(0.1)
		Play
		item = item + 1		
	endwhile

	stopwatch

	label ERREUR

	demoWaitForInput ()
		if demoClickedIn (20, 40, 40, 60)
			rTime = stopwatch
			response$ = "1"
			demo Draw rectangle: 20, 40, 40, 60
			@myTimer(0.1)
		elsif demoClickedIn (60, 80, 40, 60)
			rTime = stopwatch
			response$ = "2"
			demo Draw rectangle: 60, 80, 40, 60
			@myTimer(0.1)
		elsif demoKey$() = " "
			spaceBar = spaceBar + 1
			goto SOUND
		else
			goto ERREUR
		endif


		if response$ = goodResponse$
			result = 1
			demo Colour... Green
			demo Font size: 24
			demo Text: 50, "centre", 75, "half", "Correct :-)"
		else
			result = 0
			compteErreurs = compteErreurs + 1
			demo Colour... Red
			demo Font size: 24
			demo Text: 50, "centre", 75, "half", "Try again :-("
		endif


		if nbRep = 1
			firstResponse$ = response$
		endif

			demoShow()
			@myTimer(1)
			demo Undo
			demoShow()
			demo Colour... Black
			demo Font size: 18
		
endwhile
demo Erase all
		
		if firstResponse$ = goodResponse$
			result = 1
		else
			result = 0
		endif

allSounds$ = "'sound1$'" + "-" + "'sound2$'" 
appendFileLine: logName$, allSounds$, tab$, goodResponse$, tab$, firstResponse$, tab$, result, tab$, rTime, tab$, compteErreurs, tab$, spaceBar
select all
minus Table 'stringName$'
Remove

totalErreurs = totalErreurs + compteErreurs
endfor

demo Erase all

nbHits = nbStrings - totalErreurs

@theTime
fin = heure
temps = fin - debut
@calcTime(temps)
dTime$ = dT$

appendFileLine: logName$, newline$, "#", "TotalErreurs", "#", totalErreurs, "#", "TempsTotal", "#", dTime$

demo Paint rectangle: "{30, 30, 30}", 40, 60, 50, 80
demo Line width... 4
demo Colour... Grey
demo Draw rectangle: 40, 60, 50, 80
demo Colour... Blue
demo Font size: 20
demo Text: 50,"centre", 75, "half", "Results" 

demo Colour... Black
demo Font size: 14
demo Text: 50, "centre", 70, "half", "Number of stimuli: 'nbStrings'"
demo Text: 50, "centre", 65, "half", "Total Time: 'dTime$' "
demo Text: 50, "centre", 60, "half", "Number of Correct: 'nbHits'"
demo Text: 50, "centre", 55, "half", "Number of Errors: 'totalErreurs'"
demo Font size: 18
demo Text: 50, "centre", 20, "half", "Thanks for participating"


procedure myTimer (duree)
stopwatch
myTime = 0
while myTime < 'duree'
	currentTime = stopwatch
	myTime = myTime + currentTime
endwhile
endproc

procedure theTime
stingTime$ = date$()
h$ = mid$("'stingTime$'", 12, 2)
m$ = mid$("'stingTime$'", 15, 2)
s$ = mid$("'stingTime$'", 18, 2)
h1 = number(h$)*3600
m1 = number(m$)*60
s1 = number(s$)
heure = h1 + m1+ s1
endproc
 
procedure calcTime(temps)
h$ = string$(temps div 3600)
m$ = string$((temps mod 3600) div 60)
s$ = string$((temps mod 3600) mod 60)
	
	if h$ = "0" and m$ = "0"
		dT$ = "'s$'sec"
	elsif h$ = "0"
		dT$ = "'m$'min 's$'sec"
	else	
		dT$ = "'h$'h 'm$'min 's$'sec"
	endif
endproc