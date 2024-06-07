using System.Runtime.Serialization;

namespace MessageDataCSProject
{
    public class MessageData
    {
        void Test()
        {
            Message<string> message = new Message<string>();

            //FileStream fs = new FileStream();

            //BinaryFormatter binaryFormatter = new BinaryFormatter();
            //binaryFormatter.Serialize(fs, message);

            //DataContractSerializer ds;
            //ds.
        }

    }

    public class User
    {
        public string? name;
        public int code;
    }


    [Serializable]
    public class Message<T> where T : class
    {
        public T? data;
        public User? author;
        public User? target;
        public string? dateTime;
        public float runTime;
        public bool isRichText;
    }
    public class MessageFormatter : IFormatter
    {
        public SerializationBinder? Binder { get => throw new NotImplementedException(); set => throw new NotImplementedException(); }
        public StreamingContext Context { get => throw new NotImplementedException(); set => throw new NotImplementedException(); }
        public ISurrogateSelector? SurrogateSelector { get => throw new NotImplementedException(); set => throw new NotImplementedException(); }

        public object Deserialize(Stream serializationStream)
        {
            throw new NotImplementedException();
        }

        public void Serialize(Stream serializationStream, object graph)
        {
            throw new NotImplementedException();
        }
    }

}
