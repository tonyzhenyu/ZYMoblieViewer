using System.Collections;
using UnityEngine;

public class CbufferCopyPosition : MonoBehaviour
{
    public SkinnedMeshRenderer skinnedMesh;

    public ComputeShader computeShader;
    int kernelID;

    ComputeBuffer boneWeightBuffer;
    ComputeBuffer boneMatrixBuffer;
    ComputeBuffer mVertexBuffer;

    Vector4[] vertexDatas;
    BoneWeight[] boneWeights;
    Matrix4x4[] boneMatrix;
    Matrix4x4[] boneposes;

    int vertexCount;
    class ID
    {
        public static int boneposes = Shader.PropertyToID("_Boneposes");
        public static int mVertices = Shader.PropertyToID("_mVertices");
        public static int boneWeights = Shader.PropertyToID("_BoneWeights");
        public static int boneMatrix = Shader.PropertyToID("_BoneLocalToWorldMatrix");

        public static int mVerticesCount = Shader.PropertyToID("_VertexCount");
    }
    void Start()
    {
        kernelID = computeShader.FindKernel("VertexSkinning");
        StartCoroutine(InitBuffer());
    }
    private void OnDestroy()
    {

    }

    IEnumerator InitBuffer()
    {

        vertexCount = skinnedMesh.sharedMesh.vertexCount;
        vertexDatas = new Vector4[vertexCount];
        
        for (int i = 0; i < vertexCount; i++)
        {
            vertexDatas[i] = skinnedMesh.sharedMesh.vertices[i];
        }
        mVertexBuffer.SetData(vertexDatas);
        boneposes = skinnedMesh.sharedMesh.bindposes;
        boneWeights = skinnedMesh.sharedMesh.boneWeights;
        boneWeightBuffer.SetData(boneWeights);
        computeShader.SetBuffer(0, ID.boneWeights, boneWeightBuffer);
        

        yield return true;
    }

    private void LateUpdate()
    {
        for (int i = 0; i < skinnedMesh.bones.Length; i++)
        {
            boneMatrix[i] = skinnedMesh.bones[i].localToWorldMatrix * boneposes[i];
        }
        computeShader.SetMatrixArray(ID.boneMatrix, boneMatrix);
        computeShader.Dispatch(kernelID, Mathf.CeilToInt(vertexCount / 64), 1, 1);
    }

}
