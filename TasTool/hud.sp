public Action HudTextTimer(Handle timer, any userid)
{
	int client = GetClientOfUserId(userid);

	if (IsValidClient(client) && IsClientInGame(client))
	{
		char szHudText[128];

		if (!g_hFrames)
		    FormatEx(szHudText, sizeof(szHudText), "Tick: N/A\n");
		else
		{
		    FrameInfo Frame;
		    g_hFrames.GetArray(g_iSelectedTick, Frame, sizeof(FrameInfo));

		    // Get all speedtypes
		    float speedXYZ = GetVectorLength(Frame.vel);
		    float speedXY = SquareRoot(Frame.vel[0]*Frame.vel[0] + Frame.vel[1]*Frame.vel[1]);
		    float speedZ = Frame.vel[2];

		    // Get relative yaw
		    float yaw = Frame.angRel[1];

		    // Get buttons
		    char szButtons[32];
		    FormatEx(szButtons, sizeof(szButtons), "Buttons:");
		    if (Frame.buttons & IN_FORWARD)
			Format(szButtons, sizeof(szButtons), "%s +W", szButtons);
		    if (Frame.buttons & IN_BACK)
			Format(szButtons, sizeof(szButtons), "%s +S", szButtons);
		    if (Frame.buttons & IN_MOVELEFT)
			Format(szButtons, sizeof(szButtons), "%s +A", szButtons);
		    if (Frame.buttons & IN_MOVERIGHT)
			Format(szButtons, sizeof(szButtons), "%s +D", szButtons);
		    if (Frame.buttons & IN_DUCK)
			Format(szButtons, sizeof(szButtons), "%s +C", szButtons);
		    if (Frame.buttons & IN_JUMP)
			Format(szButtons, sizeof(szButtons), "%s +J", szButtons);

		    // Get time (todo: g_iSelectedTick - g_iStartRunTick), g_iStartRunTick to fileheader
		    float time = g_iSelectedTick * TICK_INTERVAL;

		    // Format text
		    FormatEx(szHudText, sizeof(szHudText), "Tick: %i/%i\nTime: %.2f\nXY: %.2f\nXYZ: %.2f\nZ: %.2f\nYawRel: %.2f\n%s", g_iSelectedTick, g_hFrames.Length, time, speedXY, speedXYZ, speedZ, yaw, szButtons);
		}
		// Todo: consider using SetHedTextParams() instead, no need to have effect color (?)
		// Todo: params are set globally, no need to do it every timer elapse
			SetHudTextParamsEx(0.7, 0.35, 1.0, {255, 0, 0, 0}, {255, 255, 255, 0}, 0, 0.0, 0.0, 0.0);
			ShowHudText(client, 2, szHudText);
		}
	else
		return Plugin_Stop;

	return Plugin_Continue;
}
