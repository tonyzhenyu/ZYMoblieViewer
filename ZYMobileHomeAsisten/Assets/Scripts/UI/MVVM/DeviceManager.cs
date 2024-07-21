using System.Collections.Generic;
using System.IO;
using UnityEngine;

public class DeviceManager : Singleton<DeviceManager>
{
    public List<DeviceData> devices;

    protected override void Init()
    {
        base.Init();
        LoadDeviceObjects(ref devices);
    }

    public void LoadDeviceObjects(ref List<DeviceData> devices)
    {
        string path = Application.streamingAssetsPath + "DevicesData.json";
        var str = File.ReadAllText(path);
        devices = JsonUtility.FromJson<Serialization<DeviceData>>(str).ToList();
    }
    public void SaveDeviceObject(List<DeviceData> devices)
    {
        string path = Application.streamingAssetsPath + "DevicesData.json";
        string value = JsonUtility.ToJson(new Serialization<DeviceData>(devices), true);
        File.WriteAllText(path, value);
    }
}
