using System.Net;
using System.Net.Sockets;
using System.Text.Json;
using System.Text.Json.Serialization.Metadata;

public class ServerHandler : Singleton<ServerHandler>
{
    public Server LoadServerConiguration()
    {
        using (FileStream fs = File.OpenRead(ProjectPath.Server.path))
        {
            try
            {
                JsonSerializerOptions options = new JsonSerializerOptions()
                {
                    PropertyNameCaseInsensitive = true,
                    PropertyNamingPolicy = JsonNamingPolicy.CamelCase,
                };

                var ds = JsonSerializer.Deserialize<ServerConfigure>(fs, options);
                Server s = new Server(ds.ip, ds.port);
                return s;
            }
            catch (Exception e)
            {
                throw;
            }

        }
    }
}
