using UnityEngine;

public class VertexInertiaMovement : MonoBehaviour
{
    private VertexInertiaSimulator simulator;
    public VertexInertiaSimulator.Settings setting;
    public SkinnedMeshRenderer skinnedMeshRenderer;
    public ComputeShader computeshader;
    private void Awake()
    {
        simulator = new VertexInertiaSimulator(skinnedMeshRenderer, computeshader,setting);
    }
    private void Start()
    {
        StartCoroutine(simulator.InitializedBufferAysnc());
        StartCoroutine(simulator.Initialized());
        StartCoroutine(simulator.AsyncRun());
    }
    private void LateUpdate()
    {

    }
    private void OnDestroy()
    {
        simulator?.Dispose();
    }

    [ContextMenu("Test")]
    private void Test()
    {
        simulator = new VertexInertiaSimulator(skinnedMeshRenderer, computeshader, setting);
        StartCoroutine(simulator.InitializedBufferAysnc());
        StartCoroutine(simulator.Initialized());
        //StartCoroutine(simulator.AsyncRun());
    }
}

