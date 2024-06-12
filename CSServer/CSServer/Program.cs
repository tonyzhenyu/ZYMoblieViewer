Console.WriteLine("Hello, World!");
ProgramController.Main();
public static class ProgramController
{
    const int waitTime = 300;
    static long time;
    static Server server;
    public static void Main()
    {
        server = ServerHandler.Instance.LoadServerConiguration();
    }
    private static void HeartBeating()
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