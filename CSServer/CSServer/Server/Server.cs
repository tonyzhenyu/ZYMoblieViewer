using System.Net;
using System.Net.Sockets;

public class Server
{
    #region Service
    public List<IService> services = new List<IService>();
    public delegate void RegisteringService();
    public event RegisteringService? OnRegister;
    public event RegisteringService? OnUnRegister;
    #endregion

    SocketAsyncEventArgs args = new SocketAsyncEventArgs();

    private Socket socket;
    private Socket socketMesg;

    public State state = State.Sleeping;
    public enum State
    {
        Running,
        Sleeping
    }

    public Server(string ips ,int port)
    {
        IPEndPoint ip = new IPEndPoint(IPAddress.Parse(ips), port);

        socket = new Socket(SocketType.Stream, ProtocolType.Tcp);
        socket.Bind(ip);

        InitServices();
    }

    public void Run()
    {
        Console.WriteLine("server start");
        socket.Listen(20);
        state = State.Running;
        socketMesg = socket.Accept();
        socketMesg.ReceiveAsync(args);
    }
    public void Stop()
    {
        socket.Close();
        state = State.Sleeping;
    }


    #region ServiceFunction
    public void InitServices()
    {
        foreach (var service in services)
        {
            service.Init();
        }
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
    #endregion

}
