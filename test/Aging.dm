#define fyellow "<font color=yellow>"
#define fnavy "<font color=navy>"
#define fblue "<font color=blue>"
#define fteal "<font color=teal>"
#define faqua "<font color=aqua>"
#define fcyan "<font color=cyan>"
#define fgold "<font color=gold>"
#define fend  "</font>"
#define bold "<b>"
#define bend "</b>"
//Save and Load year procs
proc/SaveYear()
	var/savefile/S=new("Year")
	S["Year"]<<Year
proc/LoadYear() if(fexists("Year"))
	var/savefile/S=new("Year")
	S["Year"]>>Year
var/Year=0
mob/var/BirthYear=0
mob/var/LastYear=0 //The last year they were logged on to the server.
mob/var/DeclineMod=1

//Aging system
proc/Years()
	Year+=0.063333333333333333333333333333333
	world<<"[bold][fyellow]It is now month [round((Year-round(Year))*12)] of year [round(Year)][bend][fend]."
	for(var/mob/M) if(M.client&&M.player)
		M.SAge=Year+4-M.BirthYear
		if(!M.dead) M.Age+=Year-M.LastYear
		M.LastYear=Year
		if(M.Age<=M.InclineAge)
			M.Body=M.Age
			M.AgeStatus="Young"
		else if(M.Age>=M.DeclineAge)
			M.AgeStatus="Old"
		else M.AgeStatus="Adult"
		if(M.immortal) M.Body=25
		M.GreyHair()
		sleep(1)
	spawn(18000)
	Years()
mob/var
	light
	dark
	normal
mob/proc/AgeCheck()
	src<<"It is now month [round((Year-round(Year))*12)] of year [round(Year)]"
	SAge=Year+4-BirthYear
	if(!dead) Age+=Year-LastYear
	LastYear=Year
	if(Age>=DeclineAge) AgeStatus="Old"
	else AgeStatus="Adult"
	if(!immortal&&!dead)
		if(Age>=25&&Age<DeclineAge) Body=25
		else if(Age>=DeclineAge&&!dead) Body=25-(Age-DeclineAge)
		if(Body<0.1)
			view(src)<<"[src] dies from old age."
			hairchanges=0
			EnteredHBTC=0
			buudead=1
			Death()
			buudead=0
			mystified=0
			enslaved=0
			Age=4
			Body=4
mob/var/hairchanges=0
mob/proc/GreyHair() if(hair&&Age>=DeclineAge)
	while(hairchanges<round(Age)-round(DeclineAge))
		hairchanges+=1
		HairR+=4
		HairG+=4
		HairB+=4
		overlays-=hair
		hair+=rgb(4,4,4)
		overlays+=hair
		sleep(1)