using System;
using System.Collections.Generic;

namespace ZY.Game.Utilities
{
    public class IOCContainer
    {
        public Dictionary<Type, object> data = new Dictionary<Type, object>();

        public void Register<T>(T instance)
        {
            var type = typeof(T);

            if (data.ContainsKey(type))
            {
                data[type] = instance;
            }
            else
            {
                data.Add(type, instance);
            }

        }
        public T Get<T>() where T : class
        {
            var type = typeof(T);

            if (data.TryGetValue(type, out object instance))
            {
                return instance as T;
            }
            return null;
        }
        public bool Remove<T>() where T : class
        {
            var type = typeof(T);
            if (data.Remove(type))
            {
                return true;
            }
            return false;
        }
    }    

}
