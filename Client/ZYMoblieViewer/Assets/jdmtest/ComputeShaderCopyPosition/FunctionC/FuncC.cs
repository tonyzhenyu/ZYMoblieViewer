using System.Collections;
using Unity.Mathematics;
using UnityEngine;

public class FuncC : MonoBehaviour
{
   public ComputeShader computeShader;
    public SkinnedMeshRenderer skinnedMeshRenderer;
    public float maxDeltaTime = 0;
    public bool isEnd = false;
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

        ComputeBuffer boneMatrixBuffer = new ComputeBuffer(skinnedMeshRenderer.bones.Length, System.Runtime.InteropServices.Marshal.SizeOf(typeof(Matrix4x4)));

        var kernal = computeShader.FindKernel("CSMain");

        computeShader.SetBuffer(kernal, "_BoneLocalToWorldMatrix", boneMatrixBuffer);

        var vertexBuffer = skinnedMeshRenderer.sharedMesh.GetVertexBuffer(0);
        var indexBuffer = skinnedMeshRenderer.sharedMesh.GetIndexBuffer();
        var boneWeightBuffer = skinnedMeshRenderer.sharedMesh.GetBoneWeightBuffer(SkinWeights.FourBones);


        skinnedMeshRenderer.sharedMesh.vertexBufferTarget |= GraphicsBuffer.Target.Raw;
        skinnedMeshRenderer.sharedMesh.indexBufferTarget |= GraphicsBuffer.Target.Raw;
        
        computeShader.SetBuffer(kernal, "_BoneWeights", boneWeightBuffer);
        computeShader.SetBuffer(kernal, "_VertexBuffer", vertexBuffer);
        computeShader.SetBuffer(kernal, "_IndexBuffer", indexBuffer);

        computeShader.SetInt("_Stride", skinnedMeshRenderer.sharedMesh.GetVertexBufferStride(0));
        computeShader.SetInt("_IndicesCount", (int)skinnedMeshRenderer.sharedMesh.GetIndexCount(0));
        computeShader.SetInt("_VerticesCount", skinnedMeshRenderer.sharedMesh.vertexCount);

        skinnedMeshRenderer.material.SetBuffer("_VertexBuffer", vertexBuffer);
        skinnedMeshRenderer.material.SetInt("_Stride", skinnedMeshRenderer.sharedMesh.GetVertexBufferStride(0));

        Matrix4x4[] resetMatrix = skinnedMeshRenderer.sharedMesh.bindposes;
        Matrix4x4[] localToWorld = new Matrix4x4[skinnedMeshRenderer.bones.Length];

        while (true)
        {
            dt += Time.deltaTime;
            if (dt > maxDeltaTime)
            {
                for (int i = 0; i < localToWorld.Length; i++)
                {
                    localToWorld[i] = skinnedMeshRenderer.bones[i].localToWorldMatrix * resetMatrix[i];
                }
                boneMatrixBuffer.SetData(localToWorld);
                computeShader.Dispatch(kernal, Mathf.CeilToInt(skinnedMeshRenderer.sharedMesh.vertexCount / 64), 1, 1);
            }
            if (isEnd == true)
            {
                boneMatrixBuffer.Release();
                yield break;
            }
            yield return null;
        }

    }
}
