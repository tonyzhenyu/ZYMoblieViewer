// See https://aka.ms/new-console-template for more information


public abstract class Service : IService
{
    public virtual string Name { get; set; }

    public abstract void Init();

    public abstract void Process();

}