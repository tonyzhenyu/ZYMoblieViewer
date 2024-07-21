
// List<T>
using System.Collections.Generic;
using System;
using UnityEngine;

[Serializable]
public class Serialization<T>
{
    [SerializeField]
    List<T> target;
    public List<T> ToList() { return target; }

    public Serialization(List<T> target)
    {
        this.target = target;
    }
}


public class DeviceData
{
    public string name;
    public string id;
    public string macAddress;
    public string ipAddress;
    public string port;
    public Status status;

    public enum Status
    {
        Awaking,
        Sleeping,
    }
}
