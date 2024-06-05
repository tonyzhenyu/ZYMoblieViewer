using UnityEngine.UI;
using UnityEngine;

public class AutoResizeInput : MonoBehaviour
{

    private InputField input;//�����
    private VerticalLayoutGroup layout;//�������
    private Text layoutContent;//layout���������ı�
    private LayoutElement layoutElement;//����Ԫ��
    /// <summary>
    /// ��ʼ����ȡ�������
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
    /// ����ʱʵʱˢ��������ߣ�ʵ������Ӧ
    /// </summary>
    /// <param name="value"></param>
    public void OnChangeInputValue(string value)
    {
        input.text = value;
        layoutContent.text = value;
        LayoutRebuilder.ForceRebuildLayoutImmediate(layout.transform as RectTransform);//ʵʱˢ�²������
        RectTransform rect = transform as RectTransform;
        rect.SetSizeWithCurrentAnchors(RectTransform.Axis.Horizontal,
            Mathf.Max(layoutElement.minWidth, (layout.transform as RectTransform).rect.width));//���������ˮƽ��Ŀ�����Ϊlayout����Ŀ�����ͬ��
        rect.SetSizeWithCurrentAnchors(RectTransform.Axis.Vertical,
            Mathf.Max(layoutElement.minHeight, (layout.transform as RectTransform).rect.height));//�����������ֱ��ĸ�����Ϊlayout����ĸߣ�����ͬ��
    }
}

