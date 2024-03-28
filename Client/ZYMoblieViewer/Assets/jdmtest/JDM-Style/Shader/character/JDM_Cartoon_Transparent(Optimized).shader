Shader "JDM/Character/JDM_Cartoon_Standard_Transparent(Optimized)"
{
    properties
    {
        [Toggle]_ZWrite("ZWrite", Float) = 1.0
        [Cull]_Cull ("Cull Mode" , float) = 2
        [Toggle(_ALPHACLIP_ENABLE)]_ALPHACLIP_ENABLE("Alpha Clip ",Float) = 0
        [KeywordSnifferDrawer(_ALPHACLIP_ENABLE)]_Cutoff("CutOff" , range(0,1)) = 0.5
        
        [UBlendMode(_SrcBlend,_DstBlend,_BlendOp)] _BlendMode("Blend Mode", float) = 0.0
        [HideInInspector][UnityEngine.Rendering.BlendMode]_SrcBlend ("Src Blend Mode", float) = 1
        [HideInInspector][UnityEngine.Rendering.BlendMode]_DstBlend ("Dst Blend Mode", float) = 0
        [HideInInspector][UnityEngine.Rendering.BlendOp]_BlendOp ("Blend Op", float) = 0
        
        //BaseColor baseMap
        [HideInInspector]_BaseColor("Base Color", Color) = (1,1,1,1)
        [MainTex][SingleLineTexColorDrawer(_BaseColor)]_BaseMap("Base Map",2D) = "white" {}

        //BumpMap
        [HideInInspector]_BumpScale("BumpScale",float) = 1
        [SingleLineTexColorDrawer(_BumpScale)][Normal]_BumpMap("Bump Map" , 2D) = "bump" {}

        //ORM Map
        [SingleLineTexColorDrawer]_PBRMap("PBR Map" , 2D) = "grey"{}

        //IDE(A) Map Alpha for tonemapping
        [SingleLineTexColorDrawer]_IDEAMap("IDE(A) Map" , 2D) = "black"{}
        
        //Advanced settings
        [Toggle(_ADVANCED_ENABLE)]_ADVANCED_ENABLE("Advanced Setting", Float) = 0.0
        [KeywordSnifferDrawer(_ADVANCED_ENABLE)]_SpecularWeight("Env specular Weight" , range(0,1)) = 1
        [KeywordSnifferDrawer(_ADVANCED_ENABLE)]_RimWeight("Rim Weight" , range(0,1)) = 1

        //Iridescence Settings
        [Toggle(_IRIDESCENCE_ENABLE)]_IRIDESCENCE_ENABLE("Enable Iridescence", Float) = 0.0
        [KeywordSnifferDrawer(_IRIDESCENCE_ENABLE)]_IridescenceWeight("Iridescence Weight",range(0,8)) = 0.5

        //Matcap metal and specular
        [Toggle(_MATCAP_ENABLE)]_MATCAP_ENABLE("Enable Matcap", Float) = 0.0
        [KeywordSnifferDrawer(_MATCAP_ENABLE)]_MatcapMetalMap("Metal Map" , 2D) = "black"{}
        [KeywordSnifferDrawer(_MATCAP_ENABLE)]_MatcapSpecularMap("Specular Map" , 2D) = "black"{}
        [KeywordSnifferDrawer(_MATCAP_ENABLE)]_MatcapMetalWeight("Metal Weight" , range(0,1)) = 0
        [KeywordSnifferDrawer(_MATCAP_ENABLE)]_MatcapSpecularWeight("Specular Weight" , range(0,1)) = 0
        [KeywordSnifferDrawer(_MATCAP_ENABLE)]_MatcapSpecularTint("specular Tint" , range(0,1)) = 0

        //Detail textures scaling and color mixing 
        [Toggle(_DETAIL_TEXTURE_ENABLE)]_DETAIL_TEXTURE_ENABLE("Enable detail texture ", float) = 1
        [KeywordSnifferDrawer(_DETAIL_TEXTURE_ENABLE)]_DetailTextureMap("_DetailTextureMap",2D) = "white"{}
		[KeywordSnifferDrawer(_DETAIL_TEXTURE_ENABLE)]_Detail00_ST("Detail ST 0", vector) = (1,1,0,0)
		[KeywordSnifferDrawer(_DETAIL_TEXTURE_ENABLE)]_DetailColor00("Detail Color 1", Color) = (1,1,1,0)
		[KeywordSnifferDrawer(_DETAIL_TEXTURE_ENABLE)]_Detail01_ST("Detail ST 1", vector) = (1,1,0,0)
		[KeywordSnifferDrawer(_DETAIL_TEXTURE_ENABLE)]_DetailColor01("Detail Color 2", Color) = (1,1,1,0)
		[KeywordSnifferDrawer(_DETAIL_TEXTURE_ENABLE)]_Detail02_ST("Detail ST 2", vector) = (1,1,0,0)
		[KeywordSnifferDrawer(_DETAIL_TEXTURE_ENABLE)]_DetailColor02("Detail Color 3", Color) = (1,1,1,0)
		[KeywordSnifferDrawer(_DETAIL_TEXTURE_ENABLE)]_Detail03_ST("Detail ST 3", vector) = (1,1,0,0)
		[KeywordSnifferDrawer(_DETAIL_TEXTURE_ENABLE)]_DetailColor03("Detail Color 4", Color) = (1,1,1,0)

        [HideInInspector]_FinalColorTint("Final Color Tint", Color) = (1,1,1,1)
    
    }
    SubShader
    {
        Pass
        {
            Tags{
                "LightMode" = "EmissionTransparent" "Queue" = "Transparent"
            }
            Name "JDM Cartoon Transparent"
            ZWrite on
            cull [_Cull]
            ZTest LEqual
            Blend [_SrcBlend] [_DstBlend] ,one one

            HLSLPROGRAM
            
            #define _SHADOWS_SOFT
			#define _ADDITIONAL_LIGHTS_VERTEX 
            #define _FINNALCOLOR_TINT
            #define _ENVIRONMENT_ENABLE

            #pragma multi_compile _ _FOG_ENABLE

			#pragma multi_compile_fragment _ _MAIN_LIGHT_SHADOWS
            #pragma multi_compile_fragment _ _MASH_UP_01 _MASH_UP_02
            #pragma multi_compile_fragment _ _FEVER_ENABLE
            #pragma multi_compile_fragment _ _ENVIRONMENT_ENABLE

			#pragma shader_feature_local_fragment _ _ALPHACLIP_ENABLE
            #pragma shader_feature_local_fragment _ _DETAIL_TEXTURE_ENABLE
            #pragma shader_feature_local_fragment _ _IRIDESCENCE_ENABLE
            #pragma shader_feature_local_fragment _ _MATCAP_ENABLE
            #pragma shader_feature_local_fragment _ _ADVANCED_ENABLE

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #pragma vertex vert
            #pragma fragment frag

            #include "renderPass/JDM_CartoonStandardPass.hlsl"
            // #include "renderPass/JDM_DebugPass.hlsl"
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
            #pragma shader_feature_local_fragment _ALPHACLIP_ENABLE
            #pragma shader_feature_local_fragment _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A

            #pragma vertex ShadowPassVertex
            #pragma fragment ShadowPassFragment
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "renderPass/JDM_CharacterShadowPass.hlsl"
            ENDHLSL
        }

    }
    CustomEditor "JDMStyleShaderGUI"
}
