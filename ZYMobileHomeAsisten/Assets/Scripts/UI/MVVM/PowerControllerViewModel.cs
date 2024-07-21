using ZY.MVVM;

public class PowerControllerModel : Singleton<PowerControllerModel> 
{
    public delegate void OnValueHandler();
    public event OnValueHandler onValueChanged;

    public string ipAddress;
    public string ipAddressPort;
    public string macAddress;
}
public class PowerControllerViewModel : ViewModelBase
{
    public readonly BindableProperty<string> ipAddressInputField = new BindableProperty<string>();
    public readonly BindableProperty<string> ipAddressPortInputField = new BindableProperty<string>();
    public readonly BindableProperty<string> macAddressInputField = new BindableProperty<string>();
    public readonly BindableProperty<bool> wakeOnLanButton = new BindableProperty<bool>();
    public readonly BindableProperty<bool> shutdownButton = new BindableProperty<bool>();

    protected override void Init()
    {
        base.Init();
        
    }
}
