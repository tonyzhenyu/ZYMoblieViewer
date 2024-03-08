using UnityEngine;

namespace ZY.MVVM
{
    [RequireComponent(typeof(CanvasGroup))]
    public abstract class ViewBase<T> : MonoBehaviour where T : ViewModelBase, new()
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
                isIntialized = true;
            }
        }
        protected virtual void Update()
        {
            context.UpdateModel();
        }
        protected virtual void OnEnable()
        {

        } 
        protected virtual void OnDestroy()
        {

        }
        
    }
}
