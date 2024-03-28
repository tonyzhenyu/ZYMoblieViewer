#ifndef INCLUDE_JDM_LIGHTING
#define INCLUDE_JDM_LIGHTING
    // --------------------------------------------------------
    // BRDF Lib
    // --------------------------------------------------------
    // [Schlick 1994, "An Inexpensive BRDF Model for Physically-Based Rendering"]
    float3 F_Schlick(float HdotV, float3 F0)
    {
        return F0 + (1 - F0) * pow(1 - HdotV, 5);
    }
    float3 fresnelSchlickRoughness(float cosTheta, half3 F0, float roughness)
    {
        return F0 + (max(half3(roughness,roughness,roughness), F0) - F0) * pow(1.0 - cosTheta, 5.0);
    }     
    half PerceptualRoughnessToMipmapLevel_C(half perceptualRoughness)
    {
        return perceptualRoughness * 6;
    }
    half ComputeEnvMapMipFromRoughness(half roughness)
    {
        half perceptualRoughness = roughness;
        perceptualRoughness = perceptualRoughness * (1.7 - 0.7 * perceptualRoughness);
        return PerceptualRoughnessToMipmapLevel_C(perceptualRoughness);
    }
    half3 EnvBRDF(half3 specColor, half roughness, half NdotV)
    {
        // [ Lazarov 2013, "Getting More Physical in Call of Duty: Black Ops II" ]
        // Adaptation to fit our G term.
        const half4 c0 = {-1, -0.0275, -0.572, 0.022};
        const half4 c1 = {1, 0.0425, 1.04, -0.04};
        half4 r = roughness * c0 + c1;
        half a004 = min(r.x * r.x, exp2(-9.28 * NdotV)) * r.x + r.y;
        half2 AB = half2(-1.04, 1.04) * a004 + r.zw;

        // Anything less than 2% is physically impossible and is instead considered to be shadowing
        // Note: this is needed for the 'specular' show flag to work, since it uses a SpecularColor of 0
        AB.y *= saturate(50.0 * specColor.g);

        return specColor * AB.x + AB.y;
    }
    // --------------------------------------------------------
    // unity light Lib
    // --------------------------------------------------------
///////////////////////////////////////////////////////////////////////////////
//                          Light Helpers                                    //
///////////////////////////////////////////////////////////////////////////////

// Abstraction over Light shading data.
struct Light
{
    half3   direction;
    half3   color;
    half    distanceAttenuation;
    half    shadowAttenuation;
};


    // Light GetMainLight()
    // {
    //     Light light;
    //     light.direction = _MainLightPosition.xyz;
    //     light.distanceAttenuation = unity_LightData.z; // unity_LightData.z is 1 when not culled by the culling mask, otherwise 0.
    //     light.shadowAttenuation = 1.0;
    //     light.color = _MainLightColor.rgb;

    //     return light;
    // }

    // Light GetMainLight(float4 shadowCoord)
    // {
    //     Light light = GetMainLight();
    //     light.shadowAttenuation = MainLightRealtimeShadow(shadowCoord);
    //     return light;
    // }

    // Light GetMainLight(float4 shadowCoord, float3 positionWS, half4 shadowMask)
    // {
    //     Light light = GetMainLight();
    //     light.shadowAttenuation = MainLightShadow(shadowCoord, positionWS, shadowMask, _MainLightOcclusionProbes);
    //     return light;
    // }

///////////////////////////////////////////////////////////////////////////////
//                        Attenuation Functions                               /
///////////////////////////////////////////////////////////////////////////////

// Matches Unity Vanila attenuation
// Attenuation smoothly decreases to light range.
float DistanceAttenuation(float distanceSqr, half2 distanceAttenuation)
{
    // We use a shared distance attenuation for additional directional and puctual lights
    // for directional lights attenuation will be 1
    float lightAtten = rcp(distanceSqr);

#if SHADER_HINT_NICE_QUALITY
    // Use the smoothing factor also used in the Unity lightmapper.
    half factor = distanceSqr * distanceAttenuation.x;
    half smoothFactor = saturate(1.0h - factor * factor);
    smoothFactor = smoothFactor * smoothFactor;
#else
    // We need to smoothly fade attenuation to light range. We start fading linearly at 80% of light range
    // Therefore:
    // fadeDistance = (0.8 * 0.8 * lightRangeSq)
    // smoothFactor = (lightRangeSqr - distanceSqr) / (lightRangeSqr - fadeDistance)
    // We can rewrite that to fit a MAD by doing
    // distanceSqr * (1.0 / (fadeDistanceSqr - lightRangeSqr)) + (-lightRangeSqr / (fadeDistanceSqr - lightRangeSqr)
    // distanceSqr *        distanceAttenuation.y            +             distanceAttenuation.z
    half smoothFactor = saturate(distanceSqr * distanceAttenuation.x + distanceAttenuation.y);
#endif

    return lightAtten * smoothFactor;
}

