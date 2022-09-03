// Precached in OnMapStart() forward
int g_iBeamSprite;
int g_iHaloSprite;

int g_iTrajectoryMode;

#define TRAJECTORYMODE_DEFAULT 0
#define TRAJECTORYMODE_MAX 1
#define TRAJECTORYMODE_MIN 2

// Todo: draw not in one frame but separate to several
// https://developer.valvesoftware.com/wiki/Temporary_Entity
// https://forums.alliedmods.net/showthread.php?t=298051
// https://forums.alliedmods.net/showthread.php?t=253428

// Is called for each gameframe from OnPlayerRunCmd() forward
// Todo: optimize
public void ShowTrajectory(int client)
{
    if (!g_hFrames || g_iSelectedTick < 0)
        return;

    FrameInfo Frame;
    float pos[3];
    pos = g_Header.pos; // header?

    // Todo: could 10 be a ConVar?
    // Todo: check if 256 is real limit?
    for (int i = g_iSelectedTick - (g_iSelectedTick >= 10 ? 10 : 0); i < (g_hFrames.Length - g_iSelectedTick > (255 - 10) ? (g_iSelectedTick + 255 - 10) : g_hFrames.Length); i++)
    {
        // Should it be optimized?
        g_hFrames.GetArray(i, Frame, sizeof(FrameInfo));

        float framepos[3];
        for (int j = 0; j < 3; j++)
            framepos[j] = Frame.pos[j];

        for (int j = 0; j < 3; j++)
            switch g_iTrajectoryMode
            {
                case TRAJECTORYMODE_MAX: framepos[j] += VEC_HULL_MAX;
                case TRAJECTORYMODE_MIN: framepos[j] += VEC_HULL_MIN;
            }

        if (i == g_iSelectedTick)
            TE_SetupBeamPoints(pos, framepos, g_iBeamSprite, g_iHaloSprite, 0, 0, 1.0, 0.5, 0.5, 2, 0.0, view_as<int>({255, 0, 0, 255}), 0);
        else
            TE_SetupBeamPoints(pos, framepos, g_iBeamSprite, g_iHaloSprite, 0, 0, 1.0, 0.5, 0.5, 2, 0.0, view_as<int>({255, 255, 0, 255}), 0);
        TE_SendToClient(client);

        for (int j = 0; i < 3; j++)
            pos[j] = framepos[j];
    }
}
