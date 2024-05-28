using System;
using UnityEngine.UIElements;

namespace ZY.MVVM
{

    public sealed class BindableProperty<T> 
    {
        public delegate void ValueChangeHandler(T oldValue, T newValue);

        public ValueChangeHandler OnValueChaged;


        private T value;
        public T Value { 
            get 
            {
                return value;
            } 
            set 
            {
                if (!Equals(this.value, value))
                {
                    T old = this.value;
                    this.value = value;
                    OnValueChaged?.Invoke(old, this.value);
                }
            } 
        }
    }
}
