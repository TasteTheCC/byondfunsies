//stats
var/globalgain = 0.001
mob
	var
		//indicators
		gains = 1
		plmod = 1.25
		pl = 100
		maxpl = 100
		rating = 0
		life = 5000
		maxlife = 5000
		energy = 40
		maxenergy = 40
		recordpl = 1200
		//stats
		strength = 10
		defense = 13
		force = 10
		resistance = 10
		speed = 20
		strengthmod = 1.5
		defensemod = 2.5
		forcemod = 3
		resmod = 3
		speedmod = 1
		lift = 5
		techskill=1
		//quality of life
		hunger = 100
		thirst = 100
		tired = 100
		Age = 4
		Body = 4
		SAge = 0
		AgeStatus = "Young"
		DeclineAge = 40
		InclineAge = 25
		//dice
		unarmed = 4
		//flags
		dead = 0
		immortal = 0
		inbed= 0
		incombat = 0
		flight=0
		inpod=0
		insuit=0
		grabbee=0
		Race = null
		EnteredHBTC = 0
		isknockback = 0
		buudead = 0
		mystified = 0
		enslaved = 0
		player = 0
		disadvantage = 0
		advantage = 0
		canattack = 1
		ko = 0
		can_move = 1
		recovering = 0
		training = 0
		meditating = 0
		//cosmetic
		hair = null
		HairR=0
		HairG=0
		HairB=0

	proc
		create_percent(percent)
			var/Total = strength + defense + force + resistance
			switch(percent)
				if("strength") return 100 * (strength/ Total)
				if("defense") return 100 * (defense/ Total)
				if("force") return 100 * (force / Total)
				if ("resistance") return 100 * (resistance / Total)
				if ("speed") return 100 * (speed/Total)
		pl_percent(currentpl)
			currentpl = round((src.pl / src.maxpl) * 100)
			return currentpl
		energy_percent(currentenergy)
			currentenergy = round((src.energy/src.maxenergy)*100)
			return currentenergy
		hp_percent(currenthp)
			currenthp = round((src.life/src.maxlife)*100)
			return currenthp
		energyhealloop()
			set background = 1
			src.recovering = 1
			while(src&&src.recovering && src.energy < src.maxenergy)
				src.energy += round(src.maxenergy/10)
				src.pl += round(src.maxpl / 10)
				if (src.pl>=src.maxpl)
					src.pl = src.maxpl
				if (src.energy >= src.maxenergy)
					src.recovering = 0
					break
		measure(percent)
			if(percent >= 90)
				return "Extremely High"
			if(percent >= 75)
				return "High"
			if(percent >= 60)
				return "Above Average"
			if(percent >= 40)
				return "Average"
			if(percent >= 25)
				return "Below Average"
			if(percent >= 10)
				return "Low"
			if (percent >= 0)
				return "Extremely Low"
			if (percent < 0)
				return "Negative"
