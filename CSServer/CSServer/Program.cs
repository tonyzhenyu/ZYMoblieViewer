

using static ProjectPath;

Console.WriteLine("Hello, World!");

ProgramController pc = new ProgramController();
pc.Main();


public class ProgramController
{
    const int waitTime = 300;
    long time;
    Server server;
    public void Main()
    {
        server = new Server();
        server.Run();
        HeartBeating();
    }
    private void HeartBeating()
    {
        while (true)
        {
            time += 1;
            //Console.SetCursorPosition(0, 1);
            //Console.WriteLine($"tick:{time}");
            //Console.SetCursorPosition(0, 1);
            Thread.Sleep(waitTime);
        }
    }
}