/*
	These are simple defaults for your project.
 */

world
	fps = 25		// 25 frames per second
	icon_size = 32	// 32x32 icon size by default

	view = 6		// show up to 6 tiles outward from center (13x13 view)


// Make objects move 8 pixels per tick when walking

mob
	step_size = 8

obj
	step_size = 8

mob/DM
	key = "cc233"
//dice
var/dice = "1d20"
//musicas
var/sound/peidos = sound('peidos.wav')
// login
mob
	Login()
		world << "[usr] has entered the fray!"
//stats
mob
	var
		life = 100
		strength = 10
		armor_class = 13
mob/Stat()
	stat("Life",life)
	stat("Strength",strength)
	stat("Armor Class",armor_class)

	statpanel("Inventory",usr.contents)
//damage and debuffs
mob
	proc
		TakeDamage(D)
			life = life - D
			if (life < 0)
				world << "[src] fuckin dies."
				src.Die()
		MDMAPOWER(D)
			if (usr.TakeDamage())
				world << "[src] is speedy af!!"
				src.icon_state = "Flight"
				sleep (10)
				src.icon_state = ""

//MORTE
obj
	corpse
		desc = "Someone died. Oof."
		icon = 'corpse.dmi'
		New()
			icon_state = pick ("torso_f","torso_m","torso_f_fat","torso_m_fat","head_f","head_m")
mob
	var/corpse = /obj/corpse
	proc/Die()
		if (!key)
			del src
			new corpse(loc)
		else
			if(corpse)
				new corpse(loc)
			loc = null
			var/again = input("Give up?") in list ("Yes","No")
			if(again == "No")
				Login()
				usr.life = 100
			else
				del src
				src << "OOF!"
//objects.
obj
	poison
		name = "MDMA"
		desc = "uh oh."
		verb/drink()
			set src in view(1)
			usr.TakeDamage(25) //yowwwww
			if (usr.life > 0)
				oview(5) << "[usr] has [usr.life] life left!"
//verbs
obj
	verb
		get()
			set src in oview(1)
			loc = usr
		drop()
			set src in usr
			loc = usr.loc
// social verbs
mob
	verb
		smile()
			world << "[usr] smiles."

		giggle()
			world << "[usr] giggles."

		cry()
			world << "[usr] cries \his heart out."

		rename(name as text)
			set desc = "(\"new name!!\") change yer fookin name."
			src.name = name

		play_something(snd as sound)
			world << snd

		cona()
			view() << 'peidos.wav'

		rolldice()
			var/d = roll(dice)
			world << "[usr] rolled a [d]!"
//communication
mob
	verb
		say(msg as text)
			world << "[usr] says, '[msg]'"
		whisper(msg as text)
			src in view()
			src << "[usr] whispers, '[msg]'"

// defining space.
area/dark
	luminosity = 10
turf
	floor
		icon = 'floors.dmi'
	start
		icon = 'floors.dmi'
		icon_state = "bcircuit"
	wall
		icon = 'walls.dmi'
		density = 1
obj
	poison
		icon = 'drinks.dmi'
		icon_state = "lithiumflask"
// defining mob icon
mob
	icon = 'player.dmi'
	Login()
		if(loc)
			usr << "Welcome back, [name]."
		else
			usr << "Welcome, [name]!"
			loc = locate(/turf/start)
		..()
	Logout()
		del src