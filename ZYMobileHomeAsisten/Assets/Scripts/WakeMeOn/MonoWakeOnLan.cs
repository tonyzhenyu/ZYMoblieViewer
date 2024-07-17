using System.Net;
using System.Threading.Tasks;
using UnityEngine;
using UnityEngine.UI;
public class MonoWakeOnLan : MonoBehaviour
{
    public InputField ipField;
    public void Wake()
    {
        var input = Dns.GetHostAddresses(ipField.text);
        WakeOnLan.Wake(new WakeOnLan.WakeData()
        {
            ipAddress = input[0],
            macAddress = "F4:B5:20:5C:0B:B8",
            port = 9
        });
    }
    public void Shutdown()
    {
        Task.Run(() =>
        {
            RemoteShutdown.SendShutdownCommand($"{ipField.text}", 13000);
        });
    }
    
}
