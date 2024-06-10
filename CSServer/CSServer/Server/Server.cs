using CSServer.Message;
using System.Net;

public class Server
{
    public List<IService> services = new List<IService>();
    public IPEndPoint ep;

    public delegate void RegisteringService();
    public event RegisteringService? OnRegister;
    public event RegisteringService? OnUnRegister;

    public Server(IPEndPoint ip)
    {
        ep = ip;
    }
    public State state = State.Sleeping;
    public enum State
    {
        Running,
        Sleeping
    }
    public void Run()
    {
        ServerHandler.Instance.Listen(ep);
    }
    public void Stop()
    {
        ServerHandler.Instance.Sleep();
    }
    public void InitServices()
    {
        foreach (var service in services)
        {
            service.Init();
        }
    }
    public void OnReciveMessage<T>(Message<T> message) where T : class
    {

    }
    public void RegisterService(IService service)
    {
        services.Add(service);
        OnRegister?.Invoke();
    }
    public void UnRegisterService(IService service)
    {
        services.Remove(service);
        OnUnRegister?.Invoke();
    }
}
