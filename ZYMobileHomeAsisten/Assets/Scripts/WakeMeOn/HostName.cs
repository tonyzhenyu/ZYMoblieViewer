using System.Net;
using System.Net.Sockets;

public class HostName
{
    public static string GetHostName(IPEndPoint remoteEndPoint)
    {
        // 获取远程终结点的IP地址
        if (remoteEndPoint != null)
        {
            IPAddress ipAddress = remoteEndPoint.Address;
            try
            {
                // 反向DNS查找获取主机名
                IPHostEntry hostEntry = Dns.GetHostEntry(ipAddress);
                
                return hostEntry.HostName;
            }
            catch (SocketException)
            {
                // 反向DNS查找失败
                return null;
            }
        }
        return null;
    }
}