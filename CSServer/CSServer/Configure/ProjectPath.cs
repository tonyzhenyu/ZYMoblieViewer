public static class ProjectPath
{ 
    public static void CheckAllPath()
    {
        string[] paths =
        {   
            projectPathDir,
            Server.Path,
            MessageSotrageDir,
        };

        for (int i = 0; i < paths.Length; i++)
        {
            // to do ..
            //Directory paths[i]; 
            throw new NotImplementedException();
        }
    }

    public static string projectPathDir = Path.GetFullPath(Path.Combine(AppDomain.CurrentDomain.BaseDirectory, @"..\..\.."));
    public static class Server
    {
        public static string Path {
            get
            {
                return System.IO.Path.Combine(projectPathDir, @"Configuration\ServerConfigure.json");
            }
        } 
    }
    public static string MessageSotrageDir = System.IO.Path.Combine(projectPathDir, @"Data\Message");
}
