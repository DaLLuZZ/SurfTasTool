// Bot index
int g_iBot;

// Is bot running a map? (playing created tas)
bool g_bInRun;
int g_iCurrentRunTick;

// Is bot predicting movement?
bool g_bInPrediction;
int g_iPredictionTick;

// Find an alive fakeclient and save index to global variable
public void FindBotIndex()
{
	g_iBot = -1;
	for (int i = 1; i < MaxClients; i++)
	{
		if (IsClientConnected(i) && IsClientInGame(i) && IsFakeClient(i) && IsPlayerAlive(i))
		{
			g_iBot = i;
			break;
		}
	}
}

// Starts bot's run
public void BotStartRun()
{
	// Check if there is a bot to use
	FindBotIndex();
	if (g_iBot < 1)
		return;

	// Make him visible
	SetEntityRenderMode(g_iBot, RENDER_NORMAL);
	TeleportEntity(g_iBot, g_Header.pos, g_Header.ang, view_as<float>({0.0, 0.0, 0.0}));
	g_iCurrentRunTick = 0;
	g_bInRun = true;
}

// Sets inputs for current run tick from g_hFrames
public void BotRun(int &buttons, float angles[3])
{
	// Stop run if there are no frames anymore
	if (g_iCurrentRunTick >= g_hFrames.Length)
	{
		BotStopRun();
		return;
	}

	FrameInfo Frame;
	g_hFrames.GetArray(g_iCurrentRunTick, Frame, sizeof(FrameInfo));

	buttons = Frame.buttons;
	angles = Frame.ang;

	g_iCurrentRunTick++;
	PrintToConsoleAll("[TAS] Playing %i/%i, delta %.2f", g_iCurrentRunTick, g_hFrames.Length, BotGetDeltaPos());
}

void BotStopRun(bool bPause = false)
{
	PrintToConsoleAll("[TAS] BotStopRun");
	g_bInRun = false;
	if (!bPause)
		g_iCurrentRunTick = -1;
	else
		PrintToConsoleAll("[TAS] Bot's Run Paused");
	SetEntityRenderMode(g_iBot, RENDER_NONE);
}

// Returns a difference between bot's current pos and his predicted pos during this frame
public float BotGetDeltaPos()
{
	if (!g_bInRun && !g_bInPrediction)
		return -1.0;

	FrameInfo Frame;

	if (g_bInRun)
		g_hFrames.GetArray(g_iCurrentRunTick - 1, Frame, sizeof(FrameInfo));
	else if (g_bInPrediction)
		g_hFrames.GetArray(g_iPredictionTick - 1, Frame, sizeof(FrameInfo));

	float pos[3];
	GetClientAbsOrigin(g_iBot, pos);

	return GetVectorDistance(pos, Frame.pos);
}

public void BotStartPrediction(int starttick)
{
	if (!g_hFrames || starttick >= g_hFrames.Length)
		return;

	// Check if there is a bot to use
	FindBotIndex();
	if (g_iBot < 1)
		return;

	// He should be invisible
	SetEntityRenderMode(g_iBot, RENDER_NONE);

	if (!starttick)
		TeleportEntity(g_iBot, g_Header.pos, g_Header.ang, view_as<float>({0.0, 0.0, 0.0}));
	else
	{
		FrameInfo Frame;
		g_hFrames.GetArray(starttick, Frame, sizeof(FrameInfo));
		SubtractVectors(Frame.ang, Frame.angRel, Frame.ang);
		TeleportEntity(g_iBot, Frame.pos, Frame.ang, Frame.vel);
	}

	g_iPredictionTick = starttick;
	g_bInPrediction = true;
}

public void BotPrediction(int &buttons, float angles[3])
{
	// Stop prediction if there are no frames to predict anymore
	if (g_iPredictionTick >= g_hFrames.Length)
	{
		BotStopPrediction();
		return;
	}

	FrameInfo Frame;
	g_hFrames.GetArray(g_iPredictionTick, Frame, sizeof(FrameInfo));

	buttons = Frame.buttons;
	angles = Frame.ang;

	// save predicted pos and vel to array
	GetClientAbsOrigin(g_iBot, Frame.pos);
	GetEntPropVector(g_iBot, Prop_Data, "m_vecAbsVelocity", Frame.vel);
	g_hFrames.SetArray(g_iPredictionTick, Frame, sizeof(FrameInfo));

	g_iPredictionTick++;
	PrintToConsoleAll("[TAS] Prediction %i/%i, delta %.2f", g_iPredictionTick, g_hFrames.Length, BotGetDeltaPos());
}

public void BotStopPrediction()
{
	g_bInPrediction = false;
	PrintToConsoleAll("[TAS] BotStopPrediction");
	g_iPredictionTick = 0;
}

public void CheckRelAngles(int startframe)
{
	if (!g_hFrames || !g_hFrames.Length || startframe >= g_hFrames.Length || startframe < 0)
		return;

	FrameInfo Frame;
	float oldang[3];
	if (!startframe)
		oldang = g_Header.ang;
	else
	{
		g_hFrames.GetArray(startframe - 1, Frame, sizeof(FrameInfo));
		oldang = Frame.ang;
	}

	int changed = -1;

	for (int i = startframe; i < g_hFrames.Length; i++)
	{
		g_hFrames.GetArray(i, Frame, sizeof(FrameInfo));
		AddVectors(oldang, Frame.angRel, Frame.angRel);
		if (Frame.angRel[1] == Frame.ang[1]) // is there any reason to check not only yaw but pitch?
		{
			oldang = Frame.ang;
			continue;
		}
		else
		{
			if (changed != -1 && i)
				changed = i - 1;
			SubtractVectors(Frame.ang, oldang, Frame.angRel);
			g_hFrames.SetArray(i, Frame, sizeof(FrameInfo));
		}
	}

	if (changed != -1)
		BotStartPrediction(changed);
}

public void CheckAbsAngles(int startframe)
{
	if (!g_hFrames || !g_hFrames.Length || startframe >= g_hFrames.Length || startframe < 0)
		return;

	FrameInfo Frame;
	float oldang[3];
	if (!startframe)
		oldang = g_Header.ang;
	else
	{
		g_hFrames.GetArray(startframe - 1, Frame, sizeof(FrameInfo));
		oldang = Frame.ang;
	}

	int changed = -1;

	for (int i = startframe; i < g_hFrames.Length; i++)
	{
		g_hFrames.GetArray(i, Frame, sizeof(FrameInfo));
		AddVectors(oldang, Frame.angRel, oldang);
		if (Frame.ang[1] != oldang[1]) // is there any reason to check not only yaw but pitch?
		{
			if (changed != -1 && i)
				changed = i - 1;
			Frame.ang = oldang;
			g_hFrames.SetArray(i, Frame, sizeof(FrameInfo));
		}
	}

	if (changed != -1)
		BotStartPrediction(changed);
}