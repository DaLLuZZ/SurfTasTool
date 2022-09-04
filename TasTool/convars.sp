#define MAX_LINEAR_SPEED 450.0

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

ConVar hstopspeed;
float sv_stopspeed;

ConVar hfriction;
float sv_friction;

ConVar haccelerate;
float sv_accelerate;

public void CheckConVars()
{
	TICK_INTERVAL = GetTickInterval();
	TICKRATE = 1.0 / TICK_INTERVAL;

	hforwardspeed = FindConVar("cl_forwardspeed");
	if (hforwardspeed)
	{
		cl_forwardspeed = GetConVarFloat(hforwardspeed);
		HookConVarChange(hforwardspeed, OnConVarChanged);
	}
	else
		cl_forwardspeed = MAX_LINEAR_SPEED;

	hbackspeed = FindConVar("cl_backspeed");
	if (hbackspeed)
	{
		cl_backspeed = GetConVarFloat(hbackspeed);
		HookConVarChange(hbackspeed, OnConVarChanged);
	}
	else
		cl_backspeed = MAX_LINEAR_SPEED;

	hsidespeed = FindConVar("cl_sidespeed");
	if (hsidespeed)
	{
		cl_sidespeed = GetConVarFloat(hsidespeed);
		HookConVarChange(hsidespeed, OnConVarChanged);
	}
	else
		cl_sidespeed = MAX_LINEAR_SPEED;

	hairaccelerate = FindConVar("sv_airaccelerate");
	sv_airaccelerate = GetConVarFloat(hairaccelerate);
	HookConVarChange(hairaccelerate, OnConVarChanged);

	hmaxspeed = FindConVar("sv_maxspeed");
	sv_maxspeed = GetConVarFloat(hmaxspeed);
	HookConVarChange(hmaxspeed, OnConVarChanged);

	hairmaxwishspeed = FindConVar("sv_air_max_wishspeed");
	sv_air_max_wishspeed = GetConVarFloat(hairmaxwishspeed);
	HookConVarChange(hairmaxwishspeed, OnConVarChanged);

	hstopspeed = FindConVar("sv_stopspeed");
	sv_stopspeed = GetConVarFloat(hstopspeed);
	HookConVarChange(hstopspeed, OnConVarChanged);

	hfriction = FindConVar("sv_friction");
	sv_friction = GetConVarFloat(hfriction);
	HookConVarChange(hfriction, OnConVarChanged);

	haccelerate = FindConVar("sv_accelerate");
	sv_accelerate = GetConVarFloat(haccelerate);
	HookConVarChange(haccelerate, OnConVarChanged);

	ServerCommand("sv_cheats 1; mp_friendlyfire 0; mp_afterroundmoney 0; mp_autokick 0; mp_autoteambalance 0; mp_do_warmup_period 0; mp_free_armor 0; mp_freezetime 0; mp_match_end_restart 0; mp_playercashawards 0; mp_playerid 0; mp_playerid_delay 0; mp_playerid_hold 0; mp_round_restart_delay 10; mp_solid_teammates 0; mp_startmoney 0; mp_maxmoney 0; mp_teamcashawards 0; mp_timelimit 0; mp_roundtime 30; mp_warmuptime 0; mp_weapons_allow_zeus 0; mp_win_panel_display_time 5; sv_pure 0; sv_allow_votes 0; sv_deadtalk 1; sv_infinite_ammo 0; sv_log_onefile 0; sv_logfile 1; sv_region 255; sv_voiceenable 1; sv_allowdownload 1; sv_allowupload 1; sv_hibernate_when_empty 0; sv_hibernate_postgame_delay 0; net_maxfilesize 256; sv_lan 0; sv_hibernate_ms 0; sv_hibernate_ms_vgui 0; host_info_show 1; host_players_show 2; sv_staminalandcost 0; sv_staminajumpcost 0; sv_staminamax 0; sv_maxspeed 350; sv_gravity 800; sv_airaccelerate 150; sv_friction 4.8; sv_accelerate 10; sv_ladder_scale_speed 1; sv_enablebunnyhopping 1; sv_cheats 1; bot_chatter off; bot_join_after_player 0; bot_quota 1; bot_quota_mode normal; mp_autoteambalance 0; mp_free_armor 1; mp_ignore_round_win_conditions 1; mp_limitteams 0; mp_playerid 0; mp_spectators_max 64; mp_drop_knife_enable 1; mp_maxmoney 0; sv_allow_votes 0; sv_infinite_ammo 2; sv_alltalk 1; sv_deadtalk 1; sv_full_alltalk 1; sv_disable_immunity_alpha 1; sv_max_queries_sec 6; sv_clamp_unsafe_velocities 0; weapon_reticle_knife_show 1; host_players_show 2; log on; sm_cvar sv_clamp_unsafe_velocities 0; bot_join_after_player 0; bot_zombie 1; mp_respawn_on_death_ct 1; mp_respawn_on_death_t 1");
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
	else if (hConVar == hstopspeed)
		sv_stopspeed = GetConVarFloat(hstopspeed);
	else if (hConVar == hfriction)
		sv_friction = GetConVarFloat(hfriction);
	else if (hConVar == haccelerate)
		sv_accelerate = GetConVarFloat(haccelerate);
}
