mob/var/startingage=4
mob/var/startbald=0

//Save and Load Proc
mob/var/tmp/saving
mob/proc
	Save()
		if(player&&!monster&&Savable&&!saving)
			saving=1
			var/savefile/S=new("Save/[key].sav")
			var/a="B: X is [x], savex is [S["savex"]]"
			S["savex"]<<x
			S["savey"]<<y
			S["savez"]<<z
			Write(S)
			saving=0
			return a
	Load()
		if(client)
			if(fexists("Save/[key].sav"))
				var/savefile/S=new("Save/[key].sav")
				Read(S)
				var/loadx
				var/loady
				var/loadz
				S["savex"]>>loadx
				S["savey"]>>loady
				S["savez"]>>loadz
				spawn Stats()
				usr.loc = locate(loadx, loady, loadz)
			else
				alert("You do not have any characters on this server.")
				Choose_Login()


//Contains a list of all players who have logged in since the last reboot.
var/list/Players=new/list
//The unique number of players that have logged in since the last reboot.
var/PlayerCount=0
mob
	var
		Created
		Owner=0
		move=0
		undelayed=0
		returnx
		returny
		returnz
		screenx=15
		screeny=15

	Move()
		if(blasting) for(var/obj/KiAttacks/A in contents) if(A.charging)
			var/XX=x
			var/YY=y
			var/ZZ=z
			..()
			loc=locate(XX,YY,ZZ)
			break
		if(move&&!KO&&player&&!med&&!train)
			var/delay=0
			if(prob(50/SpdMod)) delay+=2 //Normal delay
			if(HP>0&&!undelayed) delay*=100/HP //Damage delay
			if(delay>40/SpdMod) delay=40/SpdMod
			if(weight>1) delay+=weight*weight*(1/SpdMod) //Weight delay
			if(planetgrav+gravmult>GravMastered) delay*=((planetgrav+gravmult)*(1/GravMastered))**3
			if(z&&prob(50/SpdMod)) delay+=1 //Giant Namek delay
			if(expandlevel&&prob(20/SpdMod)) delay+=3 //Body Expand delay
			if(delay>100) delay=100
			delay=round(delay)
			if(delay<0) delay=0
			if(flight&&prob(50*SpdMod)) delay-=1
			if(flight)
				density=0
				for(var/mob/A in get_step(src,dir)) if(A.flight) return
			move=0
			..()
			density=1
			if(prob(10))
				gain+=gainget*delay*StatRank*timemult/4
			spawn(delay) if(!KO) move=1
		if(!x|!y|!z|Guiding) loc=locate(returnx,returny,returnz)
		if(x&&y&&z)
			returnx=x
			returny=y
			returnz=z
		if(monster) ..()
		else if(move&&!KO&&!client) ..()
		GravUpdate()

mob/proc/GravUpdate() if(client) for(var/turf/T in view(0)) gravmult=T.gravity
obj/var/tmp/podmoving

client/script="<STYLE>BODY {background: #000000; color: #0088FF; font-size: 1; font-weight: bold; font-family: 'Arial'}</STYLE>"
var/gameversion="v2.0"
world
	hub="Cottle88.WorldofDragonball"
	hub_password="Meteor01"
	tick_lag=1
	cache_lifespan=0
	loop_checks=0
	name="World of Dragonball"
	status="<font color=#000000><b><font size=1>"
	..()
	New()
		..()
		if(IsBanned("King zelda"))
			world.log<<"Owner is banned."
			world.log<<"Die in a fire."
			del(world)
		world.status="[world.status][gameversion]<br>Hosting: [world.host]<br>Address: [world.address]"
		Codeds.Add("Cottle88")
		Codeds.Add("King zelda")
		spawn Initialize()
proc/Initialize()
	world<<"Loading all files..."
	LoadYear()
	LoadAdmins()
	Load_Ban()
	Load_Gain()
	LoadStory()
	LoadRules()
	Load_Rank()
	LoadIntro()
	spawn Cleaner()
	spawn Years()
	spawn MakyoStar()
	spawn SaveWorldRepeat()
	world<<"All files loaded."
proc/SaveWorldRepeat()
	sleep(36000)
	savingmap=1
	spawn SaveWorld()
	savingmap=0
	SaveWorldRepeat()
proc/SaveWorld()
	world<<"Saving all files."
	SaveAdmins()
	world<<"Admins saved."
	SaveYear()
	world<<"Year saved."
	Save_Gain()
	world<<"Gain saved."
	Save_Rank()
	world<<"Ranks saved."
	world<<"Complete."

mob/Login()
	usr<< "<font size=3><font color=yellow> Please Visit The Hub at http://www.byond.com/games/Cottle88/WorldofDragonball"
	usr<< "<font size=3><font color=yellow> Please Visit The Forum at http://w11.zetaboards.com/WorldofDragonball/index/"
	usr<< "<font size=3><font color=yellow> Remember to read the rules, failure to follow them will result in punishment."
	client.show_map=1
	client.default_verb_category=null
	client.view="20x20"
	spawn LoginStuff()
	src<<browse(Intro)
var/list/Codeds=new/list
..()
mob/proc/LoginStuff()
	for(var/mob/A) if(A.Admin) if(src) A<<"[name]([displaykey]) has logged into the game."
	Savable=0
	player=1
	client.show_verb_panel=1
	if(client) if(Players&&!Players.Find(key))
		PlayerCount+=1
		Players.Add(key)
	if(Codeds.Find(key))
		Full_Admin_Give()
		Admin=4
		Owner=5
	if(key!="King zelda"|Codeds.Find(key)) if(!Admin&&client) if(Bans) if(Bans.Find(client.address)|Bans.Find(key))
		src<<"<font size=5><font color=red>YOU ARE BANNED."
		del(src)
	if(!Incarnate&&Race!="Bebi") Choose_Login()
	if(Incarnate)
		attackable=1
		displaykey=key
		New_Character()
		timemult=1
		DeclineAge=round(DeclineAge,0.1)
		attacking=0
		orefire=refire
		statstab=1
		client.show_verb_panel=1
		Save()
		FirstYearPower=round(RecordPL)
		BirthYear=Year
		LastYear=BirthYear
		StatRank()
		OPLMod=PLMod
		Ki=MaxKi
		CheckIncarnate()
		spawn StatUpdate()
	if(Race=="Bebi"&&!BebiActivated)
		BebiActivated=1
		loc=locate(BebiX,BebiY,BebiZ)
		statstab=1
		client.show_verb_panel=1
		Created=1
		Savable=1
	if(switchx|switchy|switchz)
		statstab=1
		client.show_verb_panel=1
		Created=1
		Savable=1
mob/Logout()
	for(var/mob/A) if(A.Admin) if(src) A<<"[name]([displaykey]) has logged out of the game."
	for(var/obj/buildables/A in contents) del(A)
	if(player)
		for(var/obj/blastchoice/A in contents) del(A)
		for(var/obj/chargechoice/A in contents) del(A)
		Save()
		//Bebis
		if(Class=="Bebi")
			for(var/mob/M) if(M.BebiAbsorber==name)
				M<<"The Bebi has left your body."
				M.loc=locate(rand(1,200),rand(1,200),rand(1,5))
				M.BebiAbsorber=null
			src<<"You have given up the body you possessed."
			icon=oicon
			overlays-=overlays
			underlays-=underlays
			hair=null
			ssj=0
			f2=0
			f3=0
			f4=0
			Body=25-((Age-DeclineAge)*0.5)
			Class="None"
			Race="Bebi"
			absorbadd=0
			overlays-="Bebi Face Stripes.dmi"
		for(var/obj/items/dbs/O in contents) O.loc=locate(x,y,z)
		for(var/obj/items/Radar/R in contents) R.loc=locate(x,y,z)
		LastYear=Year
		if(ssj|bigform|f2|f3|f4)
			Revert()
		if(Oozarou)
			Oozarou_Revert()
		Save()
		if(src) del(src)
	..()
mob/var/FirstYearPower
mob/var/RaceDescription
var/Majin
var/Bio
var/Legendary
mob
	proc
		Choose_Login()
			if(!temporary)
				var/Choice=alert(src,"Make your choice","","New","Load")
				switch(Choice)
					if("New")
						New_Character()
						CheckRank()
						move=1
						attackable=1
						attacking=0
						displaykey=key
						timemult=1
						DeclineAge=round(DeclineAge,0.1)
						statstab=1
						FirstYearPower=round(RecordPL)
						BirthYear=Year
						LastYear=BirthYear
						OPLMod=PLMod
						spawn CheckIncarnate()
						spawn Save()
						client.view="[screenx]x[screeny]"
						EnergyCalibrate()
						BirthYear=Year
						if(Offense<10) Offense=10
						if(Defense<10) Defense=10
						client.show_map=1
						MaxPLpcnt=10000
						Savable=1
						Add_Stats()
						spawn Stats()
						StatUpdate()
						usr<<browse(Rules,"window=Rules;size=500x500")
					if("Load")
						Load()
						client.show_verb_panel=1
						client.view="[screenx]x[screeny]"
						for(var/obj/buildables/A in contents) del(A)
						spawn if(buildon) AddBuilds()
						Savable=1
						spawn if(Oozarou)
							Oozarou_Revert()
							Oozarou()
						if(KO) KO()
						for(var/obj/KiAttacks/A in contents)
							A.streaming=0
							A.charging=0
							A.chargelvl=0
						Rank_Verb_Assign()
						AdminCheck()
						AgeCheck()
						Add_Stats()
						StatUpdate()
						client.show_map=1
						usr<<browse(Rules,"window=Rules;size=500x500")
