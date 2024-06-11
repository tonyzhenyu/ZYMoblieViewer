using CSServer.Message;
using System.Net;
using System.Net.Sockets;
using System.Runtime.Serialization;
using System.Text;
using System.Text.Json;

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

    public Server()
    {
        IPEndPoint ip = new IPEndPoint(IPAddress.Parse("127.0.0.1"), 7777);

        args = new SocketAsyncEventArgs();
        args.SetBuffer(new byte[1024], 0, 1024);
        args.Completed += new EventHandler<SocketAsyncEventArgs>(OnReceiveCompleted);
        
        socket = new Socket(AddressFamily.InterNetwork, SocketType.Stream, ProtocolType.Tcp);
        socket.Bind(ip);

        InitServices();
    }
    public Server(string ips ,int port)
    {
        IPEndPoint ip = new IPEndPoint(IPAddress.Parse(ips), port);

        args = new SocketAsyncEventArgs();
        args.SetBuffer(new byte[1024], 0, 1024);
        args.Completed += new EventHandler<SocketAsyncEventArgs>(OnReceiveCompleted);

        socket = new Socket(SocketType.Stream, ProtocolType.Tcp);
        socket.Bind(ip);

        InitServices();
    }


    private void OnReceiveCompleted(object? sender, SocketAsyncEventArgs e)
    {
        if (e.SocketError == SocketError.Success)
        {
            ProcessReceive(e);
        }
        else
        {

        }
    }
    private void ProcessReceive(SocketAsyncEventArgs e)
    {
        string mes = Encoding.UTF8.GetString(e.Buffer);
        //var receive = JsonSerializer.Deserialize<StrMessage>(e.Buffer);
        Console.WriteLine(mes.ToString());
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
