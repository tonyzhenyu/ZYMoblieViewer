using System;
using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

public class JDMStyleConfigureFeature : ScriptableRendererFeature
{
    class ConfigurePass : ScriptableRenderPass
    {
        Settings m_packing;
        JDMStyleRuntimeParamController runtimeParamsController;
        public ConfigurePass(Settings packing)
        {
            runtimeParamsController = new JDMStyleRuntimeParamController();
            m_packing = packing;
        }
        public override void Execute(ScriptableRenderContext context, ref RenderingData renderingData)
        {
            var cmd = CommandBufferPool.Get();
            cmd.BeginSample("Style Process Configuring");

            Color feverColor = JDMStyleConfigure.feverParam.feverColor;
            feverColor.a = Mathf.Min(JDMStyleConfigure.Weight, JDMStyleConfigure.feverParam.feverColor.a);
            cmd.SetGlobalColor(JDMStyleIDPackaging.id_FeverEmissionColor, feverColor);

            cmd.SetGlobalTexture(JDMStyleIDPackaging.id_irRamp, m_packing.textures.irrdescenceRamp);
            cmd.SetGlobalTexture(JDMStyleIDPackaging.id_diffRamp, m_packing.textures.diffusionProfileRamp);
            cmd.SetGlobalTexture(JDMStyleIDPackaging.id_envtex, m_packing.textures.environmentTexture);

            runtimeParamsController.UpdateData(cmd, m_packing.runtimeParams);

            cmd.SetGlobalVector(JDMStyleIDPackaging.id_UnscaledTime, new Vector4(Time.unscaledTime / 20, Time.unscaledTime, Time.unscaledTime * 2, Time.unscaledTime * 3));
            JDMStyleConfigure.mashUpModule.Update(cmd);

            cmd.SetGlobalColor(JDMStyleIDPackaging.id_EnvironmentAmbient, JDMStyleConfigure.environmentRuntimeParam.ambient);

            cmd.EndSample("Style Process Configuring");
            context.ExecuteCommandBuffer(cmd);
            cmd.Release();
        }
    }
    
    [Serializable]public struct Settings
    {
        public JDMStyleConfigure.GlobalTextures textures;
        public JDMStyleConfigure.RuntimeParam runtimeParams;
    }
    [SerializeField] private Settings m_Settings;

    private ConfigurePass pass;

    public override void AddRenderPasses(ScriptableRenderer renderer, ref RenderingData renderingData)
    {
        renderer.EnqueuePass(pass);
    }

    public override void Create()
    {
        pass = new ConfigurePass(m_Settings);
        pass.renderPassEvent = RenderPassEvent.BeforeRendering;
    }

}
