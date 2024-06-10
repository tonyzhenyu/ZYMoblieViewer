namespace CSServer.Message
{
    [Serializable]
    public abstract class Message<T> where T : class
    {
        public T? data;
        public User? author;
        public User? target;
        public string? dateTime;
        public float runTime;
        public bool isRichText;
    }

}
