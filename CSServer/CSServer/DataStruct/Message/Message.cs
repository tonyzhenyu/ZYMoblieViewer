namespace CSServer.DataStruct.Message
{

    public abstract class Message<T> where T : class
    {
        private T? data;
        private User? author;
        private User? target;
        private string? dateTime;

        public virtual T? Data { get => data; set => data = value; }
        public virtual User? Author { get => author; set => author = value; }
        public virtual User? Target { get => target; set => target = value; }
        public virtual string? DateTime { get => dateTime; set => dateTime = value; }

    }

}