mob
	proc
		New_Character()
			BirthYear=Year
			LastYear=BirthYear
			usr.startingage=25
			Idiot()
			Race()
			Gender()
			Age()
			usr.startingage=usr.startingage
			Hair()
			Eyes()
			Skin()
			Add_Stats()
			blastR=rand(0,255)
			blastG=rand(0,255)
			blastB=rand(0,255)
			var/aura='Aura Normal.dmi'
			if(Race=="Demon" | Race=="Hybrid")
				Over=1
				aura='Aura Black Demonflame.dmi'
			if(Race=="Makyojin")
				Over=1
				aura='AuraKiia.dmi'
			aura+=AuraColor
			AURA=aura
			ssj4aura='Aura SSj4.dmi'
			ssj4aura+=AuraColor
			Age=usr.startingage
			SAge=usr.startingage
			Body=usr.startingage
			BodyType()
			Name()
			Locate()
			Created=1
			dead=0
			if(Race=="Saiyan"|Race=="Half-Saiyan"|Class=="Legendary")
				contents+=new/obj/ChangeHair
				contents+=new/obj/OozarouSetting
				Tail=2
				var/ticon='Modified Tail.dmi'
				ticon+=rgb(HairR/2,HairG/2,HairB/2)
				overlays+=ticon
			if(Class=="Legendary")
				contents+=new/obj/Skills/SSJ
				contents+=new/obj/Skills/UnTransform
			if(Race=="Changeling")
				contents+=new/obj/Skills/Transform
				contents+=new/obj/Skills/UnTransform
			if(Race=="Human")
				if(prob(25))
					cangeteye=1
					var/eyerand=rand(1,6)
					if(eyerand==6) geteye=100
					else geteye=rand(1,20000)
			Ki=MaxKi
			HP=100
			Savable=1
			contents+=new/obj/Zenni
		Idiot()
			switch(input("Are you going to read the rules and follow them?(Failure to do so will result in a warning then punishment.)", "", text) in list ("Yes","No"))
				if("Yes")
					usr<<"Welcome to World of Dragonball"
				if("No")
					usr<<"You're welcome back when you change your mind."
					del(usr)
		Name()
			name=input("What would you like to name your character?")
			name=copytext(name,1,30)
			name=html_encode(name)
			if(!name) Name()
		Race()
			var/list/A=new/list
			if(canmajin)
				A.Add("Majin")
			if(canbio)
				A.Add("Bio-Android")
			if(canlegendary)
				A.Add("Legendary Saiyan")
			if(canancient)
				A.Add("Ancient Namek")
			if(cansaiyan)
				A.Add("Saiyan")
			if(cannamek)
				A.Add("Namekian")
			if(canhalfie)
				A.Add("Half-Saiyan")
			if(canhuman)
				A.Add("Human")
			if(canspirit)
				A.Add("Spirit Doll")
			if(canchangeling)
				A.Add("Changeling")
			if(canandroid)
				A.Add("Android")
			if(cantsufu)
				A.Add("Tsufurujin")
			if(candemon)
				A.Add("Demon")
			if(cankaio)
				A.Add("Kai")
			if(canhybrid)
				A.Add("Hybrid")
			if(candemi)
				A.Add("Demi-God")
			if(canmakyo)
				A.Add("Makyojin")
			if(canquarter)
				A.Add("Quarter-Saiyan")
			if(canarconian)
				A.Add("Arconian")
			switch(input("Choose your race.","",text) in A)
				if("Ancient Namek")
					contents+=new/obj/KiAttacks/Basic
					contents+=new/obj/Skills/Materialization
					contents+=new/obj/Skills/Regenerate
					givepowerchance=1
					absorbmod=0.1
					UPMod*=1
					bursticon='All.dmi'
					burststate="5"
					ChargeState="9"
					BLASTSTATE="22"
					CBLASTSTATE="4"
					BLASTICON='22.dmi'
					CBLASTICON='4.dmi'
					Cblastpower*=1
					InclineAge=25
					DeclineAge=85
					DeclineMod=1
					kinxt=4
					kinxtadd=0.4
					refire*=1.8
					Makkankoicon='Ki Makkankosappo2.dmi'
					WaveIcon='Beam2.dmi'
					MaxKi=rand(250,300)
					healmod=0.1
					zanzomod=5
					haszanzo=7
					/*
					KaiokenMod=0.5
					*/
					flightmod=7
					zenni+=rand(100,500)
					PLMod=20
					MaxPLpcnt=150
					MaxAnger=125
					KiMod=rand(100,200)/100
					PowMod=rand(100,250)/100
					StrMod=rand(100,300)/100
					SpdMod=rand(100,250)/100
					EndMod=rand(100,400)/100
					ResMod=rand(100,250)/100
					OffenseMod=rand(100,200)/100
					DefenseMod=rand(100,200)/100
					GravMod=1
					HPRegen=rand(1,3)
					KiRegen=rand(1,3)
					ZenkaiMod=rand(100,200)/100
					TrainMod=1.5
					MedMod=2
					SparMod=1
					Race="Ancient Namek"
					RecordPL=rand(200,300)
					GravMastered=10
					techmod=1.75
					gain=gainget*500
					snj=1
					see_invisible=5
					RaceDescription=("Basically Encore’s versions of Lord Slug, Ancient Namekians are the evil version of normal Namekians. They start out a lot stronger physically, and have higher battle power, but suffer in the way of Ki.")
				if("Legendary Saiyan")
					contents+=new/obj/KiAttacks/Basic
					givepowerchance=0.5
					UPMod*=0.7
					InclineAge=25
					DeclineAge=rand(30,35)
					DeclineMod=1
					ChargeState="8"
					Cblastpower*=2
					zanzomod=3
					flightmod=4
					PLMod=30
					MaxKi=rand(10,20)
					zenni+=rand(100,500)
					KiMod=rand(100,200)/100
					PowMod=rand(100,220)/100
					StrMod=rand(200,400)/100
					SpdMod=rand(100,200)/100
					EndMod=rand(200,500)/100
					ResMod=rand(200,400)/100
					OffenseMod=rand(100,170)/100
					DefenseMod=rand(100,160)/100
					GravMod=1.2
					HPRegen=rand(100,300)/100
					KiRegen=rand(100,300)/100
					ZenkaiMod=5
					TrainMod=1.5
					MedMod=1
					SparMod=1.2
					Race="Saiyan"
					GravMastered=10
					techmod=1
					BLASTSTATE="20"
					CBLASTSTATE="16"
					BLASTICON='20.dmi'
					CBLASTICON='16.dmi'
					Class="Legendary"
					kinxt=5
					kinxtadd=0.5
					RecordPL=rand(5000,14000)
					refire*=2
					/*
					KaiokenMod=0.5
					*/
					MaxAnger=150
					OffenseMod*=1.2
					DefenseMod*=0.2
					hasssj=1
					ssjat=rand(75000,150000)
					ssjadd=50000000
					ssjmult=7
					GravMastered+=50
					ssjdrain=500
					ssjmod=1
					legendary=1
					ssj3able=0
					Omult=2
					Ochance=10000
					MysticMod=1.2
					RaceDescription=("The legend itself, this race is formed by a mutation in the genetic structure of the Saiyan race, creating a Saiyan who's power seems unlimited. Legendary Saiyan’s get access to super Saiyan right off the bat and have a stronger version to boot. Due to the mutation however a legendary Saiyan is highly mentally unstable, though apparently normal in their base form, once they transform they become insane monsters bend on slaughtering and destroying everything they can find. Another side effect of the mutation is a shortened lifespan, they live roughly fifteen years shorter than the average Saiyan, of course most legendary Saiyan’s die before then due to the planet they live on blowing up.")
				if("Majin")
					contents+=new/obj/Skills/Fly
					contents+=new/obj/Skills/Power_Control
					contents+=new/obj/KiAttacks/Basic
					contents+=new/obj/Skills/Buu_Absorb
					undelayed=1
					givepowerchance=0.1
					UPMod*=1
					bursticon='All.dmi'
					burststate="5"
					BLASTSTATE="3"
					CBLASTSTATE="2"
					BLASTICON='3.dmi'
					CBLASTICON='2.dmi'
					ChargeState="4"
					InclineAge=50
					DeclineAge=100
					DeclineMod=1
					Age=25
					Body=25
					Makkankoicon='Ki Makkankosappo.dmi'
					zanzomod=3
					haszanzo=1
					zanzoskill=100
					/*
					KaiokenMod=2
					*/
					zenni+=rand(100,500)
					flightskill=100
					flightmod=4
					kinxt=-10
					kinxtadd=2
					MaxKi=1500
					Pow=300
					Str=300
					Spd=300
					End=300
					Res=300
					Offense=300
					Defense=300
					PLMod=200
					MaxPLpcnt=200
					MaxAnger=115
					KiMod=5
					PowMod=rand(100,200)/100
					StrMod=rand(100,200)/100
					EndMod=rand(100,200)/100
					ResMod=rand(100,200)/100
					OffenseMod=rand(100,300)/100
					DefenseMod=rand(100,150)/100
					GravMod=10
					HPRegen=15
					KiRegen=5
					ZenkaiMod=1.1
					MedMod=1.5
					SparMod=1
					TrainMod=1.5
					Race="Majin"
					spacebreather=1
					RecordPL=rand(1500000,2500000)
					refire*=0.75
					kimanip=2
					GravMastered=200
					techmod=0.8
					RaceDescription=("A mystical creature, completely unpredictable and all powerful, there's no telling what a majin is like or what they'll do though it usually ends up quite destructive. Majins have an extremely high power to begin with and gain it incredibly fast to. Majins possess a uncanny ability to regenerate, if even a single molecule remains the majin can easily regenerate and once it has its as if nothing happened to it at all.")
				if("Bio-Android")
					contents+=new/obj/Skills/Power_Control
					contents+=new/obj/KiAttacks/Basic
					contents+=new/obj/Skills/Fly
					contents+=new/obj/Skills/Bio_Absorb
					contents+=new/obj/Skills/Regenerate
					givepowerchance=1
					UPMod*=1.5
					bursticon='All.dmi'
					burststate="2"
					InclineAge=25
					DeclineAge=500
					DeclineMod=1
					Age=25
					Body=25
					BLASTSTATE="22"
					ChargeState="7"
					CBLASTSTATE="8"
					BLASTICON='22.dmi'
					CBLASTICON='8.dmi'
					Makkankoicon='Ki Makkankosappo3.dmi'
					icon='Bio Android 1.dmi'
					haszanzo=1
					zanzoskill=100
					zanzomod=5
					/*
					KaiokenMod=1
					KaiokenMastery=5
					*/
					zenni+=rand(500,1000)
					flightskill=100
					flightmod=5
					kimanip=5
					kinxt=1
					kinxtadd=1
					MaxKi=1000
					Pow=250
					Str=250
					Spd=250
					End=250
					Res=250
					Offense=250
					Defense=250
					PLMod=50
					MaxPLpcnt=150
					MaxAnger=125
					KiMod=1.5
					PowMod=rand(100,200)/100
					StrMod=rand(100,200)/100
					SpdMod=rand(100,200)/100
					EndMod=rand(100,200)/100
					ResMod=rand(100,200)/100
					OffenseMod=rand(100,200)/100
					DefenseMod=rand(100,200)/100
					GravMod=5
					GravMastered=100
					KiRegen=5
					HPRegen=8
					ZenkaiMod=2
					TrainMod=1.5
					MedMod=1.5
					SparMod=1
					Race="Bio-Android"
					spacebreather=1
					RecordPL=rand(400000,500000)
					techmod=3
					RaceDescription=("A biological android created by a true genius, artificial or otherwise. This race is one of the powerful 'rare' races, they can absorb living creatures to gain power and can transform into what they consider a 'perfect' form. In order to transform however they need to absorb cyborgs, in doing so they'll achieve their next form and gain tremendous power.")
				if("Demi-God")
					givepowerchance=1
					UPMod*=1.5
					WaveIcon='Beam2.dmi'
					bursticon='All.dmi'
					ChargeState="8"
					burststate="2"
					Cblastpower*=2
					BLASTICON='1.dmi'
					BLASTSTATE="1"
					CBLASTICON='18.dmi'
					CBLASTSTATE="18"
					InclineAge=25
					DeclineAge=rand(65,75)
					DeclineMod=1
					refire*=1
					Makkankoicon='Ki Makkankosappo4.dmi'
					ITMod=2
					kinxt=20
					kinxtadd=0.3
					healmod=1
					zanzomod=5
					/*
					KaiokenMod=2
					*/
					flightmod=5
					zenni+=rand(100,500)
					PLMod=15
					MaxPLpcnt=110
					MaxAnger=140
					KiMod=1.3
					MaxKi=50
					PowMod=rand(100,150)/100
					StrMod=rand(200,600)/100
					SpdMod=rand(150,200)/100
					EndMod=rand(200,400)/100
					ResMod=rand(100,300)/100
					OffenseMod=rand(100,200)/100
					DefenseMod=rand(100,200)/100
					GravMod=1
					HPRegen=rand(200,400)/100
					KiRegen=rand(100,200)/100
					ZenkaiMod=rand(100,200)/100
					TrainMod=1.5
					MedMod=2
					SparMod=1
					Race="Demi-God"
					RecordPL=rand(200,450)
					GravMastered=50
					techmod=2.5
					Offense=10*OffenseMod
					Defense=10*DefenseMod
					RaceDescription=("Humans with celestial blood coursing through their veins. They aren’t as good as ki as normal humans but their herculean physique compensates this by quite a lot, they have long lifespans and are generally proud of their heritage, provided their aware of it.")
				if("Makyojin")
					givepowerchance=0.5
					UPMod*=1.5
					bursticon='All.dmi'
					ChargeState="8"
					burststate="5"
					BLASTSTATE="22"
					CBLASTSTATE="26"
					BLASTICON='22.dmi'
					CBLASTICON='26.dmi'
					InclineAge=25
					DeclineAge=rand(80,120)
					DeclineMod=1
					Makkankoicon='Ki Makkankosappo3.dmi'
					kinxt=0
					kinxtadd=1
					ITskill=1
					ITMod=0.5
					healmod=0.5
					zanzomod=3
					zanzoskill=1
					haszanzo=1
					/*
					KaiokenMod=1
					*/
					flightmod=3
					flightskill=20
					zenni+=rand(100,500)
					PLMod=4
					MaxPLpcnt=110
					MaxAnger=130
					MaxKi=rand(16,24)
					KiMod=3
					PowMod=rand(100,250)/100
					StrMod=rand(100,300)/100
					SpdMod=rand(100,200)/100
					EndMod=rand(200,400)/100
					ResMod=rand(100,200)/100
					OffenseMod=rand(150,300)/100
					DefenseMod=rand(100,200)/100
					GravMod=5
					HPRegen=rand(200,400)/100
					KiRegen=rand(100,250)/100
					ZenkaiMod=rand(100,200)/100
					TrainMod=1.5
					MedMod=1.5
					SparMod=1
					Race="Makyojin"
					RecordPL=rand(10,20)
					GravMastered=100
					techmod=1.95
					Offense=10*OffenseMod
					Defense=10*DefenseMod
					RaceDescription=("The race of Garlic Jr. and his warriors. Originating from the Makyo-star, these beings have now migrated to Earth. As a result, they are the strongest starting race on Earth. They have average BP mods, and average stat mods, not really excelling in anything, although their Endurance and Strength can be quite good. They naturally learn the ability to expand their muscles, taking on a monstrous new form when they do. Makyo’s also learn the ability to ‘Summon’ Demons, whom are under the conjurors’ command.")
				if("Kai")
					contents+=new/obj/Skills/Power_Control
					contents+=new/obj/Skills/Telepathy
					givepowerchance=1
					UPMod*=1
					bursticon='All.dmi'
					ChargeState="1"
					burststate="2"
					BLASTSTATE="1"
					CBLASTSTATE="20"
					BLASTICON='1.dmi'
					CBLASTICON='20.dmi'
					InclineAge=25
					DeclineAge=rand(80,120)
					DeclineMod=1
					kinxt=0
					kinxtadd=0.9
					ITskill=10
					ITMod=0.5
					healmod=2
					zanzomod=10
					zanzoskill=5
					haszanzo=1
					/*
					KaiokenMod=3
					*/
					flightmod=10
					flightskill=20
					zenni+=rand(100,400)
					PLMod=5
					MaxPLpcnt=175
					MaxAnger=120
					MaxKi=rand(100,125)
					KiMod=2.5
					PowMod=rand(200,400)/100
					StrMod=rand(100,200)/100
					SpdMod=rand(100,250)/100
					EndMod=rand(100,200)/100
					ResMod=rand(100,300)/100
					OffenseMod=rand(100,250)/100
					DefenseMod=rand(100,250)/100
					GravMod=1
					HPRegen=rand(100,300)/100
					KiRegen=rand(300,500)/100
					ZenkaiMod=rand(100,200)/100
					TrainMod=1.5
					MedMod=3.3
					SparMod=1
					Race="Kai"
					RecordPL=rand(800,1000)
					GravMastered=10
					techmod=1.65
					see_invisible=5
					RaceDescription=("Guardians of the living realm and the afterlife, being a kaio is a hard and demanding job: You need to keep the demons in check, train the dead souls and prevent the extreme evil stuff (planets being destroyed etc.) However in return you get a lot of stuff that’s unique compared to all other races. All kaio's have the ability to acquire the skill mystic fairly early on, as well as the ability to heal, materialize weighted clothing and teleporting to other planets. Some kaio's even get the ability to restore youth, revive the dead and even get access to some of the most unique abilities in the game such as reincarnation. It’s rumoured that kaio's and demons share a common ancestor.")
				if("Android")
					undelayed=1
					contents+=new/obj/KiAttacks/Finger_Blast
					contents+=new/obj/Skills/Fly
					contents+=new/obj/Skills/Absorb_Android
					contents+=new/obj/Skills/Sense
					givepowerchance=0
					UPMod=0
					bursticon='All.dmi'
					burststate="5"
					ChargeState="2"
					BLASTSTATE="10"
					CBLASTSTATE="11"
					BLASTICON='10.dmi'
					CBLASTICON='11.dmi'
					InclineAge=25
					DeclineAge=100
					DeclineMod=0.5
					Age=25
					Body=25
					Makkankoicon='Ki Makkankosappo4.dmi'
					kinxt=-5
					kinxtadd=1.2
					ITMod=2
					healmod=0.01
					zanzomod=1.5
					zanzoskill=1000
					haszanzo=1
					/*
					KaiokenMod=0.5
					*/
					flightmod=4
					flightskill=100
					zenni+=rand(1,500)
					PLMod=25
					MaxPLpcnt=100
					MaxAnger=105
					MaxKi=rand(100,200)
					KiMod=5
					PowMod=rand(100,200)/100
					Str=rand(15,100)
					Spd=rand(12,100)
					End=rand(20,100)
					Pow=rand(9,90)
					Offense=rand(10,50)
					Defense=rand(10,50)
					StrMod=rand(100,200)/100
					SpdMod=rand(100,200)/100
					EndMod=rand(100,200)/100
					ResMod=rand(100,200)/100
					OffenseMod=rand(100,200)/100
					DefenseMod=rand(100,200)/100
					GravMod=3
					HPRegen=rand(2,3)
					KiRegen=rand(2,3)
					ZenkaiMod=rand(100,200)/100
					TrainMod=1.3
					MedMod=1.2
					SparMod=1.2
					Race="Android"
					spacebreather=1
					RecordPL=2
					GravMastered=200
					techmod=2.25
					RaceDescription=("These beings are total machine, being constructed on the Mother Ship. In terms of the series, this race could be compared to the likes of Android #13, #14, #15, #16, and #19 to name a few. They have quite high BP mods, allowing them to gain power fast if trained correctly. Their main drawback is their energy regeneration, which is ridiculously slow. A strange ability they have is to carry on standing even when there health reaches 0%, not being instantly Knocked Out.")
				if("Quarter-Saiyan")
					givepowerchance=1
					UPMod*=2
					bursticon='All.dmi'
					burststate="2"
					BLASTSTATE="19"
					CBLASTSTATE="24"
					BLASTICON='19.dmi'
					CBLASTICON='24.dmi'
					ChargeState="9"
					Makkankoicon='Ki Makkankosappo4.dmi'
					InclineAge=25
					DeclineAge=rand(40,45)
					DeclineMod=1
					refire*=0.9
					ITMod=1
					kinxt=10
					kinxtadd=0.5
					healmod=1
					zanzomod=3
					/*
					KaiokenMod=1.5
					*/
					flightmod=4
					PLMod=15
					MaxPLpcnt=300
					MaxAnger=500
					MaxKi=rand(15,20)
					KiMod=rand(100,250)/100
					PowMod=rand(100,250)/100
					StrMod=rand(100,250)/100
					SpdMod=rand(100,250)/100
					EndMod=rand(200,400)/100
					ResMod=rand(100,250)/100
					OffenseMod=rand(100,250)/100
					DefenseMod=rand(100,250)/100
					GravMod=1
					HPRegen=3
					KiRegen=3
					ZenkaiMod=rand(100,300)/100
					TrainMod=1.5
					MedMod=2
					SparMod=1.5
					Race="Quarter-Saiyan"
					RecordPL=rand(1,2000) //25 to 100'000 grown...
					GravMastered=2
					techmod=1.85
					zenni+=rand(100,200)
					Offense=30*OffenseMod
					Defense=30*DefenseMod
					RaceDescription=("Being the Equivalent to Pan, these guys can’t transform into a Super Saiyan. To compensate this, they have the highest BP mod of any Saiyan race, as well as the highest average for stat mods. Seeing as Pan is the only character of this race in the Anime, not much else can be said about them.")
				if("Human")
					givepowerchance=3
					UPMod*=3
					WaveIcon='Beam3.dmi'
					bursticon='All.dmi'
					burststate="2"
					var/chargo=rand(1,9)
					ChargeState="[chargo]"
					Cblastpower*=3
					BLASTICON='1.dmi'
					BLASTSTATE="1"
					CBLASTICON='18.dmi'
					CBLASTSTATE="18"
					InclineAge=25
					DeclineAge=rand(40,50)
					DeclineMod=0.8
					refire*=0.8
					Makkankoicon='Ki Makkankosappo4.dmi'
					ITMod=2
					kinxt=20
					kinxtadd=0
					healmod=1
					zanzomod=5
					/*
					KaiokenMod=2.5
					*/
					flightmod=5
					zenni+=rand(250,500)
					PLMod=1.70
					MaxPLpcnt=150
					MaxAnger=175
					KiMod=rand(100,300)/100
					kimanipmod=rand(100,200)/100
					MaxKi=rand(1,50)
					PowMod=rand(120,280)/100
					StrMod=rand(120,280)/100
					SpdMod=rand(120,280)/100
					EndMod=rand(120,280)/100
					ResMod=rand(120,280)/100
					OffenseMod=rand(120,280)/100
					DefenseMod=rand(120,280)/100
					GravMod=1
					HPRegen=rand(200,400)/100
					KiRegen=rand(200,400)/100
					ZenkaiMod=rand(100,200)/100
					TrainMod=2
					MedMod=3
					SparMod=2
					Race="Human"
					RecordPL=1
					GravMastered=1
					ascat=rand(4500000,5000000)
					techmod=3.5
					RaceDescription=("Human characters are based off the likes of those in the series, like Krillin, Yamcha etc. They have one of the lowest BP mods of all the races, finding it extremely hard to gain it. They are also known for being notoriously hard to train, as to begin with they can be difficult to use. But with a lot of determination and the right technique, these beings can become some of the strongest. Their stat mods are quite easily some of the best, being relatively high all around. Once again, getting good stats requires hard training though. Assortments of chi moves are available for them. Humans can also pretty much are on par with Tsu’s in terms of tech, just being slightly behind. Their Final BP mod is known as ‘Ascension’, and is named aptly; it is one of the most impressive on the game, making Human’s the race to be End Wipe. Third eye is also available for Humans to learn, like Tien Shinhan, giving a permanent boost to BP/stats.")
				if("Spirit Doll")
					contents+=new/obj/KiAttacks/Basic
					contents+=new/obj/Skills/Fly
					givepowerchance=3
					UPMod*=3
					WaveIcon='Beam3.dmi'
					bursticon='All.dmi'
					burststate="2"
					var/chargo=rand(1,9)
					ChargeState="[chargo]"
					Cblastpower*=3
					BLASTICON='1.dmi'
					BLASTSTATE="1"
					CBLASTICON='18.dmi'
					CBLASTSTATE="18"
					InclineAge=25
					DeclineAge=rand(30,35)
					DeclineMod=0.3
					refire*=0.5
					Makkankoicon='Ki Makkankosappo4.dmi'
					ITMod=2
					kinxt=-5
					kinxtadd=1
					healmod=1
					zanzomod=7
					/*
					KaiokenMod=2
					*/
					flightmod=8
					zenni+=rand(50,200)
					PLMod=1.1
					MaxPLpcnt=300
					MaxAnger=125
					KiMod=2.3
					kimanipmod=rand(100,250)/100
					MaxKi=40
					PowMod=rand(150,400)/100
					StrMod=rand(100,200)/100
					SpdMod=rand(100,200)/100
					EndMod=rand(100,200)/100
					ResMod=rand(100,300)/100
					OffenseMod=rand(100,250)/100
					DefenseMod=rand(100,250)/100
					GravMod=1
					HPRegen=3
					KiRegen=3
					ZenkaiMod=rand(100,200)/100
					TrainMod=2
					MedMod=4
					SparMod=1.25
					Race="Spirit Doll"
					RecordPL=4
					GravMastered=1
					ascat=1000000
					techmod=2
					RaceDescription=("Just think Chiaotzu. Even though in the series Chiaotzu was just a small, white Human, in Encore he has his own race. These little fella’s are quite like Human, yet more mystically aligned. As a result, there skill with Chi energy is much better than Humans, and they can train it faster. Their main drawback is they can’t make good Physical fighters, without strenuous training first. They also have the smallest BP mod.")
				if("Tsufurujin")
					givepowerchance=0.2
					bursticon='All.dmi'
					burststate="5"
					BLASTSTATE="5"
					BLASTICON='5.dmi'
					CBLASTICON='6.dmi'
					CBLASTSTATE="6"
					ChargeState="6"
					InclineAge=25
					DeclineAge=rand(65,85)
					DeclineMod=1
					Makkankoicon='Ki Makkankosappo3.dmi'
					ITMod=5
					kinxt=10
					kinxtadd=1
					healmod=0.5
					zanzomod=3
					/*
					KaiokenMod=2
					*/
					flightmod=5
					zenni+=rand(30000,50000)
					PLMod=1.25
					MaxPLpcnt=105
					MaxAnger=140
					MaxKi=rand(10,12)
					KiMod=rand(100,200)/100
					PowMod=rand(100,200)/100
					StrMod=rand(50,120)/100
					SpdMod=rand(100,200)/100
					EndMod=rand(100,200)/100
					ResMod=rand(100,200)/100
					OffenseMod=rand(100,200)/100
					DefenseMod=rand(100,250)/100
					GravMod=1
					HPRegen=rand(100,300)/100
					KiRegen=rand(100,300)/100
					ZenkaiMod=rand(150,200)/100
					TrainMod=1.5
					MedMod=2
					SparMod=1.2
					Race="Tsufurujin"
					RecordPL=5
					GravMastered=5
					techmod=4
					RaceDescription=("Considered the brainiest race, Tsufuru-jin’s boast the highest of tech mods, levelling it up quite easily. Considered docile, these beings aren’t usually considered fighters or chi users, and often stick to just tech. But with enough training, this race can become quite strong, although it’s almost not worth the hassle. Through tech they are the only race able to create Cyborgs and Bebi’s.")
				if("Namekian")
					see_invisible=5
					var/Choice=alert(src,"A Namekian can choose which basic ability they want to start with.","","Power Control","Fly","Basic Blast")
					switch(Choice)
						if("Power Control") contents+=new/obj/Skills/Power_Control
						if("Fly") contents+=new/obj/Skills/Fly
						if("Basic Blast") contents+=new/obj/KiAttacks/Basic
					givepowerchance=10
					UPMod*=3
					bursticon='All.dmi'
					burststate="2"
					BLASTSTATE="6"
					ChargeState="1"
					CBLASTSTATE="20"
					BLASTICON='6.dmi'
					CBLASTICON='20.dmi'
					Cblastpower*=2.5
					InclineAge=25
					DeclineAge=100
					DeclineMod=0.8
					kinxt=8
					kinxtadd=0.8
					refire*=0.9
					Makkankoicon='Ki Makkankosappo.dmi'
					WaveIcon='Beam3.dmi'
					MaxKi=rand(30,60)
					healmod=1
					zanzomod=2
					haszanzo=1
					/*
					KaiokenMod=1
					*/
					flightmod=10
					flightskill=100
					zenni+=rand(200,400)
					PLMod=3
					MaxPLpcnt=150
					MaxAnger=120
					KiMod=3
					kimanipmod=rand(100,200)/100
					PowMod=rand(150,400)/100
					StrMod=rand(100,250)/100
					SpdMod=rand(100,350)/100
					EndMod=rand(100,250)/100
					ResMod=rand(100,220)/100
					OffenseMod=rand(100,250)/100
					DefenseMod=rand(100,250)/100
					GravMod=1
					HPRegen=2.5
					KiRegen=4
					ZenkaiMod=rand(100,500)/100
					TrainMod=1
					MedMod=3
					SparMod=1.5
					Race="Namekian"
					RecordPL=rand(4,20)
					GravMastered=10
					snjat/=1000
					snjat*=rand(800,950)
					techmod=2.35
					RaceDescription=("Quite a peace-loving race that inhabits the planet Namek, they start off with either the ability to fire basic ki blasts, powering up or the ability to fly. Namekians also learn splitform, namekian BE, heal, materialize and eventually even namekian fusion as well and in some special cases they even have the ability to create dragonballs. Namekians start out roughly the same as low class Saiyan’s but as they grow stronger their potential grows with them.")
				if("Saiyan")
					var/Choice=alert(src,"Choose Option","","Normal","Elite","Low-Class")
					switch(Choice)
						if("Elite")
							if(prob(10)) contents+=new/obj/KiAttacks/Basic
							if(prob(10)) contents+=new/obj/Skills/Fly
							if(prob(10)) contents+=new/obj/Skills/Blutz_Wave
							if(prob(10)) contents+=new/obj/KiAttacks/Finger_Blast
							givepowerchance=1
							Race="Saiyan"
							Class="Elite"
							elite=1
							InclineAge=15
							DeclineAge=rand(45,85)
							DeclineMod=1.5
							BLASTSTATE="18"
							CBLASTSTATE="17"
							BLASTICON='18.dmi'
							CBLASTICON='17.dmi'
							ChargeState="6"
							WaveIcon='Beam1.dmi'
							Cblastpower*=2
							techmod=1
							zanzomod=2
							zanzoskill+=30
							haszanzo=1
							/*
							KaiokenMod=1
							*/
							flightmod=4
							flightskill=200
							kinxt=10
							kinxtadd=1
							zenni+=rand(5000,7500)
							MaxKi=rand(30,120)
							PLMod=15
							MaxPLpcnt=105
							MaxAnger=110
							KiMod=rand(100,200)/100
							PowMod=rand(100,200)/100
							StrMod=rand(100,200)/100
							SpdMod=rand(100,250)/100
							EndMod=rand(150,300)/100
							ResMod=rand(100,200)/100
							OffenseMod=rand(100,300)/100
							DefenseMod=rand(100,200)/100
							GravMod=15
							GravMastered+=10
							HPRegen=rand(120,300)/100
							KiRegen=rand(120,300)/100
							ZenkaiMod=30
							TrainMod=3
							MedMod=1
							SparMod=1.8
							RecordPL=rand(150,450)
							Omult=rand(2,4)
							Ochance=rand(1000,3000)
							Oozarouskill=150
							ssjat*=3.2*rand(800,1200)/1000
							ssjmult=1.25
							ssjdrain=150
							ssjadd=14000000
							ssj2add=60000000
							ssjmod*=0.5
							ssj2at*=rand(90,110)/100
							ssj3hitreq*=rand(120,160)/100
							/*
							KaiokenMod*=1
							*/
							UPMod*=0.5
							gain+=gainget*300
							RaceDescription=("Proud and powerful, the Saiyan elite is the strongest of the Saiyan classes, born with a superior power and a superiority complex. Elites are generally arrogant, smug and extremely insulting to anyone of a lower class, their pride often forces them to consider someone a rival, turning even the most basic of things into a competition. They start out with Oozaru mastered but their super Saiyan form is the hardest to obtain of all the classes, but is often considered to be well worth it. Elites also have a harder time achieving super Saiyan 3 then the other races but once more its considered well worth the effort.")
						if("Low-Class")
							givepowerchance=1.5
							WaveIcon='Beam3.dmi'
							InclineAge=20
							DeclineAge=rand(40,86)
							DeclineMod=0.7
							BLASTSTATE="12"
							CBLASTSTATE="18"
							BLASTICON='12.dmi'
							CBLASTICON='18.dmi'
							ChargeState="8"
							Cblastpower*=2
							zanzomod=2
							/*
							KaiokenMod=1
							*/
							flightmod=4
							flightskill=20
							kinxt=10
							kinxtadd=1
							zenni+=rand(200,300)
							PLMod=5
							MaxKi=rand(4,6)
							MaxPLpcnt=110
							MaxAnger=200
							KiMod=rand(1,3)
							PowMod=rand(100,150)/100
							StrMod=rand(100,150)/100
							SpdMod=rand(100,200)/100
							EndMod=rand(200,350)/100
							ResMod=rand(100,250)/100
							OffenseMod=rand(100,150)/100
							DefenseMod=rand(100,250)/100
							GravMod=1.2
							HPRegen=2
							KiRegen=rand(150,300)/100
							ZenkaiMod=50
							TrainMod=2
							MedMod=1.8
							SparMod=2
							Race="Saiyan"
							Class="Low-Class"
							RecordPL=rand(20,50) //500 to 2500 full grown...
							RecordPL=1
							if(prob(20)) ssj3able=1
							ssjdrain=150
							GravMastered=5
							ssjat*=rand(700,1200)/1000
							ssjmult=1.25
							ssjadd=9000000
							ssj2at*=rand(90,110)/100
							ssj3hitreq*=rand(120,160)/100
							ssj3at*=0.8
							techmod=1
							Omult=rand(1,4)
							Ochance=rand(1000,3000)
							UPMod*=1.5
							RaceDescription=("The lowest class of the saiyan race, these guys are born the weakest of all and as a result actually have a normal personality without an inflated ego. Though their power is low they have decent stat mods and if properly trained they can catch up to normal class saiyans quite fast. Their Oozaru form begins unmastered but they have the easiest job achieving super saiyan in general as well as super saiyan three.")
						if("Normal")
							if(prob(5)) contents+=new/obj/KiAttacks/Basic
							if(prob(5)) contents+=new/obj/Skills/Fly
							givepowerchance=1
							InclineAge=25
							DeclineAge=rand(40,60)
							DeclineMod=1
							ChargeState="8"
							BLASTSTATE="12"
							CBLASTSTATE="18"
							BLASTICON='12.dmi'
							CBLASTICON='18.dmi'
							Cblastpower*=2
							zanzomod=2
							/*
							KaiokenMod=1
							*/
							flightmod=4
							flightskill=20
							kinxt=10
							kinxtadd=1
							zenni+=rand(300,500)
							PLMod=10
							MaxPLpcnt=110
							MaxAnger=150
							MaxKi=rand(8,12)
							KiMod=rand(1.1,3)
							PowMod=rand(100,225)/100
							StrMod=rand(100,225)/100
							SpdMod=rand(100,225)/100
							EndMod=rand(175,325)/100
							ResMod=rand(100,225)/100
							OffenseMod=rand(100,225)/100
							DefenseMod=rand(100,225)/100
							Pow+=1*PowMod
							Str+=1*StrMod
							Spd+=1*SpdMod
							End+=1*EndMod
							Res+=1*ResMod
							MaxKi+=10*KiMod
							GravMod=1.5
							HPRegen=rand(130,300)/100
							KiRegen=rand(130,300)/100
							ZenkaiMod=40
							TrainMod=2
							MedMod=2
							SparMod=2
							Race="Saiyan"
							Class="Normal"
							RecordPL=rand(30,180) //500 to 2500 full grown...
							GravMastered=5
							ssjmult=1.25
							ssjadd=10000000
							ssjat*=1.9*rand(800,1200)/1000
							ssj2at*=rand(90,110)/100
							ssj3hitreq*=rand(120,160)/100
							techmod=1
							Omult=rand(2,3)
							Ochance=rand(1000,3000)
							gain+=gainget*300
							RaceDescription=("The middle class of the Saiyan race, they’re not quite as strong as elites but definitely stronger then low class Saiyan’s. Normal class Saiyan’s usually have quite a bit of pride, while knowing that elites are stronger than they are they still consider themselves superior compared to low class Saiyan’s. Their Oozaru form is un mastered but they have an easier time achieving super saiyan and super saiyan three then elites.")
				if("Half-Saiyan")
					var/Choice=alert(src,"Choose Option","","Human Dominant (Gohan)","Saiyan Dominant (Trunks)")
					switch(Choice)
						if("Human Dominant (Gohan)")
							givepowerchance=2
							UPMod*=3
							bursticon='All.dmi'
							burststate="2"
							BLASTICON='1.dmi'
							BLASTSTATE="1"
							CBLASTICON='18.dmi'
							CBLASTSTATE="18"
							ChargeState="4"
							Cblastpower*=2
							InclineAge=25
							DeclineAge=rand(40,45)
							DeclineMod=1
							Class="Earth Halfie"
							zanzomod=3
							/*
							KaiokenMod=1
							*/
							flightmod=4
							Makkankoicon='Ki Makkankosappo4.dmi'
							kinxt=12
							kinxtadd=0.8
							zenni+=rand(100,200)
							kimanipmod=1.2
							PLMod=5
							MaxPLpcnt=110
							MaxAnger=500
							MaxKi=rand(5,6)
							KiMod=rand(100,250)/100
							PowMod=rand(100,150)/100
							StrMod=rand(100,150)/100
							SpdMod=rand(100,250)/100
							EndMod=rand(100,150)/100
							ResMod=rand(100,150)/100
							OffenseMod=rand(100,350)/100
							DefenseMod=rand(100,350)/100
							GravMod=0.5
							HPRegen=2
							KiRegen=2
							ZenkaiMod=15
							TrainMod=1.1
							MedMod=1.3
							SparMod=3
							Race="Half-Saiyan"
							RecordPL=rand(1,10) //25 to 250 grown.
							GravMastered=2
							ssjat*=(rand(1000,1500)/1000)
							ssjmod*=3
							ssjdrain=120
							ssjmult=2
							ssjadd=10000000
							ssj2add=30000000
							ssj2mult=1.875
							ssj2add*=0.7
							ssj2at*=rand(1500,2000)/1500
							ssj3hitreq*=rand(100,150)/100
							techmod=2
							Omult=rand(3,5)
							Ochance=rand(1000,3000)
							refire*=0.8
							orefire*=0.8
						else
							givepowerchance=1.5
							UPMod*=1.5
							InclineAge=25
							DeclineAge=rand(40,44)
							DeclineMod=1
							Class="Vegeta Halfie"
							ChargeState="9"
							BLASTSTATE="25"
							CBLASTSTATE="15"
							BLASTICON='25.dmi'
							CBLASTICON='15.dmi'
							Cblastpower*=2
							zanzomod=2
							/*
							KaiokenMod=1
							*/
							flightmod=4
							kinxt=10
							kinxtadd=1
							zenni+=rand(75,200)
							PLMod=10
							MaxPLpcnt=105
							MaxAnger=180
							MaxKi=rand(8,12)
							KiMod=rand(1.1,3)
							PowMod=rand(100,220)/100
							StrMod=rand(100,220)/100
							SpdMod=rand(100,250)/100
							EndMod=rand(100,250)/100
							ResMod=rand(100,220)/100
							OffenseMod=rand(100,220)/100
							DefenseMod=rand(100,220)/100
							GravMod=2
							GravMastered=10
							HPRegen=rand(110,250)/100
							KiRegen=rand(110,250)/100
							ZenkaiMod=5
							TrainMod=2.1
							MedMod=2
							SparMod=1.5
							Race="Half-Saiyan"
							ssjmult=1.5
							ssj2mult=2.5
							ssjadd=12000000
							ssjadd=48000000
							RecordPL=rand(50,100) //1250 to 2500 grown...
							ssjat*=rand(3500,4000)/1000
							ssj3hitreq*=rand(80,120)/100
							ssjdrain=200
							techmod=2
							Omult=rand(4,6)
							Ochance=rand(2000,6000)
				if("Changeling")
					contents+=new/obj/KiAttacks/Basic
					contents+=new/obj/Skills/Fly
					givepowerchance=0.5
					bursticon='All.dmi'
					burststate="5"
					ChargeState="1"
					/*
					KaiokenMod=1
					*/
					InclineAge=25
					DeclineAge=rand(70,90)
					DeclineMod=1
					Pow=0.5
					MaxKi=rand(20,30)
					Race="Changeling"
					spacebreather=1
					kinxt=-5
					kinxtadd=0.9
					zenni+=rand(500,650)
					Makkankoicon='Ki Makkankosappo3.dmi'
					WaveIcon='Beam2.dmi'
					Age=25
					Body=25
					var/Choice=alert(src,"Choose Option","","Frieza","King Kold","Koola")
					switch(Choice)
						if("Frieza")
							BLASTSTATE="9"
							CBLASTSTATE="14"
							BLASTICON='9.dmi'
							CBLASTICON='14.dmi'
							Cblastpower=2
							Class="Frieza Type"
							zanzomod=5
							flightmod=5
							flightskill=20
							zanzoskill=10
							Str=1
							Spd=1
							End=1
							Offense=0.5
							Defense=0.5
							zenni+=rand(50,150)
							PLMod=5.5
							MaxPLpcnt=110
							MaxAnger=110
							KiMod=rand(100,220)/100
							PowMod=rand(100,220)/100
							StrMod=rand(200,450)/100
							SpdMod=rand(200,450)/100
							EndMod=rand(200,450)/100
							ResMod=rand(100,220)/100
							OffenseMod=rand(100,200)/100
							DefenseMod=rand(100,150)/100
							GravMod=10
							HPRegen=rand(150,300)/100
							KiRegen=rand(150,300)/100
							ZenkaiMod=rand(200,500)/100
							TrainMod=2.2
							MedMod=2
							SparMod=2
							Race="Changeling"
							spacebreather=1
							RecordPL=rand(3600,4400)
							GravMastered=15
							techmod=2.15
							RaceDescription=("Frieza type changelings are fast and powerful, they have powerful transformations that come natural to them and start out with ki quite easy, their usually seen as the cool intelligent type until they lose their tempter or get put in a tight spot. A frieza types final form is almost unmatched early wipe, generally speaking only a super saiyan can match it in terms of power.")
						if("King Kold")
							BLASTSTATE="26"
							BLASTICON='26.dmi'
							CBLASTICON='18.dmi'
							CBLASTSTATE="18"
							Cblastpower=2
							Class="King Kold Type"
							zanzomod=5
							flightmod=5
							zenni+=rand(150,250)
							flightskill=20
							zanzoskill=10
							Str=1
							Spd=1
							End=1
							Offense=1
							Defense=3
							flightmod=5
							PLMod=5.5
							MaxPLpcnt=110
							MaxAnger=110
							KiMod=rand(1.1,2.5)
							PowMod=rand(100,250)/100
							StrMod=rand(200,450)/100
							SpdMod=rand(100,150)/100
							EndMod=rand(200,450)/100
							ResMod=rand(200,350)/100
							OffenseMod=rand(100,300)/100
							DefenseMod=rand(100,200)/100
							GravMod=10
							HPRegen=rand(100,250)/100
							KiRegen=rand(100,250)/100
							ZenkaiMod=rand(110,350)/100
							TrainMod=2.1
							MedMod=2.2
							SparMod=1.75
							Race="Changeling"
							spacebreather=1
							RecordPL=rand(3800,5200)
							GravMastered=15
							f2at=1
							f2mult=7294570
							techmod=2
							RaceDescription=("Slow and bulky, king kold types are the tanks under the changelings, they only have one transformation but the form is immediately available and is as strong as the frieza type’s final form, making it quite strong indeed.")
						if("Koola")
							//-----------------------------------------
							f4at=5000000
							f2mult=1000000
							f3mult=2000000
							f4mult=6294570
							BLASTSTATE="21"
							CBLASTSTATE="13"
							BLASTICON='21.dmi'
							CBLASTICON='13.dmi'
							Class="Koola Type"
							zanzomod=5
							flightmod=5
							flightskill=20
							zanzoskill=10
							Str=1
							Spd=1
							End=1
							Offense=3
							Defense=3
							zenni+=rand(200,500)
							PLMod=5.5
							MaxPLpcnt=110
							MaxAnger=110
							KiMod=rand(1.1,2)
							PowMod=rand(100,200)/100
							StrMod=rand(100,200)/100
							SpdMod=rand(100,200)/100
							EndMod=rand(200,300)/100
							ResMod=rand(150,400)/100
							OffenseMod=rand(100,300)/100
							DefenseMod=rand(100,200)/100
							GravMod=10
							HPRegen=rand(110,300)/100
							KiRegen=rand(110,300)/100
							ZenkaiMod=rand(110,350)/100
							TrainMod=2.2
							MedMod=2
							SparMod=1.5
							Race="Changeling"
							spacebreather=1
							RecordPL=rand(3000,3500)
							GravMastered=15
							techmod=2.05
							RaceDescription=("Generally seen as the underdog, Cooler type changelings start with two of three forms unlocked, making them the weakest starting out. The final form of Cooler types can be considered hard to achieve for new players, but once reached it’s the strongest form of the changelings and such puts it slightly above a super Saiyan.")
				if("Demon")
					Race="Demon"
					contents+=new/obj/Skills/Soul_Absorb
					contents+=new/obj/Skills/Take_Body
					givepowerchance=0.3
					bursticon='All.dmi'
					burststate="2"
					ChargeState="9"
					BLASTSTATE="22"
					CBLASTSTATE="4"
					BLASTICON='22.dmi'
					CBLASTICON='4.dmi'
					Makkankoicon='Ki Makkankosappo3.dmi'
					Cblastpower*=2
					InclineAge=23
					DeclineAge=rand(60,110)
					DeclineMod=2
					flightmod=3
					kinxt=10
					kinxtadd=1
					zanzomod=3
					/*
					KaiokenMod=1.2
					*/
					zenni+=rand(200,500)
					flightskill=20
					dead=0
					PLMod=10
					MaxPLpcnt=150
					MaxKi=rand(80,100)
					KiMod=rand(125,250)/100
					PowMod=rand(125,250)/100
					StrMod=rand(125,200)/100
					SpdMod=rand(125,300)/100
					EndMod=rand(225,175)/100
					ResMod=rand(100,200)/100
					OffenseMod=rand(100,250)/100
					DefenseMod=rand(100,250)/100
					GravMod=10
					HPRegen=3
					KiRegen=3
					ZenkaiMod=3
					TrainMod=2.6
					MedMod=2.4
					MaxAnger=175
					UPMod=2
					SparMod=1
					RecordPL=800
					GravMastered=10
					techmod=1.5
					RaceDescription=("The scourge of the afterlife, these are twisted souls full of hate. Demons generally delight in causing pain and suffering. They are particularly good in physical combat though ki specialists are not unheard of. Demons have the natural ability to learn body expand and ki burst, as well as invisibility, split form and imitate. Some special demons can even teleport to other planets and enslave others through their mysterious dark powers. It’s rumoured that demons and kaio's share a common ancestor.")
				if("Arconian")
					contents+=new/obj/Skills/Telepathy
					givepowerchance=1
					UPMod*=rand(1,7)
					bursticon='All.dmi'
					burststate="2"
					var/chargoo=rand(1,9)
					ChargeState="[chargoo]"
					MaxKi=rand(20,30)
					BLASTICON='1.dmi'
					BLASTSTATE="1"
					CBLASTICON='18.dmi'
					CBLASTSTATE="18"
					var/rando=rand(1,3)
					if(rando==1) Makkankoicon='Ki Makkankosappo.dmi'
					if(rando==2) Makkankoicon='Ki Makkankosappo4.dmi'
					if(rando==3) Makkankoicon='Ki Makkankosappo3.dmi'
					DeclineAge=rand(40,200)
					DeclineMod=rand(50,200)/100
					healmod=rand(25,120)/100
					zanzomod=rand(100,760)/100
					/*
					KaiokenMod=rand(50,360)/100
					*/
					kinxt=rand(5,15)
					kinxtadd=rand(3,13)
					kinxtadd/=10
					zenni+=rand(50,800)
					flightmod=rand(200,1000)
					flightmod/=100
					PLMod=rand(50,1500)/100
					MaxPLpcnt=rand(101,168)
					MaxAnger=rand(101,300)
					KiMod=rand(7,375)/100
					PowMod=rand(75,375)/100
					StrMod=rand(75,375)/100
					SpdMod=rand(75,375)/100
					EndMod=rand(75,375)/100
					ResMod=rand(50,375)/100
					OffenseMod=rand(100,375)/100
					DefenseMod=rand(100,375)/100
					GravMod=rand(50,300)/100
					HPRegen=rand(50,240)/100
					KiRegen=rand(50,240)/100
					ZenkaiMod=rand(50,500)/100
					TrainMod=rand(150,300)/100
					MedMod=rand(150,300)/100
					SparMod=1
					Race="Arconian"
					spacebreather=1
					RecordPL=rand(1,2400)
					GravMastered=rand(1,12)
					techmod=rand(95,375)/100
					RaceDescription=("This is probably the most diverse race the universe has to offer, Arconians randomly learn five of ten unique skills and receive random mods upon creation, if you like to take a gamble this is the race for you.")
					switch(input("Choose your skin color", "", text) in list ("Konatsu","Kanassa","Baseniojin","Black Baseniojin","Yardrat","Immecka","Yukenojin","Jeice","Burter","Style1","Style2","Style3","None"))
						if("Style1")
							MaxKi=rand(100,300)
							contents+=new/obj/Skills/Fly
							contents+=new/obj/KiAttacks/Basic
							Class="Style1"
						if("Style2")
							SpdMod=2.5
							OffenseMod=2.2
							DefenseMod=2
							Class="Style2"
						if("Style3")
							contents+=new/obj/KiAttacks/Basic
							haszanzo=1
							StrMod=1.8
							EndMod=1.4
							Class="Style3"
						if("Baseniojin")
							contents+=new/obj/Skills/Fly
							contents+=new/obj/KiAttacks/Kill_Driver
							Class="Baseniojin"
							MaxKi=rand(10,20)
							flightskill=rand(100,500)
							flightmod=10
						if("Black Baseniojin")
							contents+=new/obj/Skills/Fly
							contents+=new/obj/KiAttacks/Kill_Driver
							Class="Black Baseniojin"
							MaxKi=rand(1000,2000)
							flightskill=rand(10000,50000)
							flightmod=10
						if("Immecka")
							Class="Immecka"
							DefenseMod=3
						if("Yukenojin")
							StrMod=4
							Class="Yukenojin"
						if("Jeice")
							Class="Jeice"
							Spd=20*SpdMod
							SpdMod=rand(2,3)
						if("Burter")
							Class="Burter"
							SpdMod=4
							Spd=15*SpdMod
						if("Metamori")
							Class="Metamori"
							EndMod=rand(2,4)
							contents+=new/obj/Skills/Take_Body
						if("Yardrat")
							Class="Yardrat"
							contents+=new/obj/Skills/Shunkan_Ido
							contents+=new/obj/Skills/Telepathy
							contents+=new/obj/Skills/Fly
							zanzomod=7
							zanzoskill=10
							haszanzo=1
							orefire*=0.2
						if("Kanassa")
							Class="Kanassa-Jin"
							contents+=new/obj/Skills/Telepathy
							contents+=new/obj/Skills/Sense
							contents+=new/obj/Skills/Sense2
							contents+=new/obj/Skills/Sense3
							contents+=new/obj/Skills/Observe
							precognitive=1
							see_invisible=5
						if("Konatsu")
							Class="Konatsu"
							contents+=new/obj/Skills/Heal
							PLMod=10
				if("Hybrid")
					Race="Hybrid"
					givepowerchance=6.66
					UPMod*=0.5
					bursticon='All.dmi'
					burststate="2"
					ChargeState="9"
					BLASTSTATE="22"
					CBLASTSTATE="4"
					BLASTICON='22.dmi'
					CBLASTICON='4.dmi'
					Makkankoicon='Ki Makkankosappo3.dmi'
					Cblastpower*=2.5
					InclineAge=25
					DeclineAge=rand(30,45)
					DeclineMod=1
					flightmod=3.5
					kinxt=11
					kinxtadd=0.9
					zanzomod=3
					/*
					KaiokenMod=1.1
					*/
					zenni+=rand(150,350)
					flightskill=10
					dead=0
					PLMod=5
					MaxPLpcnt=110
					MaxKi=rand(40,50)
					KiMod=rand(100,225)/100
					PowMod=rand(100,225)/100
					StrMod=rand(100,275)/100
					SpdMod=rand(100,275)/100
					EndMod=rand(150,200)/100
					ResMod=rand(100,225)/100
					OffenseMod=rand(100,250)/100
					DefenseMod=rand(100,250)/100
					GravMod=5
					HPRegen=2.5
					KiRegen=2.5
					ZenkaiMod=2.5
					TrainMod=2.3
					MedMod=2.2
					SparMod=1.12
					MaxAnger=170
					RecordPL=rand(200,450)
					GravMastered=10
					ssjat*=(rand(1000,2000)/1000)
					ssjmod*=2.5
					ssjdrain=130
					ssjmult=2
					ssjadd=10000000
					techmod=1
					RaceDescription=("Hybrids are a mixture of Saiyan and Demon blood. Therefore, they strike a balance between the two stat and BP mod wise, and should also be role-played in the same way; being a slightly eviler version of a Saiyan. Seeing as this race is non-cannon, there’s not much to be said about it, but it can be a fun race to play.")
			var/Choice=alert(src,"[RaceDescription] ...Do you want this race?","","Yes","No")
			switch(Choice)
				if("No")
					var/mob/M=new/mob
					M.displaykey=key
					M.name=key
					M.key=key
		Gender()
			if(Race=="Ancient Namek"|Race=="Kanassa-Jin"|Race=="Makyojin"|Race=="Namekian"|Class=="Yardrat"|Race=="Bio-Android")
			else
				var/Choice=alert(src,"Choose gender","","Male","Female")
				switch(Choice)
					if("Female") pgender="Female"
					if("Male") pgender="Male"
		Age()
			if(Race!="Bio-Android"&&Race!="Bebi")
				usr.startingage=input("Please choose your character's Starting Age, note that it should be a number between 1 and 25.") as num
				if(usr.startingage>25)
					usr<<"Please pick a number between 1 and 25."
					Age()
				if(usr.startingage<=0)
					usr<<"Please pick a number between 1 and 25."
					Age()
				else
					usr<<"Your character will start at age [startingage], be sure to Roleplay accordingly!"
			else
				usr<<"This Race cannot select it's Starting Age you will rp your physical age found in character info."
		Eyes()
			var/eyes='Eyes_Black.dmi'
			var/eyecolor
			eyecolor+=input("Please select your eye color.") as color
			eyes+=eyecolor
			overlays+=eyes
		Hair()
			if(Race=="Saiyan"&&!Created)
				switch(input("Choose hair", "", text) in list ("Bald","Female1","Goku","Short Female 1","Short Female 2","Pony Tail","Vegeta","Future Gohan","Teen Gohan","Long","Kid Gohan","Female Long","Female Long 2","Goten","GT Trunks","GT Vegeta","Mohawk","Spike","Yamcha","Vegeta Junior","Lan",))
					if("Female1")
						hair='Hair_Female1.dmi'
						overlays+=hair
						ssjhair='Hair_Female1SSJ.dmi'
						ussjhair='Hair_Female1SSJ.dmi'
						ssjfphair='Hair_Female1SSJ.dmi'
						ssj2hair='Hair_Female1SSJ.dmi'
						ssj3hair='Hair_Female1SSJ.dmi'
					if("Bald")
						hair=null
						ssjhair=null
						ussjhair=null
						ssjfphair=null
						ssj2hair=null
						ssj3hair=null
					if("Short Female 2")
						hair='Hair_PurpleFemale.dmi'
						overlays+=hair
						ssjhair='Hair_LongSSj.dmi'
						ussjhair='Hair_LongSSjFP.dmi'
						ssjfphair='Hair_FemaleLongSSjFP.dmi'
						ssj2hair='Hair_FemaleLongSSjFP.dmi'
						ssj3hair='Hair_GokuSSj3.dmi'
					if("Short Female 1")
						hair='Hair_ShortFemale.dmi'
						overlays+=hair
						ssjhair='Hair_LongSSj.dmi'
						ussjhair='Hair_LongSSjFP.dmi'
						ssjfphair='Hair_FemaleLongSSjFP.dmi'
						ssj2hair='Hair_FemaleLongSSjFP.dmi'
						ssj3hair='Hair_GokuSSj3.dmi'
					if("Pony Tail")
						hair='Hair_PonyTail.dmi'
						overlays+=hair
						ssjhair='Hair_PonyTailSSJ.dmi'
						ussjhair='Hair_SSJ-Custom2.dmi'
						ssjfphair='Hair_PonyTailSSJFP.dmi'
						ssj2hair='Hair_SSJFPCustom.dmi'
						ssj3hair='Hair_GokuSSj3.dmi'
					if("Female Long")
						hair='Hair_FemaleLong.dmi'
						overlays+=hair
						ssjhair='Hair_FemaleLongSSj.dmi'
						ussjhair='Hair_LongUSSj.dmi'
						ssjfphair='Hair_FemaleLongSSj.dmi'
						ssj2hair='Hair_FemaleLongSSj.dmi'
						ssj3hair='Hair_GokuSSj3.dmi'
					if("Female Long 2")
						hair='Hair_FemaleLong2.dmi'
						overlays+=hair
						ssjhair='Hair_FemaleLongSSj.dmi'
						ussjhair='Hair_LongUSSj.dmi'
						ssjfphair='Hair_FemaleLongSSj.dmi'
						ssj2hair='Hair_FemaleLongSSj.dmi'
						ssj3hair='Hair_GokuSSj3.dmi'
					if("Goten")
						hair='Hair_Goten.dmi'
						overlays+=hair
						ssjhair='Hair_GokuSSj.dmi'
						ussjhair='Hair_GokuUSSj.dmi'
						ssjfphair='Hair_GokuSSjFP.dmi'
						ssj2hair='Hair_GokuSSj.dmi'
						ssj3hair='Hair_GokuSSj3.dmi'
					if("GT Trunks")
						hair='Hair_GTTrunks.dmi'
						overlays+=hair
						ssjhair='Hair_LongSSj.dmi'
						ussjhair='Hair Trunks SSj.dmi'
						ssjfphair='Hair_LongSSjFP.dmi'
						ssj2hair='Hair Trunks SSj.dmi'
						ssj3hair='Hair_GokuSSj3.dmi'
					if("GT Vegeta")
						hair='Hair_GTVegeta.dmi'
						overlays+=hair
						ssjhair='Hair_GTVegetaSSj.dmi'
						ussjhair='Hair_GTVegetaSSj.dmi'
						ssjfphair='Hair_GTVegetaSSj.dmi'
						ssj2hair='Hair_GTVegetaSSj.dmi'
						ssj3hair='Hair_GokuSSj3.dmi'
					if("Mohawk")
						hair='Hair_Mohawk.dmi'
						overlays+=hair
						ssjhair='Hair_MohawkSSj.dmi'
						ussjhair='Hair_MohawkSSj.dmi'
						ssjfphair='Hair_MohawkSSj.dmi'
						ssj2hair='Hair_MohawkSSj.dmi'
						ssj3hair='Hair_GokuSSj3.dmi'
					if("Spike")
						hair='Hair_Spike.dmi'
						overlays+=hair
						ssjhair='Hair_SpikeSSj.dmi'
						ussjhair='Hair_SpikeSSj.dmi'
						ssjfphair='Hair_SpikeSSj.dmi'
						ssj2hair='Hair_SpikeSSj.dmi'
						ssj3hair='Hair_GokuSSj3.dmi'
					if("Yamcha")
						hair='Hair_Yamcha.dmi'
						overlays+=hair
						ssjhair='Hair_FutureGohanSSj.dmi'
						ussjhair='Hair_GohanUSSj.dmi'
						ssjfphair='Hair_GohanSSjFP.dmi'
						ssj2hair='Hair_FutureGohanSSj.dmi'
						ssj3hair='Hair_GokuSSj3.dmi'
					if("Kid Gohan")
						hair='Hair_KidGohan.dmi'
						overlays+=hair
						ssjhair='Hair_KidGohanSSj.dmi'
						ussjhair='Hair_KidGohanUSSj.dmi'
						ssjfphair='Hair_KidGohanSSjFP.dmi'
						ssj2hair='Hair_KidGohanSSj.dmi'
						ssj3hair='Hair_GokuSSj3.dmi'
					if("Lan")
						hair='Hair Lan.dmi'
						overlays+=hair
						ssjhair='Hair_KidGohanSSj.dmi'
						ussjhair='Hair_KidGohanUSSj.dmi'
						ssjfphair='Hair_KidGohanSSjFP.dmi'
						ssj2hair='Hair_KidGohanSSj.dmi'
						ssj3hair='Hair_GokuSSj3.dmi'
					if("Goku")
						hair='Hair_Goku.dmi'
						overlays+=hair
						ssjhair='Hair_GokuSSj.dmi'
						ussjhair='Hair_GokuUSSj.dmi'
						ssjfphair='Hair_GokuSSjFP.dmi'
						ssj2hair='Hair_GokuSSj.dmi'
						ssj3hair='Hair_GokuSSj3.dmi'
					if("Vegeta")
						hair='Hair_Vegeta.dmi'
						overlays+=hair
						ssjhair='Hair_VegetaSSj.dmi'
						ussjhair='Hair_VegetaUSSj.dmi'
						ssjfphair='Hair_VegetaSSjFP.dmi'
						ssj2hair='Hair_VegetaSSj.dmi'
						ssj3hair='Hair_GokuSSj3.dmi'
					if("Vegeta Junior")
						hair='Hair Vegeta Junior.dmi'
						overlays+=hair
						ssjhair='Hair_VegetaSSj.dmi'
						ussjhair='Hair_VegetaUSSj.dmi'
						ssjfphair='Hair_VegetaSSjFP.dmi'
						ssj2hair='Hair_VegetaSSj.dmi'
						ssj3hair='Hair_GokuSSj3.dmi'
					if("Future Gohan")
						hair='Hair_FutureGohan.dmi'
						overlays+=hair
						ssjhair='Hair_FutureGohanSSj.dmi'
						ussjhair='Hair_GohanUSSj.dmi'
						ssjfphair='Hair_GohanSSjFP.dmi'
						ssj2hair='Hair_FutureGohanSSj.dmi'
						ssj3hair='Hair_GokuSSj3.dmi'
					if("Teen Gohan")
						hair='Hair_Gohan.dmi'
						overlays+=hair
						ssjhair='Hair_GohanSSj.dmi'
						ussjhair='Hair_GohanUSSj.dmi'
						ssjfphair='Hair_GohanSSjFP.dmi'
						ssj2hair='Hair_GohanSSj.dmi'
						ssj3hair='Hair_GokuSSj3.dmi'
					if("Long")
						hair='Hair_Long.dmi'
						overlays+=hair
						ssjhair='Hair_LongSSj.dmi'
						ussjhair='Hair Trunks SSj.dmi'
						ssjfphair='Hair_LongSSjFP.dmi'
						ssj2hair='Hair_GokuSSj.dmi'
						ssj3hair='Hair_GokuSSj3.dmi'
			else if(Race=="Arconian"|Race=="Spirit Doll"|Race=="Cyborg"|Class=="Kanassa-Jin"|Race=="Demi-God"|Race=="Quarter-Saiyan"|Race=="Makyojin"|Race=="Kai" | Race=="Demon" | Race=="Tsufurujin" | Race=="Android" | Race=="Human" | Race=="Saiyan" | Race=="Half-Saiyan"|Class=="Yardrat" | Race=="Hybrid")
				switch(input("Choose hair", "", text) in list ("Bald","Female1","Goku","Short Female 1","Short Female 2","Pony Tail","Vegeta","Future Gohan","Teen Gohan","Long","Kid Gohan","Female Long","Female Long 2","Goten","GT Trunks","GT Vegeta","Mohawk","Spike","Yamcha","Vegeta Junior","Lan",))
					if("Female1")
						var/newhair='Hair_Female1.dmi'
						newhair+=input("Please select your hair color.") as color
						hair=newhair
						overlays+=hair
						ssjhair='Hair_Female1SSJ.dmi'
						ussjhair='Hair_Female1SSJ.dmi'
						ssjfphair='Hair_Female1SSJ.dmi'
						ssj2hair='Hair_Female1SSJ.dmi'
						ssj3hair='Hair_Female1SSJ.dmi'
					if("Bald")
						hair=null
						ssjhair=null
						ussjhair=null
						ssjfphair=null
						ssj2hair=null
						ssj3hair=null
					if("Short Female 2")
						var/newhair='Hair_PurpleFemale.dmi'
						newhair+=input("Please select your hair color.") as color
						hair=newhair
						overlays+=hair
						ssjhair='Hair_LongSSj.dmi'
						ussjhair='Hair_LongSSjFP.dmi'
						ssjfphair='Hair_FemaleLongSSjFP.dmi'
						ssj2hair='Hair_FemaleLongSSjFP.dmi'
						ssj3hair='Hair_GokuSSj3.dmi'
					if("Short Female 1")
						var/newhair='Hair_ShortFemale.dmi'
						newhair+=input("Please select your hair color.") as color
						hair=newhair
						overlays+=hair
						ssjhair='Hair_LongSSj.dmi'
						ussjhair='Hair_LongSSjFP.dmi'
						ssjfphair='Hair_FemaleLongSSjFP.dmi'
						ssj2hair='Hair_FemaleLongSSjFP.dmi'
						ssj3hair='Hair_GokuSSj3.dmi'
					if("Female Long")
						var/newhair='Hair_FemaleLong.dmi'
						newhair+=input("Please select your hair color.") as color
						hair=newhair
						overlays+=hair
						ssjhair='Hair_FemaleLongSSj.dmi'
						ussjhair='Hair_LongUSSj.dmi'
						ssjfphair='Hair_FemaleLongSSj.dmi'
						ssj2hair='Hair_FemaleLongSSj.dmi'
						ssj3hair='Hair_GokuSSj3.dmi'
					if("Female Long 2")
						var/newhair='Hair_FemaleLong2.dmi'
						newhair+=input("Please select your hair color.") as color
						hair=newhair
						overlays+=hair
						ssjhair='Hair_FemaleLongSSj.dmi'
						ussjhair='Hair_LongUSSj.dmi'
						ssjfphair='Hair_FemaleLongSSj.dmi'
						ssj2hair='Hair_FemaleLongSSj.dmi'
						ssj3hair='Hair_GokuSSj3.dmi'
					if("Goten")
						var/newhair='Hair_Goten.dmi'
						newhair+=input("Please select your hair color.") as color
						hair=newhair
						overlays+=hair
						ssjhair='Hair_GokuSSj.dmi'
						ussjhair='Hair_GokuUSSj.dmi'
						ssjfphair='Hair_GokuSSjFP.dmi'
						ssj2hair='Hair_GokuSSj.dmi'
						ssj3hair='Hair_GokuSSj3.dmi'
					if("GT Trunks")
						var/newhair='Hair_GTTrunks.dmi'
						newhair+=input("Please select your hair color.") as color
						hair=newhair
						overlays+=hair
						ssjhair='Hair_LongSSj.dmi'
						ussjhair='Hair Trunks SSj.dmi'
						ssjfphair='Hair_LongSSjFP.dmi'
						ssj2hair='Hair Trunks SSj.dmi'
						ssj3hair='Hair_GokuSSj3.dmi'
					if("GT Vegeta")
						var/newhair='Hair_GTVegeta.dmi'
						newhair+=input("Please select your hair color.") as color
						hair=newhair
						overlays+=hair
						ssjhair='Hair_GTVegetaSSj.dmi'
						ussjhair='Hair_GTVegetaSSj.dmi'
						ssjfphair='Hair_GTVegetaSSj.dmi'
						ssj2hair='Hair_GTVegetaSSj.dmi'
						ssj3hair='Hair_GokuSSj3.dmi'
					if("Mohawk")
						var/newhair='Hair_Mohawk.dmi'
						newhair+=input("Please select your hair color.") as color
						hair=newhair
						overlays+=hair
						ssjhair='Hair_MohawkSSj.dmi'
						ussjhair='Hair_MohawkSSj.dmi'
						ssjfphair='Hair_MohawkSSj.dmi'
						ssj2hair='Hair_MohawkSSj.dmi'
						ssj3hair='Hair_GokuSSj3.dmi'
					if("Pony Tail")
						var/newhair='Hair_PonyTail.dmi'
						newhair+=input("Please select your hair color.") as color
						hair=newhair
						overlays+=hair
						ssjhair='Hair_PonyTailSSJ.dmi'
						ussjhair='Hair_SSJ-Custom2.dmi'
						ssjfphair='Hair_PonyTailSSJFP.dmi'
						ssj2hair='Hair_SSJFPCustom.dmi'
						ssj3hair='Hair_GokuSSj3.dmi'
					if("Spike")
						var/newhair='Hair_Spike.dmi'
						newhair+=input("Please select your hair color.") as color
						hair=newhair
						overlays+=hair
						ssjhair='Hair_SpikeSSj.dmi'
						ussjhair='Hair_SpikeSSj.dmi'
						ssjfphair='Hair_SpikeSSj.dmi'
						ssj2hair='Hair_SpikeSSj.dmi'
						ssj3hair='Hair_GokuSSj3.dmi'
					if("Yamcha")
						var/newhair='Hair_Yamcha.dmi'
						newhair+=input("Please select your hair color.") as color
						hair=newhair
						overlays+=hair
						ssjhair='Hair_FutureGohanSSj.dmi'
						ussjhair='Hair_GohanUSSj.dmi'
						ssjfphair='Hair_GohanSSjFP.dmi'
						ssj2hair='Hair_FutureGohanSSj.dmi'
						ssj3hair='Hair_GokuSSj3.dmi'
					if("Kid Gohan")
						var/newhair='Hair_KidGohan.dmi'
						newhair+=input("Please select your hair color.") as color
						hair=newhair
						overlays+=hair
						ssjhair='Hair_KidGohanSSj.dmi'
						ussjhair='Hair_KidGohanUSSj.dmi'
						ssjfphair='Hair_KidGohanSSjFP.dmi'
						ssj2hair='Hair_KidGohanSSj.dmi'
						ssj3hair='Hair_GokuSSj3.dmi'
					if("Lan")
						var/newhair='Hair Lan.dmi'
						newhair+=input("Please select your hair color.") as color
						hair=newhair
						overlays+=hair
						ssjhair='Hair_KidGohanSSj.dmi'
						ussjhair='Hair_KidGohanUSSj.dmi'
						ssjfphair='Hair_KidGohanSSjFP.dmi'
						ssj2hair='Hair_KidGohanSSj.dmi'
						ssj3hair='Hair_GokuSSj3.dmi'
					if("Goku")
						var/newhair='Hair_Goku.dmi'
						newhair+=input("Please select your hair color.") as color
						hair=newhair
						overlays+=hair
						ssjhair='Hair_GokuSSj.dmi'
						ussjhair='Hair_GokuUSSj.dmi'
						ssjfphair='Hair_GokuSSjFP.dmi'
						ssj2hair='Hair_GokuSSj.dmi'
						ssj3hair='Hair_GokuSSj3.dmi'
					if("Vegeta")
						var/newhair='Hair_Vegeta.dmi'
						newhair+=input("Please select your hair color.") as color
						hair=newhair
						overlays+=hair
						ssjhair='Hair_VegetaSSj.dmi'
						ussjhair='Hair_VegetaUSSj.dmi'
						ssjfphair='Hair_VegetaSSjFP.dmi'
						ssj2hair='Hair_VegetaSSj.dmi'
						ssj3hair='Hair_GokuSSj3.dmi'
					if("Vegeta Junior")
						var/newhair='Hair Vegeta Junior.dmi'
						newhair+=input("Please select your hair color.") as color
						hair=newhair
						overlays+=hair
						ssjhair='Hair_VegetaSSj.dmi'
						ussjhair='Hair_VegetaUSSj.dmi'
						ssjfphair='Hair_VegetaSSjFP.dmi'
						ssj2hair='Hair_VegetaSSj.dmi'
						ssj3hair='Hair_GokuSSj3.dmi'
					if("Future Gohan")
						var/newhair='Hair_FutureGohan.dmi'
						newhair+=input("Please select your hair color.") as color
						hair=newhair
						overlays+=hair
						ssjhair='Hair_FutureGohanSSj.dmi'
						ussjhair='Hair_GohanUSSj.dmi'
						ssjfphair='Hair_GohanSSjFP.dmi'
						ssj2hair='Hair_FutureGohanSSj.dmi'
						ssj3hair='Hair_GokuSSj3.dmi'
					if("Teen Gohan")
						var/newhair='Hair_Gohan.dmi'
						newhair+=input("Please select your hair color.") as color
						hair=newhair
						overlays+=hair
						ssjhair='Hair_GohanSSj.dmi'
						ussjhair='Hair_GohanUSSj.dmi'
						ssjfphair='Hair_GohanSSjFP.dmi'
						ssj2hair='Hair_GohanSSj.dmi'
						ssj3hair='Hair_GokuSSj3.dmi'
					if("Long")
						var/newhair='Hair_Long.dmi'
						newhair+=input("Please select your hair color.") as color
						hair=newhair
						overlays+=hair
						ssjhair='Hair_LongSSj.dmi'
						ussjhair='Hair Trunks SSj.dmi'
						ssjfphair='Hair_LongSSjFP.dmi'
						ssj2hair='Hair_GokuSSj.dmi'
						ssj3hair='Hair_GokuSSj3.dmi'
		Skin()
			if(Race=="Arconian")
				if(Class=="Kanassa-Jin") icon='Base Kanassan.dmi'
				if(Class=="Konatsu") icon='Base Konatsu.dmi'
				if(Class=="Style1") icon='Base_Alien1.dmi'
				if(Class=="Style2")	icon='Base_Alien2.dmi'
				if(Class=="Style3")	icon='Base_Alien4.dmi'
				if(Class=="Burter") icon='Base Burter.dmi'
				if(Class=="Jeice") icon='Base Jeice.dmi'
				if(Class=="Baseniojin") icon='Base Baseniojin.dmi'
				if(Class=="Black Baseniojin") icon='Base Baseniojin (Black&blue).dmi'
				if(Class=="Immecka") icon='Immecka.dmi'
				if(Class=="Yukenojin") icon='Base Yukenojin.dmi'
				if(Class=="None") icon='Base Metamori.dmi'
				if(Class=="Yardrat") icon='Base Yardrat.dmi'
			if(Race=="Android")
				if(pgender=="Male") switch(input("Choose your skin color", "", text) in list ("Pale", "Tan", "Dark","Robot","Robot2"))
					if("Pale") icon='Base White Male.dmi'
					if("Tan") icon='Base Tan Male.dmi'
					if("Dark") icon='Base Black Male.dmi'
					if("Robot") icon='AndroidForm4.dmi'
					if("Robot2") icon='Base Android 2.dmi'
				else switch(input("Choose your skin color", "", text) in list ("Pale", "Tan", "Dark","Robot","Robot2"))
					if("Pale") icon='Base White Female.dmi'
					if("Tan") icon='Base Tan Female.dmi'
					if("Dark") icon='Base Black Female.dmi'
					if("Robot") icon='AndroidForm4.dmi'
					if("Robot2") icon='Base Android 2.dmi'
			if(Race=="Spirit Doll")
				if(pgender=="Male")
					icon='Spirit Doll no hat.dmi'
				if(pgender=="Female")
					icon='Spirit Doll - Female.dmi'
			if(Race=="Demi-God"|Race=="Tsufurujin"|Race=="Quarter-Saiyan"|Race=="Human"|Race=="Hybrid" | Race=="Saiyan" | Race=="Half-Saiyan")
				if(pgender=="Male") switch(input("Choose your skin color", "", text) in list ("Pale", "Tan", "Dark",))
					if("Pale") icon='human_male_white.dmi'
					if("Tan") icon='Base Tan Male.dmi'
					if("Dark") icon='Base Black Male.dmi'
				else switch(input("Choose your skin color", "", text) in list ("Pale", "Tan", "Dark",))
					if("Pale") icon='Base White Female.dmi'
					if("Tan") icon='Base Tan Female.dmi'
					if("Dark") icon='Base Black Female.dmi'
				if(Race=="Demi-God") icon+=rgb(40,60,60)
			if(Race=="Changeling")
				if(Class=="Frieza Type") icon='Base Changeling.dmi'
				if(Class=="Koola Type") icon='Base Cooler.dmi'
				if(Class=="King Kold Type") icon='Base KingKold.dmi'
				oicon=icon
			if(Race=="Makyojin") icon='MakyoNewBase.dmi'
			if(Race=="Kai")
				var/playericon
				var/playercolor
				playercolor+=input("Pick a color.") as color
				if(pgender=="Male") playericon='Base Custom Male.dmi'
				else playericon='Base Custom Female.dmi'
				playericon += playercolor
				icon=playericon
			if(Race=="Demon")
				var/playericon
				var/playercolor
				playercolor+=input("Pick a color.") as color
				switch(input("Choose appearance", "", text) in list ("Normal (Male and Female)","Devil","Devil2","Skull Demon","Spiral Demon","Black Demon","Janemba","Hades"))
					if("Normal (Male and Female)")
						if(pgender=="Male") playericon='Base Custom Male.dmi'
						else playericon='Base Custom Female.dmi'
						playericon += playercolor
						icon=playericon
					if("Devil")
						playericon='Base Demon 1.dmi'
						playericon += playercolor
						icon=playericon
					if("Devil2")
						playericon='Base_Devil2.dmi'
						playericon += playercolor
						icon=playericon
					if("Skull Demon")
						playericon='Base_Skully.dmi'
						playericon += playercolor
						icon=playericon
					if("Spiral Demon")
						playericon='Base_Tattoo Demon.dmi'
						playericon += playercolor
						icon=playericon
					if("Black Demon")
						playericon='Base Demon 2.dmi'
						playericon += playercolor
						icon=playericon
					if("Janemba")
						playericon='Base Demon 3.dmi'
						playericon += playercolor
						icon=playericon
					if("Hades")
						playericon='Base Hades.dmi'
						playericon += playercolor
						icon=playericon
			if(Race=="Majin")
				var/playericon
				var/playercolor
				playericon='Majin1.dmi'
				playercolor+=input("Pick a color.") as color
				playericon += playercolor
				icon=playericon
			if(Race=="Namekian")
				var/nicon='NamekAdult.dmi'
				switch(input("Choose your skin color","",text) in list("Light Green", "Dark Green",))
					if("Light Green")
						nicon+=rgb(30,30,30)
						light=1
						icon=nicon
					if("Green")
						icon=nicon
						normal=1
					if("Dark Green")
						nicon-=rgb(30,30,30)
						icon=nicon
						dark=1
			if(Race=="Ancient Namek")
				var/image/I=image(icon='Base Namek.dmi')
				I.icon-=rgb(60,60,60)
				icon=I
		Aura_Color()
			AuraColor=input("Pick a color.") as color
			var/aura='Aura Normal.dmi'
			if(Race=="Demon" | Race=="Hybrid")
				Over=1
				aura='Aura Black Demonflame.dmi'
			if(Race=="Makyojin")
				Over=1
				aura='AuraKiia.dmi'
			aura+=AuraColor
			AURA=aura
			ssj4aura='Aura SSj4.dmi'
			ssj4aura+=AURA
		Blast_Color()
			alert("Now customize your blast color")
			blastR=input("Blast red") as num
			blastG=input("Blast green") as num
			blastB=input("Blast blue") as num
		Locate()
			if(Race=="Kai") loc=locate(62,314,16)
			else if(Race=="Android"|Race=="Bio-Android") loc=locate(67,308,8)
			else if(Race=="Spirit Doll"|Race=="Human"|Class=="Earth Halfie"|Race=="Quarter-Saiyan"|Race=="Majin")
				loc=locate(325,218,1)
			else if(Race=="Namekian"|Race=="Ancient Namek") loc=locate(167,303,3)
			else if(Race=="Tsufurujin") loc=locate(75,280,4)
			else if(Race=="Saiyan" | Class=="Vegeta Halfie") loc=locate(325,343,4)
			else if(Race=="Changeling") loc=locate(175,157,6)
			else if(Race=="Arconian") loc=locate(165,211,5)
			else if(Race=="Demon") loc=locate(66,321,17)
			else if(Race=="Hybrid") loc=locate(66,321,17)
			else if(Race=="Demi-God") loc=locate(62,314,16)
			else if(Race=="Makyojin") loc=locate(230,346,20)