half AngleAttenuation(half3 spotDirection, half3 lightDirection, half2 spotAttenuation)
{
    // Spot Attenuation with a linear falloff can be defined as
    // (SdotL - cosOuterAngle) / (cosInnerAngle - cosOuterAngle)
    // This can be rewritten as
    // invAngleRange = 1.0 / (cosInnerAngle - cosOuterAngle)
    // SdotL * invAngleRange + (-cosOuterAngle * invAngleRange)
    // SdotL * spotAttenuation.x + spotAttenuation.y

    // If we precompute the terms in a MAD instruction
    half SdotL = dot(spotDirection, lightDirection);
    half atten = saturate(SdotL * spotAttenuation.x + spotAttenuation.y);
    return atten * atten;
}

    uint GetPerObjectLightIndexOffset()
    {
    #if USE_STRUCTURED_BUFFER_FOR_LIGHT_DATA
        return unity_LightData.x;
    #else
        return 0;
    #endif
    }

    // Fills a light struct given a perObjectLightIndex
    Light GetAdditionalPerObjectLight(int perObjectLightIndex, float3 positionWS)
    {
        // Abstraction over Light input constants
    #if USE_STRUCTURED_BUFFER_FOR_LIGHT_DATA
        float4 lightPositionWS = _AdditionalLightsBuffer[perObjectLightIndex].position;
        half3 color = _AdditionalLightsBuffer[perObjectLightIndex].color.rgb;
        half4 distanceAndSpotAttenuation = _AdditionalLightsBuffer[perObjectLightIndex].attenuation;
        half4 spotDirection = _AdditionalLightsBuffer[perObjectLightIndex].spotDirection;
    #else
        float4 lightPositionWS = _AdditionalLightsPosition[perObjectLightIndex];
        half3 color = _AdditionalLightsColor[perObjectLightIndex].rgb;
        half4 distanceAndSpotAttenuation = _AdditionalLightsAttenuation[perObjectLightIndex];
        half4 spotDirection = _AdditionalLightsSpotDir[perObjectLightIndex];
    #endif

        // Directional lights store direction in lightPosition.xyz and have .w set to 0.0.
        // This way the following code will work for both directional and punctual lights.
        float3 lightVector = lightPositionWS.xyz - positionWS * lightPositionWS.w;
        float distanceSqr = max(dot(lightVector, lightVector), HALF_MIN);

        half3 lightDirection = half3(lightVector * rsqrt(distanceSqr));
        half attenuation = DistanceAttenuation(distanceSqr, distanceAndSpotAttenuation.xy) * AngleAttenuation(spotDirection.xyz, lightDirection, distanceAndSpotAttenuation.zw);

        Light light;
        light.direction = lightDirection;
        light.distanceAttenuation = attenuation;
        light.shadowAttenuation = 1.0;
        light.color = color;

        return light;
    }

    // Returns a per-object index given a loop index.
    // This abstract the underlying data implementation for storing lights/light indices
    int GetPerObjectLightIndex(uint index)
    {
    /////////////////////////////////////////////////////////////////////////////////////////////
    // Structured Buffer Path                                                                   /
    //                                                                                          /
    // Lights and light indices are stored in StructuredBuffer. We can just index them.         /
    // Currently all non-mobile platforms take this path :(                                     /
    // There are limitation in mobile GPUs to use SSBO (performance / no vertex shader support) /
    /////////////////////////////////////////////////////////////////////////////////////////////
    #if USE_STRUCTURED_BUFFER_FOR_LIGHT_DATA
        uint offset = unity_LightData.x;
        return _AdditionalLightsIndices[offset + index];

    /////////////////////////////////////////////////////////////////////////////////////////////
    // UBO path                                                                                 /
    //                                                                                          /
    // We store 8 light indices in float4 unity_LightIndices[2];                                /
    // Due to memory alignment unity doesn't support int[] or float[]                           /
    // Even trying to reinterpret cast the unity_LightIndices to float[] won't work             /
    // it will cast to float4[] and create extra register pressure. :(                          /
    /////////////////////////////////////////////////////////////////////////////////////////////
    #elif !defined(SHADER_API_GLES)
        // since index is uint shader compiler will implement
        // div & mod as bitfield ops (shift and mask).

        // TODO: Can we index a float4? Currently compiler is
        // replacing unity_LightIndicesX[i] with a dp4 with identity matrix.
        // u_xlat16_40 = dot(unity_LightIndices[int(u_xlatu13)], ImmCB_0_0_0[u_xlati1]);
        // This increases both arithmetic and register pressure.
        return unity_LightIndices[index / 4][index % 4];
    #else
        // Fallback to GLES2. No bitfield magic here :(.
        // We limit to 4 indices per object and only sample unity_4LightIndices0.
        // Conditional moves are branch free even on mali-400
        // small arithmetic cost but no extra register pressure from ImmCB_0_0_0 matrix.
        half2 lightIndex2 = (index < 2.0h) ? unity_LightIndices[0].xy : unity_LightIndices[0].zw;
        half i_rem = (index < 2.0h) ? index : index - 2.0h;
        return (i_rem < 1.0h) ? lightIndex2.x : lightIndex2.y;
    #endif
    }

    // Fills a light struct given a loop i index. This will convert the i
    // index to a perObjectLightIndex
    Light GetAdditionalLight(uint i, float3 positionWS)
    {
        int perObjectLightIndex = GetPerObjectLightIndex(i);
        return GetAdditionalPerObjectLight(perObjectLightIndex, positionWS);
    }

    int GetAdditionalLightsCount()
    {
        // TODO: we need to expose in SRP api an ability for the pipeline cap the amount of lights
        // in the culling. This way we could do the loop branch with an uniform
        // This would be helpful to support baking exceeding lights in SH as well
        return min(_AdditionalLightsCount.x, unity_LightData.y);
    }


    // --------------------------------------------------------
    // vertex lighting 
    // --------------------------------------------------------
    float3 VertexCartoonBRDF(float3 normalWS,float3 positionWS){
        half3 vertexLighting = 0;
        uint count = GetAdditionalLightsCount();
        for(uint i = 0u;i < count;i++){
            Light light = GetAdditionalLight(i,positionWS);
            half nol = saturate(dot(normalWS,light.direction));
            nol =(1-step(nol,0))*0.5;
            vertexLighting += nol * light.color * light.distanceAttenuation ;
        }
        return vertexLighting;
    }
    float3 VertexBRDF(float3 normalWS,float3 positionWS){
        half3 vertexLighting = 0;
        uint count = GetAdditionalLightsCount();
        for(uint i = 0u;i < count;i++){
            Light light = GetAdditionalLight(i,positionWS);
            half nol = saturate(dot(normalWS,light.direction));
            vertexLighting += nol * light.color * light.distanceAttenuation ;
        }
        return vertexLighting;
    }
    // --------------------------------------------------------
    // directlight 
    // --------------------------------------------------------
    half3 DirectBRDFCartoon(Light light,InputData inputData,SurfaceData surfaceData){

        half3 Lo = 0;
        
        float3 halfDir = normalize(light.direction + inputData.viewDirectionWS);

        half nl = saturate(dot(light.direction,inputData.normalWS));
        half nv = saturate(dot(inputData.viewDirectionWS,inputData.normalWS));
        half lh = saturate(dot(light.direction,halfDir));
        half nh = saturate(dot(inputData.normalWS,halfDir));

        half3 radiance = light.shadowAttenuation * light.distanceAttenuation * nl ;
        radiance = light.color  * (1-step(radiance,0));
        half3 F0 = lerp((half3)0.04,surfaceData.albedo ,surfaceData.metallic) ;
        half3 F = F_Schlick(lh,F0) ;
        half3 kD = (half3)(1-F)*(1-surfaceData.metallic);
        
        half3 diffuse   =(1-step(nl,0)) * surfaceData.albedo;

        half a2 = (surfaceData.smoothness) * (surfaceData.smoothness) ;
        a2 += 0.0001;
        float d = ((nh * a2 - nh) * nh + 1);
        d = a2 / (d * d * PI);
        
        half a22 = a2 / 2;
        half g_v = nv / (nv *(1-a22) + a22) ;
        half g_l = nl / (nl *(1-a22) + a22) ;
        half g = g_v * g_l;
        
        half3 specular  =  d  *g * F / (4 * nv  + 0.0005  );

        Lo = (kD * diffuse + specular) * radiance;

        return Lo;
    }

    // --------------------------------------------------------
    // rimlight 
    // --------------------------------------------------------
    half3 RimLightBRDFRaddiance(Light light,InputData inputData,SurfaceData surfaceData,ExternData exData){

        half3 Lo = 0;
        
        float3 halfDir = normalize(light.direction + inputData.viewDirectionWS);

        half nl = saturate(dot(light.direction,exData.vertexNormal));
        half nv = saturate(dot(inputData.viewDirectionWS,exData.vertexNormal));
        half lh = saturate(dot(light.direction,halfDir));
        half nh = saturate(dot(exData.vertexNormal,halfDir));

        half3 radiance = light.color * light.shadowAttenuation * light.distanceAttenuation * nl * 4;

        half3 F0 = lerp((half3)0.04,surfaceData.albedo ,surfaceData.metallic) ;
        half3 F = F_Schlick(lh,F0) ;
        half3 kD = (half3)(1-F)*(1-surfaceData.metallic);
        
        half3 rim = nh * F;
        half3 diffuse = saturate(pow(max(0,surfaceData.albedo),(half3)0.4));
        
        half kn = pow((1-nv),5);
        half3 raddiance0 = nl * kn ;
        raddiance0 = smoothstep(raddiance0,0,0.05);
        raddiance0 *= saturate(1-step(light.shadowAttenuation,0.1)) * pow(light.color, 10) *  light.distanceAttenuation * surfaceData.occlusion * (surfaceData.smoothness);
        Lo = 4 * (kD * diffuse + rim) * raddiance0 ;

        kn = pow((1-nv),2);
        half3 raddiance1 = nl * kn ;
        raddiance1 = smoothstep(raddiance1,0,0.1) + 0.05;
        raddiance1 *= saturate(1-step(light.shadowAttenuation,0.1)) * light.color *  light.distanceAttenuation * surfaceData.occlusion * (surfaceData.smoothness);
        Lo += (kD * diffuse + rim) * raddiance1 ;

        return Lo;
    }
#endif