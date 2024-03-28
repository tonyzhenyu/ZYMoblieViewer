using UnityEngine;


public class MFurController : MonoBehaviour
{
    //MagicaRenderDeformer deformer;
    private SkinnedMeshRenderer mr;
    private ComputeBuffer buffer;
    private Mesh mesh;

    public float test =1;
    void Start()
    {
        //mesh = deformer.Deformer.Mesh;
        buffer = new ComputeBuffer(mesh.vertices.Length, sizeof(float) * 3);
    }
    private void LateUpdate()
    {
        
    }
}
