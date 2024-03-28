using UnityEngine;


[ExecuteInEditMode]
public class JDMStyleRuntimeController : MonoBehaviour
{
    public JDMStyleConfigure.RuntimeParam runtimeParam = new JDMStyleConfigure.RuntimeParam()
    {
        environmentLighting = new JDMStyleConfigure.EnvironmentLighting()
        {
            characterEnvironmentTint = Color.white,
            characterEnvironmentIntensity = 0.5f
        },
        fog = new JDMStyleConfigure.Fog()
        {
            fogweight = 0
        },
        matcapLighting = new JDMStyleConfigure.MatcapLighting()
        {
            highlightWeight = 1,
            matcapWeight = 1,
            metalReflectWeight = 1
        }
    };

    public JDMStyleConfigure.FeverParam feverparam = new JDMStyleConfigure.FeverParam();
    [Range(0, 1)] public float staticWeight;
    // Start is called before the first frame update
    void Start()
    {
        
    }

    private void OnEnable()
    {
        JDMStyleConfigure.runtimeParam = runtimeParam;
        JDMStyleConfigure.feverParam = feverparam;
        JDMStyleConfigure.Weight = staticWeight;
    }
    private void OnDisable()
    {
        JDMStyleConfigure.runtimeParam = default;
        JDMStyleConfigure.feverParam = default;
        JDMStyleConfigure.Weight = 0;
    }
    private void OnValidate()
    {
        JDMStyleConfigure.runtimeParam = runtimeParam;
        JDMStyleConfigure.feverParam = feverparam;
        JDMStyleConfigure.Weight = staticWeight;
    }
    private void OnDestroy()
    {
        JDMStyleConfigure.runtimeParam = default;
        JDMStyleConfigure.feverParam = default;
        JDMStyleConfigure.Weight = 0;
    }
    // Update is called once per frame
    void Update()
    {
        JDMStyleConfigure.runtimeParam = runtimeParam;
        JDMStyleConfigure.feverParam = feverparam;
        JDMStyleConfigure.Weight = staticWeight;
    }
}
