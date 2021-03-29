
proc/editableLists()
	return world.contents
var/worldtime = 1

proc/Save_Gain()
	var/savefile/S=new("GAIN")
	S["GAIN"]<< globalgain
	S["Time"]<<worldtime
proc/Load_Gain()
	if(fexists("GAIN"))
		var/savefile/S=new("GAIN")
		S["GAIN"]>> globalgain
		S["Time"]>>worldtime
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
			sleep(1200)
			view() << "[fgreen] [src] [fend] stands up again!"
			src.ko = 0
			src.can_move = 1
			src.canattack = 1
		KillCheck(var/mob/M)
			if (M.ko == 1)
				if(src.client)
					switch(alert("Do you want to kill them?",,"Yes","No"))
						if("Yes")
							if(M.client)
								world<<"[src] killed [M]!"
								M.life=M.maxlife
								flick("Fall",M)
								spawncorpse(M)
								M.dead = 1
								Death(M)
								M.ko = 0
								M.can_move = 1
								M.canattack = 1
								M.loc=locate(/turf/start)
							else
								src<<"<b>You killed [M]."
								src.plgain()
								flick("Fall",M)
								spawncorpse(M)
								M.dead = 1
								del M

						if("No")
							view() << "[src] gave mercy on [M]"
							M.loc = M.loc
				else
					Death(M)
					flick("Fall",M)
					M.life=M.maxlife
					spawncorpse(M)
					M.dead=1
					M.ko = 0
					M.can_move = 1
					M.canattack = 1
		DeathCheck(var/mob/Killer)
			if(src.life<=0)
				KO(src)
			if(src.ko == 1)
				view() << "[Killer] is about to kill [src]"
mob/var/firstdeath=1
mob
	proc
		Death()
			if (player&&dead)
				if(firstdeath)
					firstdeath=0
					var/DeathPL = gains*1000*plmod
					if(DeathPL>recordpl) DeathPL = recordpl
					maxpl += DeathPL
					src.loc = /turf/start
		knockback(var/r,var/d) // r range, d dir
			if(!r) return
			while(r > 0)
				dir = d
				step(src, dir)
				r--
				new/obj/dust(src.loc,src.dir)
					..()
				sleep(1)
			if(/mob)
				dir=turn(dir,180)
			if(Bump(null))
				return
			if(Bump(/obj/destructable))
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
	S.desc = "[src]'s corpse. May \he rest in peace."
	S.name = "[src]'s corpse"

obj/destructable
	proc
		Decheck(var/Damage)
			durability -= Damage
			if(src==null) return 1
			if(durability < maxdurability && durability >= (maxdurability/2))
				src.overlays += "overlay_damage"
			if(durability < (maxdurability/2) && durability >= (maxdurability/4))
				src.overlays += "overlay_damage2"
			if(durability < (maxdurability/4) && durability >= 1)
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
				speedgain(0.5)
				statgain("fight",0.3)
				src.energy -= src.maxenergy / (10*src.maxenergy)
				src.lift += rand(3,5)*((src.strengthmod + src.defensemod)/200)
				ratinggain(1)
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
		ratinggain(mod)
			if (src.rating <= 100)
				src.rating+= rand(1,50)
			else
				src.rating += mod*round(rand(1,5)*(src.rating/10000))
			sleep(15)
	proc
		MeditatingLoop()
			set background = 1
			while(src.meditating)
				sleep(10)
				plgain(0.3)
				src.energy ++
				energygain(0.5)
				ratinggain(0.5)
				speedgain(1)
				statgain("spirit",0.3)
				if (inbed && (tired <= 100))
					tired+=1
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

		speedgain(gain)
			src.speed += globalgain*gain*speedmod*(src.rating/100)*0.001
		plgain(gain)
			src.maxpl += globalgain*gain*1*plmod*10 * (src.rating/100)
		energygain(gain)
			src.maxenergy += globalgain*gain*forcemod*10 *(src.rating/100)
		statgain(focus,gain)
			switch(focus)
				if ("spirit")
					src.force+= globalgain*gain*forcemod *(src.rating/100)
					src.resistance+= globalgain*gain*resmod *(src.rating/100)
				if("fight")
					src.defense+= globalgain*gain*defensemod *(src.rating/100)
					src.strength+=globalgain*gain* strengthmod *(src.rating/100)
					src.lift += rand(3,5)*((src.strengthmod + src.defensemod)/200*(src.rating/100))