

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

