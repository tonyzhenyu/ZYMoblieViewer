using UnityEngine;

namespace StageProcess
{
    [ExecuteInEditMode]
    public class MAmbientController : MonoBehaviour
    {
        [SerializeField] private Color color;

        public Color @Color 
        { 
            get => color_tmp; 
            set 
            {
                if (value == color_tmp)
                {

                }
                else
                {
                    color_tmp = value;
                    JDMStyleConfigure.environmentRuntimeParam.ambient = color_tmp;
                }
            } 
        }
        private Color color_tmp;
   
        private void Update()
        {
            @Color = color;
        }
        private void OnValidate()
        {
            @Color = color;
        }
    }
}
