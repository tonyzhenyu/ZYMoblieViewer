Shader "JDM/Colorful/Character/JDM_Colorful_Standard_Skin"
{
    properties{
        
        //BaseColor
        [HideInInspector]_BaseColor("* Base Color", Color) = (1,1,1,1)
        [MainTex][SingleLineTexColorDrawer(_BaseColor)]_BaseMap("Base Map",2D) = "white" {}
        
        //Bump
        [HideInInspector]_BumpScale("BumpScale",float) = 1
        [SingleLineTexColorDrawer(_BumpScale)][Normal]_BumpMap("Bump Map" , 2D) = "bump" {}
        
        [SingleLineTexColorDrawer]_PBRMap("PBR Map" , 2D) = "white"{}

        [HideInInspector]_Scatter("Scatter Intensity" , Range(0,1)) = 0
        [SingleLineTexColorDrawer(_Scatter)]_ScatterMask("Scatter Thickness" ,2D) = "white"{}
        
        [SingleLineTexColorDrawer]_InnerMask("Inner mask" ,2D) = "black"{}		
        
        _ToneMapWeight("ToneMap Weight" , range(0,1)) = 1
        
        [HideInInspector]_FinalColorTint("Final Color Tint", Color) = (1,1,1,1)
    }
    SubShader
    {
        
        Pass
        {
            Tags{
                "LightMode" = "EmissionOpaque" 
            }
            Name "SubSurface Scattering"
            
            ZTest LEqual
            Blend one zero, one one
            
            HLSLPROGRAM

            #pragma exclude_renderers gles glcore
			#pragma target 4.5
            
			#pragma multi_compile _ _MAIN_LIGHT_SHADOWS

            #pragma multi_compile _ _MASH_UP_01 _MASH_UP_02
            
            #define _SHADOWS_SOFT
			#define _ADDITIONAL_LIGHTS_VERTEX 
			#define _USE_SCATTER
            #define _FINNALCOLOR_TINT

            #pragma vertex vert
            #pragma fragment frag
             

            struct FragmentOutput{
                half4 color : SV_Target0;
                half4 emission : SV_Target1;
            };
            struct Attributes{
                float4 positionOS : POSITION;
                half2 uv : TEXCOORD0;
                float3 normal : NORMAL;
                float4 tangent : TANGENT;

            };
            struct Varyings{
                float4 positionCS : SV_POSITION;
                half2 uv : TEXCOORD0;
                float3 positionWS : TEXCOORD4;
                half3 normalWS : TEXCOORD1;
                half3 tangentWS : TEXCOORD2;
                half3 biTangent : TEXCOORD3;
                half3 vertexLighting: TEXCOORD5;
                half3 vertexSH:TEXCOORD6;
                half3 positionVS : TEXCOORD7;
            };
			 
			 
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            CBUFFER_START(UnityPerMaterial)
            uniform half4 _BaseMap_ST;
            uniform half4 _BaseColor;
            uniform half _BumpScale;
			uniform half _Scatter;
			uniform half4 _FinalColorTint; 
            uniform half _ToneMapWeight;
            CBUFFER_END
            // uniform half4 _EmissionColor;
            // uniform half4 _DetailNormalMap_ST;
            // uniform half4 _AbsortionColor;
            // uniform half _Roughness;
            // uniform half _Occlusion;
            // uniform half _Metallic;
            // uniform half _Height;
            // uniform half _DetailNormalScale;
            // uniform half _Cutoff; 
			
            #include "JDMStyleCore.hlsl"
			
            TEXTURE2D(_BaseMap);
            TEXTURE2D(_BumpMap);
            TEXTURE2D(_PBRMap);

            TEXTURE2D(_InnerMask);

            Varyings vert(Attributes input)
            {
                Varyings output = (Varyings)0;
                output.positionCS = mul(UNITY_MATRIX_MVP,input.positionOS);
                
                VertexNormalInputs normalInput = GetVertexNormalInputs(input.normal, input.tangent);

                output.uv = input.uv;
                output.normalWS = normalInput.normalWS;
                output.biTangent = normalInput.bitangentWS;
                output.tangentWS = normalInput.tangentWS;
                output.positionWS = mul(UNITY_MATRIX_M,input.positionOS).xyz;
                output.positionVS = mul(UNITY_MATRIX_V,output.positionWS).xyz;

                InputData inputData = (InputData)0;
                inputData.normalWS = output.normalWS;
                inputData.viewDirectionWS = normalize(_WorldSpaceCameraPos - output.positionWS);

                uint lod = _Scatter * 5;
                SurfaceData surfaceData = (SurfaceData)0;
                surfaceData.occlusion = 1;
                surfaceData.albedo = _BaseMap.SampleLevel(sampler_LinearRepeat,input.uv,lod).rgb;
                
                half3 SSSRaddiance = 0;

                for(uint i = 0u;i < GetAdditionalLightsCount();i++){
                    Light light = GetAdditionalLight(i,output.positionWS,1);
                    SSSRaddiance += LightSSSRaddiance(light,inputData,surfaceData);
                }
                output.vertexLighting = VertexBRDF(output.normalWS,output.positionWS) * surfaceData.albedo   + SSSRaddiance ;
                //output.vertexSH = SampleCharacterSH(inputData.normalWS);
                return output;
            }
            FragmentOutput frag(Varyings input) : SV_Target
            {
                FragmentOutput output = (FragmentOutput)0;
                half3 mixmap = _PBRMap.Sample(sampler_LinearRepeat,input.uv).rgb;
                half3 bump = UnpackNormalScale(_BumpMap.Sample(sampler_LinearRepeat, input.uv),_BumpScale).rgb;
                half3 basemap = _BaseMap.Sample(sampler_LinearRepeat,input.uv).rgb;
                half innerMaskMap = _InnerMask.Sample(sampler_LinearClamp,input.uv).r;

                InputData inputData = (InputData)0;
                inputData.normalWS = normalize(bump.x * input.tangentWS + bump.y * input.biTangent + bump.z * normalize(input.normalWS));
                inputData.viewDirectionWS = normalize(_WorldSpaceCameraPos - input.positionWS);
                inputData.positionWS = input.positionWS;
                inputData.shadowCoord = TransformWorldToShadowCoord(input.positionWS);
                inputData.bakedGI = input.vertexSH;
                inputData.vertexLighting = input.vertexLighting;

                SurfaceData surfaceData = (SurfaceData)0;
                surfaceData.albedo = basemap * _BaseColor.rgb;
                surfaceData.occlusion = mixmap.r;
                surfaceData.smoothness = mixmap.g;
                surfaceData.metallic = mixmap.b;
                
                ExternData exData = (ExternData)0;
                exData.positionVS = input.positionVS;
                exData.vertexNormal = normalize(input.normalWS);
                exData.matcapUV = mul(UNITY_MATRIX_V,inputData.normalWS).xy * 0.5 + 0.5;
                half innerAtten = lerp(1,surfaceData.occlusion,innerMaskMap);
                half3 raddiance = innerAtten * JDMFragmentSSS(inputData,surfaceData,exData);

                half3 neutral = JDMSkinPixelToneMapping(raddiance,_ToneMapWeight);
                
                half4 mashup = MashUp(exData);
                neutral = JDMPostFX(neutral,mashup,inputData);

                half4 finnalColor = half4(neutral.xyz,1);

                output.color = finnalColor; 
                output.emission.a = 1;

                half3 emit = max(0,raddiance.rgb - 1) / 40;
                emit /= 1 + emit;
                emit = lerp(0,emit,surfaceData.metallic);
                emit = JDMPostFX(emit,mashup,inputData);
                
                output.emission.rgb = emit; 

                return  output;
            }
            ENDHLSL
        }


    }
    CustomEditor "JDMStyleShaderGUI"
}
