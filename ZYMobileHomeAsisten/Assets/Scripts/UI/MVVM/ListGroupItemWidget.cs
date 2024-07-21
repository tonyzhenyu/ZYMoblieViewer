using UnityEngine.UI;
using ZY.MVVM;

public class ListGroupItemWidget : ViewBase<ListGroupItemWidgetViewModel>
{
    public bool editable;
    public InputField indexField;
    public InputField inputField;
    public InputField valueField;
    public Button button;
    protected override void Init()
    {

    }
}
