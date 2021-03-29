mob/proc/SaveProc()
    var/FileName="Players/[ckey(src.key)].sav"
    if(fexists(FileName))   fdel(FileName)
    var/savefile/F=new(FileName)
    F["MaxLife"]<<src.maxlife
    F["Str"]<<src.strength
    F["Armor Class"]<<src.defense
    F["Force"]<<src.force
    F["Resistance"]<<src.resistance
    F["Hair"]<<src.hair
    F["Rating"]<<src.rating
    F["mPL"]<<src.maxpl
    F["PL"]<<src.pl
    F["Speed"]<<src.speed
    F["Max Energy"]<<src.maxenergy
    F["LastX"]<<src.x
    F["LastY"]<<src.y
    F["LastZ"]<<src.z
    F["Lift"]<<src.lift
    F["Dead"]<<src.dead
    F["Age"]<<src.Age
    F["Body Age"]<<src.Body
    F["Decline"]<<src.DeclineAge
    F["Incline"]<<src.InclineAge
    F["Hunger"]<<src.hunger
    F["Thirst"]<<src.thirst
    F["Tiredness"]<<src.tired
    F["HairR"]<<src.HairR
    F["HairG"]<<src.HairG
    F["HairB"]<<src.HairB
    F["QP"]<<src.techskill
    src<<"Character Saved!"

mob/proc/LoadProc()
    var/FileName="Players/[ckey(src.key)].sav"
    if(fexists(FileName))
        var/savefile/F=new(FileName)
        F["Rating"]>>src.rating
        F["mPL"]>>src.maxpl
        F["PL"]>>src.pl
        F["MaxLife"]>>src.maxlife
        F["Str"]>>src.strength
        F["Armor Class"]>>src.defense
        F["Force"]>>src.force
        F["Resistance"]>>src.resistance
        F["Hair"]>>src.hair
        F["Speed"]>>src.speed
        F["Max Energy"]>>src.maxenergy
        F["Lift"]>>src.lift
        F["Dead"]>>src.dead
        F["Age"]>>src.Age
        F["Body Age"]>>src.Body
        F["Decline"]>>src.DeclineAge
        F["Incline"]>>src.InclineAge
        F["Hunger"]>>src.hunger
        F["Thirst"]>>src.thirst
        F["Tiredness"]>>src.tired
        F["HairR"]>>src.HairR
        F["HairG"]>>src.HairG
        F["HairB"]>>src.HairB
        F["QP"]>>src.techskill
        src.overlays += src.hair
        src.hair += rgb(HairR,HairG,HairB)
        src.loc=locate(F["LastX"],F["LastY"],F["LastZ"])
        src<<"Character Loaded..."
        return 1