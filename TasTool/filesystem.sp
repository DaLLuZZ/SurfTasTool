public void CreateMapDir()
{
	char szPath[256];
	char szMap[32];
	GetCurrentMap(szMap, sizeof(szMap));

	BuildPath(Path_SM, szPath, sizeof(szPath), "data/SurfTasTool/%s", szMap);
	if (!DirExists(szPath))
		CreateDirectory(szPath, 511);
}
