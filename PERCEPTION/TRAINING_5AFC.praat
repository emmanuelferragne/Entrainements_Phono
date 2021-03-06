form Choisir l'experience
	comment Choisir l'experience
	optionmenu cond : 2
	option 1
	option 2
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
demo Text: 50, "centre", 80, "half", "In this experiment you will be hearing a series of words. These words can contain one of the 5 vowels in the words below:"
demo Text: 50, "centre", 75, "half", "[\ic] pig – [i:] feet – [\ae] cat – [\vt] cup – [\as:] card"
demo Text: 50, "centre", 70, "half", "Your task is to click a button on the screen to indicate which vowel you think was spoken."
demo Text: 50, "centre", 65, "half", ""
demo Text: 50, "centre", 60, "half", "You can play the word again by pressing the SPACE BAR"
demo Text: 50, "centre", 55, "half", ""
demo Text: 50, "centre", 50, "half", "If your answer is right, Correct :-) will be displayed and the next word will be played."
demo Text: 50, "centre", 45, "half", "If your answer is wrong, Try again :-( will be displayed " 
demo Text: 50, "centre", 40, "half", "and the same word will be re-played before you can give the correct answer."
demo Text: 50, "centre", 30, "half", "The experiment consists of 210 trials."
demo Text: 50, "centre", 25, "half", ""
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

logName$ = "5AFC" + "'cond$'" + "_" + "'myID$'" + ".txt"
appendFileLine: logName$, date$(), newline$, "Sound File", tab$, "Stimulus", tab$, "Vowel", tab$, "FirstResponse", tab$, "Response Time", tab$, "NbErreurs", tab$, "Repetitions"


stimFileName$ = "Liste5AFC_" + "'cond$'" + ".txt"
Read Strings from raw text file... 'stimFileName$'
Randomize
stringName$ = selected$("Strings")
nbStrings = Get number of strings
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

demo Font size: 18
demo Text: 50, "centre", 95, "half", "Choose the best option according to the vowel you hear"
demo Paint rectangle: "{50,50,50}", 20, 40, 55, 75
demo Text: 30, "centre", 65, "half", "[\ic] pig"
demo Paint rectangle: "{50,50,50}", 60, 80, 55, 75
demo Text: 70, "centre", 65, "half", "[i:] feet"

demo Paint rectangle: "{50,50,50}", 15, 35, 15, 35
demo Text: 25, "centre", 25, "half", "[\ae] cat"
demo Paint rectangle: "{50,50,50}", 40, 60, 15, 35
demo Text: 50, "centre", 25, "half", "[\vt] cup"
demo Paint rectangle: "{50,50,50}", 65, 85, 15, 35
demo Text: 75, "centre", 25, "half", "[\as:] card"

demo Text: 95, "centre", 95, "half", "'stim'/'nbStrings'"

	select Strings 'stringName$'
	currentStim$ = Get string... stim
	currentVowel$ = left$("'currentStim$'")
	tiret2 = rindex("'currentStim$'","_")
	currentWord$ = mid$("'currentStim$'",3,'tiret2'-3)
	Read from file... Stimuli\'currentStim$'.wav
	result = 0
	compteErreurs = 0
	spaceBar = 0
	nbRep = 0
	
	while result = 0
	nbRep = nbRep + 1
		
		label SOUND
		stopwatch
		asynchronous Play
		label ERREUR

		demoWaitForInput ()
		if demoClickedIn (60, 80, 55, 75)
			rTime = stopwatch
			response$ = "I"
			demo Draw rectangle: 60, 80, 55, 75
			@myTimer(0.5)
		elsif demoClickedIn (20, 40, 55, 75)
			rTime = stopwatch
			response$ = "i"
			demo Draw rectangle: 20, 40, 55, 75
			@myTimer(0.5)
		elsif demoClickedIn (15, 35, 15, 35)
			rTime = stopwatch
			response$ = "a"
			demo Draw rectangle: 15, 35, 15, 35
			@myTimer(0.5)
		elsif demoClickedIn (65, 85, 15, 35)
			rTime = stopwatch
			response$ = "A"
			demo Draw rectangle: 65, 85, 15, 35
			@myTimer(0.5)
		elsif demoClickedIn (40, 60, 15, 35)
			rTime = stopwatch
			response$ = "v"
			demo Draw rectangle: 40, 60, 15, 35
			@myTimer(0.5)
		elsif demoKey$() = " "
			spaceBar = spaceBar + 1
			goto SOUND
		else
			#Si le sujet clique à côté
			goto ERREUR
		endif


			if response$ = currentVowel$
				result = 1
				demo Colour... Green
				demo Font size: 24
				demo Text: 50, "centre", 90, "half", "Correct :-)"
			else
				result = 0
				compteErreurs = compteErreurs + 1
				demo Colour... Red
				demo Font size: 24
				demo Text: 50, "centre", 90, "half", "Try again :-("
				
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
	
appendFileLine: logName$, currentStim$, tab$, currentWord$, tab$, currentVowel$, tab$, firstResponse$, tab$, rTime, tab$, compteErreurs, tab$, spaceBar
select all
minus Strings 'stringName$'
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
demo Text: 50, "centre", 60, "half", "Number of Corrects: 'nbHits'"
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