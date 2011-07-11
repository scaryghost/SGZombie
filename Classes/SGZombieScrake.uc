class SGZombieScrake extends ZombieScrake;

function TakeDamage( int Damage, Pawn InstigatedBy, Vector Hitlocation, Vector Momentum, class<DamageType> damageType, optional int HitIndex)
{
	local bool bIsHeadShot;
    local int dmgIndex,oldHealth;

    oldHealth= Health;
    dmgIndex= class'SGZombieMut'.static.findDmgTypeScale(String(damageType),class'SGZombieMut'.default.SCDmgScale);
    if (dmgIndex != -1 && (class'SGZombieMut'.default.SCDmgScale[dmgIndex].bNeedHeadShot && bIsHeadShot || !class'SGZombieMut'.default.SCDmgScale[dmgIndex].bNeedHeadShot) && 
            (class'SGZombieMut'.static.diffToMask(Level.Game.GameDifficulty) & class'SGZombieMut'.default.SCDmgScale[dmgIndex].difficultyMask) != 0) {
        Damage*= class'SGZombieMut'.default.SCDmgScale[dmgIndex].dmgScale;
    }
	Super(KFMonster).TakeDamage(Damage, instigatedBy, hitLocation, momentum, damageType, HitIndex);

    class'SGZombieAux'.static.outputToChat(Level.ControllerList,"SGZombieScrake: Health lost: "$(OldHealth - Health));
	// Added in Balance Round 3 to make the Scrake "Rage" more reliably when his health gets low(limited to Suicidal and HoE in Round 7)
	if ( Level.Game.GameDifficulty >= 5.0 && !IsInState('SawingLoop') && !IsInState('RunningState') && float(Health) / HealthMax < 0.75 )
		RangedAttack(InstigatedBy);
}

