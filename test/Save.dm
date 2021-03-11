mob/proc/SaveProc()
    var/FileName="Players/[ckey(src.key)].sav"
    if(fexists(FileName))   fdel(FileName)
    var/savefile/F=new(FileName)
    F["Level"]<<src.level
    F["Exp"]<<src.Exp
    F["Nexp"]<<src.Nexp
    F["Life"]<<src.life
    F["MaxLife"]<<src.maxlife
    F["Str"]<<src.strength
    F["Armor Class"]<<src.defense
    F["LastX"]<<src.x
    F["LastY"]<<src.y
    F["LastZ"]<<src.z
    src<<"Character Saved!"

mob/proc/LoadProc()
    var/FileName="Players/[ckey(src.key)].sav"
    if(fexists(FileName))
        var/savefile/F=new(FileName)
        F["Level"]>>src.level
        F["Exp"]>>src.Exp
        F["Nexp"]>>src.Nexp
        F["Life"]>>src.life
        F["Max Life"]>>src.maxlife
        F["Str"]>>src.strength
        F["Armor Class"]>>src.defense
        src.loc=locate(F["LastX"],F["LastY"],F["LastZ"])
        src<<"Character Loaded..."
        return 1