// See https://aka.ms/new-console-template for more information
Console.WriteLine("Hello, World!");
ProgramController pc = new ProgramController();

pc.Main();

public class ProgramController
{
    const int waitTime = 300;
    long time;
    public void Main()
    {
        HeartBeating();
    }
    private void HeartBeating()
    {
        while (true)
        {
            time += 1;
            Console.WriteLine($"tick:{time}");
            Console.SetCursorPosition(0, 1);
            Thread.Sleep(waitTime);
        }
    }
}