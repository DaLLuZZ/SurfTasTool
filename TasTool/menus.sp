/**
 * Tas Main Menu (OpenTasMenu)
 * * Tas Helpers Menu (OpenTasHelpersMenu)
 * * * Strafe Control Menu (OpenStrafeControlMenu)
 * * * * Strafe Algorithm Selector Menu (TODO)
 * * * Board Control Menu (TODO)
 * * Frame Control Menu (OpenFrameControlMenu)
 * * * Edit single selected frame menu (OpenEditFrameMenu)
 * * * * Edit single selected frame buttons menu (OpenEditFrameButtonsMenu)
 * * * * Edit single selected frame Relative Yaw menu (OpenEditFrameRelYawMenu)
 */

/**
 * Opens Tas Main Menu
 */
public void OpenTasMenu(int client)
{
	Menu menu = new Menu(TasMainMenuHandler);

	menu.SetTitle("Surf Tas");
	menu.AddItem("0", "Helpers");
	menu.AddItem("1", "Frames");

	menu.Display(client, MENU_TIME_FOREVER);
}

/**
 * Surf Tas
 * 1. Helpers
 * 2. Frames
 */
public int TasMainMenuHandler(Menu menu, MenuAction action, int param1, int param2)
{
	switch (action)
	{
		case MenuAction_Select:
		{
			switch (param2)
			{
				case 0: OpenTasHelpersMenu(param1);
				case 1: OpenFrameControlMenu(param1);
			}
		}
		case MenuAction_End:
			delete menu;
	}
}

/**
 * Opens Tas Helpers Menu
 */
public void OpenTasHelpersMenu(int client)
{
	Menu menu = new Menu(TasHelpersMenuHandler);

	menu.SetTitle("Surf Tas Helpers");
	menu.AddItem("0", "Strafe");
	menu.AddItem("1", "Board");

	menu.Display(client, MENU_TIME_FOREVER);
}

/**
 * Surf Tas Helpers
 * 1. Strafe
 * 2. Board
 */
public int TasHelpersMenuHandler(Menu menu, MenuAction action, int param1, int param2)
{
	switch (action)
	{
		case MenuAction_Select:
		{
			switch (param2)
			{
				case 0: OpenStrafeControlMenu(param1);
				//case 1: landing help
			}
		}
		case MenuAction_Cancel:
		{
			if (param2 == MenuCancel_Exit)
				OpenTasMenu(param1);
		}
		case MenuAction_End:
			delete menu;
	}
}

/**
 * Opens Strafe Control Menu
 */
public void OpenStrafeControlMenu(int client)
{
	Menu menu = new Menu(StrafeControlMenuHandler);

	menu.SetTitle("Strafe Control");
	menu.AddItem("0", "Algorithm");

	menu.Display(client, MENU_TIME_FOREVER);
}

/**
 * Strafe Control
 * 1. Algorithm
 */
public int StrafeControlMenuHandler(Menu menu, MenuAction action, int param1, int param2)
{
	switch (action)
	{
		case MenuAction_Select:
		{
			switch (param2)
			{
				//case 0: algorithm selector menu...
			}
		}
		case MenuAction_Cancel:
		{
			if (param2 == MenuCancel_Exit)
				OpenTasHelpersMenu(param1);
		}
		case MenuAction_End:
			delete menu;
	}
}

/**
 * Opens Frame Control Menu
 */
public void OpenFrameControlMenu(int client)
{
	Menu menu = new Menu(FrameControlMenuHandler);

	menu.SetTitle("Manage Frames");
	menu.AddItem("0", "Add");
	menu.AddItem("1", "Delete");

	char szAmount[16];
	FormatEx(szAmount, sizeof(szAmount), "Amount: %i", g_iFramesToAdd);
	menu.AddItem("2", szAmount);

	char szCopy[16];
	FormatEx(szCopy, sizeof(szCopy), "Copy: %s", g_bCopyTurn ? "turn" : "cmd"); // turn will copy relAng and buttons, cmd - ang instead of relang
	menu.AddItem("3", szCopy);

	menu.AddItem("4", "Select Last");
	menu.AddItem("5", "Edit selected");

	menu.Display(client, MENU_TIME_FOREVER);
}

