using System.Collections;
using UnityEngine;
using UnityEngine.SceneManagement;

public class SceneLoaderManager : MonoBehaviour
{
    public static SceneLoaderManager Instance;
    public UITransitionLayer UITransitionLayer { get; private set; }

    private void Awake()
    {
        if (Instance != null && Instance != this)
        {
            Destroy(gameObject);
            return;
        }

        Instance = this;
    }

    void Start()
    {
        UITransitionLayer = GetComponentInChildren<UITransitionLayer>();
    }

    public void LoadScene(SceneType type)
    {
        SceneTransitionUtils.TryGet(type, out string sceneName);
        SceneManager.LoadScene(sceneName);
    }

    public void LoadSceneSync(SceneType type, float duration = 1f)
    {
        StartCoroutine(LoadAsync(type, duration));
    }

    IEnumerator LoadAsync(SceneType nextScene, float duration)
    {
        yield return StartCoroutine(UITransitionLayer.PlayIn(duration));
        //UITransitionLayer.Show();
        SceneTransitionUtils.TryGet(nextScene, out string sceneName);
        AsyncOperation aop = SceneManager.LoadSceneAsync(sceneName);
        aop.allowSceneActivation = false;

        float elapsedTime = 0f;
        while (elapsedTime < duration /* || !effectLayer.IsDone */)
        {
            elapsedTime += Time.unscaledDeltaTime;
            yield return null;
        }

        aop.allowSceneActivation = true;
        yield return StartCoroutine(UITransitionLayer.PlayOut());

    }

}
