float TICKRATE;
float TICK_INTERVAL;

ConVar hforwardspeed;
float cl_forwardspeed;

ConVar hbackspeed;
float cl_backspeed;

ConVar hsidespeed;
float cl_sidespeed;

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
}

public void OnConVarChanged(Handle hConVar, const char[] oldValue, const char[] newValue)
{
	if (hConVar == hforwardspeed)
		cl_forwardspeed = GetConVarFloat(hforwardspeed);
	else if (hConVar == hbackspeed)
		cl_backspeed = GetConVarFloat(hbackspeed);
	else if (hConVar == hsidespeed)
		cl_sidespeed = GetConVarFloat(hsidespeed);
}