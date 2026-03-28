using System;
using System.Collections.Generic;
public static class SceneTransitionUtils
{
    private static readonly Dictionary<SceneType, string> SceneNameMap = new()
    {
        { SceneType.Scene_A, "Scene_A" },
        { SceneType.Scene_B, "Scene_B" },
    };

    public static void TryGet(SceneType type, out string sceneName)
    {
        SceneNameMap.TryGetValue(type, out sceneName);
    }
}