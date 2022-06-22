// Frames to save, starts from 0
ArrayList g_hRecording;

// Should we record smth?
bool g_bRecording;

public void StartRecording(int client)
{
	// Delete old recording
	DeleteRecording();

	if (!g_hFrames || g_iSelectedTick < 0)
	{
		// Starting new tas
		TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, view_as<float>({0.0, 0.0, 0.0}));
		GetClientAbsOrigin(client, g_Header.pos);
		GetClientEyeAngles(client, g_Header.ang);
	}
	else
	{
		// Continue tas or replace frames in tas and continue...
		FrameInfo Frame;
		g_hFrames.GetArray(g_iSelectedTick, Frame, sizeof(FrameInfo));
		TeleportEntity(client, Frame.pos, Frame.ang, Frame.vel);
	}

	PrintToChatAll("[TAS] Recording started, waiting for inputs...");
	g_hRecording = new ArrayList(sizeof(FrameInfo));
	g_bRecording = true;
}

public void RecordFrame(int client, int buttons, float angles[3])
{
	if (!g_hRecording)
		return;

	float oldang[3];
	float oldpos[3];
	float oldvel[3];
	GetClientEyeAngles(client, oldang);
	GetClientAbsOrigin(client, oldpos);
	GetEntPropVector(client, Prop_Data, "m_vecAbsVelocity", oldvel);
	float angRel[3];
	SubtractVectors(angles, oldang, angRel);

	// Check that client has started moving
	if (!oldvel[0] && !oldvel[1] && !oldvel[2] && !buttons)
	{
		PrintToConsole(client, "[TAS] Waiting for your movement to record");
		return;
	}

	FrameInfo Frame;
	Frame.buttons = buttons;
	Frame.ang = angles;
	Frame.angRel = angRel;
	Frame.pos = oldpos;
	Frame.vel = oldvel;

	g_hRecording.PushArray(Frame);
}

public void StopRecording()
{
	if (!g_bRecording)
		PrintToChatAll("[TAS] Recording had been already stopped");
	g_bRecording = false;
}

public void StoreRecordToTas()
{
	// If nothing was recorded
	if (!g_hRecording)
	{
		PrintToChatAll("[TAS] No any frames were recorded");
		return;
	}

	if (g_hFrames && g_iSelectedTick++ != g_hFrames.Length)
		g_hFrames.Resize(g_iSelectedTick);
	else if (!g_hFrames)
		g_hFrames = new ArrayList(sizeof(FrameInfo));

	for (int i = 0; i < g_hRecording.Length; i++)
	{
		FrameInfo Frame;
		g_hRecording.GetArray(i, Frame, sizeof(FrameInfo));
		g_hFrames.PushArray(Frame, sizeof(FrameInfo));
	}

	// Delete cause we don't need to keep in anymore
	DeleteRecording();
}

public void DeleteRecording()
{
	if (g_hRecording)
		delete g_hRecording;
}

public void GoToTickPos(int client, int tick)
{
	FrameInfo Frame;
	g_hFrames.GetArray(tick, Frame, sizeof(FrameInfo));
	AddVectors(Frame.ang, Frame.angRel, Frame.ang);
	TeleportEntity(client, Frame.pos, Frame.ang, view_as<float>({0.0, 0.0, 0.0}));
}