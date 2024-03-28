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
    // frontlight 
    // --------------------------------------------------------
    float3 FrontLightFunction(InputData inputData,SurfaceData surfaceData,ExternData exData){
        float3 frontLight = 1;
        half nv = saturate(dot(inputData.viewDirectionWS,exData.vertexNormal));
        frontLight = pow(1-nv,2);
        return _CharacterFrontLightWeight * frontLight * surfaceData.albedo;
    }
    // --------------------------------------------------------
    // vertex lighting 
    // --------------------------------------------------------
    float3 VertexCartoonBRDF(float3 normalWS,float3 positionWS){
        half3 vertexLighting = 0;
        uint count = GetAdditionalLightsCount();
        for(uint i = 0u;i < count;i++){
            Light light = GetAdditionalLight(i,positionWS,1);
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
            Light light = GetAdditionalLight(i,positionWS,1);
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

    // --------------------------------------------------------
    // subsurface
    // --------------------------------------------------------
    #ifdef _SUBSURFACE_ENABLE
        TEXTURE2D(_DiffSliceRamp);
        TEXTURE2D(_ScatterMask);
        half3 LightSSSRaddiance(Light light,InputData inputData, SurfaceData surfaceData){
            //half scatterMask = _ScatterMask.Sample(sampler_LinearRepeat,input.uv).r;
            half3 sssRaddiance = 0;
            
            half nol = dot(light.direction,inputData.normalWS);

            half rampUV2 = saturate((nol + 1) / 2);
            half rampRD = saturate((nol + _Scatter * 2) / 2 * _Scatter);
            half3 ramp = _DiffSliceRamp.SampleLevel(sampler_LinearClamp,rampUV2,0).rgb * rampRD ;

            half3 rd = light.color * light.distanceAttenuation * (1-step(light.shadowAttenuation,0));
            // half3 rd = light.color * light.distanceAttenuation * light.shadowAttenuation;
            sssRaddiance += ramp * rd * surfaceData.albedo ;
            sssRaddiance += lerp(0,_DiffSliceRamp.Sample(sampler_LinearClamp,0.01),smoothstep(0.95,0,light.shadowAttenuation)) * surfaceData.albedo;
            return sssRaddiance;
        }
    #endif
#endif