using System.Collections;
using System.Collections.Generic;
using UnityEngine;
namespace QuickAnimate
{
    public enum AnimaState { Play,Stop,Pause}
    [System.Serializable]
    public class QuickAnimation
    {
        public AnimationCurve animationCurve;
        public float delay;
        public float duration;
        public float value;

        public AnimaState myState = AnimaState.Stop;


        private float t;
        public QuickAnimation()
        {
            animationCurve  = new AnimationCurve(new Keyframe(0,0), new Keyframe(1,1));
            animationCurve.postWrapMode = WrapMode.Clamp;
            animationCurve.preWrapMode = WrapMode.Clamp;

            delay           = 0;
            duration        = 1;
            value           = 0;
        }

        public void Evaluate()
        {
            if (myState == AnimaState.Play)
            {
                t += Time.deltaTime / duration;
                value = animationCurve.Evaluate(t);
            }
        }
    }
}