/**
 * Manage Frames
 * 1. Add
 * 2. Delete
 * 3. Amount: {g_iFramesToAdd}
 * 4. Copy: "turn" / "cmd"
 * 5. Select Last
 * 6. Edit selected
 */
public int FrameControlMenuHandler(Menu menu, MenuAction action, int param1, int param2)
{
	switch (action)
	{
		case MenuAction_Select:
		{
			switch (param2)
			{
				case 0: AddFrames(g_iFramesToAdd, g_bCopyTurn);
				case 1: RemoveFrames(g_iFramesToAdd);
				case 2: g_iFramesToAdd = (g_iFramesToAdd > TICKRATE ? 1 : (2 * g_iFramesToAdd));
				case 3: g_bCopyTurn = !g_bCopyTurn;
				case 4: g_iSelectedTick = (g_hFrames && g_hFrames.Length) ? (g_hFrames.Length - 1) : -1;
				case 5:
				{
					OpenEditFrameMenu(param1, g_iSelectedTick);
					return;
				}
			}
			OpenFrameControlMenu(param1);
		}
		case MenuAction_Cancel:
		{
			if (param2 == MenuCancel_Exit)
				OpenTasMenu(param1);
		}
		case MenuAction_End:
			delete menu;
	}
}

public void AddFrames(int toadd, bool turncopy)
{
	if (!g_hFrames)
		return;

	for (int i = 0; i < toadd; i++)
	{
		FrameInfo Frame;
		g_hFrames.GetArray(g_hFrames.Length - 1, Frame, sizeof(FrameInfo));
		if (turncopy)
			AddVectors(Frame.ang, Frame.angRel, Frame.ang);
		else
			Frame.angRel = {0.0, 0.0, 0.0};
		float velS[3];
		velS = Frame.vel;
		ScaleVector(velS, TICK_INTERVAL);
		AddVectors(Frame.pos, velS, Frame.pos);
		g_hFrames.PushArray(Frame, sizeof(FrameInfo));
	}

	BotStartPrediction(g_hFrames.Length - toadd - 1);
}

public void RemoveFrames(int toremove)
{
	if (!g_hFrames)
		return;

	if (g_hFrames.Length <= toremove)
		g_hFrames.Resize(1);
	else
		g_hFrames.Resize(g_hFrames.Length - toremove);

	if (g_iSelectedTick >= g_hFrames.Length)
		g_iSelectedTick = g_hFrames.Length - 1;
}

/**
 * Opens Single Selected Frame Edit Menu
 */
public void OpenEditFrameMenu(int client, int frame)
{
	if (!g_hFrames || g_hFrames.Length <= frame || frame < 0)
		return;

	Menu menu = new Menu(EditFrameMenuHandler);

	menu.SetTitle("Edit Selected Frame");
	menu.AddItem("0", "Buttons");
	menu.AddItem("1", "RelYaw");
	menu.AddItem("2", "RelPitch");

	menu.Display(client, MENU_TIME_FOREVER);
}

/**
 * Edit Selected Frame
 * 1. Buttons
 * 2. RelYaw
 * 3. RelPitch
 */
public int EditFrameMenuHandler(Menu menu, MenuAction action, int param1, int param2)
{
	switch (action)
	{
		case MenuAction_Select:
		{
			switch (param2)
			{
				case 0: OpenEditFrameButtonsMenu(param1);
				case 1: OpenEditFrameRelYawMenu(param1);
//				case 2: OpenEditFrameRelPitchMenu(param1);
			}
		}
		case MenuAction_Cancel:
		{
			if (param2 == MenuCancel_Exit)
				OpenFrameControlMenu(param1);
		}
		case MenuAction_End:
			delete menu;
	}
}

/**
 * Opens Single Selected Frame Edit Buttons Menu
 */
