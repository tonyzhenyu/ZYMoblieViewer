using UnityEngine;
using ZY.Game;

namespace ZY.MVVM
{
    public interface IView
    {
        public void OnRegister();
        public void OnUnregister();
        public GameObject GetObject();
    }
    [RequireComponent(typeof(CanvasGroup))]
    public abstract class ViewBase<T> :  MonoBehaviour,IView where T : ViewModelBase, new()
    {
        public ViewBase<T> Parent { get; set; }

        private T context = new T();
        public T BindingContext 
        { 
            get => context; 
            set 
            {
                if (isIntialized == false)
                {
                    Init();
                    isIntialized = true;
                }
                context = value;
            }
        }
        private bool isIntialized = false;
        protected abstract void Init();
        protected virtual void Awake()
        {
            if (isIntialized == false)
            {
                Init();
                OnRegister();
                isIntialized = true;
            }
        }
        protected virtual void OnEnable()
        {

        } 
        protected virtual void OnDestroy()
        {
            OnUnregister();
        }

        public void OnRegister()
        {
            UIManager.GetInstance().Register(this.gameObject.name,this);
        }        
        public void OnUnregister()
        {
            UIManager.GetInstance().Unregister(this.gameObject.name);
        }

        public GameObject GetObject()
        {
            return this.gameObject;
        }
    }
}
