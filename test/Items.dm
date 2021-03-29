#include "Vars.dm"
mob
	Punching_Bag
		New()
			life = maxlife
		icon = 'Punching bag.dmi'
		can_move = 0
		canattack = 0
		maxlife = 9999999
		defense = 1
		ko = 0
		TakeDamage(Damage,var/mob/Attacker)
			flick("Hit",src)
			Attacker.ratinggain(2)
			Attacker.statgain("fight",Attacker.gains)
			if (src.life <= 0)
				icon_state = "Destroyed"
				sleep(20)
				del(src)
