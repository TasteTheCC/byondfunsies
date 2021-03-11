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
client
	authenticate = 0
world
	name="fuck you"
	mob=/mob/Player
	fps = 25		// 25 frames per second
	icon_size = 32	// 32x32 icon size by default

	view = 6		// show up to 6 tiles outward from center (13x13 view)


// Make objects move 8 pixels per tick when walking

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

//dice
var/dice = "1d20"
//musicas
var/sound/peidos = sound('peidos.wav')
// ----------
mob/Stat()
	stat("Level:","[src.level]")
	stat("EXP:","[src.Exp]/[src.Nexp]")
	stat("Life","[src.life]/[src.maxlife]")
	stat("Strength",strength)
	stat("Armor Class",defense)

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
		gettable = 0
		desc = "Someone died. Oof."
		icon = 'corpse.dmi'
		New()
			icon_state = pick ("torso_f","torso_m","torso_f_fat","torso_m_fat","head_f","head_m")
	dust
		icon = 'dirt.dmi'
		density = 0
		gettable = 0
		New()
			walk(src,pick(NORTH,EAST,WEST,SOUTH),6)
			spawn(10)
				del(src)
// defining space.
area/dark
	luminosity = 10
turf
	floor
	icon = 'floors.dmi'
	start
		icon_state = "bcircuit"
	wall
		icon = 'walls.dmi'
		density = 1
		opacity = 1
obj
	poison
		icon = 'drinks.dmi'
		icon_state = "lithiumflask"

//login/logout
mob/Player
	icon = 'player.dmi'

mob
	Login()
		if(src.LoadProc())
			usr << "Welcome back, [name]."
			src.life = 100
		else
			usr << "Welcome, [name]!"
			loc = locate(/turf/start)
			src.life = 100

	Logout()
		world<<"[src] has left the building."
		src.SaveProc()
		del src
