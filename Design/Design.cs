

namespace MobileViewer{
    public class Design
    {
        
    }

    [Serializable]
    public class Message<T> where T : class
    {
        public User author;
        public User target;


        public bool isReaded;
        public DateTime dateTime;
        public T data;

    }
    public interface MessageHandler<T> where T : class
    {
        public T Encoding(Message<T> input);
    }



}



namespace Server{

    public interface ServiceHandler{
        void Send();
        void Recive();
    }
    public interface Service{
            
    }
    public class Server{
        public IpAddress ip;
        public string name;
        public Service[] services;
    }

    public class DataBase : Service{
        
    }
    public class SMBFileSystem : Service{

    }

}