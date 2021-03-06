
//testing
mob
	verb
		RepopWorld()
			set category = "Admin"
			if(src.ckey == "cc233")
				world.Repop()
			else src << "No."
		Reset_Stats(var/mob/Player/M in world)
			set category = "Admin"
			if (src.ckey == "cc233")
				rating = 1
				M.strength = 1
				defense = 1
				force = 1
				resistance = 1
				speed = 20
				strengthmod = 1.5
				defensemod = 2.5
				forcemod = 3
				resmod = 3
				lift = 0
			else src << "No."
// social verbs
mob
	verb
		Smile()
			set category = "Emote"
			world << "[usr] smiles."

		Giggle()
			set category = "Emote"
			world << "[usr] giggles."

		Cry()
			set category = "Emote"
			world << "[usr] cries \his heart out."

		Rename(name as text)
			set desc = "(\"new name!!\") change yer fookin name."
			src.name = name
			world << "[usr.key] changed his name to [name]!"

		PlaySomething(snd as sound)
			set category = "Emote"
			world << snd

		Cona()
			set category = "Emote"
			view() << 'peidos.wav'

		Roll(dice as num)
			set desc = "(\"Choose the Die\")"
			var/d = roll(dice)
			if (d== 1) world << "[usr] rolled a [fred][bold][d][bend][fend]!"
			else if (d==dice) world<< "[usr] rolled a [fgreen][bold][d][bend][fend]!"
			else world << "[usr] rolled a [d]!"
		Who()
			var/counter=0
			for(var/mob/Player/M in world)
				counter+=1
				src<<"(Lvl.[M.maxpl])[M]"
			src<<"<b>[counter] players online!"
//communication
mob
	verb
		Examine(obj/A in view())
			src << "[bold] [A]: [bend][A.desc]"
		Say(msg as text)
			view() << "[usr] says, '[msg]'"
		OOC(msg as text)
			world << "(OOC)<b>[src]:</b> [msg]"
		Whisper(msg as text)
			src in view()
			src << "[usr] whispers, '[msg]'"
//verbs
obj
	verb
		Get()
			if (gettable == 1)
				for(var/obj/O in src.loc)
					O.loc = usr
					src << "Picked up [O]."
		Drop()
			set src in usr
			loc = usr.loc

mob
	verb
		Save()
			src.SaveProc()

mob/verb/Variable_Edit(atom/A in world, edit as text)
    var/list/variables = A.vars - list("ckey", "contents", "loc", "locs", "key","parent_type","type")  //  I'm subtracting out any forbidden variables as changing these itself directly can have VERY serious consequences
    if(!variables.Find(edit)){ alert("Variable [edit] does not exist."); return}
    else if(istype(A.vars[edit], /list)){ alert("Cannot edit [edit] as it is a /list"); return}

    var/change = input("Change [edit] on [A] to what?", "Edit [edit]", A.vars[edit]) as text

    if(isnum(text2num(change)))
        //  Don't want the numeric alert? Remove the following line (but be sure to have the text2num() portion)
        if("Number" == alert("The value '[change]' appears to be a number. Which variable type is this?","Variable Type", "Number", "Text"))
            change = text2num(change)

    A.vars[edit] = change
    alert({"Changed [edit] to [A.vars[edit]] ([isnum(A.vars[edit])?"Numeric":"Text"])"}, "Edit [edit]")

//combat?
var/mob/iswaiting
mob
	verb
		Check_Structure_Life(obj/destructable/A in view(usr))
			src << "Structure HP: [A.durability]"
		Melee_Attack()
			set category = "Combat"
			var/wait = 30 - (src.speed/4)
			stamcheck()
			var/DamageW = src.maxpl
			if(src.canattack == 1)
				src.canattack = 0
				src.incombat = 1
				for(var/obj/destructable/M in get_step(src,src.dir))
					if(energy <= 0) break
					if(iswaiting) break
					else
						if (src.ko == 1)
							break
						if (DamageW <= 0) break
						flick(pick("RPunch","RKick","LPunch","LKick"),src)
						M.Decheck(DamageW)
						src.canattack = 0
						src.plgain(1.5)
						src.speedgain(0.5)
						src.energy -= round(maxenergy/10)
						break
					src.canattack = 0
					break
				for(var/mob/M in get_step(src,src.dir))
					if (energy <= 0) break
					var/Damage = src.strength - M.defense
					if(iswaiting) break
					else
						KillCheck(M)
						if (M == src) break;
						else
							if (src.ko == 1)
								break
							src.plgain(3)
							src.speedgain(1)
							M.training = 0
							M.meditating = 0
							src.energy -= round(maxenergy/10)
							flick(pick("RPunch","RKick","LPunch","LKick"),src)
							if (Damage >= 1)
								view(M)<<"[src] hit [M] for [bold][Damage][bend] Damage!"
								flick("Block",M)
								M.TakeDamage(Damage,src)
							else
								flick("Block",M)
								view(M) << "[M] dodges the attack!"
					break
				iswaiting = 1
				src.canattack = 0
				sleep(wait)
				src.canattack = 1
				iswaiting = 0
				spawn(100)
					src.incombat=0

		Train()
			set category = "Training"
			if(src.meditating!=0)
				Stop_MeditatingLoop()
			if(src.training==0)
				src.can_move = 0
				src.recovering = 0
				src.canattack = 0
				training=1
				icon_state="Train"
				src << "You start to train."
				src.TrainingLoop()
			else
				Stop_TrainingLoop()

		Meditate()
			set category = "Training"
			if(src.training!=0)
				Stop_TrainingLoop()
			if(src.meditating==0)
				src.can_move = 0
				src.recovering = 0
				src.canattack = 0
				meditating=1
				src << "You start to meditate."
				icon_state="Meditate"
				energyhealloop()
				MeditatingLoop()
			else
				src.recovering=0
				Stop_MeditatingLoop()
				src << "You stop meditating."

