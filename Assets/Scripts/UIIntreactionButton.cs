using UnityEngine;
using UnityEngine.UIElements;

[RequireComponent(typeof(UIDocument))]
public class UIIntreactionButton : MonoBehaviour
{
    public SceneType NextSceneType;


    private UIDocument _uiDocument;
    private Button _changeSceneButton;

    void Awake()
    {
        _uiDocument = GetComponent<UIDocument>();
    }

    void Start()
    {
        var root = _uiDocument.rootVisualElement;

        _changeSceneButton = root.Q<Button>("Change_Scene");

        if (_changeSceneButton != null)
        {
            _changeSceneButton.clicked += ChangeScene;
        }
    }

    void OnDisable()
    {
        if (_changeSceneButton != null)
        {
            _changeSceneButton.clicked -= ChangeScene;
        }
    }

    private void ChangeScene()
    {
        SceneLoaderManager.Instance.LoadSceneSync(NextSceneType, 2.5f);
        Debug.Log("Change Scene");
    }

}
