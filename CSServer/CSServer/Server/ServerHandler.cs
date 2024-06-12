using System.Text.Json;

public class ServerHandler : Singleton<ServerHandler>
{
    public Server LoadServerConiguration()
    {
        using (FileStream fs = File.OpenRead(ProjectPath.Server.Path))
        {
            try
            {
                JsonSerializerOptions options = new JsonSerializerOptions()
                {
                    PropertyNameCaseInsensitive = true,
                    PropertyNamingPolicy = JsonNamingPolicy.CamelCase,
                    NumberHandling = System.Text.Json.Serialization.JsonNumberHandling.AllowReadingFromString|System.Text.Json.Serialization.JsonNumberHandling.WriteAsString
                };

                ServerConfigure ds = JsonSerializer.Deserialize<ServerConfigure>(fs,options)!;
                return new Server(ds.Ip, ds.Port);
            }
            catch (Exception e)
            {
                throw;
            }

        }
    }
}
