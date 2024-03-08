using System.Collections.Generic;

namespace ZY.Game.Utilities
{
    public class FieldContainer
    {
        public Dictionary<string, object> data = new Dictionary<string, object>();

        public void Register<T>(T instance)
        {
            string name = nameof(instance);
            
            if (data.ContainsKey(name))
            {
                data[name] = instance;
            }
            else
            {
                data.Add(name, instance);
            }

        }
        public T Get<T>(string name) where T : class
        {
            var type = typeof(T);

            if (data.TryGetValue(name, out object instance))
            {
                return instance as T;
            }
            return null;
        }
    }

}
