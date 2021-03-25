
proc/editableLists()
	return world.contents

mob
	proc
		TakeDamage(var/Damage,var/mob/Attacker)
			src.life -= Damage
			var knockback = rand(5, (max(round(Damage)))- src.defense)
			src.DeathCheck(Attacker)
			var dir = Attacker.dir
			if(src.isknockback == 0)
				spawn() src.knockback(knockback, dir)
				flick("Block",src)
				src.isknockback = 1
				DisadvantageRegulator(src)
			if(src.isknockback >= 1)
				sleep(knockback)
				src.isknockback = 0
			if(Damage >= src.life)
				KO(src)
			Attacker<<"[src] has [src.life] left."
		KO()
			src.ko = 1
			src.canattack = 0
			view() << "[fyellow] [src] [fend] is KOED!"
			icon_state = "KO"
			src.can_move = 0
			sleep(120)
			view() << "[fgreen] [src] [fend] stands up again!"
			src.ko = 0
			src.can_move = 1
			src.canattack = 1
		KillCheck(var/mob/M)
			if (M.ko == 1)
				switch(alert("Do you want to kill them?",,"Yes","No"))
					if("Yes")
						if(M.client)
							world<<"[src] killed [M]!"
							M.life=M.maxlife
							flick("Fall",M)
							spawncorpse(M)
							M.loc=locate(/turf/start)
						else
							src<<"<b>You killed [M]."
							src.plgain()
							flick("Fall",M)
							spawncorpse(M)
							del M

					if("No")
						view() << "[src] gave mercy on [M]"
						M.loc = M.loc
		DisadCheck(var/Damage,var/mob/M)
			if (M == null || src == null)
				return
			if (M.disadvantage == 0 && Damage >= (2 * M.defense))
				view(M) << "[M] got hit for [bold] DOUBLE [bend] their AC! They're stunned and will hit/defend with disadvantage!"
				M.disadvantage = 1
			else M.disadvantage = 1
		DisadvantageRegulator()
			if (src == null)
				return
			if (src.disadvantage == 1)
				sleep(3)
				src.disadvantage = 0

		DeathCheck(var/mob/Killer)
			if(src.life<=0)
				KO(src)
			if(src.ko == 1)
				view() << "[Killer] is about to kill [src]"

		knockback(var/r,var/d) // r range, d dir
			if(!r) return
			while(r > 0)
				dir = d
				step(src, dir)
				r--
				new/obj/dust(loc,dir)
					..()
				sleep(1)
			if(/mob)
				dir=turn(dir,180)

			if(Bump(/obj/wall))
				new/obj/dust(src.loc,src.dir)
				new/obj/dust(src.loc,src.dir)
		stamcheck()
			if(src.energy <= 0)
				src.canattack = 0
				src.training=0
				src.energy=0
mob/proc/spawncorpse()
	var/obj/corpse/S = new(src.loc)
	S.icon = src.icon
	flick("Fall",S)
	S.gettable= 0
	S.desc = "[src]'s corpse. May \he rest in peace"
	S.name = "[src]'s corpse"

obj/wall
	proc
		Decheck(var/Damage)
			durability -= Damage
			if(src==null) return 1
			if(durability < 100 && durability >= 50)
				src.overlays += "overlay_damage"
			if(durability < 50 && durability >= 25)
				src.overlays += "overlay_damage2"
			if(durability < 25 && durability >= 1)
				src.overlays += "overlay_damage3"
			if(durability <= 0)
				density=0
				opacity=0
				new/obj/turf/floor_destroyed(loc)
				new/obj/crater(loc)
				new/obj/dust(loc,dir)
mob
	proc
		TrainingLoop()
			set background = 1
			set waitfor=0
			while(src.training==1)
				sleep(15)
				plgain(0.5)
				energygain(0.1)
				statgain("fight",0.3)
				src.energy -= src.maxenergy / (10*src.maxenergy)
				src.lift += rand(3,5)*((src.strengthmod + src.defensemod)/200)
				ratinggain()
				if(src.energy <= 0)
					spawn(5)stamcheck()
					src << "You stop training due to exhaustion."
					src.can_move = 1
					src.canattack = 1
					break

		Stop_TrainingLoop()
			src.training=0
			src.icon_state = ""
			src.can_move = 1
			src.canattack = 1
			src << "You stop training."
		ratinggain()
			src.rating += round(rand(1,5)*(src.rating/100))
			sleep(15)
	proc
		MeditatingLoop()
			set background = 1
			while(src.meditating)
				sleep(10)
				plgain(0.3)
				src.energy ++
				energygain(0.5)
				statgain("spirit",0.3)
				spawn(5)src.stamcheck()
				if (src.energy >= src.maxenergy) src.energy = src.maxenergy
				if(src.meditating==0)
					break
				sleep(300)
		Stop_MeditatingLoop()
			src.meditating=0
			src.icon_state = ""
			src.can_move = 1
			src.canattack = 1

		plgain(gain)
			src.maxpl += src.globalgain*gain*1*10 * (src.rating/100)
		energygain(gain)
			src.maxenergy += src.globalgain*gain*forcemod*10 *(src.rating/100)
		statgain(focus,gain)
			switch(focus)
				if ("spirit")
					src.force+= src.globalgain*gain*forcemod*50 *(src.rating/100)
					src.resistance+= src.globalgain*gain*resmod*50 *(src.rating/100)
				if("fight")
					src.defense+= src.globalgain*gain*defensemod*50 *(src.rating/100)
					src.strength+=src.globalgain*gain* strengthmod*50 *(src.rating/100)