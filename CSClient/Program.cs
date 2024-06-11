// See https://aka.ms/new-console-template for more information
using System.Linq.Expressions;
using System.Net;
using System.Net.Sockets;
using System.Text;

Console.WriteLine("Hello, World!");

AProgram.Main(args);


public static class AProgram
{
    public static void Main(string[] args)
    {
        Socket client = new Socket(AddressFamily.InterNetwork, SocketType.Stream, ProtocolType.Tcp);

        EndPoint endpoint = new IPEndPoint(IPAddress.Parse("127.0.0.1"), 7777);
        client.Connect(endpoint);
        string content = DateTime.Now + "客户端";
        byte[] data = Encoding.UTF8.GetBytes(content);
        client.Send(data);

        client.Close();

        Console.WriteLine(content);
    }
}
