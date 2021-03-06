/*
	These are simple defaults for your project.
 */
//colors
#define fblack "<font color=black>"
#define fsilver "<font color=silver>"
#define fgray "<font color=gray>"
#define fwhite "<font color=white>"
#define fmaroon "<font color=maroon>"
#define fred "<font color=red>"
#define fpurple "<font color=purple>"
#define ffuchsia "<font color=fuchsia>"
#define fmagenta "<font color=magenta>"
#define fgreen "<font color=green>"
#define flime "<font color=lime>"
#define folive "<font color=olive>"
#define fgold "<font color=gold>"
#define fyellow "<font color=yellow>"
#define fnavy "<font color=navy>"
#define fblue "<font color=blue>"
#define fteal "<font color=teal>"
#define faqua "<font color=aqua>"
#define fcyan "<font color=cyan>"
#define fend  "</font>"
#define bold "<b>"
#define bend "</b>"
#include "30x30.dmm"
#include "lobby.dmm"
client
	authenticate = 0
mob
	proc
		LifeCheck()
			set background = 1
			var/hasticked=0
			if(hasticked==1)
				return
			else
				if(src.dead==0)
					if(src.loc != /obj/destructable/bed)
						src.tired-=0.005
					src.hunger-=0.05
					src.thirst-=0.05
					hasticked=1
				spawn(rand(5,10))
					hasticked = 0
					LifeCheck()
				if(energy <= maxenergy && !incombat)
					energy+=maxenergy/20

var/savingmap
world
	name="fuck you"
	mob=/mob/Player
	fps = 25		// 25 frames per second
	icon_size = 32	// 32x32 icon size by default

	view = 6		// show up to 6 tiles outward from center (13x13 view)
	..()
	New()
		..()
		spawn Initialize()
proc/Initialize()
	world<<"Loading all files..."
	LoadYear()
	Load_Gain()
	spawn Years()
	spawn SaveWorldRepeat()
	world << "All files loaded."
proc/SaveWorldRepeat()
	sleep(36000)
	savingmap=1
	spawn SaveWorld()
	savingmap=0
	SaveWorldRepeat()
proc/SaveWorld()
	world << "Saving all files."
	SaveYear()
	Save_Gain()
	world<<"Year saved."
	world<<"Complete"
// Make objects move 8 pixels per tick when walking

var/const
	CLOTHES_LAYER = FLOAT_LAYER-1
	HAIR_LAYER = FLOAT_LAYER-2

obj
	overlay
		hair
			hairadult
				icon = 'short_hair_dbz.dmi'
				layer = HAIR_LAYER
			hairkid
				icon = 'short_hair_dbz_kid.dmi'
				layer = HAIR_LAYER
mob/verb
	get_hair()
		set category = "Style"
		overlays += /obj/overlay/hair/hairadult
		src.hair = overlays
	remove_hair()
		set category = "Style"
		src.hair = null
		overlays = src.hair



mob
	step_size = 32

obj
	step_size = 32
mob
    var
        last_move = 0
        move_delay = 1
    Move(newloc,dir,step_x,step_y)
        if(!last_move||world.time>=last_move+move_delay)
            . = ..(newloc,dir,step_x,step_y)
            last_move = world.time
        else
            return 0
mob
	Move()
		if(src.can_move==1)
			return ..()
		return 0
	Bump(obj/destructable/M)
		if(isknockback==1 && M!=null)
			new/obj/turf/floor_destroyed(src.loc)
			new/obj/crater(src.loc)
			new/obj/dust(src.loc,src.dir)
			del(M)

// ----------
mob/Stat()
	stat("Rating([src.rating])","[round(src.rating)]")
	stat("Power", "[src.pl_percent()]%")
	stat("Energy","[src.energy_percent()]%")
	stat("Vitals","[src.hp_percent()]%")
	stat("Age", "[round(src.Age,0.1)]([round(src.Body,0.1)]) years old.")
	stat("Strength, ([src.strength])", "[measure(create_percent("strength"))]")
	stat("Endurance,([src.defense])", "[measure(create_percent("defense"))]")
	stat("Force, ([src.force])","[measure(create_percent("force"))]")
	stat("Resistance, ([src.resistance])","[measure(create_percent("resistance"))]")
	stat("Speed, ([src.speed])","[measure(create_percent("speed"))]")
	stat("Lift","[round(src.lift,0.01)]")
	stat("================","==============================")
	stat("Hunger:","[round(src.hunger)]%")
	stat("Thirst:","[round(src.thirst)]%")
	stat("Tiredness:","[round(src.tired)]%")
	statpanel("Inventory",usr.contents)
//objects.
obj
	poison
		name = "poison"
		desc = "uh oh."
		verb/drink()
			set src in view(1)
			usr.TakeDamage(25,null) //yowwwww
			if (usr.life > 0)
				view(5) << "[usr] has [usr.life] life left!"
//obj
obj/var/gettable = 1
obj
	corpse
		name = null
		gettable = 0
		desc = "Someone died. Oof."
		icon = 'corpse.dmi'
		New()
			icon = 'human_male_white.dmi'
			icon_state = "KO"

	dust
		icon = 'dirt.dmi'
		density = 0
		gettable = 0
		New()
			walk(src,pick(NORTH,EAST,WEST,SOUTH),6)
			spawn(10)
				del(src)
	crater
		icon = 'dirt.dmi'
		icon_state = "small crater"
		density = 0
		opacity=1
		gettable = 0
		New()
			sleep(30)
			del(src)
	attack
		blast
// defining space.
area/dark
	luminosity = 10
turf
	floor
	icon = 'floors.dmi'
	floor_creepy
		icon_state = "cult-narsie"
	start
		icon_state = "bcircuit"

obj/turf
	floor_destroyed
		icon = 'floors.dmi'
		density = 0
		icon_state = "asteroid"
		var/durability = 50
obj/destructable
	var/maxdurability = 10000
	var/durability = 10000
	wall
		icon = 'walls.dmi'
		desc = "It's a wall."
		density = 1
		opacity = 1

	door
		icon = 'walls.dmi'
		icon_state = "fakewindows"
		desc = "It's a door. Open and close it."
		density = 1
		opacity = 1
		verb/Open()
			set src in view(1)
			opacity = 0
			density = 0

			sleep (20)
			opacity = 1
			density = 1
		Click()
			Open()
			sleep(20)
	bed
		icon = 'Turf 52.dmi'
		icon_state = "bed top"
		density = 0
		Entered(var/mob/Player/M)
			M.inbed=1
		Exited(var/mob/Player/M)
			M.inbed=0

	bedbot
		icon = 'Turf 52.dmi'
		icon_state = "bed"
		density = 1
		New()
			..()
			new/obj/destructable/bed(NORTH)
obj
	poison
		icon = 'drinks.dmi'
		desc = "Don't drink this."
		icon_state = "lithiumflask"

//login/logout
mob/Player
	icon = 'human_male_white.dmi'
mob
	Login()
		if(src.LoadProc())
			usr << "Welcome back, [name]."
		else
			usr << "Welcome, [name]!"
			loc = locate(/turf/start)
			src.life = src.maxlife
			src.energy = src.maxenergy
			src.pl = src.maxpl
		src.player = 1
		src.LifeCheck()
		src.AgeCheck()

	Logout()
		world<<"[src] has left the building."
		src.SaveProc()
		del src
