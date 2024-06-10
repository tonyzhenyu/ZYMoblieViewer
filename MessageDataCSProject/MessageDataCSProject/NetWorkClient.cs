using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Net.Sockets;
using System.Text;
using System.Threading.Tasks;

namespace MessageDataCSProject
{
    internal class NetWorkClient
    {
        private Socket clientSocket;
        public NetWorkClient()
        {
            clientSocket = new Socket(AddressFamily.InterNetwork, SocketType.Stream, ProtocolType.Tcp);
        }
        public void Initialize(string serverAddress,int serverPort)
        {
            IPAddress serverIp = IPAddress.Parse(serverAddress);
            IPEndPoint serverEndPoint = new IPEndPoint(serverIp, serverPort);
            ConnectToServer(serverEndPoint);
        }

        private void ConnectToServer(IPEndPoint endPoint)
        {
            try
            {
                clientSocket.Connect(endPoint);
                Console.WriteLine("Connected to server");
            }
            catch (SocketException e)
            {
                Console.WriteLine($"Failed to connect: {e.Message}");
                throw;
            }
        }

        public void Send(byte[] data)
        {
            if (clientSocket.Connected)
            {
                try
                {
                    // 发送数据
                    int bytesSent = clientSocket.Send(data);
                    Console.WriteLine($"Sent {bytesSent} bytes.");
                }
                catch (SocketException e)
                {
                    Console.WriteLine($"Error sending data: {e.Message}");
                    throw;
                }
            }
            else
            {
                Console.WriteLine("Not connected to server.");
            }
        }
        public byte[]? Receive(int bufferSize)
        {
            byte[] receivedData = new byte[bufferSize];

            if (clientSocket.Connected)
            {
                try
                {
                    // 接收数据
                    int bytesReceived = clientSocket.Receive(receivedData);
                    Console.WriteLine($"Received {bytesReceived} bytes.");
                    Array.Resize(ref receivedData, bytesReceived);
                    return receivedData;
                }
                catch (SocketException e)
                {
                    Console.WriteLine($"Error receiving data: {e.Message}");
                    return null;
                }
            }
            else
            {
                Console.WriteLine("Not connected to server.");
                return null;
            }
        }
    }
}
