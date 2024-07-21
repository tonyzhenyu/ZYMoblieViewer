using System.Collections;
using UnityEngine;
using UnityEngine.UI;

public class PrintTextAnimation : MonoBehaviour
{
    public string str;
    public float duration = 0.02f;
    public bool skip = false;
    Text text;
    int currentIndex = 0;
    private void Awake()
    {
        text = GetComponent<Text>();
    }
    void Start()
    {
        text.text = "";
    }
    private void OnEnable()
    {
        StartCoroutine(enumerator());
    }

    IEnumerator enumerator()
    {
        while (true)
        {
            yield return new WaitForSeconds(duration);
            if (currentIndex >= str.Length - 1 || skip == true)
            {
                text.text = str;
                Destroy(this);
            }
            currentIndex += 1;
            text.text = str.Substring(0, Mathf.Min(currentIndex,str.Length));
            
        }
    }
}
