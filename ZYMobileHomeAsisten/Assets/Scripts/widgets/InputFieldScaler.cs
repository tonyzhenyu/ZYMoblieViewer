using UnityEngine;
using UnityEngine.UI;

[RequireComponent(typeof(InputField))]
public class InputFieldScaler : MonoBehaviour, ILayoutElement
{
    private Text textComponent
    {
        get
        {
            return this.GetComponent<Text>();
        }
    }

    public TextGenerationSettings GetTextGenerationSettings(Vector2 extents)
    {
        var settings = textComponent.GetGenerationSettings(extents);
        settings.generateOutOfBounds = true;
        return settings;
    }

    private RectTransform m_Rect;

    private RectTransform rectTransform
    {
        get
        {
            if (m_Rect == null)
                m_Rect = GetComponent<RectTransform>();
            return m_Rect;
        }
    }

    public void OnValueChanged(string v)
    {
        if (!fixedWidth)
        {
            rectTransform.SetSizeWithCurrentAnchors((RectTransform.Axis)0, LayoutUtility.GetPreferredWidth(m_Rect));
        }
        rectTransform.SetSizeWithCurrentAnchors((RectTransform.Axis)1, LayoutUtility.GetPreferredHeight(m_Rect));
    }

    void OnEnable()
    {
        this.inputField.onValueChanged.AddListener(OnValueChanged);
    }

    void OnDisable()
    {

    }

    private Vector2 originalSize;
    private InputField _inputField;

    public InputField inputField
    {
        get
        {
            return _inputField ?? (_inputField = this.GetComponent<InputField>());
        }
    }
    private float _offsetHeight;
    public float offsetHeight
    {
        get
        {
            if (_offsetHeight == 0)
                _offsetHeight = generatorForLayout.GetPreferredHeight(text, GetTextGenerationSettings(Vector2.zero)) / textComponent.pixelsPerUnit;
            return _offsetHeight;
        }
    }

    private float _offsetTextComponentLeftRingt;
    public float offsetTextComponentLeftRingt
    {
        get
        {
            if (_offsetTextComponentLeftRingt == 0)
                _offsetTextComponentLeftRingt = Mathf.Abs(rectTransform.rect.width - textComponent.rectTransform.rect.width);
            return _offsetTextComponentLeftRingt;
        }
    }
    protected void Awake()
    {
        textComponent.fontSize = fontSize;
        inputField.placeholder.GetComponent<Text>().fontSize = fontSize;
        this.originalSize = this.GetComponent<RectTransform>().sizeDelta;
        inputField.lineType = fixedWidth ? InputField.LineType.MultiLineNewline : InputField.LineType.SingleLine;
        rectTransform.SetSizeWithCurrentAnchors((RectTransform.Axis)1, LayoutUtility.GetPreferredHeight(m_Rect));
    }

    private string text
    {
        get
        {
            return this.GetComponentInChildren<Text>().text;
        }
    }

    private TextGenerator _generatorForLayout;

    public TextGenerator generatorForLayout
    {
        get
        {
            return _generatorForLayout ?? (_generatorForLayout = new TextGenerator());
        }
    }

    public void Update()
    {

    }

    public float preferredWidth
    {
        get
        {
            if (fixedWidth)
            {
                return this.originalSize.x;
            }
            else
            {
                if (keepInitWidthSize)
                {
                    return Mathf.Max(this.originalSize.x, generatorForLayout.GetPreferredWidth(text, GetTextGenerationSettings(Vector2.zero)) / textComponent.pixelsPerUnit + offsetTextComponentLeftRingt);
                }
                else
                {
                    return generatorForLayout.GetPreferredWidth(text, GetTextGenerationSettings(Vector2.zero)) / textComponent.pixelsPerUnit + offsetTextComponentLeftRingt;
                }
            }
        }
    }

    public virtual float preferredHeight
    {
        get
        {
            if (fixedWidth)
            {
                return generatorForLayout.GetPreferredHeight(text, GetTextGenerationSettings(new Vector2(this.textComponent.GetPixelAdjustedRect().size.x, 0.0f))) / textComponent.pixelsPerUnit + offsetHeight;
            }
            else
            {
                return generatorForLayout.GetPreferredHeight(text, GetTextGenerationSettings(new Vector2(this.textComponent.GetPixelAdjustedRect().size.x, 0.0f))) / textComponent.pixelsPerUnit + offsetHeight;
            }

        }
    }

    public virtual void CalculateLayoutInputHorizontal()
    {
    }

    public virtual void CalculateLayoutInputVertical()
    {
    }

    public virtual float minWidth
    {
        get { return -1; }
    }

    public virtual float minHeight
    {
        get { return -1; }
    }

    public virtual float flexibleWidth { get { return -1; } }

    public virtual float flexibleHeight { get { return -1; } }


    //[Tooltip("�����������С��InputField�Ĵ�С���������С�ı�߶�")]
    [HideInInspector]
    public int fontSize = 20;

    //[Tooltip("�Ƿ񱣳�InputField�Ŀ�Ȳ���")]
    [HideInInspector]
    public bool fixedWidth = true;

    //[Tooltip("�Ƿ�����InputField�Ŀ��")]
    [HideInInspector]
    public bool keepInitWidthSize = true;

    //[SerializeField]
    //[Tooltip("���Layout�������ȼ���Ҫ��InputField�� ������Ϊ1")]
    private int priority = 1;

    public virtual int layoutPriority { get { return priority; } }
}