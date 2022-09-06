#pragma semicolon 1

#define PLUGIN_VERSION "1.0"

#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <cstrike>
#include <smlib>

#pragma newdecls required

public Plugin myinfo = 
{
	name = "Surf Tas Tool",
	author = "DaLLuZZ",
	description = "Plugin let you create a surf tas",
	version = PLUGIN_VERSION,
	url = "https://steamcommunity.com/id/DaLLuZZ/"
}

enum struct FrameInfo
{
	int buttons; // buttons the player should press to move in this frame
	float angRel[3]; // relative angles (comparing to previous frame) = ang - oldang
	float ang[3]; // absolute angles = oldang + angRel
	float pos[3]; // absolute position of the player before any movement calculations 
	float vel[3]; // absolute velocity of the player before any movement calculations
	bool autostrafe; // is autostrafe used for this frame?
}

enum struct FileHeader
{
	float pos[3]; // Initial position
	float ang[3]; // Initial angles
}

// Saved to tas frames, starts from 0
ArrayList g_hFrames;

// Saved initial header
FileHeader g_Header;

// Currently selected tick number to edit
int g_iSelectedTick;

// Frame Control Options
int g_iFramesToAdd = 1; // amount of frames to add or delete per menu action select (frame control menu)
bool g_bCopyTurn = true; // should copy angRel + buttons or not?

// Float and int values to read and store from chat/console
float g_fFloatValue;
int g_iIntValue;

#include "TasTool/convars.sp"
#include "TasTool/movement.sp"
#include "TasTool/bot.sp"
#include "TasTool/recording.sp"
#include "TasTool/commands.sp"
#include "TasTool/trajectory.sp"
#include "TasTool/menus.sp"
#include "TasTool/hud.sp"

public void OnPluginStart()
{
	CreateCommands();
	HookEvent("player_spawn", Event_OnPlayerSpawn, EventHookMode_Post);
}

public void OnConfigsExecuted()
{
	CheckConVars();
}

public void OnMapStart()
{
	// To draw trajectory
	g_iBeamSprite = PrecacheModel("materials/sprites/laserbeam.vmt", true);
	g_iHaloSprite = PrecacheModel("materials/sprites/halo.vmt", true);
}

public Action Event_OnPlayerSpawn(Event hEvent, const char[] szName, bool bDontBroadcast)
{
	int client = GetClientOfUserId(hEvent.GetInt("userid"));
	SetEntityRenderMode(client, RENDER_NONE);
	return Plugin_Continue;
}

public void OnClientPutInServer(int client)
{
	SDKHook(client, SDKHook_OnTakeDamage, Hook_OnTakeDamage);
	if (!IsFakeClient(client))
		CreateTimer(0.1, HudTextTimer, GetClientUserId(client), TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
}

public bool IsValidClient(int client)
{
	if (client > 0 && client <= MaxClients && IsClientInGame(client))
		return true;

	return false;
}

public void OnGameFrame()
{
	for (int client = 1; client <= MaxClients; client++)
	{
		if (IsValidClient(client))
		{

		}
	}
}

/**
 * Prevent taking damage
 */
public Action Hook_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
	return Plugin_Handled;
}

public void OnClientDisconnect(int client)
{
	SDKUnhook(client, SDKHook_OnTakeDamage, Hook_OnTakeDamage);
}

/**
 * CBasePlayer::PlayerRunCommand hooked
 */
public Action OnPlayerRunCmd(int client, int &buttons, int &impulse, float vel[3], float angles[3], int &weapon, int &subtype, int &cmdnum, int &tickcount, int &seed, int mouse[2])
{
	if (!IsValidClient(client))
		return Plugin_Handled;

	if (weapon != CSWeapon_NONE)
		Client_RemoveAllWeapons(client);

	// Client is not bot
	if (!IsFakeClient(client))
	{
		ShowTrajectory(client);
		// Record frame if we need to record and then return
		if (g_bRecording)
			RecordFrame(client, buttons, angles);
		return Plugin_Continue;
	}

	// From this point we can be sure that client is a bot (fakeclient)

	// Reset bot's inputs
	buttons = 0;
	for (int i = 0; i < 3; i++)
		vel[i] = 0.0;

	// Client is not our TAS bot, so we need to return
	if (client != g_iBot)
		return Plugin_Continue;

	// From this point we can be sure that client is our TAS bot (g_iBot)

	// Sets TAS bot's inputs
	if (g_bInRun)
		BotRun(buttons, angles);
	else if (g_bInPrediction)
		BotPrediction(buttons, angles);

//	angles[1] = ... (yaw) should calc it for every frame to strafe;
//	angles[2] = 0.0; //(roll) zero it because there is no any reason to keep it not zero

// should strafe by angles[1] here
// angles[0] (pitch) is just height of cursor and doesn't have any effect on surfing/bhoping

	// Applies inputs on the TAS bot
	ComputeMove(buttons, vel); // Convert movement buttons to forward- and sidemove values
	TeleportEntity(client, NULL_VECTOR, angles, NULL_VECTOR); // Is there another way to apply angles on bot?

	// Bot's movement should be processed by game, so we need to return Plugin_Continue
	return Plugin_Continue;
}
