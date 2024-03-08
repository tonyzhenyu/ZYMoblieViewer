using System.Collections.Generic;

namespace ZY.Game.Utilities
{
    public class ObjectPool<T> where T : new()
    {
        private Stack<T> pool;

        public ObjectPool(int initialSize)
        {
            pool = new Stack<T>(initialSize);
            for (int i = 0; i < initialSize; i++)
            {
                pool.Push(new T());
            }
        }

        public T GetObject()
        {
            if (pool.Count > 0)
            {
                return pool.Pop();
            }
            else
            {
                return new T();
            }
        }

        public void ReturnObject(T obj)
        {
            pool.Push(obj);
        }
    }
}
