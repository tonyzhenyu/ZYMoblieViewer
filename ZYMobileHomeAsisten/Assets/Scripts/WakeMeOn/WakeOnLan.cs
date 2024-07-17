using System;
using System.Net;
using System.Net.Mail;
using System.Net.Sockets;
using UnityEngine;

public class WakeOnLan 
{
	public struct WakeData
	{
		public IPAddress ipAddress;
		public int port;
		public string macAddress;
	}
    public static void Wake(WakeData wakeData)
    {
        try
        {
            UdpClient udpClient = new UdpClient();
            udpClient.Connect(wakeData.ipAddress, wakeData.port);
            var packet = GetPacket(wakeData.macAddress);
            udpClient.Send(packet, packet.Length);
            Debug.Log("send");
        }
        catch (System.Exception ex)
        {
            Debug.Log(ex);
            throw;
        }
    }
    public static void Wake(string macAddress)
    {
		try
		{
			UdpClient udpClient = new UdpClient();
			udpClient.Connect(IPAddress.Broadcast, 9);
			var packet = GetPacket(macAddress);
			udpClient.Send(packet, packet.Length);
			Debug.Log("send");
		}
		catch (System.Exception ex)
		{
			Debug.Log(ex);
			throw;
		}
    }

	static byte[] GetPacket(string macAddress)
	{
		byte[] packet = new byte[17 * 6];
		byte[] macBytes = GetMacBytes(macAddress);
		for (int i = 0; i < 6; i++)
		{
            packet[i] = 0xFF;
		}

		for (int i = 1; i <= 16; i++)
		{
			for (int j = 0; j < 6; j++)
			{
				packet[i * 6 + j] = macBytes[j];
			}
		}
		return packet;
	}
	static byte[] GetMacBytes(string macAddress)
	{
		string[] macStr = macAddress.Split(':', '-');
		byte[] macBytes = new byte[6];

		for (int i = 0; i < 6; i++)
		{
			macBytes[i] = Convert.ToByte(macStr[i], 16);
		}
		return macBytes;
	}
}
