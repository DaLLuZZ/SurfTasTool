float TICKRATE;
float TICK_INTERVAL;

ConVar hforwardspeed;
float cl_forwardspeed;

ConVar hbackspeed;
float cl_backspeed;

ConVar hsidespeed;
float cl_sidespeed;

ConVar hairaccelerate;
float sv_airaccelerate;

ConVar hmaxspeed;
float sv_maxspeed;

ConVar hairmaxwishspeed;
float sv_air_max_wishspeed;

public void CheckConVars()
{
	TICK_INTERVAL = GetTickInterval();
	TICKRATE = 1.0 / TICK_INTERVAL;

	hforwardspeed = FindConVar("cl_forwardspeed");
	cl_forwardspeed = GetConVarFloat(hforwardspeed);
	HookConVarChange(hforwardspeed, OnConVarChanged);

	hbackspeed = FindConVar("cl_backspeed");
	cl_backspeed = GetConVarFloat(hbackspeed);
	HookConVarChange(hbackspeed, OnConVarChanged);

	hsidespeed = FindConVar("cl_sidespeed");
	cl_sidespeed = GetConVarFloat(hsidespeed);
	HookConVarChange(hsidespeed, OnConVarChanged);

	hairaccelerate = FindConVar("sv_airaccelerate");
	sv_airaccelerate = GetConVarFloat(hairaccelerate);
	HookConVarChange(hairaccelerate, OnConVarChanged);

	hmaxspeed = FindConVar("sv_maxspeed");
	sv_maxspeed = GetConVarFloat(hmaxspeed);
	HookConVarChange(hmaxspeed, OnConVarChanged);

	hairmaxwishspeed = FindConVar("sv_air_max_wishspeed");
	sv_air_max_wishspeed = GetConVarFloat(hairmaxwishspeed);
	HookConVarChange(hairmaxwishspeed, OnConVarChanged);
}

public void OnConVarChanged(Handle hConVar, const char[] oldValue, const char[] newValue)
{
	if (hConVar == hforwardspeed)
		cl_forwardspeed = GetConVarFloat(hforwardspeed);
	else if (hConVar == hbackspeed)
		cl_backspeed = GetConVarFloat(hbackspeed);
	else if (hConVar == hsidespeed)
		cl_sidespeed = GetConVarFloat(hsidespeed);
	else if (hConVar == hairaccelerate)
		sv_airaccelerate = GetConVarFloat(hairaccelerate);
	else if (hConVar == hmaxspeed)
		sv_maxspeed = GetConVarFloat(hmaxspeed);
	else if (hConVar == hairmaxwishspeed)
		sv_air_max_wishspeed = GetConVarFloat(hairmaxwishspeed);
}
