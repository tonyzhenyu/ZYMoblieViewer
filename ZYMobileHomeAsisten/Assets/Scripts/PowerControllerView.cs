using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Events;
using UnityEngine.UI;
using ZY.MVVM;
public class PowerControllerView : ViewBase<PowerControllerViewModel>
{
    public InputField ipAddressInputField;
    public InputField ipAddressPortInputField;
    public InputField macAddressInputField;
    public Button wakeOnLanButton;
    public Button shutdownButton;

    public Image statusOffline;
    public Image statusOnline;

    protected override void Init()
    {
        ipAddressInputField.onSubmit.AddListener((s) =>
        {
            BindingContext.ipAddressInputField.Value = ipAddressInputField.text;
        });
        ipAddressPortInputField.onSubmit.AddListener((s) =>
        {
            BindingContext.ipAddressPortInputField.Value = ipAddressPortInputField.text;
        });
        macAddressInputField.onSubmit.AddListener((s) =>
        {
            BindingContext.macAddressInputField.Value = macAddressInputField.text;
        });
        wakeOnLanButton.onClick.AddListener(() =>
        {
            WakeOnLan.Wake(new WakeOnLan.WakeData()
            {

            });
        });
        shutdownButton.onClick.AddListener(() =>
        {

        });

        //BindingContext.ipAddressInputField.OnValueChaged += (o, n) =>
        //{
        //    ipAddressInputField.text = n;
        //};      

        //BindingContext.ipAddressPortInputField.OnValueChaged += (o, n) =>
        //{
        //    ipAddressPortInputField.text = n;
        //};   

        //BindingContext.macAddressInputField.OnValueChaged += (o, n) =>
        //{
        //    macAddressInputField.text = n;
        //};       

        //BindingContext.wakeOnLanButton.OnValueChaged += (o, n) =>
        //{

        //};        
        //BindingContext.shutdownButton.OnValueChaged += (o, n) =>
        //{

        //};
    }
}
