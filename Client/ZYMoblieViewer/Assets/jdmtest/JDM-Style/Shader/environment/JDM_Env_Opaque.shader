Shader "JDM/JDM_Env_Opaque"
{
    properties
    {
        [Cull]_Cull ("Cull Mode" , float) = 2
        [Toggle(_ALPHACLIP_ENABLE)]_ALPHACLIP_ENABLE("Alpha Clip ",Float) = 0
        [KeywordSnifferDrawer(_ALPHACLIP_ENABLE)]_Cutoff("CutOff" , range(0,1)) = 0.5

        //BaseColor baseMap
        _BaseColor("Base Color", Color) = (1,1,1,1)
        [MainTex][SingleLineTexColorDrawer(_BaseColor)]_BaseMap("Base Map",2D) = "white" {}

        //BumpMap
        _BumpScale("BumpScale",float) = 1
        [SingleLineTexColorDrawer(_BumpScale)][Normal]_BumpMap("Bump Map" , 2D) = "bump" {}

        //ORM Map
        [SingleLineTexColorDrawer]_PBRMap("PBR Map" , 2D) = "grey"{}
        _Occlusion("occlusion",Range(0,1)) = 1
        _Smoothness("smoothness",Range(0,1)) = 0.5
        
        [SingleLineTexColorDrawer]_LightMap("Light Map" , 2D) = "black"{}
        [SingleLineTexColorDrawer]_EnvReflectMap("Env Reflect Map" , 2D) = "black"{}
        [SingleLineTexColorDrawer]_EnvDiffuseMap("Env Diffuse Map" , 2D) = "black"{}
        
        //Detail textures scaling and color mixing 
        [Toggle(_DETAIL_TEXTURE_ENABLE)]_DETAIL_TEXTURE_ENABLE("Enable detail texture ", float) = 1
        [KeywordSnifferDrawer(_DETAIL_TEXTURE_ENABLE)]_DetailTextureMap("Detail TextureMap",2D) = "white"{}
		[KeywordSnifferDrawer(_DETAIL_TEXTURE_ENABLE)]_Detail00_ST("Detail ST 0", vector) = (1,1,0,0)
		[KeywordSnifferDrawer(_DETAIL_TEXTURE_ENABLE)]_DetailColor00("Detail Color 1", Color) = (1,1,1,0)
		[KeywordSnifferDrawer(_DETAIL_TEXTURE_ENABLE)]_Detail01_ST("Detail ST 1", vector) = (1,1,0,0)
		[KeywordSnifferDrawer(_DETAIL_TEXTURE_ENABLE)]_DetailColor01("Detail Color 2", Color) = (1,1,1,0)
		[KeywordSnifferDrawer(_DETAIL_TEXTURE_ENABLE)]_Detail02_ST("Detail ST 2", vector) = (1,1,0,0)
		[KeywordSnifferDrawer(_DETAIL_TEXTURE_ENABLE)]_DetailColor02("Detail Color 3", Color) = (1,1,1,0)
		[KeywordSnifferDrawer(_DETAIL_TEXTURE_ENABLE)]_Detail03_ST("Detail ST 3", vector) = (1,1,0,0)
		[KeywordSnifferDrawer(_DETAIL_TEXTURE_ENABLE)]_DetailColor03("Detail Color 4", Color) = (1,1,1,0)
    
    }
    SubShader
    {
        Pass
        {
            Tags{
                "LightMode" = "UniversalForward" "Queue" = "Opaque"
            }
            Name "JDM Env Opaque"
            ZWrite on
            cull [_Cull]
            ZTest LEqual
            Blend one zero,one one
            
            HLSLPROGRAM
            
            #define _SHADOWS_SOFT
			#define _ADDITIONAL_LIGHTS_VERTEX 

            #pragma multi_compile _ _FOG_ENABLE
			#pragma multi_compile_fragment _ _MAIN_LIGHT_SHADOWS
			#pragma shader_feature_local_fragment _ _ALPHACLIP_ENABLE
            #pragma shader_feature_local_fragment _ _DETAIL_TEXTURE_ENABLE

            #pragma vertex vert
            #pragma fragment frag

            #include "renderPass/JDM_EnvStandardPass.hlsl"
            ENDHLSL
        }
        Pass
        {
            Name "ShadowCaster"
            
            Tags
            {
               "RenderPipeline" = "UniversalRenderPipeline"  "LightMode" = "ShadowCaster" 
            } 

            Blend off 
			ZWrite on
            ZTest LEqual
			Cull off

            HLSLPROGRAM
            //--------------------------------------
            // GPU Instancing
            #pragma multi_compile_instancing

            // -------------------------------------
            // Material Keywords
            #define _ENVIRONMENT_ENABLE
            #pragma shader_feature_local_fragment _ALPHACLIP_ENABLE
            #pragma shader_feature_local_fragment _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A

            #pragma vertex ShadowPassVertex
            #pragma fragment ShadowPassFragment
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "renderPass/JDM_ShadowPass.hlsl"
            ENDHLSL
        }

    }
}
