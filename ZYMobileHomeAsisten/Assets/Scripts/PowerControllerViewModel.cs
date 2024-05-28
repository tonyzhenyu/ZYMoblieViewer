using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using ZY.MVVM;

public class PowerControllerViewModel : ViewModelBase
{
    public readonly BindableProperty<string> ipAddressInputField = new BindableProperty<string>();
    public readonly BindableProperty<string> ipAddressPortInputField = new BindableProperty<string>();
    public readonly BindableProperty<string> macAddressInputField = new BindableProperty<string>();
    public readonly BindableProperty<bool> wakeOnLanButton = new BindableProperty<bool>();
    public readonly BindableProperty<bool> shutdownButton = new BindableProperty<bool>();

    public override void UpdateModel()
    {
        
    }
}
