using System;
using System.Diagnostics;
using System.Net;
using System.Net.Sockets;
using System.ServiceProcess;
using System.Text;

namespace ShutdownService
{
    public partial class ShutdownService : ServiceBase
    {
        public ShutdownService()
        {
            InitializeComponent();
        }

        protected override void OnStart(string[] args)
        {
            TcpListener server = null;
            try
            {
                Int32.TryParse(args[0],out var output);
                Int32 port = output;
                server = new TcpListener(IPAddress.Any, port);
                server.Start();

                Byte[] bytes = new Byte[256];
                String data = null;

                while (true)
                {
                    Console.Write("Waiting for a connection... ");

                    TcpClient client = server.AcceptTcpClient();
                    Console.WriteLine("Connected!");

                    data = null;

                    NetworkStream stream = client.GetStream();

                    int i;
                    while ((i = stream.Read(bytes, 0, bytes.Length)) != 0)
                    {
                        data = Encoding.ASCII.GetString(bytes, 0, i);
                        Console.WriteLine("Received: {0}", data);
                        if (data.Trim().ToLower() == "shutdown")
                        {
                            Process.Start("shutdown", "/s /t 0");
                        }
                    }

                    client.Close();
                }
            }
            catch (SocketException e)
            {
                Console.WriteLine("SocketException: {0}", e);
            }
            finally
            {
                server.Stop();
            }

            Console.WriteLine("\nHit enter to continue...");
            Console.Read();
        }

        protected override void OnStop()
        {
        }
    }
}
