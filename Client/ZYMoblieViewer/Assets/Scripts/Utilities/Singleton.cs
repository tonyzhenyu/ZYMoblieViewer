using System;
using UnityEngine;

public class Singleton<T> where T : class,new()
{
    // 单件子类实例
    private static T _instance;
    /// <summary>
    ///     获得C#单件实例
    ///     自行控制生命周期
    /// </summary>
    /// <returns>返回单件实例</returns>
    public static T GetInstance()
    {
        if (_instance == null)
        {
            _instance = new T();
        }
        return _instance;
    }
    public Singleton()
    {
        Init();
    }

    public static bool HasInstance()
    {
        return _instance != null;
    }
    /// <summary>
    /// 初始化调用
    /// </summary>
    protected virtual void Init() { }
    /// <summary>
    /// 反初始化调用
    /// </summary>
    protected virtual void UnInit()
    {
        _instance = null;
    }
};
