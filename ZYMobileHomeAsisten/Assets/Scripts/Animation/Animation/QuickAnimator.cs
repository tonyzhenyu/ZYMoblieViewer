using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace QuickAnimate
{
    public class QuickAnimator : MonoBehaviour
    {
        public delegate void QuickAnimationHandler();
        public event QuickAnimationHandler OnStart;
        public event QuickAnimationHandler OnEvaluate;
        public event QuickAnimationHandler OnEnd;

        public QuickAnimation animaType;

        private void Awake()
        {
            animaType = new QuickAnimation();
        }
        private void Start()
        {
            StartCoroutine("PlayAnimation");
        }
        private void Update()
        {
            animaType.Evaluate();
            OnEvaluate?.Invoke();
        }

        IEnumerator PlayAnimation()
        {
            yield return new WaitForSeconds(animaType.delay);
            animaType.myState = AnimaState.Play;
            OnStart?.Invoke();

            yield return new WaitForSeconds(animaType.delay + animaType.duration);
            animaType.myState = AnimaState.Stop;
            OnEnd?.Invoke();
            Destroy(this);

        }
    }

}

