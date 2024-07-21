//using ZY.Game.Utilities;
using System.Collections.Generic;
using ZY.MVVM;

namespace ZY.Game
{
    public class UIManager :Singleton<UIManager>
    {
        //protected override void Init()
        //{
        //    base.Init();

        //}

        private Dictionary<string, IView> viewDictionary;
        public Dictionary<string, IView> ViewDictionary
        {
            get => viewDictionary;
        }

        private void Start()
        {

        }
        private void Update()
        {

        }
        protected override void Init()
        {
            base.Init();
            viewDictionary = new Dictionary<string, IView>();

        }
        public void Register(string name,IView view)
        {
            ViewDictionary.Add(name,view);
        }
        public void Unregister(string name)
        {
            viewDictionary.Remove(name);
        }

    }
}


