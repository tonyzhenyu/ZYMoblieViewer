// See https://aka.ms/new-console-template for more information
public class Singleton<T>  where T : new()
{
    private static T instance = default;
    public static T Instance
    {
        get
        {
            if (instance == null)
            {
                instance = new T();
            }
            return instance;
        }
    }
}