Shader "JDM/JDM_Env_Skybox_Octahedral"
{
    properties
    {
        
        [Toggle(_ALPHACLIP_ENABLE)]_ALPHACLIP_ENABLE("Alpha Clip ",Float) = 0
        [KeywordSnifferDrawer(_ALPHACLIP_ENABLE)]_Cutoff("CutOff" , range(0,1)) = 0.5

        //BaseColor baseMap
        _BaseColor("Base Color", Color) = (1,1,1,1)
        [MainTex][SingleLineTexColorDrawer(_BaseColor)]_BaseMap("Octahedral Map",2D) = "black" {}
        _Rotation("Rotation",vector) = (0,0,0,0)

        _Horizon("Horizon",float) = 1
    }
    SubShader
    {
        Pass
        {
            Tags{
                "LightMode" = "UniversalForward" "Queue" = "Opaque"
            }
            Name "JDM Env Skybox"
            ZWrite on
            cull back
            ZTest LEqual
            Blend one zero,one one
            
            HLSLPROGRAM
            
            #pragma multi_compile _ _FOG_ENABLE
            #define _ENVIRONMENT_ENABLE
            #pragma vertex vert
            #pragma fragment frag

            #include "renderPass/JDM_SkyboxPass.hlsl"
            ENDHLSL
        }
    }
}
