using System.ComponentModel;
using ZY.Game;

namespace ZY.MVVM
{
    public abstract class ViewModelBase : INotifyPropertyChanged
    {
        public event PropertyChangedEventHandler PropertyChanged;
        protected virtual void OnPropertyChanged(string propertyName)
        {
            PropertyChanged?.Invoke(this, new PropertyChangedEventArgs(propertyName));
        }
        protected virtual void Init()
        {

        }
        public ViewModelBase()
        {
            Init();
        }
    }
}
