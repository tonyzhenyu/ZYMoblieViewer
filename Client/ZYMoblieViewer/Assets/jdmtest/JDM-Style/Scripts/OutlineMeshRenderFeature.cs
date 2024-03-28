using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;


public class OutlineMeshRenderFeature : ScriptableRendererFeature
{
    [HideInInspector] public string passName = "OutlineMesh";
    private DrawObectsPass m_ScriptablePass;

    public float outlineWidth = 1;
    public override void Create()
    {
        m_ScriptablePass = new DrawObectsPass(outlineWidth);
        m_ScriptablePass.ShaderTagId = new ShaderTagId(passName);
        m_ScriptablePass.renderPassEvent = RenderPassEvent.BeforeRenderingOpaques;
    }

    public override void AddRenderPasses(ScriptableRenderer renderer, ref RenderingData renderingData)
    {
        renderer.EnqueuePass(m_ScriptablePass);
    }
    public class DrawObectsPass : ScriptableRenderPass
    {
        public ShaderTagId ShaderTagId { get; set; }
        public float Width { get; set; }

        static int propID = Shader.PropertyToID("_OutlineWidth");
        public DrawObectsPass(float outlineWidth)
        {
            Width = outlineWidth;
        }
        public override void Execute(ScriptableRenderContext context, ref RenderingData renderingData)
        {
            if (Width <= 0)
            {
                return;
            }


            CommandBuffer cmd = CommandBufferPool.Get();
            cmd.SetGlobalFloat(propID, Width);
            context.ExecuteCommandBuffer(cmd);
           

            DrawingSettings drawingSettings = new DrawingSettings(ShaderTagId, new SortingSettings());
            FilteringSettings filteringSettings = new FilteringSettings(RenderQueueRange.all);
            drawingSettings.perObjectData |= PerObjectData.LightProbe;
            context.DrawRenderers(renderingData.cullResults, ref drawingSettings, ref filteringSettings);

            cmd.Release();

        }
    }
}
