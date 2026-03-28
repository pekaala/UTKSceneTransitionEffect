
using UnityEngine;
using UnityEngine.AddressableAssets;

public static class SystemInitializerUtils
{
    [RuntimeInitializeOnLoadMethod(RuntimeInitializeLoadType.BeforeSceneLoad)]
    private static void Init()
    {
        Addressables.InitializeAsync().WaitForCompletion();

        GameObject gameManager = Addressables.InstantiateAsync("GameManager").WaitForCompletion();

        if (gameManager != null)
        {
            gameManager.name = "GameManager";
            Object.DontDestroyOnLoad(gameManager);
            return;
        }
        Debug.LogError("GameManager not loaded!");
    }
}