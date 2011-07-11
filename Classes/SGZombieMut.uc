class SGZombieMut extends Mutator
    config(SGZombie);

struct oldNewZombiePair {
    var string oldClass;
    var string newClass;
};

struct dmgScale {
    var string dmgType;
    var float dmgScale;
    var bool bNeedHeadShot;
    var byte difficultyMask;
};

var array<oldNewZombiePair> replacementArray;
var() config bool bLog;
var() config array<dmgScale> FPDmgScale;
var() config array<dmgScale> SCDmgScale;

static function int diffToMask(int difficulty) {
    if (difficulty == 7) {
        return 0x10;
    }
    if (difficulty == 5) {
        return 0x8;
    }
    return difficulty;
}

static function int findDmgTypeScale(String dmgType, array<dmgScale> dmgScaleArray) {
    local int index;
    local int i;

    index=-1;
    for(i=0;index == -1 && i<dmgScaleArray.length;i++) {
        if (dmgType ~= dmgScaleArray[i].dmgType) {
            index = i;
        }
    }
    return index;
}

function replaceSpecialSquad(out array<KFGameType.SpecialSquad> squadArray) {
    local int i,j,k;
    local oldNewZombiePair replacementValue;
    for(j=0; j<squadArray.Length; j++) {
        for(i=0;i<squadArray[j].ZedClass.Length; i++) {
            for(k=0; k<replacementArray.Length; k++) {
                replacementValue= replacementArray[k];
                if(squadArray[j].ZedClass[i] ~= replacementValue.oldClass) {
                    squadArray[j].ZedClass[i]=  replacementValue.newClass;
                }
            }
        }
    }
}

function PostBeginPlay() {
    local int i,k;
    local KFGameType KF;
    local oldNewZombiePair replacementValue;

    KF = KFGameType(Level.Game);
    if (Level.NetMode != NM_Standalone)
        AddToPackageMap("SGZombie");

    if (KF == none) {
        Destroy();
        return;
    }

    //Replace all instances of the old specimens with the new ones 
    for( i=0; i<KF.StandardMonsterClasses.Length; i++) {
        for(k=0; k<replacementArray.Length; k++) {
            replacementValue= replacementArray[k];
            //Use ~= for case insensitive compare
            if (KF.StandardMonsterClasses[i].MClassName ~= replacementValue.oldClass) {
                KF.StandardMonsterClasses[i].MClassName= replacementValue.newClass;
            }
        }
    }

    //Replace the special squad arrays
    replaceSpecialSquad(KF.ShortSpecialSquads);
    replaceSpecialSquad(KF.NormalSpecialSquads);
    replaceSpecialSquad(KF.LongSpecialSquads);
    replaceSpecialSquad(KF.FinalSquads);

//    KF.EndGameBossClass= "SuperZombie.ZombieSuperBoss";
//    KF.FallbackMonsterClass= "SuperZombie.ZombieSuperStalker";

}

static function FillPlayInfo(PlayInfo PlayInfo) {

    Super.FillPlayInfo(PlayInfo);
   
    PlayInfo.AddSetting("SGCustomZombie", "bLog", "Enable debug logging", 0, 0, "Check");
}

static event string GetDescriptionText(string property) {

    if(property == "bLog") {
        return "Check if you want debug output displayed in the chat box on screen";
    }

    return Super.GetDescriptionText(property);
}

defaultproperties {
    GroupName="KFSGZombieMut"
    FriendlyName="SG Zombie"
    Description="Replaces the default specimens with a set of customized specimens that allow the user to configure their damage multipliers"

    bLog= false;
    replacementArray(0)=(oldClass="KFChar.ZombieFleshPound_CIRCUS",NewClass="SGZombie.SGZombieFleshpound")
    replacementArray(1)=(oldClass="KFChar.ZombieScrake_CIRCUS",NewClass="SGZombie.SGZombieScrake")
}

