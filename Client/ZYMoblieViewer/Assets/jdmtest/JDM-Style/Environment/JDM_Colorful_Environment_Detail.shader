Shader "JDM/Colorful/Environment/Detail"
{
	Properties
	{
		_BaseMap("Base Color", 2D) = "white" {}
		_BaseColor("Tint Color", Color) = (1.0, 1.0, 1.0, 1.0)
		[NoScaleOffset] _BumpMap("Normal", 2D) = "bump" {}
		_BumpScale("Bump Scale", Range(0.0, 2.0)) = 1.0
		[NoScaleOffset] _OccRoughMetalTexture("ORMMap", 2D) = "yellow" {}
		_OcclusionStrength("AO Strength", Range(0.0, 1.0)) = 1.0
		_Smoothness("Smoothness", Range(0.0, 1.0)) = 1.0
		_EmissionMap("Emission Map", 2D) = "white" {}
		[HDR]_EmissionColor("Emission Color", Color) = (0.0, 0.0, 0.0, 1.0)


        [Toggle(_DETAIL_NORMAL)]_DETAIL_NORMAL("Detail Normal", Float) = 0.0
        //[KeywordSnifferDrawer(_DETAIL_NORMAL)]_LayerCount("Detail Layer Count" , int) = 0
        [KeywordSnifferDrawer(_DETAIL_NORMAL)]_IDTexture("ID Texture", 2D) = "white" {}

		[KeywordSnifferDrawer(_DETAIL_NORMAL)]_BumpScale_1("Bump Scale 1", float) = 1.0
		[KeywordSnifferDrawer(_DETAIL_NORMAL)]_NormalOpacityTexture_1("NO 1", 2D) = "black" {}

		[KeywordSnifferDrawer(_DETAIL_NORMAL)]_BumpScale_2("Bump Scale 2", float) = 1.0
		[KeywordSnifferDrawer(_DETAIL_NORMAL)]_NormalOpacityTexture_2("NO 2", 2D) = "black" {}

		[KeywordSnifferDrawer(_DETAIL_NORMAL)]_BumpScale_3("Bump Scale 3", float) = 1.0
		[KeywordSnifferDrawer(_DETAIL_NORMAL)]_NormalOpacityTexture_3("NO 3", 2D) = "black" {}

		[KeywordSnifferDrawer(_DETAIL_NORMAL)]_BumpScale_4("Bump Scale 4", float) = 1.0
		[KeywordSnifferDrawer(_DETAIL_NORMAL)]_NormalOpacityTexture_4("NO 4", 2D) = "black" {}

		[KeywordSnifferDrawer(_DETAIL_NORMAL)]_BumpScale_5("Bump Scale 5", float) = 1.0
		[KeywordSnifferDrawer(_DETAIL_NORMAL)]_NormalOpacityTexture_5("NO 5", 2D) = "black" {}

	}
		SubShader
		{
			Pass
			{
                Name "ForwardLit"
                Tags
                {
                    "RenderPipeline" = "UniversalRenderPipeline"  "LightMode" = "UniversalForward"
                }
                Cull back

                HLSLPROGRAM

                #pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
                #pragma multi_compile _ _MAIN_LIGHT_SHADOWS            
                #pragma shader_feature_local_fragment _ _DETAIL_NORMAL

                // -------------------------------------
                // Unity defined keywords
                #pragma multi_compile _ DIRLIGHTMAP_COMBINED
                #pragma multi_compile _ LIGHTMAP_ON
                #pragma multi_compile_fog

                //--------------------------------------
                // GPU Instancing
                //#pragma multi_compile_instancing

                #pragma vertex Vert
                #pragma fragment Frag
                
                #include "JDMStyleEnvironmentCore.hlsl"

                #define CUSTOM_BATCH
                CBUFFER_START(UnityPerMaterial)
                float4 _BaseMap_ST;
                float4 _EmissionMap_ST;
                half4 _BaseColor;
                half4 _EmissionColor;
                half _Smoothness;
                half _BumpScale;
                half _OcclusionStrength;
                half4 _NormalOpacityTexture_1_ST;
                half4 _NormalOpacityTexture_2_ST;
                half4 _NormalOpacityTexture_3_ST;
                half4 _NormalOpacityTexture_4_ST;
                half4 _NormalOpacityTexture_5_ST;

                half _BumpScale_1;
                half _BumpScale_2;
                half _BumpScale_3;
                half _BumpScale_4;
                half _BumpScale_5;

                CBUFFER_END
                
                TEXTURE2D(_EmissionMap);            SAMPLER(sampler_EmissionMap);
                TEXTURE2D(_BaseMap);                SAMPLER(sampler_BaseMap);
                TEXTURE2D(_BumpMap);                SAMPLER(sampler_BumpMap);      
                TEXTURE2D(_OccRoughMetalTexture);   SAMPLER(sampler_OccRoughMetalTexture);

                struct Attributes
                {
                    float4 positionOS   : POSITION;
                    float3 normalOS     : NORMAL;
                    float4 tangentOS    : TANGENT;
                    float2 texcoord     : TEXCOORD0;
                    float2 lightmapUV   : TEXCOORD1;
                    UNITY_VERTEX_INPUT_INSTANCE_ID
                };

                struct Varyings
                {
                    float2 uv                       : TEXCOORD0;
                    DECLARE_LIGHTMAP_OR_SH(lightmapUV, vertexSH, 1);
                    float3 positionWS               : TEXCOORD2;
                    float4 tangentWS                : TEXCOORD4; // xyz: tangent, w: sign
                    half3 biTangent : TEXCOORD10;

                    #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
                    #endif
                        float4 shadowCoord              : TEXCOORD7;

                    float3 normalWS                             : TEXCOORD3;
                    float3 viewDirWS                            : TEXCOORD5;
                    half4 fogFactorAndVertexLight               : TEXCOORD6; // x: fogFactor, yzw: vertex light
                    float4 positionCS                           : SV_POSITION;
                    float2 normalizedUV                         : TEXCOORD9;
                    
                    UNITY_VERTEX_INPUT_INSTANCE_ID
                    UNITY_VERTEX_OUTPUT_STEREO
                };
                #ifdef _DETAIL_NORMAL
                    #include "JDMStyleEnvLayering.hlsl"
                #endif
                ///////////////////////////////////////////////////////////////////////////////
                //                  <Function> Vertex                                        //
                ///////////////////////////////////////////////////////////////////////////////

                Varyings Vert(Attributes input)
                {
                    Varyings output = (Varyings)0;

                    UNITY_SETUP_INSTANCE_ID(input);
                    UNITY_TRANSFER_INSTANCE_ID(input, output);
                    UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

                    VertexPositionInputs vertexInput = GetVertexPositionInputs(input.positionOS.xyz);
                    VertexNormalInputs normalInput = GetVertexNormalInputs(input.normalOS, input.tangentOS);


                    output.uv = TRANSFORM_TEX(input.texcoord, _BaseMap);
                    output.normalizedUV = input.texcoord;
                    output.normalWS = normalInput.normalWS;
                    output.viewDirWS = GetCameraPositionWS() - vertexInput.positionWS;

                    real sign = input.tangentOS.w * GetOddNegativeScale();
                    output.tangentWS = half4(normalInput.tangentWS.xyz, sign);
  
                    OUTPUT_LIGHTMAP_UV(input.lightmapUV, unity_LightmapST, output.lightmapUV);
                    OUTPUT_SH(output.normalWS.xyz, output.vertexSH);

                    output.fogFactorAndVertexLight = half4(ComputeFogFactor(vertexInput.positionCS.z),  VertexLighting(vertexInput.positionWS, normalInput.normalWS));
                    output.positionWS = vertexInput.positionWS;
                    output.positionCS = vertexInput.positionCS;

                    #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
                        output.shadowCoord = GetShadowCoord(vertexInput);
                    #endif

                    output.biTangent = normalInput.bitangentWS;
                    return output;
                }

                ///////////////////////////////////////////////////////////////////////////////
                //                             Fragment functions                            //
                ///////////////////////////////////////////////////////////////////////////////
                half4 Frag(Varyings input): SV_Target0
                {
                    UNITY_SETUP_INSTANCE_ID(input);
                    UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);
                    
                    SurfaceData surfaceData = (SurfaceData)0;

                    half2 uv = input.uv;
            
                    half4 albedoAlpha = SampleAlbedoAlpha(uv, TEXTURE2D_ARGS(_BaseMap, sampler_BaseMap));
                    half4 channels = SAMPLE_TEXTURE2D(_OccRoughMetalTexture,sampler_OccRoughMetalTexture,uv);
                    half4 normalMap = SAMPLE_TEXTURE2D(_BumpMap, sampler_BumpMap, uv);
                    half3 emitmap = SAMPLE_TEXTURE2D(_EmissionMap, sampler_EmissionMap, uv).rgb;

                    #ifdef _DETAIL_NORMAL                
                        albedoAlpha.rgb = ColorDetailLayering(albedoAlpha.rgb,input.uv);
                    #endif

                    surfaceData.albedo = albedoAlpha.rgb * _BaseColor.rgb;
                    surfaceData.specular = half3(0.0h, 0.0h, 0.0h);
                    surfaceData.occlusion = LerpWhiteTo(channels.r, _OcclusionStrength);
                    surfaceData.smoothness = channels.g * _Smoothness;
                    surfaceData.metallic = channels.b;
                    surfaceData.normalTS = UnpackNormalScale(normalMap, _BumpScale).xyz;
                    surfaceData.emission = _EmissionColor.rgb * emitmap;
                    surfaceData.alpha = Alpha(albedoAlpha.a, _BaseColor,
                    #if defined(_ALPHATEST_ON)
                        _Cutoff
                    #else
                        0
                    #endif
                    );

                    InputData inputData = (InputData)0;
                    inputData = InitializeInputData( 
                        surfaceData.normalTS,
                        input.normalWS ,
                        input.tangentWS,
                        input.viewDirWS,
                        input.positionWS,
                        input.fogFactorAndVertexLight,
                        input.shadowCoord);
                    
                    half3 normalTS = surfaceData.normalTS;
                    inputData.normalWS = normalize(normalTS.x * input.tangentWS.xyz + normalTS.y * input.biTangent + normalTS.z * input.normalWS).xyz;
                    inputData.bakedGI = SAMPLE_GI(input.lightmapUV, input.vertexSH, inputData.normalWS) * _EnvironmentColorTint.rgb;
                    inputData.shadowMask = SAMPLE_SHADOWMASK(input.lightmapUV);
        
                    half4 finnalColor = 0;
                    finnalColor = UniversalFragmentPBR(inputData, surfaceData) ;
                    finnalColor.rgb = MixFog(finnalColor.rgb, inputData.fogCoord);
                    finnalColor.a = surfaceData.alpha; 
                    return finnalColor;
                }
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
                #pragma shader_feature_local_fragment _ALPHATEST_ON
                #pragma shader_feature_local_fragment _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A

                #pragma vertex ShadowPassVertex
                #pragma fragment ShadowPassFragment

                #define CUSTOM_BATCH
                
                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

                #define CUSTOM_BATCH
                CBUFFER_START(UnityPerMaterial)
                float4 _BaseMap_ST;
                float4 _EmissionMap_ST;
                half4 _BaseColor;
                half4 _EmissionColor;
                half _Smoothness;
                half _BumpScale;
                half _OcclusionStrength;
                half4 _NormalOpacityTexture_1_ST;
                half4 _NormalOpacityTexture_2_ST;
                half4 _NormalOpacityTexture_3_ST;
                half4 _NormalOpacityTexture_4_ST;
                half4 _NormalOpacityTexture_5_ST;

                half _BumpScale_1;
                half _BumpScale_2;
                half _BumpScale_3;
                half _BumpScale_4;
                half _BumpScale_5;

                CBUFFER_END
                #include "JDMStyleShadowCasterPass.hlsl"
                ENDHLSL
            }        
            Pass
            {
                Name "Meta"
                Tags{"LightMode" = "Meta"}

                Cull back

                HLSLPROGRAM
                #pragma exclude_renderers gles gles3 glcore
                #pragma target 4.5

                #pragma vertex UniversalVertexMeta
                #pragma fragment UniversalFragmentMeta

                #define _NORMALMAP
                #define _CHANNELSMAP
            
                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

                #define CUSTOM_BATCH
                CBUFFER_START(UnityPerMaterial)
                float4 _BaseMap_ST;
                float4 _EmissionMap_ST;
                half4 _BaseColor;
                half4 _EmissionColor;
                half _Smoothness;
                half _BumpScale;
                half _OcclusionStrength;
                half4 _NormalOpacityTexture_1_ST;
                half4 _NormalOpacityTexture_2_ST;
                half4 _NormalOpacityTexture_3_ST;
                half4 _NormalOpacityTexture_4_ST;
                half4 _NormalOpacityTexture_5_ST;

                half _BumpScale_1;
                half _BumpScale_2;
                half _BumpScale_3;
                half _BumpScale_4;
                half _BumpScale_5;

                CBUFFER_END
                #pragma shader_feature EDITOR_VISUALIZATION
                #pragma shader_feature_local_fragment _SPECULAR_SETUP
                #pragma shader_feature_local_fragment _EMISSION
                #pragma shader_feature_local_fragment _METALLICSPECGLOSSMAP
                #pragma shader_feature_local_fragment _ _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A
                #pragma shader_feature_local _ _DETAIL_MULX2 _DETAIL_SCALED

                #pragma shader_feature_local_fragment _SPECGLOSSMAP

                #include "JDM_PBRInput.hlsl"
                #include "JDM_PBRMetaPass.hlsl"

                ENDHLSL
            }
    }
}
