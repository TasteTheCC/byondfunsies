mob
	Enemies
		Evil_Kid
			icon = 'human_female_white_kid.dmi'
			pl = 300
			maxlife = 3000
			strength = 1500
			defense = 5000
		New()
			src.life = src.maxlife
			spawn (-1)
				src.CombatAI()
			return ..()
mob/var/wander=0 // flag to find if he's wandering.
mob/var/Hostile=0 // flag to signal hostility from the AI.
mob
	Enemies
		proc
			CombatAI()
				while(src)
					for(var/mob/Player/M in world) //finds everyone player in the world.
						for(M in oview()) // everyone in range
							src.Hostile=1 //if player in range, become hostile.
							src.wander=0
							if(get_dist(src,M)<=1) // if player right next, attack.
								src.dir=get_dir(src,M)
								src.Melee_Attack()
							else
								step_to(src,M) // if player isnt right next but still seen, walk to him
							break
							if(get_dist(src,M)>=8) // if player in view but not in range, give up.
								src.wander=1
								src.Hostile=0
								src.dir = pick(NORTH,WEST,EAST,SOUTH)
								step_to(src,src.dir)
					sleep(rand(4,8))