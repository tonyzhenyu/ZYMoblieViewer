#ifndef INCLUDE_JDM_CHARACTERSHADOWPASS
#define INCLUDE_JDM_CHARACTERSHADOWPASS
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
    #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Packing.hlsl"
    #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/CommonMaterial.hlsl"
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"
    
    half3 _LightDirection;
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
    TEXTURE2D(_BaseMap);
    SAMPLER(sampler_BaseMap);


    struct Attributes
    {
        float4 positionOS   : POSITION;
        float3 normalOS     : NORMAL;
        float2 texcoord     : TEXCOORD0;
        float4 color : COLOR;
        UNITY_VERTEX_INPUT_INSTANCE_ID
    };

    struct Varyings
    {
        float2 uv           : TEXCOORD0;
        float4 positionCS   : SV_POSITION;
    };

    float4 GetShadowPositionHClip(Attributes input)
    {
        float3 positionWS = TransformObjectToWorld(input.positionOS.xyz);
        float3 normalWS = TransformObjectToWorldNormal(input.normalOS);

        float4 positionCS = TransformWorldToHClip(ApplyShadowBias(positionWS, normalWS, _LightDirection)) ;

        #if UNITY_REVERSED_Z
            positionCS.z = min(positionCS.z, positionCS.w * UNITY_NEAR_CLIP_VALUE);
        #else
            positionCS.z = max(positionCS.z, positionCS.w * UNITY_NEAR_CLIP_VALUE);
        #endif

        return positionCS;
    }
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
    Varyings ShadowPassVertex(Attributes input)
    {
        Varyings output;
        UNITY_SETUP_INSTANCE_ID(input);

        output.uv = TRANSFORM_TEX(input.texcoord, _BaseMap);
        output.positionCS = GetShadowPositionHClip(input) * input.color.r;
        return output;
    }

    half4 ShadowPassFragment(Varyings input) : SV_TARGET
    {
        Alpha(SampleAlbedoAlpha(input.uv, TEXTURE2D_ARGS(_BaseMap, sampler_BaseMap)).a, _BaseColor, 
        #if defined(_ALPHATEST_ON)
        _Cutoff
        #else
        0
        #endif
        );
        return 0;
    }

#endif