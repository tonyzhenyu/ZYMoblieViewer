Shader "JDM/Character/JDM_Cartoon_Standard_Opaque(Optimized)bak01"
{
    properties
    {
        [Cull]_Cull ("Cull Mode" , float) = 2
        [Toggle(_ALPHACLIP_ENABLE)]_ALPHACLIP_ENABLE("Alpha Clip ",Float) = 0
        [KeywordSnifferDrawer(_ALPHACLIP_ENABLE)]_Cutoff("CutOff" , range(0,1)) = 0.5

        //BaseColor baseMap
        [HideInInspector]_BaseColor("* Base Color", Color) = (1,1,1,1)
        [MainTex][SingleLineTexColorDrawer(_BaseColor)]_BaseMap("Base Map",2D) = "white" {}

        //BumpMap
        [HideInInspector]_BumpScale("BumpScale",float) = 1
        [SingleLineTexColorDrawer(_BumpScale)][Normal]_BumpMap("Bump Map" , 2D) = "bump" {}

        //ORM Map
        [SingleLineTexColorDrawer]_PBRMap("PBR Map" , 2D) = "white"{}

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
        [KeywordSnifferDrawer(_MATCAP_ENABLE)]_MatcapMetalMap(" Metal Map" , 2D) = "black"{}
        [KeywordSnifferDrawer(_MATCAP_ENABLE)]_MatcapSpecularMap(" Specular Map" , 2D) = "black"{}
        [KeywordSnifferDrawer(_MATCAP_ENABLE)]_MatcapMetalWeight(" Metal Weight" , range(0,1)) = 0
        [KeywordSnifferDrawer(_MATCAP_ENABLE)]_MatcapSpecularWeight(" Specular Weight" , range(0,1)) = 0
        [KeywordSnifferDrawer(_MATCAP_ENABLE)]_MatcapSpecularTint("specular Tint" , range(0,1)) = 0

        //Detail textures scaling and color mixing 
        [Toggle(_DETAIL_TEXTURE_ENABLE)]_DETAIL_TEXTURE_ENABLE("Enable detail texture ", float) = 1
        [KeywordSnifferDrawer(_DETAIL_TEXTURE_ENABLE)]_DetailTextureCount("_DetailTextureCount", Range(0,4)) = 0
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
                "LightMode" = "UniversalForward" 
            }
            Name "JDM Colorful Cartoon Opaque"
            ZWrite on
            cull [_Cull]
            ZTest LEqual
            Blend one zero,one one
            
            HLSLPROGRAM
            #define _SHADOWS_SOFT
			#define _ADDITIONAL_LIGHTS_VERTEX 
            #define _FINNALCOLOR_TINT

			#pragma multi_fragment_compile _ _MAIN_LIGHT_SHADOWS
            #pragma multi_fragment_compile _ _MASH_UP_01 _MASH_UP_02
            #pragma multi_fragment_compile _ _FEVER_ENABLE
            #pragma multi_fragment_compile _ _ENVIRONMENT_ENABLE

			#pragma shader_feature_local_fragment _ _ALPHACLIP_ENABLE
            #pragma shader_feature_local_fragment _ _DETAIL_TEXTURE_ENABLE
            #pragma shader_feature_local_fragment _ _IRIDESCENCE_ENABLE
            #pragma shader_feature_local_fragment _ _MATCAP_ENABLE
            #pragma shader_feature_local_fragment _ _ADVANCED_ENABLE

            #pragma vertex vert
            #pragma fragment frag
			
		    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            struct Attributes{
                float4 positionOS : POSITION;
                half2 uv : TEXCOORD0;
                float3 normal : NORMAL;
                float4 tangent : TANGENT;
            };
            struct FragmentOutput{
                half4 color : SV_Target0;
                half4 emission : SV_Target1;
            };
            struct Varyings{
                float4 positionCS : SV_POSITION;
                half2 uv : TEXCOORD0;
                float3 positionWS : TEXCOORD4;
                half3 normalWS : TEXCOORD1;
                half3 tangentWS : TEXCOORD2;
                half3 biTangent : TEXCOORD3;
                half3 vertexLighting: TEXCOORD5;
                half3 viewDirectionWS:TEXCOORD6;
                half3 positionVS : TEXCOORD7;
            };
            cbuffer UnityPerDraw{
                
            };
            cbuffer JDMGlobalParams{
                
            };
            cbuffer UnityPerMaterial
            {
                half4 _BaseMap_ST;
                half4 _BaseColor;
                half _BumpScale;
                half4 _FinalColorTint;

                // #ifdef _ALPHACLIP_ENABLE
                    half _Cutoff;
                // #endif

                // #ifdef _IRIDESCENCE_ENABLE
                    half _IridescenceWeight;
                // #endif

                // #ifdef _ADVANCED_ENABLE
                    half _SpecularWeight;
                    half _RimWeight;
                // #endif

                // #ifdef _MATCAP_ENABLE
                    half _MatcapMetalWeight;
                    half _MatcapSpecularWeight;
                    half _MatcapSpecularTint;
                // #endif

                // #ifdef _DETAIL_TEXTURE_ENABLE
                    half4 _DetailColor00;
                    half4 _DetailColor01;
                    half4 _DetailColor02;
                    half4 _DetailColor03;

                    half4 _Detail00_ST;
                    half4 _Detail01_ST;
                    half4 _Detail02_ST;
                    half4 _Detail03_ST;
                // #endif
            };
            

            #include "JDMStyleCore.hlsl"

            TEXTURE2D(_BaseMap);
            TEXTURE2D(_BumpMap);
            TEXTURE2D(_PBRMap);    
            TEXTURE2D(_IDEAMap);    

            #ifdef _MATCAP_ENABLE
                TEXTURE2D(_MatcapMetalMap);
                TEXTURE2D(_MatcapSpecularMap);
            #endif

            #ifdef _DETAIL_TEXTURE_ENABLE
                #include "JDMStyleLayering.hlsl"
            #endif

            Varyings vert(Attributes input)
            {
                Varyings output = (Varyings)0;

                VertexNormalInputs normalInput = GetVertexNormalInputs(input.normal, input.tangent);

                output.normalWS = normalInput.normalWS;
                output.biTangent = normalInput.bitangentWS;
                output.tangentWS = normalInput.tangentWS;

                output.positionWS = mul(UNITY_MATRIX_M,input.positionOS).xyz;
                output.positionCS = mul(UNITY_MATRIX_MVP,input.positionOS);

                output.uv = input.uv * _BaseMap_ST.xy + _BaseMap_ST.zw;

                output.viewDirectionWS = GetWorldSpaceViewDir(output.positionWS);
                output.vertexLighting = VertexCartoonBRDF(output.normalWS,output.positionWS);

                output.positionVS = normalize(mul(UNITY_MATRIX_V , float4(output.positionWS,1)).xyz);

                return output;
            }
            FragmentOutput frag(Varyings input)
            {
                FragmentOutput output = (FragmentOutput)0;

                half4 diffMap = _BaseMap.Sample(sampler_LinearRepeat,input.uv).rgba * _BaseColor.rgba;

                #ifdef _ALPHACLIP_ENABLE
                    clip(diffMap.a - _Cutoff);
                #endif

                half3 mixmap = _PBRMap.Sample(sampler_LinearRepeat,input.uv).rgb;
                half4 ideaMap = _IDEAMap.Sample(sampler_LinearRepeat,input.uv).rgba ;
                half3 normalTS = UnpackNormalScale(_BumpMap.Sample(sampler_LinearRepeat, input.uv),_BumpScale);

                #ifdef _DETAIL_TEXTURE_ENABLE                
                    diffMap.rgb = DetailTexturing(diffMap.rgb,ideaMap.r,input.uv);
                #endif

                InputData inputData = (InputData)0;
                inputData.normalWS = normalize(normalTS.x * input.tangentWS + normalTS.y * input.biTangent + normalTS.z * input.normalWS);
                inputData.viewDirectionWS = normalize(input.viewDirectionWS);
                inputData.positionWS = input.positionWS;
                inputData.shadowCoord = TransformWorldToShadowCoord(input.positionWS);
                inputData.vertexLighting = input.vertexLighting;
                //inputData.bakedGI = input.bakedGI;

                SurfaceData surfaceData = (SurfaceData)0;
                surfaceData.albedo = diffMap.rgb;
                surfaceData.occlusion = mixmap.r;
                surfaceData.smoothness = mixmap.g;
                surfaceData.metallic = mixmap.b;
                surfaceData.alpha = diffMap.a;

                ExternData exData = (ExternData)0;
                #ifdef _IRIDESCENCE_ENABLE
                    exData.iridescence = _IridescenceWeight;
                    exData.iridescenceMask = ideaMap.g;
                #endif

                #ifdef _ADVANCED_ENABLE
                    exData.specularWeight = _SpecularWeight;
                    exData.rimWeight = _RimWeight;
                #else
                    exData.specularWeight = 1;
                    exData.rimWeight = 1;
                #endif

                exData.vertexNormal = normalize(input.normalWS);
                exData.positionVS = input.positionVS;

                #ifdef _MATCAP_ENABLE
                    exData.matcapUV = GetMatcapUV(normalize(input.positionVS),inputData.normalWS);
                    exData.highlightMatcap = _MatcapSpecularMap.Sample(sampler_LinearClamp,exData.matcapUV ).rgb * _MatcapSpecularWeight;
                    exData.highlightTint = _MatcapSpecularTint;
                    exData.matcapReflection = _MatcapMetalMap.Sample(sampler_LinearClamp,exData.matcapUV).rgb * _MatcapMetalWeight;// addition for metal
                #endif

                half3 raddiance = 0;
                raddiance = JDMFragmentCartoon(inputData,surfaceData,exData).rgb;

                half3 neutral =  lerp(JDMPixelToneMapping(raddiance, surfaceData.metallic),raddiance * _FinalColorTint,ideaMap.a);
                
                half4 mashup = MashUp(exData);
                neutral = JDMPostFX(neutral,mashup,inputData);
                neutral = Fever(neutral,ideaMap.b);
				output.color = saturate(float4(neutral,surfaceData.alpha)); 

                half3 emit = max(0,raddiance.rgb - 1) / 40;
                emit /= 1 + emit;
                emit = lerp(0,emit,surfaceData.metallic);
                emit = JDMPostFX(emit,mashup,inputData);
                emit = Fever(emit,ideaMap.b);
                output.emission.rgb = emit; 
                output.emission.a = 1;

                return output;
            }
            ENDHLSL
        }

        // Pass
        // {
        //     Name "ShadowCaster"
            
        //     Tags
        //     {
        //        "RenderPipeline" = "UniversalRenderPipeline"  "LightMode" = "ShadowCaster" 
        //     } 

        //     Blend off 
		// 	ZWrite on
        //     ZTest LEqual
		// 	Cull off

        //     HLSLPROGRAM
        //     //--------------------------------------
        //     // GPU Instancing
        //     #pragma multi_compile_instancing

        //     // -------------------------------------
        //     // Material Keywords
        //     #pragma shader_feature_local_fragment _ALPHACLIP_ENABLE
        //     #pragma shader_feature_local_fragment _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A

        //     #pragma vertex ShadowPassVertex
        //     #pragma fragment ShadowPassFragment

        //     #define CUSTOM_BATCH
            
        //     #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        //     CBUFFER_START(UnityPerMaterial)
        //     uniform half4 _BaseMap_ST;
        //     uniform half4 _BaseColor;
        //     uniform half _BumpScale;

        //     uniform half _Cutoff;


        //     uniform half _IridescenceWeight;
        //     uniform half _SpecularWeight;
        //     uniform half _RimWeight;

        //     uniform half _MatcapMetalWeight;
        //     uniform half _MatcapSpecularWeight;
        //     uniform half _MatcapSpecularTint;

        //     uniform half4 _FinalColorTint;

        //     #ifdef _DETAIL_TEXTURE_ENABLE
        //         uniform half4 _DetailColor00;
        //         uniform half4 _DetailColor01;
        //         uniform half4 _DetailColor02;
        //         uniform half4 _DetailColor03;

        //         uniform half4 _Detail00_ST;
        //         uniform half4 _Detail01_ST;
        //         uniform half4 _Detail02_ST;
        //         uniform half4 _Detail03_ST;
        //     #endif
        //     CBUFFER_END
        //     #include "JDMStyleShadowCasterPass.hlsl"
        //     ENDHLSL
        // }

    }
    CustomEditor "JDMStyleShaderGUI"
}
