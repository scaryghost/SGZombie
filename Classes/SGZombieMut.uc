class SGZombieMut extends Mutator
    config(SGZombieMut);

struct oldNewZombiePair {
    var string oldClass;
    var string newClass;
};

var() globalconfig array<SGZombieAux.dmgScale> FPDmgScale;
