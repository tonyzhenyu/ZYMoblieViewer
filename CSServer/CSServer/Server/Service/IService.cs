// See https://aka.ms/new-console-template for more information


public interface IService
{
    public void Init();
    public void Process();
}

public abstract class Service : IService
{
    public string? name;

    public abstract void Init();

    public abstract void Process();

}