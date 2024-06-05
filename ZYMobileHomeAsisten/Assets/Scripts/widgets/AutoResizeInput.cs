using UnityEngine.UI;
using UnityEngine;

public class AutoResizeInput : MonoBehaviour
{

    private InputField input;//输入框
    private VerticalLayoutGroup layout;//布局组件
    private Text layoutContent;//layout的子物体文本
    private LayoutElement layoutElement;//布局元素
    /// <summary>
    /// 初始化获取各个组件
    /// </summary>
    private void Awake()
    {
        input = GetComponent<InputField>();
        layout = transform.Find("layout").GetComponent<VerticalLayoutGroup>();
        layoutContent = layout.gameObject.GetComponentInChildren<Text>();
        layoutElement = layout.gameObject.GetComponent<LayoutElement>();
        input.onValueChanged.AddListener(OnChangeInputValue);
    }
    /// <summary>
    /// 输入时实时刷新输入框宽高，实现自适应
    /// </summary>
    /// <param name="value"></param>
    public void OnChangeInputValue(string value)
    {
        input.text = value;
        layoutContent.text = value;
        LayoutRebuilder.ForceRebuildLayoutImmediate(layout.transform as RectTransform);//实时刷新布局组件
        RectTransform rect = transform as RectTransform;
        rect.SetSizeWithCurrentAnchors(RectTransform.Axis.Horizontal,
            Mathf.Max(layoutElement.minWidth, (layout.transform as RectTransform).rect.width));//将输入框在水平轴的宽设置为layout物体的宽，保持同步
        rect.SetSizeWithCurrentAnchors(RectTransform.Axis.Vertical,
            Mathf.Max(layoutElement.minHeight, (layout.transform as RectTransform).rect.height));//将输入框在竖直轴的高设置为layout物体的高，保持同步
    }
}

