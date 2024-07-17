using System;
using System.Net.Sockets;
using System.Text;
using UnityEngine;

public class RemoteShutdown 
{
    public static void SendShutdownCommand(string ipAddress, int port)
    {
        try
        {
            TcpClient client = new TcpClient(ipAddress, port);
            NetworkStream stream = client.GetStream();

            string message = "shutdown";
            byte[] data = Encoding.ASCII.GetBytes(message);

            stream.Write(data, 0, data.Length);
            Debug.Log("Sent: " + message);

            stream.Close();
            client.Close();
        }
        catch (ArgumentNullException e)
        {
            Debug.LogError("ArgumentNullException: " + e);
        }
        catch (SocketException e)
        {
            Debug.LogError("SocketException: " + e);
        }
    }
}
