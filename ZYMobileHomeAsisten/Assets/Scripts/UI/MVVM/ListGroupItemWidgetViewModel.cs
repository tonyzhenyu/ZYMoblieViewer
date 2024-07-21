using ZY.MVVM;

public class ListGroupItemWidgetViewModel: ViewModelBase
{
    public readonly BindableProperty<string> indexInputField = new BindableProperty<string>();
    public readonly BindableProperty<string> valueInputField = new BindableProperty<string>();
    public readonly BindableProperty<string> inputField = new BindableProperty<string>();

}