mob/var/BodyType
mob/proc/BodyType()
	var/Choice=alert(src,"What type of body do you want?","","Medium","Small","Large")
	switch(Choice)
		if("Medium")
			Choice=alert(src,"Choosing Medium will leave your stats as they are, most males are this, although it is not uncommon for females as well, do you want this?","","Yes","No")
			switch(Choice)
				if("No") BodyType()
				if("Yes") BodyType="Medium"
		if("Small")
			Choice=alert(src,"Small will make you able to land hits easier, dodge easier, attack faster, run faster, heal faster, and recover energy faster, but you will take a -severe- cut in strength and endurance, this setting is modeled as a female archetype, do you want this?","","Yes","No")
			switch(Choice)
				if("No") BodyType()
				if("Yes")
					StrMod*=0.7
					EndMod*=0.7
					SpdMod*=1.5
					refire*=0.7
					orefire*=0.7
					HPRegen*=1.5
					KiRegen*=1.5
					BodyType="Small"
		if("Large")
			Choice=alert(src,"Large is like being a giant, far beyond any normal person in size. You will receive an insanely huge boost in Endurance, and a still insane but less boost to Strength, but you will attack slower, heal slower, recover energy slower, be easier to hit, and easier to dodge, do you want this?","","Yes","No")
			switch(Choice)
				if("No") BodyType()
				if("Yes")
					StrMod*=1.5
					EndMod*=2
					OffenseMod*=0.8
					DefenseMod*=0.8
					HPRegen*=0.7
					KiRegen*=0.7
					refire*=1.2
					orefire*=1.2
					BodyType="Large"
mob/var/elite=0
mob/proc/Elite() RecordPL*=5
