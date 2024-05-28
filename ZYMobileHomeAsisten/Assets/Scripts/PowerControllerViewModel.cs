using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using ZY.MVVM;

public class PowerControllerViewModel : ViewModelBase
{
    public InputField ipAddressInputField;
    public InputField ipAddressPortInputField;
    public InputField macAddressInputField;
    public Button wakeOnLanButton;
    public Button shutdownButton;

    public Image statusOffline;
    public Image statusOnline;
    public override void UpdateModel()
    {
        throw new System.NotImplementedException();
    }
}
