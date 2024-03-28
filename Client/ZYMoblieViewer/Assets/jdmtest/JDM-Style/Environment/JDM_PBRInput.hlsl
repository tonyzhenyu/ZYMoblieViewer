#ifndef UNITY_JDM_PBR_INPUT_INCLUDED
#define UNITY_JDM_PBR_INPUT_INCLUDED

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Packing.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/CommonMaterial.hlsl"

#ifndef CUSTOM_BATCH
#define CUSTOM_BATCH

CBUFFER_START(UnityPerMaterial)
float4 _BaseMap_ST;
half4 _BaseColor;
half4 _EmissionColor;
half _Smoothness;
half _BumpScale;
half _OcclusionStrength;
#if defined(_ALPHATEST_ON)
half _Cutoff;
#endif

#if defined(_DISSOLVE)
float4 _WolrdUV_ST;
float4 _Dissolve_BaseMap_ST;
half4 _Dissolve_BaseColor;
half _Dissolve_BumpScale;
half _Dissolve_OcclusionStrength;
half _Dissolve_Smoothness;
half _DissolveValue;
#endif

#if defined(_UV_SLIDE)
float _SlideXSpeed;
float _SlideYSpeed;
float _DistortionXSpeed;
float _DistortionYSpeed;
float _DistortionStrength;
#endif

CBUFFER_END
#endif

TEXTURE2D(_BaseMap);   SAMPLER(sampler_BaseMap);
TEXTURE2D(_BumpMap);    SAMPLER(sampler_BumpMap);      
TEXTURE2D(_OccRoughMetalTexture);   SAMPLER(sampler_OccRoughMetalTexture);

#if defined(_DISSOLVE)
TEXTURE2D(_Dissolve_BaseMap);   SAMPLER(sampler_Dissolve_BaseMap);
TEXTURE2D(_Dissolve_BumpMap);    SAMPLER(sampler_Dissolve_BumpMap);
TEXTURE2D(_Dissolve_OccRoughMetalTexture);   SAMPLER(sampler_Dissolve_OccRoughMetalTexture);

TEXTURE2D(_NoiseMap);   SAMPLER(sampler_NoiseMap);
#endif

#ifdef NEED_BLOOM_MRT
TEXTURE2D(_EmissionMap);    SAMPLER(sampler_EmissionMap); 
#endif


  
struct CustomSurfaceData
{
    half3 albedo;
    half3 specular;
    half  metallic;
    half  smoothness;
    half3 normalTS;
    half3 emission;
    half  occlusion;
    half  alpha;
};


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

inline half4 SampleChannels(float2 uv){
#ifdef _CHANNELSMAP
    return SAMPLE_TEXTURE2D(_OccRoughMetalTexture,sampler_OccRoughMetalTexture,uv);
#else
    return half4(0,0,0,0);
#endif
}

inline void InitializeStandardLitSurfaceData(float2 uv, out CustomSurfaceData outSurfaceData)
{
    half4 albedoAlpha = SampleAlbedoAlpha(uv, TEXTURE2D_ARGS(_BaseMap, sampler_BaseMap));
    
    half4 channels = SampleChannels(uv);

    outSurfaceData.alpha = Alpha(albedoAlpha.a, _BaseColor, 
    #if defined(_ALPHATEST_ON)
    _Cutoff
    #else
    0
    #endif
    );
        
    outSurfaceData.albedo = albedoAlpha.rgb * _BaseColor.rgb;

    outSurfaceData.metallic = channels.b;
    outSurfaceData.specular = half3(0.0h, 0.0h, 0.0h);
    outSurfaceData.smoothness = channels.g * _Smoothness;
    
    outSurfaceData.normalTS = SampleNormal(uv, TEXTURE2D_ARGS(_BumpMap, sampler_BumpMap), _BumpScale);
    outSurfaceData.occlusion = LerpWhiteTo(channels.r, _OcclusionStrength);

    #ifdef NEED_BLOOM_MRT
    outSurfaceData.emission = SAMPLE_TEXTURE2D(_EmissionMap, sampler_EmissionMap, uv).rgb * _EmissionColor.rgb;
    #else
    outSurfaceData.emission = _EmissionColor.rgb;
    #endif
}