public void OpenEditFrameButtonsMenu(int client)
{
	FrameInfo Frame;
	g_hFrames.GetArray(g_iSelectedTick, Frame, sizeof(FrameInfo));

	Menu menu = new Menu(EditFrameButtonsMenuHandler);

	menu.SetTitle("IN_BUTTONS");
	menu.AddItem("0", (Frame.buttons & IN_JUMP) ? "[+] JUMP" : "[ ] JUMP");
	menu.AddItem("1", (Frame.buttons & IN_DUCK) ? "[+] DUCK" : "[ ] DUCK");
	menu.AddItem("2", (Frame.buttons & IN_MOVELEFT) ? "[+] MOVELEFT" : "[ ] MOVELEFT");
	menu.AddItem("3", (Frame.buttons & IN_MOVERIGHT) ? "[+] MOVERIGHT" : "[ ] MOVERIGHT");
	menu.AddItem("4", (Frame.buttons & IN_FORWARD) ? "[+] FORWARD" : "[ ] FORWARD");
	menu.AddItem("5", (Frame.buttons & IN_BACK) ? "[+] BACK" : "[ ] BACK");

	menu.Display(client, MENU_TIME_FOREVER);
}

/**
 * IN_BUTTONS
 * 1. [ ] JUMP
 * 2. [ ] DUCK
 * 3. [ ] MOVELEFT
 * 4. [ ] MOVERIGHT
 * 5. [ ] FORWARD
 * 6. [ ] BACK
 */
public int EditFrameButtonsMenuHandler(Menu menu, MenuAction action, int param1, int param2)
{
	switch (action)
	{
		case MenuAction_Select:
		{
			FrameInfo Frame;
			g_hFrames.GetArray(g_iSelectedTick, Frame, sizeof(FrameInfo));
			switch (param2)
			{
				case 0: Frame.buttons ^= IN_JUMP;
				case 1: Frame.buttons ^= IN_DUCK;
				case 2: Frame.buttons ^= IN_MOVELEFT;
				case 3: Frame.buttons ^= IN_MOVERIGHT;
				case 4: Frame.buttons ^= IN_FORWARD;
				case 5: Frame.buttons ^= IN_BACK;
			}
			g_hFrames.SetArray(g_iSelectedTick, Frame, sizeof(FrameInfo));
			BotStartPrediction(g_iSelectedTick - 1);
			OpenEditFrameButtonsMenu(param1);
		}
		case MenuAction_Cancel:
		{
			if (param2 == MenuCancel_Exit)
				OpenEditFrameMenu(param1, g_iSelectedTick);
		}
		case MenuAction_End:
			delete menu;
	}
}

/**
 * Opens Single Selected Frame Edit RelYaw Menu
 */
public void OpenEditFrameRelYawMenu(int client)
{
	Menu menu = new Menu(EditFrameRelYawMenuHandler);

	menu.SetTitle("Set Relative Yaw\n0.0+ => Left");

	char szBuffer[32];
	FormatEx(szBuffer, sizeof(szBuffer), "sm_set_float %f", g_fFloatValue);
	menu.AddItem("0", szBuffer);
	menu.AddItem("1", "Save");

	menu.Display(client, MENU_TIME_FOREVER);
}

/**
 * Set Relative Yaw
 * Left is Positive
 * 1. sm_set_float {g_fFloatValue}
 * 2. Save
 */
public int EditFrameRelYawMenuHandler(Menu menu, MenuAction action, int param1, int param2)
{
	switch (action)
	{
		case MenuAction_Select:
		{
			switch (param2)
			{
				case 0: OpenEditFrameRelYawMenu(param1);
				case 1:
				{
					FrameInfo Frame;
					g_hFrames.GetArray(g_iSelectedTick, Frame, sizeof(FrameInfo));
					Frame.angRel[1] = g_fFloatValue;
					g_hFrames.SetArray(g_iSelectedTick, Frame, sizeof(FrameInfo));
					CheckAbsAngles(g_iSelectedTick);
					OpenEditFrameMenu(param1, g_iSelectedTick);
				}
			}
		}
		case MenuAction_Cancel:
		{
			if (param2 == MenuCancel_Exit)
				OpenEditFrameMenu(param1, g_iSelectedTick);
		}
		case MenuAction_End:
			delete menu;
	}
}