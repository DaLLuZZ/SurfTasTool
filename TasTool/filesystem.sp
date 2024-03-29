#define MAXFILESCOUNT (1 << 7)

public void CreateMapDir()
{
	char szPath[256];
	char szMap[32];
	GetCurrentMap(szMap, sizeof(szMap));

	BuildPath(Path_SM, szPath, sizeof(szPath), "data/SurfTasTool/%s/", szMap);
	if (!DirExists(szPath))
		CreateDirectory(szPath, ((FPERM_O_READ|FPERM_O_EXEC)|(FPERM_G_EXEC|FPERM_G_READ)|(FPERM_U_EXEC|FPERM_U_WRITE|FPERM_U_READ)));
}

public void WriteCurrentTAS()
{
	char szPath[256];
	char szMap[32];

	GetCurrentMap(szMap, sizeof(szMap));
	BuildPath(Path_SM, szPath, sizeof(szPath), "data/SurfTasTool/%s/1.tas", szMap);

	if (FileExists(szPath))
		for (int i = 2; FileExists(szPath) && i < MAXFILESCOUNT; i++)
			BuildPath(Path_SM, szPath, sizeof(szPath), "data/SurfTasTool/%s/%i.tas", szMap, i);

	File hFile = OpenFile(szPath, "wb");

	if (!hFile)
		return;

	hFile.Write(g_Header.pos, 3, 4);
	hFile.Write(g_Header.ang, 3, 4);
	hFile.WriteInt32(view_as<int>(TICKRATE));
	hFile.WriteInt32(g_hFrames.Length);

	FrameInfo Frame;

	for (int i = 0; i < g_hFrames.Length; i++)
	{
		g_hFrames.GetArray(i, Frame, sizeof(FrameInfo));
		hFile.WriteInt32(Frame.buttons);
		hFile.Write(view_as<int>(Frame.angRel), 3, 4);
		hFile.Write(view_as<int>(Frame.ang), 3, 4);
		hFile.WriteInt32(Frame.autostrafe);
	}

	hFile.Close();
}

public void ReadFileToCurrentTAS(char[] szPath)
{
	if (!FileExists(szPath))
		return;

	if (g_hFrames)
		delete g_hFrames;

	g_hFrames = new ArrayList(sizeof(FrameInfo));

	int len;
	float tick;

	File hFile = OpenFile(szPath, "rb");

	hFile.Read(g_Header.pos, 3, 4);
	hFile.Read(g_Header.ang, 3, 4);
	hFile.ReadInt32(view_as<int>(tick));
	hFile.ReadInt32(len);

	if (tick < TICKRATE - 0.1 || tick > TICKRATE + 0.1)
		return;

	FrameInfo Frame;

	for (int i = 0; i < len; i++)
	{
		hFile.ReadInt32(Frame.buttons);
		hFile.Read(view_as<int>(Frame.angRel), 3, 4);
		hFile.Read(view_as<int>(Frame.ang), 3, 4);
		hFile.ReadInt32(Frame.autostrafe);
		g_hFrames.PushArray(Frame, sizeof(FrameInfo));
	}

	hFile.Close();
}

public void FileManagerInit(int client)
{
	char szPath[256];
	char szMap[32];
	GetCurrentMap(szMap, sizeof(szMap));

	BuildPath(Path_SM, szPath, sizeof(szPath), "data/SurfTasTool/%s", szMap);

	if (!DirExists(szPath))
		return;

	DirectoryListing MapDir = OpenDirectory(szPath);
	if (!MapDir)
		return;

	FileType type;
	char szBuffer[256];
	Menu menu = new Menu(FileManagerHandler);
	menu.SetTitle(szMap);

	while (ReadDirEntry(MapDir, szBuffer, sizeof(szBuffer), type))
	{
		if (StrEqual(szBuffer, "..") || StrEqual(szBuffer, "."))
			continue;

		if (type == FileType_File)
			menu.AddItem(szBuffer, szBuffer);
		else if (type == FileType_Directory)
		{
		}
	}

	delete MapDir;

	menu.Display(client, MENU_TIME_FOREVER);
}

public int FileManagerHandler(Menu menu, MenuAction action, int param1, int param2)
{
	switch (action)
	{
		case MenuAction_Select:
		{
			char szName[32];
			int style;
			menu.GetItem(param2, szName, sizeof(szName), style, szName, sizeof(szName), -1);
			char szPath[256];
			char szMap[32];
			GetCurrentMap(szMap, sizeof(szMap));
			BuildPath(Path_SM, szPath, sizeof(szPath), "data/SurfTasTool/%s/%s", szMap, szName);
			ReadFileToCurrentTAS(szPath);
			FileManagerInit(param1);
		}
		case MenuAction_Cancel:
		{
			if (param2 == MenuCancel_Exit)
				OpenFileMenu(param1);
		}
		case MenuAction_End:
			delete menu;
	}
}
