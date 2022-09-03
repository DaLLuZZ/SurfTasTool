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
public void Friction(float vecVelocity[3])
{
	float speed = SquareRoot(vecVelocity[0] * vecVelocity[0] + vecVelocity[1] * vecVelocity[1] + vecVelocity[2] * vecVelocity[2]);

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

	if (sv_maxspeed - accelspeed >= speed)
		return 90.0;

	return RadToDeg(ArcCosine((sv_maxspeed - accelspeed) / speed));
}
