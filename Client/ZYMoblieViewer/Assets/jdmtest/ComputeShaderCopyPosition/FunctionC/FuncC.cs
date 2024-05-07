using System.Collections;
using Unity.Mathematics;
using UnityEngine;

public class FuncC : MonoBehaviour
{
    public ComputeShader computeShader;
    public SkinnedMeshRenderer skinnedMeshRenderer;
    public float kk = 0;

    // Start is called before the first frame update
    void Start()
    {
        StartCoroutine(Ticking());

    }

    // Update is called once per frame
    void Update()
    {

    }
    private void LateUpdate()
    {

    }

    struct VertexData
    {
        public uint id;
        public float3 vertexPosition;
    }
    IEnumerator Ticking()
    {
        float dt = 0;

        var v = skinnedMeshRenderer.sharedMesh.vertices;
        var b = skinnedMeshRenderer.sharedMesh.boneWeights;
        int[] index = new int[v.Length];

        for (int i = 0; i < index.Length; i++)
        {
            index[i] = i;
        }

        ComputeBuffer vertexBuffer = new ComputeBuffer(v.Length, System.Runtime.InteropServices.Marshal.SizeOf(typeof(float3)));
        ComputeBuffer indexBuffer = new ComputeBuffer(index.Length, System.Runtime.InteropServices.Marshal.SizeOf(typeof(int)));
        ComputeBuffer boneBuffer = new ComputeBuffer(b.Length, System.Runtime.InteropServices.Marshal.SizeOf(typeof(BoneWeight)));
        ComputeBuffer boneMatrixBuffer = new ComputeBuffer(skinnedMeshRenderer.bones.Length, System.Runtime.InteropServices.Marshal.SizeOf(typeof(Matrix4x4)));

        vertexBuffer.SetData(v);
        indexBuffer.SetData(index);
        boneBuffer.SetData(b);
        
        var kernal = computeShader.FindKernel("CSMain");
        computeShader.SetBuffer(kernal, "_vertexBuffer", vertexBuffer);
        computeShader.SetBuffer(kernal, "_indexBuffer", indexBuffer);
        computeShader.SetBuffer(kernal, "_BoneWeights", boneBuffer);
        computeShader.SetBuffer(kernal, "_BoneLocalToWorldMatrix", boneMatrixBuffer);

        Matrix4x4[] resetMatrix = skinnedMeshRenderer.sharedMesh.bindposes;
        Matrix4x4[] localToWorld = new Matrix4x4[skinnedMeshRenderer.bones.Length];

        while (true)
        {
            dt += Time.deltaTime;
            if (dt > kk)
            {
                var buffer = skinnedMeshRenderer.GetPreviousVertexBuffer();
                skinnedMeshRenderer.sharedMesh.vertexBufferTarget |= GraphicsBuffer.Target.Raw;
                skinnedMeshRenderer.sharedMaterial.SetBuffer("_PreviousBuffer", buffer);
                skinnedMeshRenderer.sharedMaterial.SetBuffer("_vertexBuffer",vertexBuffer);

                for (int i = 0; i < localToWorld.Length; i++)
                {
                    localToWorld[i] = skinnedMeshRenderer.bones[i].localToWorldMatrix * resetMatrix[i];
                }
                boneMatrixBuffer.SetData(localToWorld);
                computeShader.Dispatch(kernal, Mathf.CeilToInt(skinnedMeshRenderer.sharedMesh.vertexCount / 64), 1, 1);
            }
            yield return null;
        }

    }
}
