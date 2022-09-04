#define PITCH 0
#define YAW 1
#define ROLL 2

// player
float VEC_VIEW[] = { 0.0, 0.0, 64.0 };
float VEC_HULL_MIN[] = { -16.0, -16.0, 0.0 };
float VEC_HULL_MAX[] = { 16.0, 16.0, 72.0 };
float VEC_DUCK_HULL_MIN[] = {-16.0, -16.0, 0.0 };
float VEC_DUCK_HULL_MAX[] = { 16.0, 16.0, 54.0 };
float VEC_DUCK_VIEW[] = { 0.0, 0.0, 46.0 };

#define CS_PLAYER_SPEED_RUN 260.0

//
// Calculate forward & side components to make fakeclient react on forced movement (walk) buttons
// Called when buttons had been already applied to fakeclient in OnPlayerRunCmd (CBasePlayer::PlayerRunCommand)
//
public void ComputeMove(int &buttons, float vel[3])
{
	// Reset vel
	for (int i = 0; i < 3; i++)
		vel[i] = 0.0;

	// +W and +S
	vel[0] += cl_forwardspeed * (buttons & IN_FORWARD ? 1 : 0);
	vel[0] -= cl_backspeed * (buttons & IN_BACK ? 1 : 0);

	// +A and +D
	vel[1] += cl_sidespeed * (buttons & IN_MOVERIGHT ? 1 : 0);
	vel[1] -= cl_sidespeed * (buttons & IN_MOVELEFT ? 1 : 0);
}

//
// Calculates perfect delta angle (deg) for autostrafing
//
public float GetPerfectDelta(float speed)
{
	float accelspeed = sv_airaccelerate * sv_maxspeed * TICK_INTERVAL;

	if (accelspeed >= sv_air_max_wishspeed) // should clamp it to sv_air_max_wishspeed
		return 90.0; // return 90.0 because ArcCosine(0) is 90 degrees

	return RadToDeg(ArcCosine((sv_air_max_wishspeed - accelspeed) / speed));
}

//
// Reimplementation of CGameMovement::Friction
//
public float Friction(float vecVelocity[3])
{
	float speed = SquareRoot(vecVelocity[0] * vecVelocity[0] + vecVelocity[1] * vecVelocity[1]);

	if (speed < 0.1)
		return 0.0;

	float newspeed = speed - ((speed < sv_stopspeed) ? sv_stopspeed : speed) * sv_friction * TICK_INTERVAL;

	if (newspeed < 0.0)
		newspeed = 0.0;

	float fret = newspeed;

	if (newspeed != speed)
	{
		newspeed /= speed;
		ScaleVector(vecVelocity, newspeed);
	}

	return fret;
}

//
// Calculates perfect gamma angle (deg) for prespeed
// Friction should be applied on speed before calling GetPerfectGamma
//
public float GetPerfectGamma(float speed)
{
	float accelspeed = sv_accelerate * TICK_INTERVAL * (sv_maxspeed > 250.0 ? 250.0 : sv_maxspeed);

	if (CS_PLAYER_SPEED_RUN - accelspeed >= speed)
		return 90.0;

	return RadToDeg(ArcCosine((CS_PLAYER_SPEED_RUN - accelspeed) / speed));
}

/*
SetupMove
move->m_flClientMaxSpeed		= player->m_flMaxspeed;

ProcessMovement
mv->m_flMaxSpeed = pPlayer->GetPlayerMaxSpeed();

NOW mv->m_flMaxSpeed = CS_PLAYER_SPEED_RUN (260.0)

PlayerMove -> CheckParameters
	if ( player->GetMoveType() != MOVETYPE_ISOMETRIC &&
		 player->GetMoveType() != MOVETYPE_NOCLIP &&
		 player->GetMoveType() != MOVETYPE_OBSERVER )
	{
		float spd;
		float maxspeed;

		spd = ( mv->m_flForwardMove * mv->m_flForwardMove ) +
			  ( mv->m_flSideMove * mv->m_flSideMove ) +
			  ( mv->m_flUpMove * mv->m_flUpMove );

		maxspeed = mv->m_flClientMaxSpeed;
		if ( maxspeed != 0.0 )
		{
			mv->m_flMaxSpeed = MIN( maxspeed, mv->m_flMaxSpeed );
		}

		// Slow down by the speed factor
		float flSpeedFactor = 1.0f;
		if (player->m_pSurfaceData)
		{
			flSpeedFactor = player->m_pSurfaceData->game.maxSpeedFactor;
		}

		// If we have a constraint, slow down because of that too.
		float flConstraintSpeedFactor = ComputeConstraintSpeedFactor();
		if (flConstraintSpeedFactor < flSpeedFactor)
			flSpeedFactor = flConstraintSpeedFactor;

		mv->m_flMaxSpeed *= flSpeedFactor;

		if ( g_bMovementOptimizations )
		{
			// Same thing but only do the sqrt if we have to.
			if ( ( spd != 0.0 ) && ( spd > mv->m_flMaxSpeed*mv->m_flMaxSpeed ) )
			{
				float fRatio = mv->m_flMaxSpeed / sqrt( spd );
				mv->m_flForwardMove *= fRatio;
				mv->m_flSideMove    *= fRatio;
				mv->m_flUpMove      *= fRatio;
			}
		}
		else
		{
			spd = sqrt( spd );
			if ( ( spd != 0.0 ) && ( spd > mv->m_flMaxSpeed ) )
			{
				float fRatio = mv->m_flMaxSpeed / spd;
				mv->m_flForwardMove *= fRatio;
				mv->m_flSideMove    *= fRatio;
				mv->m_flUpMove      *= fRatio;
			}
		}
	}

FullWalkMove -> StartGravity

FullWalkMove -> Friction

FullWalkMove -> CheckVelocity (just checks sv_maxvelocity on axes)

WalkMove
wishvel and wishspeed clampled to mv->m_flMaxSpeed
mv->m_vecVelocity[2] = 0;

Accelerate()


First
void CGameMovement::StartGravity( void )
{
	float ent_gravity;
	
	if (player->GetGravity())
		ent_gravity = player->GetGravity();
	else
		ent_gravity = 1.0;

	// Add gravity so they'll be in the correct position during movement
	// yes, this 0.5 looks wrong, but it's not.  
	mv->m_vecVelocity[2] -= (ent_gravity * sv_gravity.GetFloat() * 0.5 * gpGlobals->frametime );
	mv->m_vecVelocity[2] += player->GetBaseVelocity()[2] * gpGlobals->frametime;

	Vector temp = player->GetBaseVelocity();
	temp[ 2 ] = 0;
	player->SetBaseVelocity( temp );

	CheckVelocity();
}

Second Friction
*/
