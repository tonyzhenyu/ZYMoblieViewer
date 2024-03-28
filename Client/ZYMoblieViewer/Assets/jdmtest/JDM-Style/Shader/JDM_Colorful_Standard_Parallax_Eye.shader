Shader "JDM/Colorful/Character/JDM_Colorful_Parallax_Eye"
{
    properties{
        _BaseMap ("Base Color", 2D) = "white" {}
        _IrisMap ("Iris", 2D) = "white" {}
        _BumpMap("Bump map" , 2D) = "bump"{}
        _BumpScale("Bump" ,float) = 1 
        _PBRMap("PBR Map" , 2D) = "white"{}
        _Parallax("parallax" , float) = 0

        [HideInInspector]_FinalColorTint("Final Color Tint", Color) = (1,1,1,1)
    }
    SubShader
    {
        
        Pass
        {
            Tags{
                "LightMode" = "EmissionOpaque" 
            }
            Name "JDM Colorful Standard PBR"
            ZWrite on
            ZTest LEqual
            Blend one zero , one one
            
            HLSLPROGRAM

			#pragma multi_compile _ _MAIN_LIGHT_SHADOWS
            #pragma multi_compile _ _MASH_UP_01 _MASH_UP_02
            
            #define _SHADOWS_SOFT
			#define _ADDITIONAL_LIGHTS_VERTEX 
            #define _FINNALCOLOR_TINT

            #pragma vertex vert
            #pragma fragment frag
			
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            CBUFFER_START(UnityPerMaterial)
            uniform half4 _BaseMap_ST;
            uniform half _BumpScale; 
            uniform half4 _IrisMap_ST;
            uniform half _Parallax;
			uniform half4 _FinalColorTint; 
            CBUFFER_END


            #include "JDMStyleCore.hlsl"
            

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
            

            TEXTURE2D(_BaseMap);
            TEXTURE2D(_IrisMap);
            TEXTURE2D(_BumpMap);
            TEXTURE2D(_PBRMap);
            

            uniform half4 _BaseColor; 

            Varyings vert(Attributes input)
            {
                Varyings output = (Varyings)0;
                output.positionCS = mul(UNITY_MATRIX_MVP,input.positionOS);
                output.uv = input.uv;

                VertexNormalInputs normalInput = GetVertexNormalInputs(input.normal, input.tangent);

                output.normalWS = normalInput.normalWS;
                output.biTangent = normalInput.bitangentWS;
                output.tangentWS = normalInput.tangentWS;
                output.positionWS = mul(UNITY_MATRIX_M,input.positionOS).xyz;

                InputData inputData = (InputData)0;
                inputData.normalWS = output.normalWS;


                output.vertexLighting = VertexBRDF(output.normalWS,output.positionWS);
                output.viewDirectionWS = GetWorldSpaceViewDir(output.positionWS);

                output.positionVS = mul(UNITY_MATRIX_V , output.positionWS);

                return output;
            }
            FragmentOutput frag(Varyings input)
            {
                FragmentOutput output = (FragmentOutput)0;

                half renormFactor = 1.0 / length(input.normalWS);
                half3x3 worldToTangent;
                worldToTangent[0] = input.tangentWS * renormFactor;
                worldToTangent[1] = input.biTangent  * renormFactor;
                worldToTangent[2] = input.normalWS * renormFactor;
                half3 viewDirTS = mul(worldToTangent,normalize(input.viewDirectionWS));
                half2 parallaxUV = input.uv * _IrisMap_ST.xy + _IrisMap_ST.zw - (viewDirTS.xy / viewDirTS.z * _Parallax );


                half2 transformedUV = input.uv * _BaseMap_ST.xy + _BaseMap_ST.zw;
                half4 diffMap = _BaseMap.Sample(sampler_LinearClamp,transformedUV).rgba;

                SurfaceData ball = (SurfaceData)0;
                ball.albedo = diffMap.rgb;
                ball.occlusion = _PBRMap.Sample(sampler_LinearClamp,transformedUV).r;
                ball.smoothness = _PBRMap.Sample(sampler_LinearClamp,transformedUV).g;
                ball.metallic = 0;
                ball.alpha = 1 - pow(diffMap.a,5);
                ball.emission = 0;
                ball.specular = 0;

                SurfaceData iris = (SurfaceData)0;
                half3 mixmap = _PBRMap.Sample(sampler_LinearClamp,parallaxUV).rgb;
                
                iris.occlusion = mixmap.r;
                iris.smoothness = mixmap.g;
                iris.metallic = 0;

                mixmap.g *= 2;

                parallaxUV = input.uv * _IrisMap_ST.xy + _IrisMap_ST.zw - (viewDirTS.xy / viewDirTS.z * mixmap.g * (ball.alpha) * _Parallax);
                half4 diffMap_Iris = _IrisMap.Sample(sampler_LinearClamp , parallaxUV ).rgba;
                iris.albedo = diffMap_Iris;

                half3 iris_bump = UnpackNormalScale(_BumpMap.Sample(sampler_LinearClamp, parallaxUV),_BumpScale);
                half3 ball_bump = half3(0,0,1);
                
                half3 normalTS = lerp(iris_bump,ball_bump,1-ball.alpha);
                half3 normalWS =  normalTS.x * input.tangentWS + normalTS.y * input.biTangent + normalTS.z * input.normalWS;
                normalWS = normalize(normalWS);

                InputData inputData = (InputData)0;
                inputData.normalWS = normalWS;
                inputData.viewDirectionWS = normalize(input.viewDirectionWS);
                inputData.positionWS = input.positionWS;
                inputData.shadowCoord = TransformWorldToShadowCoord(input.positionWS);
                inputData.vertexLighting = input.vertexLighting ;
                inputData.bakedGI = SampleOctaheral_Diffuse(inputData.normalWS).rgb * _CharacterEnvironmentWeight;

                SurfaceData surfaceData = (SurfaceData)0;
                surfaceData.albedo = lerp(diffMap.rgb,diffMap_Iris.rgb,ball.alpha);
                surfaceData.occlusion = ball.occlusion;
                surfaceData.smoothness = 0.005;
                surfaceData.metallic = mixmap.b;
                surfaceData.alpha = 0;
                surfaceData.emission = 0;
                surfaceData.specular = 0;

                ExternData exData = (ExternData)0;
                exData.vertexNormal = input.normalWS;
                exData.positionVS = input.positionVS;
                half3 raddiance = 0;

                half3 Lo = 0;
                Light mainLight = GetMainLight();
                Lo += DirectBRDF(mainLight,inputData,surfaceData) * 2 * ball.alpha * surfaceData.albedo;

                inputData.normalWS = normalize(input.normalWS);
                mainLight = GetMainLight(inputData.shadowCoord, inputData.positionWS, 0);
                Lo += DirectBRDF(mainLight,inputData,surfaceData)  * surfaceData.occlusion;

                half nl = saturate(dot(mainLight.direction,inputData.normalWS));
                half nv = saturate(dot(inputData.normalWS,inputData.viewDirectionWS));
                half3 reflDirWS = reflect(-inputData.viewDirectionWS,inputData.normalWS);
                half nr = saturate(dot(inputData.normalWS,reflDirWS));

                half3 F0 = lerp(0.04,surfaceData.albedo,surfaceData.metallic);
                half3 F = fresnelSchlickRoughness(nv,F0 ,surfaceData.smoothness) ;
                half3 kD = (1-F) * (1 - surfaceData.metallic);

                half envMip = ComputeEnvMapMipFromRoughness(surfaceData.smoothness);
                half4 hdri = SampleOctaheral_Reflect(reflDirWS,envMip);

                half3 envSpecular = hdri * EnvBRDF(F, surfaceData.smoothness, nv) * (1-surfaceData.smoothness);

                Lo += kD * inputData.vertexLighting * surfaceData.albedo * surfaceData.occlusion;
                Lo *= _CharacterDirectWeight;

                Lo += (kD * inputData.bakedGI * surfaceData.albedo + envSpecular * surfaceData.albedo) * surfaceData.occlusion;

                Light frontLight = (Light)0;
                frontLight.direction = normalize(inputData.viewDirectionWS+half3(0.25,0,0));
                frontLight.color = half3(1,1,1) * 5 ;

                half nlf = saturate(pow( saturate(dot(frontLight.direction,inputData.normalWS)) , 500));
                nlf = smoothstep(0.5,0.85,nlf);
                half3 frontRaddiance =  frontLight.color * nlf  ;  
                Lo += frontRaddiance * _CharacterFrontLightWeight ;

                raddiance = Lo;
                half3 neutral = lerp(raddiance* _FinalColorTint,JDMPixelToneMapping(raddiance,1),1-ball.alpha);
                half4 mashup = MashUp(exData);
                neutral = JDMPostFX(neutral,mashup,inputData);

                half4 finnalColor = half4(neutral.xyz,1);

                output.color = finnalColor;
                output.emission.a = 1;

                half3 emit = max(0,raddiance.rgb - 1) / 40;
                emit /= 1 + emit;
                emit = lerp(0,emit,surfaceData.metallic);
                emit = JDMPostFX(emit,mashup,inputData);
                output.emission.rgb = emit ;
                return output;
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
            #pragma exclude_renderers gles glcore
			#pragma target 4.5
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
            
            uniform half4 _BaseColor;
            CBUFFER_START(UnityPerMaterial)
            uniform half4 _BaseMap_ST;
            uniform half _BumpScale; 
            uniform half4 _IrisMap_ST;
            uniform half _Parallax;
			uniform half4 _FinalColorTint; 
            CBUFFER_END

            
            #include "JDMStyleShadowCasterPass.hlsl"
            ENDHLSL
        }
    }
}
