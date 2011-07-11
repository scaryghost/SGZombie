class SGZombieFleshpound extends ZombieFleshpound_CIRCUS;

function TakeDamage( int Damage, Pawn InstigatedBy, Vector Hitlocation, Vector Momentum, class<DamageType> damageType, optional int HitIndex)
{
	local int BlockSlip, OldHealth, dmgIndex;
	local float BlockChance;//, RageChance;
	local Vector X,Y,Z, Dir;
	local bool bIsHeadShot;
	local float HeadShotCheckScale;

	GetAxes(Rotation, X,Y,Z);

	if( LastDamagedTime<Level.TimeSeconds )
		TwoSecondDamageTotal = 0;
	LastDamagedTime = Level.TimeSeconds+2;
	OldHealth = Health; // Corrected issue where only the Base Health is counted toward the FP's Rage in Balance Round 6(second attempt)

    HeadShotCheckScale = 1.0;

    // Do larger headshot checks if it is a melee attach
    if( class<DamTypeMelee>(damageType) != none )
    {
        HeadShotCheckScale *= 1.25;
    }

    bIsHeadShot = IsHeadShot(Hitlocation, normal(Momentum), 1.0);

    dmgIndex= class'SGZombieMut'.static.findDmgTypeScale(String(damageType),class'SGZombieMut'.default.FPDmgScale);
    if (dmgIndex != -1 && (class'SGZombieMut'.default.FPDmgScale[dmgIndex].bNeedHeadShot && bIsHeadShot || !class'SGZombieMut'.default.FPDmgScale[dmgIndex].bNeedHeadShot) && 
            (class'SGZombieMut'.static.diffToMask(Level.Game.GameDifficulty) & class'SGZombieMut'.default.FPDmgScale[dmgIndex].difficultyMask) != 0) {
        Damage*= class'SGZombieMut'.default.FPDmgScale[dmgIndex].dmgScale;
    } else {
        Damage*= 0.5;
    }

	// Shut off his "Device" when dead
	if (Damage >= Health)
		PostNetReceive();

	// Damage Berserk responses...
	// Start a charge.
	// The Lower his health, the less damage needed to trigger this response.
	//RageChance = (( HealthMax / Health * 300) - TwoSecondDamageTotal );

	// Calculate whether the shot was coming from in front.
	Dir = -Normal(Location - hitlocation);
	BlockSlip = rand(5);

	if (AnimAction == 'PoundBlock')
		Damage *= BlockDamageReduction;

	if (Dir Dot X > 0.7 || Dir == vect(0,0,0))
		BlockChance = (Health / HealthMax * 100 ) - Damage * 0.25;


	// We are healthy enough to block the attack, and we succeeded the blockslip.
	// only 40% damage is done in this circumstance.
	//TODO - bring this back?

	// Log (Damage);

	Super(KFMonster).takeDamage(Damage, instigatedBy, hitLocation, momentum, damageType,HitIndex) ;

	TwoSecondDamageTotal += OldHealth - Health; // Corrected issue where only the Base Health is counted toward the FP's Rage in Balance Round 6(second attempt)

    class'SGZombieAux'.static.outputToChat(Level.ControllerList,"SGZombieFleshpound: Health lost: "$(OldHealth - Health));
    class'SGZombieAux'.static.outputToChat(Level.ControllerList,"SGZombieFleshpound: Damage type: "$(String(damageType)));

	if (!bDecapitated && TwoSecondDamageTotal > RageDamageThreshold && !bChargingPlayer &&
        (!(bCrispified && bBurnified) || bFrustrated) )
		StartCharging();

}

