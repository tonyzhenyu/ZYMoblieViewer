using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
public class PowerController : MonoBehaviour
{
    public InputField ipAddressInputField;
    public InputField ipAddressPortInputField;
    public InputField macAddressInputField;
    public Button wakeOnLanButton;
    public Button shutdownButton;

    public Image statusOffline;
    public Image statusOnline;

    PowerControllerViewModel powerControllerViewModel;

    private void Awake()
    {
        powerControllerViewModel = new PowerControllerViewModel();
    }
    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        
    }

}
