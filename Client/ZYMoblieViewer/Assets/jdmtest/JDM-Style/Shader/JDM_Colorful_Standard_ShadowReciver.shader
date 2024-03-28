Shader "JDM/Character/Effect_ShadowReciver"
{
    properties{
        
        [Toggle(_PROJECTION)]_Projection("Projection" , float) = 0
        [Toggle(_ALPHATEST_ON)]_ALPHATEST_ON("Alpha Clip ",Float) = 0
        [KeywordSnifferDrawer(_ALPHATEST_ON)]_Cutoff("CutOff" , range(0,1)) = 0.5

        _BaseColor("ShadowColor",color) = (0,0,0,0.5)
        //Bump
        [HideInInspector]_BumpScale("BumpScale",float) = 1
        [SingleLineTexColorDrawer(_BumpScale)][Normal]_BumpMap("Bump Map" , 2D) = "bump" {}

		

    }
    SubShader
    {
        Tags{
			"Queue" = "Transparent"
		}
        Pass
        {
            Tags{
                "LightMode" = "ForwardDecal" 
            }
            Name "JDM Colorful ShadowReciver"

            ZWrite off
            ZTest LEqual
            Blend srcalpha oneminussrcalpha,one one
            cull back
            
            HLSLPROGRAM

            #pragma exclude_renderers gles glcore
			#pragma target 4.5
            
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS
            #define _SHADOWS_SOFT
			#define _ADDITIONAL_LIGHTS_VERTEX 
            #define  MAIN_LIGHT_CALCULATE_SHADOWS 

			#pragma multi_compile _ _ALPHATEST_ON
			#pragma multi_compile _ _PROJECTION

            #pragma vertex vert
            #pragma fragment frag
			
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"            
            CBUFFER_START(UnityPerMaterial)
            half4 _BumpMap_ST;
            half4 _BaseColor;
            half _BumpScale;
            half _Cutoff;
            CBUFFER_END

            #include "JDMStyleCore.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareDepthTexture.hlsl"
            
            struct Attributes{
                float4 positionOS : POSITION;
                half2 uv : TEXCOORD0;
                float3 normal : NORMAL;
                float4 tangent : TANGENT;

            };
            struct FragmentOutput{
                half4 color : SV_Target0;
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

                #ifdef _PROJECTION
                    float4 positionSS : TEXCOORD7;
                #endif
            };
        
            TEXTURE2D(_BumpMap); 

            Varyings vert(Attributes input)
            {
                Varyings output = (Varyings)0;
                VertexNormalInputs normalInput = GetVertexNormalInputs(input.normal, input.tangent);

                output.normalWS = normalInput.normalWS;
                output.biTangent = normalInput.bitangentWS;
                output.tangentWS = normalInput.tangentWS;
                output.positionWS = mul(UNITY_MATRIX_M,input.positionOS).xyz;
                output.positionCS = mul(UNITY_MATRIX_MVP,input.positionOS);
                output.uv = input.uv;

                output.viewDirectionWS = GetWorldSpaceViewDir(output.positionWS);
                output.vertexLighting = SampleSH(output.normalWS) + VertexBRDF(output.normalWS,output.positionWS);

                #ifdef _PROJECTION
                    float4 positionSS = ComputeScreenPos(output.positionCS);
                    output.positionSS = positionSS;
                #endif
                return output;
            }
            float SampleDepth(float2 UV)
            {
                #if UNITY_REVERSED_Z
                    real depth = SampleSceneDepth(UV);
                #else
                    real depth = lerp(UNITY_NEAR_CLIP_VALUE, 1, SampleSceneDepth(UV));
                #endif
                return depth;
            }

            FragmentOutput frag(Varyings input)
            {
                FragmentOutput output = (FragmentOutput)0;

                half3 normalTS = UnpackNormalScale(_BumpMap.Sample(sampler_LinearRepeat, input.uv),_BumpScale);

                InputData inputData = (InputData)0;
                inputData.normalWS = normalize(normalTS.x * input.tangentWS + normalTS.y * input.biTangent + normalTS.z * input.normalWS);
                inputData.viewDirectionWS = normalize(input.viewDirectionWS);

                float3 positionWS = input.positionWS;

                #ifdef _PROJECTION

                    float2 positionNDC = input.positionSS.xy / input.positionSS.ww;
                    float depth = SampleDepth(positionNDC);
                    float4 positionCS = float4(positionNDC * 2 - 1 , depth,1);

                    #if UNITY_UV_STARTS_AT_TOP
                        positionCS.y = -positionCS.y;
                    #endif

                    float4 hPositionWS = mul(UNITY_MATRIX_I_VP,positionCS.xyzw);
                    
                    positionWS = hPositionWS.xyz / hPositionWS.w;
                    // float3 positionOS = mul(UNITY_MATRIX_I_M , float4(positionWS.xyz,1)).xyz;
                    
                #endif

                inputData.positionWS = positionWS;

                inputData.shadowCoord = TransformWorldToShadowCoord(inputData.positionWS);
                inputData.vertexLighting = input.vertexLighting;
                
                SurfaceData surfaceData = (SurfaceData)0;
                surfaceData.albedo = _BaseColor.rgb;
                surfaceData.alpha = _BaseColor.a;

                half3 raddiance = 0;
                
                Light mainLight = GetMainLight(inputData.shadowCoord, inputData.positionWS, 0);

                raddiance += surfaceData.albedo * mainLight.distanceAttenuation * mainLight.color;
                raddiance += inputData.vertexLighting * surfaceData.albedo;

                #ifdef _ALPHATEST_ON
                    clip(1- mainLight.shadowAttenuation -_Cutoff);
                #endif

                half3 neutral = JDMPixelToneMapping(raddiance,surfaceData.metallic);

                half4 finnalColor = half4(neutral,(1 - mainLight.shadowAttenuation * mainLight.distanceAttenuation) * surfaceData.alpha);
       
                output.color = finnalColor;
                return output;
            }
            ENDHLSL
        }
        Pass
        {
            Tags{
                "LightMode" = "EmissionTransparent" 
            }
            Name "JDM Colorful ShadowReciver"

            ZWrite off
            ZTest LEqual
            Blend srcalpha oneminussrcalpha,one one
            cull back
            
            HLSLPROGRAM

            #pragma exclude_renderers gles glcore
			#pragma target 4.5
            
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS
            #define _SHADOWS_SOFT
			#define _ADDITIONAL_LIGHTS_VERTEX 
            #define  MAIN_LIGHT_CALCULATE_SHADOWS 

			#pragma multi_compile _ _ALPHATEST_ON
			#pragma multi_compile _ _PROJECTION

            #pragma vertex vert
            #pragma fragment frag
			
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"            
            CBUFFER_START(UnityPerMaterial)
            half4 _BumpMap_ST;
            half4 _BaseColor;
            half _BumpScale;
            half _Cutoff;
            CBUFFER_END

            #include "JDMStyleCore.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareDepthTexture.hlsl"
            
            struct Attributes{
                float4 positionOS : POSITION;
                half2 uv : TEXCOORD0;
                float3 normal : NORMAL;
                float4 tangent : TANGENT;

            };
            struct FragmentOutput{
                half4 color : SV_Target0;
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

                #ifdef _PROJECTION
                    float4 positionSS : TEXCOORD7;
                #endif
            };
        
            TEXTURE2D(_BumpMap); 

            Varyings vert(Attributes input)
            {
                Varyings output = (Varyings)0;
                VertexNormalInputs normalInput = GetVertexNormalInputs(input.normal, input.tangent);

                output.normalWS = normalInput.normalWS;
                output.biTangent = normalInput.bitangentWS;
                output.tangentWS = normalInput.tangentWS;
                output.positionWS = mul(UNITY_MATRIX_M,input.positionOS).xyz;
                output.positionCS = mul(UNITY_MATRIX_MVP,input.positionOS);
                output.uv = input.uv;

                output.viewDirectionWS = GetWorldSpaceViewDir(output.positionWS);
                output.vertexLighting = SampleSH(output.normalWS) + VertexBRDF(output.normalWS,output.positionWS);

                #ifdef _PROJECTION
                    float4 positionSS = ComputeScreenPos(output.positionCS);
                    output.positionSS = positionSS;
                #endif
                return output;
            }
            float SampleDepth(float2 UV)
            {
                #if UNITY_REVERSED_Z
                    real depth = SampleSceneDepth(UV);
                #else
                    real depth = lerp(UNITY_NEAR_CLIP_VALUE, 1, SampleSceneDepth(UV));
                #endif
                return depth;
            }

            FragmentOutput frag(Varyings input)
            {
                FragmentOutput output = (FragmentOutput)0;

                half3 normalTS = UnpackNormalScale(_BumpMap.Sample(sampler_LinearRepeat, input.uv),_BumpScale);

                InputData inputData = (InputData)0;
                inputData.normalWS = normalize(normalTS.x * input.tangentWS + normalTS.y * input.biTangent + normalTS.z * input.normalWS);
                inputData.viewDirectionWS = normalize(input.viewDirectionWS);

                float3 positionWS = input.positionWS;

                #ifdef _PROJECTION

                    float2 positionNDC = input.positionSS.xy / input.positionSS.ww;
                    float depth = SampleDepth(positionNDC);
                    float4 positionCS = float4(positionNDC * 2 - 1 , depth,1);

                    #if UNITY_UV_STARTS_AT_TOP
                        positionCS.y = -positionCS.y;
                    #endif

                    float4 hPositionWS = mul(UNITY_MATRIX_I_VP,positionCS.xyzw);
                    
                    positionWS = hPositionWS.xyz / hPositionWS.w;
                    // float3 positionOS = mul(UNITY_MATRIX_I_M , float4(positionWS.xyz,1)).xyz;
                    
                #endif

                inputData.positionWS = positionWS;

                inputData.shadowCoord = TransformWorldToShadowCoord(inputData.positionWS);
                inputData.vertexLighting = input.vertexLighting;
                
                SurfaceData surfaceData = (SurfaceData)0;
                surfaceData.albedo = _BaseColor.rgb;
                surfaceData.alpha = _BaseColor.a;

                half3 raddiance = 0;
                
                Light mainLight = GetMainLight(inputData.shadowCoord, inputData.positionWS, 0);

                raddiance += surfaceData.albedo * mainLight.distanceAttenuation * mainLight.color;
                raddiance += inputData.vertexLighting * surfaceData.albedo;

                #ifdef _ALPHATEST_ON
                    clip(1- mainLight.shadowAttenuation -_Cutoff);
                #endif

                half3 neutral = JDMPixelToneMapping(raddiance,surfaceData.metallic);

                half4 finnalColor = half4(neutral,(1 - mainLight.shadowAttenuation * mainLight.distanceAttenuation) * surfaceData.alpha);
       
                output.color = finnalColor;
                return output;
            }
            ENDHLSL
        }
    }
    CustomEditor "JDMStyleShaderGUI"
}
