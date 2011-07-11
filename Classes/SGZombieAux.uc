class SGZombieAux extends Object;

static function outputToChat(Controller controllerList, string msg) {
    local Controller C;

    if (!class'SGZombieMut'.default.bLog)
        return;

    for (C = controllerList; C != None; C = C.NextController) {
        if (PlayerController(C) != None) {
            PlayerController(C).ClientMessage(msg);
        }
    }
}
