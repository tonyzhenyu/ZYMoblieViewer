using System;
using System.Collections;
using System.Runtime.InteropServices;
using Unity.Mathematics;
using UnityEngine;
using UnityEngine.Rendering;

public class VertexInertiaSimulator : IDisposable
{
    private SkinnedMeshRenderer skinnedMeshRenderer;
    [Serializable]public class Settings
    {
        public float mass = 1;
        public float stepTime = 0.02f;
        public Vector3 gravity = Physics.gravity;
    }
    private Settings settings;
    public struct VertexData
    {
        public float4 vertex;
        public float4 normal;
    }
    private VertexData[] vertices;
    private BoneWeight[] boneWeights;
    private Matrix4x4[] boneMatrix;
    private Matrix4x4[] bindPose;

    public class ShaderID
    {
        public static int vertexDataBufferID = Shader.PropertyToID("_VertexInputData");
        public static int cmbSkinnedOutputData = Shader.PropertyToID("_skinnedOutputData");

        public static int deltaTime = Shader.PropertyToID("_deltaTime");

        public static int boneWeights = Shader.PropertyToID("_BoneWeights");
        public static int boneMatrix = Shader.PropertyToID("_BoneLocalToWorldMatrix");

    }
    private CommandBuffer cmd;
    private ComputeShader computeshader;

    private ComputeBuffer cmbVertexData;
    private ComputeBuffer cmbBoneWeight;
    private ComputeBuffer cmbSkinnedOutputData;
    private ComputeBuffer cmbBoneMatrix;

    private int kernelStepPosition;
    private int kernelSkinning;

    private bool isInitialized = false;

    private int vertexCount;
    private int threadGroupX;

    public VertexInertiaSimulator(SkinnedMeshRenderer skinnedMeshRenderer,ComputeShader computeshader, Settings settings)
    {
        this.skinnedMeshRenderer = skinnedMeshRenderer;
        this.computeshader = computeshader;
        this.settings = settings;
    }
    public void Dispose()
    {
        if (!isInitialized) return;
        cmd.Dispose();
        cmbVertexData.Dispose();
        cmbBoneWeight.Dispose();
        cmbSkinnedOutputData.Dispose();
        cmbBoneMatrix.Dispose();
    }

    public IEnumerator InitializedBufferAysnc()
    {
        vertexCount = skinnedMeshRenderer.sharedMesh.vertexCount;

        cmbVertexData = new ComputeBuffer(vertexCount, Marshal.SizeOf(typeof(VertexData)));
        cmbBoneWeight = new ComputeBuffer(vertexCount, Marshal.SizeOf(typeof(BoneWeight)));
        cmbSkinnedOutputData = new ComputeBuffer(vertexCount, Marshal.SizeOf(typeof(VertexData)));
        cmbBoneMatrix = new ComputeBuffer(skinnedMeshRenderer.bones.Length, Marshal.SizeOf(typeof(Matrix4x4)));

        ComputeBuffer[] buffers = new ComputeBuffer[]
        {
            cmbVertexData,
            cmbBoneWeight,
            cmbSkinnedOutputData,
            cmbBoneMatrix
        };

        AsyncGPUReadbackRequest[] rqs = new AsyncGPUReadbackRequest[buffers.Length];

        
        for (int i = 0; i < buffers.Length; i++)
        {
            rqs[i] = AsyncGPUReadback.Request(buffers[i]);    
        }

        bool allTrue = false;
        while (!allTrue)
        {
            allTrue = true;
            foreach (var item in rqs)
            {
                if (!item.done)
                {
                    allTrue = false;
                    break;
                }
            }

            if (allTrue)
            {
                Debug.Log("Inited");
                isInitialized = true;
                break;
            }
            yield return null;
        }
    }

    public IEnumerator Initialized() // need to be async
    {
        while (true) // loop test
        {
            if (isInitialized == true)
            {
                cmd = CommandBufferPool.Get();

                this.kernelSkinning = computeshader.FindKernel("_KernelSkinning");
                //this.kernelStepPosition = computeshader.FindKernel("_KernelStepPosition");

                threadGroupX = Mathf.CeilToInt(vertexCount / 64);

                vertices = new VertexData[vertexCount];
                for (int i = 0; i < vertexCount; i++)
                {
                    Vector4 vertex = skinnedMeshRenderer.sharedMesh.vertices[i];
                    Vector4 normal = skinnedMeshRenderer.sharedMesh.normals[i];

                    vertices[i] = new VertexData()
                    {
                        vertex = vertex,
                        normal = normal
                    };
                }
                bindPose = skinnedMeshRenderer.sharedMesh.bindposes;
                boneWeights = skinnedMeshRenderer.sharedMesh.boneWeights;

                cmbVertexData.SetData(vertices);
                cmbSkinnedOutputData.SetData(vertices);
                cmbBoneWeight.SetData(boneWeights);

                // --- 这一段堵塞主线程
                computeshader.SetBuffer(kernelSkinning, ShaderID.boneWeights, cmbBoneWeight);
                computeshader.SetBuffer(kernelSkinning, ShaderID.boneMatrix, cmbBoneMatrix);

                computeshader.SetBuffer(kernelSkinning, ShaderID.vertexDataBufferID, cmbVertexData);
                computeshader.SetBuffer(kernelSkinning, ShaderID.cmbSkinnedOutputData, cmbSkinnedOutputData);

                //computeshader.SetBuffer(kernelStepPosition, ShaderID.vertexDataBufferID, cmbVertexData);
                //computeshader.SetBuffer(kernelStepPosition, ShaderID.cmbSkinnedOutputData, cmbSkinnedOutputData);
                //

                skinnedMeshRenderer.sharedMaterial.SetBuffer(ShaderID.vertexDataBufferID, cmbVertexData);
                boneMatrix = new Matrix4x4[skinnedMeshRenderer.bones.Length];

                OnRunEvt += () =>
                {
                    //skinning update
                    for (int i = 0; i < this.skinnedMeshRenderer.bones.Length; i++)
                    {
                        boneMatrix[i] = this.skinnedMeshRenderer.bones[i].localToWorldMatrix * bindPose[i];
                    }
                    cmbBoneMatrix.SetData(boneMatrix);
                    cmd.Clear();
                    cmd.DispatchCompute(computeshader, kernelSkinning, threadGroupX, 1, 1);
                    Graphics.ExecuteCommandBuffer(cmd);
                    return true;
                };
                //OnRunEvt += () =>
                //{
                //    //vertex data update
                //    cmd.Clear();
                //    cmd.DispatchCompute(computeshader, kernelStepPosition, threadGroupX, 1, 1);
                //    Graphics.ExecuteCommandBuffer(cmd);
                //    return true;
                //};

                yield break;
            }
            yield return null;
        }
    }

    public delegate bool OnAsyncRun();
    public event OnAsyncRun OnRunEvt;

    public IEnumerator AsyncRun()
    {
        float dt = 0;
        while (true)
        {
            dt += Time.deltaTime;
            if (dt >= settings.stepTime)
            {
                dt = 0;
                OnRunEvt?.Invoke();
            }
            yield return null;
        }
    }

}

