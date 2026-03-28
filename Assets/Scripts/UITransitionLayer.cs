using System.Collections;
using UnityEngine;
using UnityEngine.UIElements;

[RequireComponent(typeof(UIDocument))]
public class UITransitionLayer : MonoBehaviour
{
    [SerializeField] private Material _transitionMaterial;

    static readonly int ProgressID = Shader.PropertyToID("_Progress");
    private float _progress;

    private float _loadingLabelThreshold = 0.85f;
    private UIDocument _uiDocument;
    private VisualElement _overlay;
    private RenderTexture _renderTexture;
    private Label _loadingLabel;

    void Awake()
    {
        _uiDocument = GetComponent<UIDocument>();
    }

    void Start()
    {
        var root = _uiDocument.rootVisualElement;
        _overlay = root.Q<VisualElement>("Background_Image");
        _overlay.pickingMode = PickingMode.Ignore;

        _loadingLabel = root.Q<Label>("Loading_Label");
        _loadingLabel.style.display = DisplayStyle.None;

        _renderTexture = new RenderTexture(Screen.width, Screen.height, 0);
        _overlay.style.backgroundImage = new StyleBackground(
            Background.FromRenderTexture(_renderTexture)
        );

        SetProgress(0f);
    }

    public void Show()
    {
        _uiDocument.sortingOrder = 2;
    }

    public void Hide(float delay = 0f)
    {
        if (delay <= 0f) { _uiDocument.sortingOrder = 0; return; }
        StartCoroutine(HideDelayed(delay));
    }

    private IEnumerator HideDelayed(float delay)
    {
        yield return new WaitForSecondsRealtime(delay);
        _uiDocument.sortingOrder = 0;
    }

    public IEnumerator PlayIn(float duration = 0.5f)
    {
        Show();
        for (float t = 0f; t < duration; t += Time.unscaledDeltaTime)
        {
            SetProgress(Mathf.Pow(t / duration, 0.5f));
            yield return null;
        }
        SetProgress(1f);
    }

    public IEnumerator PlayOut(float duration = 1.2f)
    {
        SetProgress(1f);
        for (float t = 0f; t < duration; t += Time.unscaledDeltaTime)
        {
            SetProgress(1f - Mathf.Pow(t / duration, 1.8f));
            yield return null;
        }
        SetProgress(0f);
        Hide();
    }

    private void SetProgress(float v)
    {
        _progress = Mathf.Clamp01(v);
        _transitionMaterial.SetFloat(ProgressID, _progress);
        Graphics.Blit(null, _renderTexture, _transitionMaterial);
        _overlay.MarkDirtyRepaint();

        _loadingLabel.style.display = _progress >= _loadingLabelThreshold
            ? DisplayStyle.Flex
            : DisplayStyle.None;
    }

    void OnDestroy()
    {
        if (_renderTexture != null)
            _renderTexture.Release();
    }
}