#ifndef INCLUDE_JDM_STYLE_ENVIRONMENT_CORE
#define INCLUDE_JDM_STYLE_ENVIRONMENT_CORE

    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
    #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Packing.hlsl"
    #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/CommonMaterial.hlsl"
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
    
    extern half4 _EnvironmentColorTint = half4(1,1,1,0);


    SAMPLER(sampler_LinearRepeat);

    half Alpha(half albedoAlpha, half4 color, half cutoff)
    {
        half alpha = albedoAlpha * color.a;
        #if defined(_ALPHATEST_ON)
            clip(alpha - cutoff);
        #endif
        return alpha;
    }

    half4 SampleAlbedoAlpha(float2 uv, TEXTURE2D_PARAM(albedoAlphaMap, sampler_albedoAlphaMap))
    {
        return SAMPLE_TEXTURE2D(albedoAlphaMap, sampler_albedoAlphaMap, uv);
    }

    half3 SampleNormal(float2 uv, TEXTURE2D_PARAM(_BumpMap, sampler_BumpMap), half scale = 1.0h)
    {
        #ifdef _NORMALMAP
            half4 n = SAMPLE_TEXTURE2D(_BumpMap, sampler_BumpMap, uv);
            #if BUMP_SCALE_NOT_SUPPORTED
                return UnpackNormal(n);
            #else
                return UnpackNormalScale(n, scale);
            #endif
        #else
            return half3(0.0h, 0.0h, 1.0h);
        #endif
    }
    ///////////////////////////////////////////////////////////////////////////////
    //                  <Function> InputData                                        //
    ///////////////////////////////////////////////////////////////////////////////

    InputData InitializeInputData( half3 normalTS,half3 normalWS ,half4 tangentWS,half3 viewDirectionWS,half3 positionWS,half4 fogFactorAndVertexLight,half4 shadowCoord)
    {
        InputData inputData = (InputData)0;

        inputData.positionWS = positionWS;

        #ifdef _NORMALMAP 
            float sgn = tangentWS.w;      // should be either +1 or -1
            float3 bitangent = sgn * cross(normalWS.xyz, tangentWS.xyz);
            inputData.normalWS = TransformTangentToWorld(normalTS, half3x3(tangentWS.xyz, 
            bitangent.xyz, normalWS.xyz));
        #else
            inputData.normalWS = normalWS;
        #endif
    
        inputData.normalWS = normalize(inputData.normalWS);
        inputData.viewDirectionWS = SafeNormalize(viewDirectionWS);

        #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
            inputData.shadowCoord = shadowCoord;
        #elif defined(MAIN_LIGHT_CALCULATE_SHADOWS)
            inputData.shadowCoord = TransformWorldToShadowCoord(inputData.positionWS);
        #else
            inputData.shadowCoord = float4(0, 0, 0, 0);
        #endif

        inputData.fogCoord = fogFactorAndVertexLight.x;
        inputData.vertexLighting = fogFactorAndVertexLight.yzw;
        //inputData.normalizedScreenSpaceUV = ScreenSpaceUV.xy / ScreenSpaceUV.ww;
        

        return inputData;
    }


#endif