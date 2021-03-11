
proc/editableLists()
	return world.contents

mob
	proc
		TakeDamage(var/Damage,var/mob/Attacker)
			src.life -= Damage
			src.DeathCheck(Attacker)
			var knockback = rand(5, (max(round(Damage)))- src.defense)
			var dir = Attacker.dir
			if(src.isknockback == 0)
				spawn() src.knockback(knockback, dir)
				src.isknockback = 1
				DisadvantageRegulator(src)
			if(src.isknockback == 0)
				spawn() src.knockback(knockback, dir)
				src.isknockback = 1
			if(src.isknockback >= 1)
				sleep(10)
				src.isknockback = 0
			Attacker<<"[src] has [src.life] left."

		LevelCheck()
			if(src.Exp>=src.Nexp)
				src.Exp = 0
				src.Nexp+=10
				src.level+=1
				src.maxlife += roll(1,20)
				src.strength+= 1
				src<<"You are now Level [src.level]"

		DisadCheck(var/Damage,var/mob/M)
			if (M.disadvantage == 0 || Damage >= (2 * M.defense))
				view(M) << "[M] got hit for [bold] DOUBLE [bend] their AC! They're stunned and will hit/defend with disadvantage!"
				M.disadvantage = 1

		DisadvantageRegulator()
			if (src.disadvantage == 1)
				sleep(20)
				src.disadvantage = 0
		DeathCheck(var/mob/Killer)
			if(src.life<=0)
				if(src.client)
					world<<"[Killer] killed [src]!"
					src.life=src.maxlife
					src.loc=locate(/turf/start)
				else
					Killer<<"<b>You killed [src] for [src.Exp] exp"
					Killer.Exp+=src.Exp
					Killer.LevelCheck()
					del src

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

			if(Bump(/turf/wall))
				new/obj/dust(src.loc,src.dir)
				new/obj/dust(src.loc,src.dir)

