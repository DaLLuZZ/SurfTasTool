public void CreateCommands()
{
	RegConsoleCmd("sm_record_start", Command_StartRecording, "Starts recording of player movement");
	RegConsoleCmd("sm_record_stop", Command_StopRecording, "Stops recording of player movement");
	RegConsoleCmd("sm_record_totas", Command_StoreRecordToTas, "Stores recorded frames to tas");
	RegConsoleCmd("sm_tas_play", Command_BotStartRun, "Starts run of a bot");
	RegConsoleCmd("sm_tick_select", Command_SelectTick, "Use it to select a tick number");
	RegConsoleCmd("sm_prediction_start", Command_BotStartPrediction, "Use it to start trajectory prediction");
	RegConsoleCmd("sm_tas_menu", Command_OpenTasMenu, "Use it to open control menu");
	RegConsoleCmd("sm_goto", Command_GoTo, "Use it to teleport to selected tick");
	RegConsoleCmd("sm_set_int", Command_SetIntValue, "Use to set global int value");
	RegConsoleCmd("sm_set_float", Command_SetFloatValue, "Use to set global float value");
}

public Action Command_StartRecording(int client, int args)
{
	if (!IsValidClient(client))
		return Plugin_Handled;

	StartRecording(client);

	return Plugin_Handled;
}

public Action Command_StopRecording(int client, int args)
{
	if (!IsValidClient(client))
		return Plugin_Handled;

	StopRecording();

	return Plugin_Handled;
}

public Action Command_StoreRecordToTas(int client, int args)
{
	if (!IsValidClient(client))
		return Plugin_Handled;

	StoreRecordToTas();

	return Plugin_Handled;
}

public Action Command_BotStartRun(int client, int args)
{
	// Client can be spectator so don't need to check if he is valid
	BotStartRun();

	return Plugin_Handled;
}

public Action Command_SelectTick(int client, int args)
{
	if (g_hFrames && args && g_hFrames.Length)
	{
		char buff[16];
		GetCmdArg(1, buff, sizeof(buff));
		int wishtick = StringToInt(buff);
		if (wishtick >= 0 && wishtick < g_hFrames.Length)
			g_iSelectedTick = wishtick;
		else
			g_iSelectedTick = g_hFrames.Length - 1;
	}
	else
		g_iSelectedTick = -1;

	return Plugin_Handled;
}

public Action Command_BotStartPrediction(int client, int args)
{
	if (!g_hFrames)
		return Plugin_Handled;

	if (args)
	{
		char buff[16];
		GetCmdArg(1, buff, sizeof(buff));
		int starttick = StringToInt(buff);
		if (starttick >= g_hFrames.Length)
			PrintToChatAll("[TAS] Invalid starttick");
		else
			BotStartPrediction(starttick);
	}
	else
		BotStartPrediction(0);

	return Plugin_Handled;
}

public Action Command_OpenTasMenu(int client, int args)
{
	if (!IsValidClient(client))
		return Plugin_Handled;

	OpenTasMenu(client);

	return Plugin_Handled;
}

public Action Command_GoTo(int client, int args)
{
	if (!g_hFrames || !g_hFrames.Length || g_iSelectedTick < 0)
		return Plugin_Handled;

	if (args)
	{
		char buff[16];
		GetCmdArg(1, buff, sizeof(buff));
		int tick = StringToInt(buff);
		if (tick < 0 || tick >= g_hFrames.Length)
			PrintToChatAll("[TAS] Invalid tick");
		else
			GoToTickPos(client, tick);
	}
	else if (g_iSelectedTick < g_hFrames.Length)
		GoToTickPos(client, g_iSelectedTick);

	return Plugin_Handled;
}

public Action Command_SetIntValue(int client, int args)
{
	if (args)
	{
		char buff[16];
		GetCmdArg(1, buff, sizeof(buff));
		g_iIntValue = StringToInt(buff);
	}
	else
		g_iIntValue = 0;

	return Plugin_Handled;
}

public Action Command_SetFloatValue(int client, int args)
{
	if (args)
	{
		char buff[16];
		GetCmdArg(1, buff, sizeof(buff));
		g_fFloatValue = StringToFloat(buff);
	}
	else
		g_fFloatValue = 0.0;

	return Plugin_Handled;
}