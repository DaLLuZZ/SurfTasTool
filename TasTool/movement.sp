#define PITCH 0
#define YAW 1
#define ROLL 2

#define MAX_LINEAR_SPEED 450.0

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
