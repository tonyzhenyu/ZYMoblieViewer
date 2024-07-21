using ZY.MVVM;

public class ListGroupViewModel : ViewModelBase
{
    public readonly BindableProperty<string> ipAddressInputField = new BindableProperty<string>();
    
    protected override void Init()
    {
        base.Init();
        
    }
}
