 form Informations
	comment Choose the session
	optionmenu cond : 3
	option a
	option av
	option i

	comment Choose your gender
	optionmenu sex : 2
	option M
	option F

	comment Enter your login
	sentence myID
endform

programName$ = chooseReadFile$: "Sélectionner le script"

demo Select inner viewport: 0, 100, 0, 100
demo Axes: 0, 100, 0, 100

@theTime
debut = heure


stimFileName$ = "listeStims_" + "'cond$'" + ".txt"
!charge la liste des stims (qui doit s'appeler listeStims.txt)
Read Strings from raw text file... 'stimFileName$'
Randomize
nameStimList$ = selected$("Strings")

!Crée un log sous forme de TableOfReal
Create TableOfReal... 'myID$' 1 4

if sex$ = "F"
	!charge le modèle d'analyse discriminante
	Read from file... femmes.Discriminant
	modelName$ = selected$("Discriminant")
	!charge la table des valeurs moyennes de voyelles
	Read TableOfReal from headerless spreadsheet file... meansFem.txt
	Rename... meanTable
elsif sex$ = "M"
	!charge le modèle d'analyse discriminante
	Read from file... hommes.Discriminant
	modelName$ = selected$("Discriminant")
	!charge la table des valeurs moyennes de voyelles
	Read TableOfReal from headerless spreadsheet file... meansHom.txt
	Rename... meanTable
endif

if cond$ = "a" 
		goto VA
	elsif cond$ = "av"
		goto VAV
	elsif cond$ = "i" 
		goto VI
endif

label VA
	labelbutton1$ = "[\ae] cat"
	labelbutton2$ = "[\vt] cup"
	vowel1$ = "a"
	vowel2$ = "v"
	goto CONSIGNE

label VAV
	labelbutton1$ = "[\as:] card"
	labelbutton2$ = "[\vt] cup"
	vowel1$ = "A"
	vowel2$ = "v"
	goto CONSIGNE

label VI
	labelbutton1$ = "[i:] feet"
	labelbutton2$ = "[\ic] pig"
	vowel1$ = "I"
	vowel2$ = "i"
	goto CONSIGNE

label CONSIGNE
demo Erase all
demo Black
demo Times
demo Font size: 22
!demo Line width... 2
demo Text: 50, "centre", 100, "top", "INSTRUCTIONS"
demo Font size: 16
demo Text: 50, "centre", 90, "half", "In this experiment you will be asked to repeat some English words containing one of the 2 vowels below:"
demo Text: 50, "centre", 85, "half", "'labelbutton1$' - 'labelbutton2$'"
demo Text: 10, "left", 78, "half", "For each word, you must perform 3 steps:"
demo Text: 10, "left", 75, "top", "1. Listen to the word"
demo Font size: 14
demo Text: 15, "left", 70, "half", "This word can be pronounced either by a man or a women."
demo Text: 15, "left", 67, "half", "You can play the word as many times as you want."
demo Text: 15, "left", 64, "half", "The vowel contained in the word will be framed on the top of the screen."
demo Font size: 16
demo Text: 10, "left", 60, "top", "2. Record your word"
demo Font size: 14
demo Colour... blue
demo Text: 15, "left", 55, "half", "This is not an imitation task, you must repeat the word as you would pronounce it."
demo Black
demo Text: 10, "left", 55, "half", ""
demo Font size: 16
demo Text: 10, "left", 50, "half", "3. Compare your pronunciation to a native English pronunciation"
demo Font size: 14
demo Text: 15, "left", 47, "half", "Your pronunciation will be displayed in blue and the target in red. "
demo Text: 15, "left", 44, "half", "The dots represent vowel quality and the bars at the bottom represent vowel length."
demo Text: 10, "left", 5, "half", ""
demo Font size: 16
demo Text: 10, "left", 35, "half", "Your must try to be as close as possible to the target."
demo Text: 10, "left", 30, "half", "You will have 3 attempts for each word, after which you will go to the next word."
demo Text: 10, "left", 5, "half", ""
demo Text: 10, "left", 20, "half", "The task contains 240 words."

demo Text: 40, "centre", 5, "half", "When you've finished reading these instructions, please click on START to begin the experiment." 
demo Paint rectangle: "{60, 60, 60}", 80, 95, 0, 10
demo Text: 87.5,  "centre", 5, "half", "START" 
		
while demoWaitForInput()
	if demoClickedIn(80, 95, 0, 10)
		demo Draw rectangle: 80, 95, 0, 10
		@myTimer(0.5)
		goto DEBUT
	endif
endwhile


label DEBUT
demo Erase all

succeed = 0
failed = 0

succeed1 = 0
succeed2 = 0
failed1 = 0
failed2 = 0

nbItemsTot = 0
!boucle sur chacun des stims
select Strings 'nameStimList$'
nbRowsStimTable = Get number of strings
for stimNum from 1 to nbRowsStimTable

nbItemsTot = nbItemsTot + 1
@theTime
tTime = heure
duree = tTime - debut

#limite la duree de l'entrainement à 1h
if duree > 3600 and nbRowsStimTable - nbItemsTot > 10
	stimNum = nbRowsStimTable
endif

	select Strings 'nameStimList$'
	!nom du stim
	currentStim$ = Get string... 'stimNum'
	currentStim$ = "'currentStim$'" - ".wav"
	!voyelle du stim
	currentVowel$ = left$("'currentStim$'",1)
	!va chercher les valeurs moyennes du modèle dans la table des moyennes
	select TableOfReal meanTable
	Extract rows where label: "is equal to", "'currentVowel$'"
	
	modelF1 = Get value... 1 1
	modelF2 = Get value... 1 2
	modelF3 = Get value... 1 3
	modelDur = Get value... 1 4

	#initialisation des variables critères d'arrêt
	#distance euclidienne en Hz dans F1/F2
	distAuModele = 500
	#pourcentage de la durée de la voyelle du modèle
	distDur = 400
	#somme des entropies des probabilités postérieures de l'analyse discriminante
	myEntropy = - 10
	#booléen qui marque si la classification de la voyelle produite est correcte
	myClassifIsOk = 0

	#chargement du fichier son
	Read from file... Stimuli\'currentStim$'.wav
	
	nbEssai = 0
	
	#tant que ces critères ne sont pas satisfaits, on continue de boucler sur le même stimulus et qu'on n'a pas essayé 5 fois
	while (myClassifIsOk = 0 or distAuModele > 145) and nbEssai < 2
	nbEssai = nbEssai + 1

	label windowListenAndListen
		
		demo Erase all
		demo Select inner viewport: 0, 100, 0, 100
		demo Black
		demo Text: 95, "centre", 95, "half", "'stimNum'/'nbRowsStimTable'"
		demo 24
		demo Colour... red
		demo Line width... 2
		demo Axes: 0, 100, 0, 100
		if currentVowel$ = "I"
			demo Draw rectangle: 28, 37, 82, 93
			myTag$ = "'labelbutton1$'"
		elsif currentVowel$ = "i"
			demo Draw rectangle: 63, 72, 82, 93
			myTag$ = "'labelbutton2$'"
		elsif currentVowel$ = "a"
			demo Draw rectangle: 28, 37, 82, 93
			myTag$ = "'labelbutton1$'"
		elsif currentVowel$ = "v"
			demo Draw rectangle: 63, 72, 82, 93
			myTag$ = "'labelbutton2$'"
		else
			demo Draw rectangle: 28, 37, 82, 93
			myTag$ = "'labelbutton1$'"
		endif
		demo Colour... black
		demo Line width... 2
			
		!demo Paint rectangle: "{0,0,0}", 25, 40, 80, 95
		demo Text: 32.5, "centre", 87.5, "half", labelbutton1$
		!demo Paint rectangle: "{0,0,0}", 60, 75, 80, 95
		demo Text: 67.5, "centre", 87.5, "half", labelbutton2$
		
		demo Paint rectangle: "grey", 25, 75, 50, 70
		demo Text: 50, "centre", 60, "half", "Click here to listen"
		demo Paint rectangle: "grey", 25, 75, 20, 40
		demo Colour... {96,96,96}
		demo Text: 50, "centre", 30, "half", "Click to start recording"

		
		#on attend que l'utilisateur appuie sur le bouton enregistrement
		
		listenOk = 0
		moveToRecord = 0
		while moveToRecord = 0
			demoWaitForInput ( )
			if demoClickedIn (25, 75, 50, 70) and listenOk = 0 or demoKey$ () = " " and listenOk = 0
				@listenToSound ()
				demo Undo
				demo Colour... black
				demo Text: 50, "centre", 30, "half", "Click to start recording"
				listenOk = 1
			elsif demoClickedIn (25, 75, 50, 70) and listenOk = 1 or demoKey$ () = " " and listenOk = 1
				@listenToSound ()
			elsif demoClickedIn (25, 75, 20, 40) and listenOk = 1 or demoKey$ () = "v" and listenOk = 1
				moveToRecord = 1
			endif
		endwhile
		#if demoClickedIn (25, 75, 20, 40)
			demo Colour... red
			demo Text: 50, "centre", 42, "half", "Recording..."
			demo Colour... black

			#l'enregistrement est lancé pour un temps fixe (dernier argument de la fonction)
			Record Sound (fixed time)... "Microphone" 0.1 0.5 44100 2
			Rename... monSon

			#analyse du pitch pour déterminer grosso modo les limites temporelles de la voyelle
			#on se fiche de la justesse de l'estimation de la fréquence, d'où la fourchette 75-400
			#du moment qu'on détecte la périodicité
			To Pitch... 0 75 400
			To PointProcess
			To TextGrid (vuv)... 0.02 0.01
			nbInter = Get number of intervals... 1
			goodDuration = 0.000001
			ok = 0
			#recherche de l'intervalle voisé le plus long
			for i from 1 to nbInter
				currentLabel$ = Get label of interval... 1 i
				if currentLabel$ = "V"
					#teste s'il y a au moins une portion voisée
					ok = 1
					currentStart = Get starting point... 1 i
					currentEnd = Get end point... 1 i
					currentDuration = currentEnd - currentStart
					if currentDuration > goodDuration
						goodDuration = currentDuration
						goodStart = currentStart
						goodEnd = currentEnd
					endif
				endif
			endfor
			#impose une fourchette pour le pitch (mon test sur l'existence de voisement ne suffit pas)
			#select Pitch monSon
			#meanPitch  = Get mean... goodStart goodEnd Hertz
			#if meanPitch < 10000
				#ok = 0
			#endif

			#message d'erreur si aucun intervalle voisé n'a pu être repéré
			
			if ok = 0
				demo Erase all
				demo Text: 50, "centre", 50, "half", "Failed to record. Please try again; click anywhere"
				demoWaitForInput ()
				goto windowListenAndListen
			else

				select Sound monSon
				Extract part... goodStart goodEnd "rectangular" 1 no
				!l'analyse en formants sera faite à la moitié de la partie voisée
				analysisTime = goodDuration/2
	
				!calcule les formants
				To Formant (burg): 0, 5, 5000, 0.025, 50
				myF1 = Get value at time: 1, 'analysisTime', "Hertz", "Linear"
				myF2 = Get value at time: 2, 'analysisTime', "Hertz", "Linear"
				myF3 = Get value at time: 3, 'analysisTime', "Hertz", "Linear"

				!crée la table pour l'analyse discriminante
				Create TableOfReal... currentTable 1 4
				Set row label (index)... 1 'currentVowel$'
				Set column label (index)... 1 F1
				Set column label (index)... 2 F2
				Set column label (index)... 3 F3
				Set column label (index)... 4 Duree

				Set value... 1 1 'myF1'
				Set value... 1 2 'myF2'
				Set value... 1 3 'myF3'
				Set value... 1 4 'goodDuration'*1000

				!effectue la classification
				plus Discriminant 'modelName$'
				To ClassificationTable... yes yes
				tableClassif$ = selected$("ClassificationTable")

				!repère si la classification est bonne
				To Confusion
				myClassifIsOk= Get fraction correct

				!if "'myClassif$'" = "'currentVowel$'"
					!myClassifIsOk = 1
				!else
					!myClassifIsOk = 0
				!endif

				!calcul de l'entropie
				!myEntropy = 0
				select ClassificationTable 'tableClassif$'

					
				!calcule la distance au modèle en Hz
				distAuModele = sqrt((myF1-modelF1)^2 + (myF2-modelF2)^2)

				!calcule la distance au modèle de durée en pourcentage
				distDur = goodDuration * 1000/modelDur * 100
				absDur = abs(distDur - 100)

				demo Erase all
				demo 14
				demo Axes: 'modelF2'+500, 'modelF2'-500, 'modelF1'+250, 'modelF1'-250
				demo Paint circle... red 'modelF2' 'modelF1' 5
				demo Colour... {96,96,96}
				demo Draw circle... 'modelF2' 'modelF1' 145
				demo Black
				demo Paint circle... blue 'myF2' 'myF1' 10
				demo Axes: 0, 100, 0, 100
				demo Text: 3, "left", 90, "half", "VOWEL REALISATION INDICATOR"
				!demo Paint rectangle: 0.9, 2, 78, 3, 17
				demo Text: 3, "left", 15, "half", "VOWEL LENGTH INDICATOR"
				demo Paint rectangle: "red", 7, 50, 5, 7
				demo Paint rectangle: "blue", 7, distDur/2, 10, 12
				demo Text: 3, "left", 5, "bottom", "Target"
				demo Text: 3, "left", 10, "bottom", "Yours" 
				demo Paint rectangle: "{60, 60, 60}", 80, 95, 7, 17
				demo Text: 87.5,  "centre", 12, "half", "NEXT WORD"
				demo Text: 50, "centre", 47, "top", "'myTag$'"

				if (myClassifIsOk = 1 and distAuModele < 145) or (myClassifIsOk = 1 and distAuModele = 145)
					demo Colour... Green
					demo Text: 87.5, "centre", 20, "half", "CORRECT"
					succeed = succeed + 1
					if "'currentVowel$'" = "'vowel1$'"
						succeed1 = succeed1 + 1
					elsif "'currentVowel$'" = "'vowel2$'"
						succeed2 = succeed2 + 1
					endif


				elsif  (myClassifIsOk = 0 or distAuModele > 145) and nbEssai < 2
					demo Colour... Red
					demo Text: 87.5, "centre", 20, "half", "Please Try again"
				elsif (myClassifIsOk = 0 or distAuModele > 145) and nbEssai = 2
					demo Colour... Red
					demo Text: 87.5, "centre", 20, "half", "INCORRECT, go the next word." 
					failed = failed + 1
					if "'currentVowel$'" = "'vowel1$'"
						failed1 = failed1 + 1
					elsif "'currentVowel$'" = "'vowel2$'"
						failed2 = failed2 + 1
					endif
				endif
				
				testWait = 0
				while testWait = 0
					demoWaitForInput ()
					if demoClickedIn (80, 95, 7, 17) or demoKey$ () = "n"
						testWait = 1
					endif
				endwhile
			endif
			select TableOfReal 'myID$'
			plus TableOfReal currentTable
			Append
			Rename... 'myID$'
			select all
			minus Strings 'nameStimList$'
			minus TableOfReal meanTable
			minus Discriminant 'modelName$'
			minus Sound 'currentStim$'
			minus TableOfReal 'myID$'
			Remove
			!demoWaitForInput ()
			demo Erase all
		#endif
	
	
endwhile
endfor
select TableOfReal 'myID$'
logName$ = "TRAINING" + "'cond$'" + "_" + "'myID$'" + ".txt"
Save as headerless spreadsheet file... 'logName$'

select Strings 'nameStimList$'
stimOrderName$ = "List" +"'cond$'"+ "_" + "'myID$'" + ".txt"
Save as raw text file... 'stimOrderName$'

@theTime
fin = heure
temps = fin - debut
@calcTime(temps)
dTime$ = dT$

appendFileLine: logName$, newline$, "#", date$(), "#", programName$, "#", myID$, newline$, "TempsTotal", "#", dTime$, "#", "Succeeds", "#", succeed, "#", "Failed", "#", failed
appendFileLine: logName$, newline$, "vowel", tab$,"'vowel1$'", tab$, "'vowel2$'" 
appendFileLine: logName$, newline$, "succeeds", tab$, succeed1, tab$, succeed2
appendFileLine: logName$, newline$, "failed", tab$, failed1, tab$, failed2
appendFileLine: logName$, newline$, "nbStimTot", tab$, nbItemsTot

pc1 = round(succeed1/(succeed1 + failed1)*100)
pc2 = round(succeed2/(succeed2 + failed2)*100)

demo Paint rectangle: "{30, 30, 30}", 30, 70, 30, 80
demo Line width... 4
demo Colour... Grey
demo Draw rectangle: 30, 70, 30, 80
demo Colour... Blue
demo Font size: 20
demo Text: 50,"centre", 75, "half", "Results" 


demo Colour... Black
demo Font size: 14
demo Text: 50, "centre", 70, "half", "Number of stimuli: 'nbItemsTot'"
demo Text: 50, "centre", 65, "half", "Total Time: 'dTime$'"
demo Text: 50, "centre", 60, "half", "Number of Succeeds: 'succeed'"
demo Text: 50, "centre", 55, "half", "Number of Failed: 'failed'"
demo Text: 50, "centre", 50, "half", "Pourcent succeeds regarding the vowel:"
demo Text: 50, "centre", 48, "half", "'labelbutton1$': 'pc1'" 
demo Text: 50, "centre", 45, "half", "'labelbutton2$': 'pc2'" 
demo Font size: 18
demo Text: 50, "centre", 20, "half", "Thanks for participating"



procedure listenToSound ()
		select Sound 'currentStim$'
		Play
		
endproc

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