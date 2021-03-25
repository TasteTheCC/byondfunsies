mob
	Enemies
		Green_bad
			icon = 'human_female_white_kid.dmi'
			pl = 300
			maxlife = 100
			strength = 10
			defense = 5
		New()
			src.life = src.maxlife
			spawn (-1)
				src.CombatAI()
			return ..()

		proc
			CombatAI()
				while(src)
					for(var/mob/Player/M in oview())
						if(get_dist(src,M)<=1)
							src.dir=get_dir(src,M)
							src.Melee_Attack()
						else
							step_to(src,M)
						break
					sleep(rand(4,8))