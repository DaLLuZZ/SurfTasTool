#define MAXFILESCOUNT (1 << 10)

public void CreateMapDir()
{
	char szPath[256];
	char szMap[32];
	GetCurrentMap(szMap, sizeof(szMap));

	BuildPath(Path_SM, szPath, sizeof(szPath), "data/SurfTasTool/%s", szMap);
	if (!DirExists(szPath))
		CreateDirectory(szPath, 511);
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

	File.Write(g_Header.pos, 3, 4);
	File.Write(g_Header.ang, 3, 4);
	File.WriteInt32(view_as<int>(TICKRATE));
	File.WriteInt32(g_hFrames.Length);

	FrameInfo Frame;

	for (int i = 0; i < g_hFrames.Length; i++)
	{
		g_hFrames.GetArray(i, Frame, sizeof(FrameInfo));
		File.WriteInt32(Frame.buttons);
		File.Write(view_as<int>(Frame.angRel), 3, 4);
		File.Write(view_as<int>(Frame.ang), 3, 4);
		File.WriteInt32(Frame.autostrafe);
	}

	File.Close();
}

public void ReadFileToCurrentTAS(char szPath[])
{
	if (!FileExists(szPath))
		return;

	if (g_hFrames)
		delete g_hFrames;

	g_hFrames = new ArrayList(sizeof(FrameInfo));

	int len;
	float tick;

	File hFile = OpenFile(szPath, "rb");

	File.Read(g_Header.pos, 3, 4);
	File.Read(g_Header.ang, 3, 4);
	File.ReadInt32(len);
	File.ReadInt32(view_as<int>(tick));

	if (tick < TICKRATE - 0.1 || tick > TICKRATE + 0.1)
		return;

	FrameInfo Frame;

	for (int i = 0; i < len; i++)
	{
		File.ReadInt32(Frame.buttons);
		File.Read(view_as<int>(Frame.angRel), 3, 4);
		File.Read(view_as<int>(Frame.ang), 3, 4);
		File.ReadInt32(Frame.autostrafe);
		g_hFrames.PushArray(Frame, sizeof(FrameInfo));
	}

	File.Close();
}
