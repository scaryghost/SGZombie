class SGZombieAux extends Object;

struct dmgScale {
    var string dmgType;
    var float dmgScale;
    var bool bNeedHeadShot;
    var byte difficultyMask;
};

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
        if (dmgType == dmgScaleArray[i].dmgType) {
            index = i;
        }
    }
    return index;
}
