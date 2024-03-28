Shader "JDM/Colorful/Environment/Shear"
{
	Properties
	{
		_BaseMap("Base Color", 2D) = "white" {}
		_BaseColor("Tint Color", Color) = (1.0, 1.0, 1.0, 1.0)
		[NoScaleOffset] _BumpMap("Normal", 2D) = "bump" {}
		_BumpScale("Bump Scale", Range(0.0, 2.0)) = 1.0
		[NoScaleOffset] _OccRoughMetalTexture("ORMMap", 2D) = "black" {}
		_OcclusionStrength("AO Strength", Range(0.0, 1.0)) = 1.0
		_Smoothness("Smoothness", Range(0.0, 1.0)) = 1.0
		_EmissionMap("Emission Map", 2D) = "white" {}
		[HDR]_EmissionColor("Emission Color", Color) = (0.0, 0.0, 0.0, 1.0)

		_GlobalDirection("Shear",float) = 0
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

                CBUFFER_START(UnityPerMaterial)
                float4 _BaseMap_ST;
                float4 _EmissionMap_ST;
                half4 _BaseColor;
                half4 _EmissionColor;
                half _Smoothness;
                half _BumpScale;
                half _OcclusionStrength;
                half _GlobalDirection;
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

                    half4x4 matrixShear ;
                    matrixShear[0] = half4(1,0,tan(_GlobalDirection),0);
                    matrixShear[1] = half4(0,1,0,0);
                    matrixShear[2] = half4(0,0,1,0);
                    matrixShear[3] = half4(0,0,0,1);

                    half3 positionWS = 0;
                    positionWS = mul(matrixShear,half4(input.positionOS.xyz ,1)).xyz;

                    output.uv = TRANSFORM_TEX(positionWS.xz, _BaseMap);
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

                    half2 uv = saturate(input.uv);
            
                    half4 albedoAlpha = SampleAlbedoAlpha(uv, TEXTURE2D_ARGS(_BaseMap, sampler_BaseMap));
                    half4 channels = SAMPLE_TEXTURE2D(_OccRoughMetalTexture,sampler_OccRoughMetalTexture,uv);
                    half4 normalMap = SAMPLE_TEXTURE2D(_BumpMap, sampler_BumpMap, uv);
                    half3 emitmap = SAMPLE_TEXTURE2D(_EmissionMap, sampler_EmissionMap, uv).rgb;

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
                    inputData.bakedGI = SAMPLE_GI(input.lightmapUV, input.vertexSH, inputData.normalWS);
                    inputData.shadowMask = SAMPLE_SHADOWMASK(input.lightmapUV);
        
                    half4 finnalColor = 0;
                    finnalColor = UniversalFragmentPBR(inputData, surfaceData);
                    finnalColor.rgb = MixFog(finnalColor.rgb, inputData.fogCoord);
                    finnalColor.a = surfaceData.alpha; 
                    return finnalColor;
                }
			ENDHLSL
        }
    }
}