#if defined(_DISSOLVE)
inline void InitializeDissolveLitSurfaceData(float2 uv, float2 worldUV, out CustomSurfaceData outSurfaceData)
{
	float2 uvBase = uv * _BaseMap_ST.xy + _BaseMap_ST.zw;
	float2 uvDissolve = uv * _Dissolve_BaseMap_ST.xy + _Dissolve_BaseMap_ST.zw;
	//Base Part
	half4 albedoAlphaBase = SampleAlbedoAlpha(uvBase, TEXTURE2D_ARGS(_BaseMap, sampler_BaseMap));

	half4 channelsBase = SAMPLE_TEXTURE2D(_OccRoughMetalTexture, sampler_OccRoughMetalTexture, uvBase);

	half3 NormalBase = SampleNormal(uvBase, TEXTURE2D_ARGS(_BumpMap, sampler_BumpMap), _BumpScale);

	half smoothnessBase = channelsBase.y * _Smoothness;

	half occlusionBase = LerpWhiteTo(channelsBase.x, _OcclusionStrength);

	albedoAlphaBase *= _BaseColor;

	//Dissolve Part
	half4 albedoAlphaDissolve = SampleAlbedoAlpha(uvDissolve, TEXTURE2D_ARGS(_Dissolve_BaseMap, sampler_Dissolve_BaseMap));

	half4 channelsDissolve = SAMPLE_TEXTURE2D(_Dissolve_OccRoughMetalTexture, sampler_Dissolve_OccRoughMetalTexture, uvDissolve);

	half3 NormalDissolve = SampleNormal(uvDissolve, TEXTURE2D_ARGS(_Dissolve_BumpMap, sampler_Dissolve_BumpMap), _Dissolve_BumpScale);

	half smoothnessDissolve = channelsDissolve.y * _Dissolve_Smoothness;

	half occlusionDissolve = LerpWhiteTo(channelsDissolve.x, _Dissolve_OcclusionStrength);

	albedoAlphaDissolve *= _Dissolve_BaseColor;

	//Dissolve Factor
	worldUV = worldUV * _WolrdUV_ST.xy + _WolrdUV_ST.zw;
	float NoiseFactor = SAMPLE_TEXTURE2D(_NoiseMap, sampler_NoiseMap, worldUV).r;
	float DissolveFactor = smoothstep(_DissolveValue, _DissolveValue + 0.1, NoiseFactor);

	//Layer Blend

	outSurfaceData.alpha = lerp(albedoAlphaDissolve.a, albedoAlphaBase.a, DissolveFactor);
	outSurfaceData.albedo = lerp(albedoAlphaDissolve.xyz, albedoAlphaBase.xyz, DissolveFactor);
	outSurfaceData.metallic = lerp(channelsDissolve.z, channelsBase.z, DissolveFactor);
	outSurfaceData.specular = half3(0.0h, 0.0h, 0.0h);
	outSurfaceData.smoothness = lerp(smoothnessDissolve, smoothnessBase, DissolveFactor);
	outSurfaceData.normalTS = lerp(NormalDissolve, NormalBase, DissolveFactor);
	outSurfaceData.occlusion = lerp(occlusionDissolve, occlusionBase, DissolveFactor);

	
#if defined(_ALPHATEST_ON)
	clip(outSurfaceData.alpha - _Cutoff);
#else

#endif



	outSurfaceData.emission = _EmissionColor.rgb;

}
#endif
 

#if defined(_UV_SLIDE)
inline void InitializeUVSlideSurfaceData(float2 uv, out CustomSurfaceData outSurfaceData)
{
	half2 SlideUV = half2(uv.x + _Time.x * _SlideXSpeed, uv.y + _Time.x * _SlideYSpeed);
	half2 DistortionUV = half2(uv.x + _Time.x * _DistortionXSpeed, uv.y + _Time.x * _DistortionYSpeed);

	half4 albedoAlpha = SampleAlbedoAlpha(SlideUV, TEXTURE2D_ARGS(_BaseMap, sampler_BaseMap));
	half4 distortionAlbedo = SampleAlbedoAlpha(DistortionUV, TEXTURE2D_ARGS(_BaseMap, sampler_BaseMap));
	albedoAlpha = lerp(albedoAlpha, albedoAlpha * distortionAlbedo, _DistortionStrength);
	
	float3 normal = SampleNormal(SlideUV, TEXTURE2D_ARGS(_BumpMap, sampler_BumpMap), _BumpScale);
	float3 distortionNormal = SampleNormal(DistortionUV, TEXTURE2D_ARGS(_BumpMap, sampler_BumpMap), _BumpScale);
	normal = normalize(normal + distortionNormal * _DistortionStrength);

	half4 channels = SampleChannels(uv);

	outSurfaceData.alpha = Alpha(albedoAlpha.a, _BaseColor,	0);

	outSurfaceData.albedo = albedoAlpha.rgb * _BaseColor.rgb;

	outSurfaceData.metallic = channels.b;
	outSurfaceData.specular = half3(0.0h, 0.0h, 0.0h);
	outSurfaceData.smoothness = channels.g * _Smoothness;

	outSurfaceData.normalTS = normal;
	outSurfaceData.occlusion = LerpWhiteTo(channels.r, _OcclusionStrength);

	outSurfaceData.emission = _EmissionColor.rgb;

}

#endif
 


#endif
