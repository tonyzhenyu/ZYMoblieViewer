#ifndef INCLUDE_JDM_STYLECORE
#define INCLUDE_JDM_STYLECORE

    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/UnityInput.hlsl"
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
    #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
    #include "GGXBRDF.hlsl"
    
    uniform half4 _FeverEmissionColor;

    SAMPLER(sampler_LinearRepeat);
    SAMPLER(sampler_LinearClamp);
    SAMPLER(sampler_PointClamp);

    struct ExternData{
        half iridescence;
        half3 iridescenceMask;
        half3 vertexNormal;
        half specularWeight;
        half rimWeight;
        half3 positionVS;
        half2 matcapUV;
        half3 highlightMatcap;
        half highlightTint;
        half3 matcapReflection;
    };
    struct PostData{
        half4 mashupColor;
        half4 feverColor;
    };

    #include "JDMStyleEnvironment.hlsl"
    #include "JDMStyleMashUp.hlsl"
    
    // -------------------------------------
    // Matcap UV function
    // -------------------------------------

    half2 GetMatcapUV(half3 positionVS,half3 normalWS){
        positionVS = - positionVS;
        half3 normalVS = mul(UNITY_MATRIX_V,normalWS).xyz;
        half3 tangentVS = cross(-positionVS,half3(0,1,0));
        half3 binormalVS = cross(positionVS,tangentVS);

        half2 matcapUV = half2(dot(tangentVS,normalVS),dot(binormalVS,normalVS)) * 0.495 + 0.5;
        
        return matcapUV;
    }

    // -------------------------------------
    // FinnalColor Blending function
    // -------------------------------------
    half4 AlphaBlending(half3 raddiance,half alpha){
        half4 finnalColor =0;
        #if defined(ALPHA_PREMULTIPLY) 
            finnalColor = half4(raddiance * alpha,alpha);
        #elif defined(ALPHA_PREMULTIPLY_INVERT)
            finnalColor = half4(lerp(1,raddiance, alpha) ,alpha);
        #else
            finnalColor = half4(raddiance,alpha);
        #endif
        return finnalColor;
    }
    ///////////////////////////////////////////////////////////////////////////////
    //                  <Function> Remap                                         //
    ///////////////////////////////////////////////////////////////////////////////

    float4 Remap(float4 oa, float4 ob, float4 na, float4 nb, float4 val)
    {
        return (val - oa) / (ob - oa) * (nb - na) + na;
    }
    float Remap(float oa, float ob, float na, float nb, float val)
    {
        return (val - oa) / (ob - oa) * (nb - na) + na;
    }


    // -------------------------------------
    // snap function
    // -------------------------------------
    float Snap(float value,float increcement)
    {
        return floor(value / increcement) * increcement;
    }
    float2 Snap(float2 value,float2 increcement)
    {
        return floor(value / increcement) * increcement;
    }
    float3 Snap(float3 value,float3 increcement)
    {
        return floor(value / increcement) * increcement;
    }
    float4 Snap(float4 value,float4 increcement)
    {
        return floor(value / increcement) * increcement;
    }
    //

    // -------------------------------------
    // Mod function
    // -------------------------------------
    float mod(float x,float threshold) {
        return x - floor(x * (1.0 /threshold)) * threshold;
    }
    
    // -------------------------------------
    // Post FX Function
    // -------------------------------------
    half4 MashUp(ExternData exData){
        half4 mashUp = SampleMashUpMap(exData.positionVS.xyz);
        return mashUp;
    }
    half3 Fever(half3 input, half3 feverEmissionMap){
        return lerp(input,_FeverEmissionColor.rgb, feverEmissionMap.r * _FeverEmissionColor.a);
    }
    half3 JDMPostFX(half3 neutral,half4 mashUp,InputData inputData){
        half3 output = neutral;
        
        #if defined(_MASH_UP_01)
            output = lerp(neutral,mashUp.rgb,mashUp.a);
        #elif defined(_MASH_UP_02)
            output = lerp(neutral,mashUp.rgb,mashUp.a);
        #endif
        output = FogBlending(output,inputData.positionWS,_CharacterFogColor,_CharacterFogWeight);
        return output;
    }

    // -------------------------------------
    // Texture Packaging function
    // -------------------------------------
    #ifdef _IRIDESCENCE_ENABLE
        TEXTURE2D(_IridescenceRamp);
        extern float _CharacterIridescenceWeight;
    #endif

    // -------------------------------------
    // Matcap Texture packing
    // -------------------------------------
    TEXTURE2D(_Matcap_FrontFacet);

    #ifdef _USE_SCATTER
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

    half3 JDMPixelToneMapping(half3 input,half blendWeight){
        half3 neutral = NeutralTonemap(max(0,input));
        neutral = lerp(neutral,input,blendWeight);

        #ifdef _FINNALCOLOR_TINT
             neutral *= _FinalColorTint;
        #endif

        return neutral;
    }
    half3 JDMSkinPixelToneMapping(half3 input,half blendWeight){
        half3 neutral = NeutralTonemap(input);
        half3 x = neutral;
        x = pow(x,2) / (sqrt(x) + 0.0001);
        neutral = lerp(neutral,x,blendWeight);
        
        #ifdef _FINNALCOLOR_TINT
             neutral *= _FinalColorTint;
        #endif

        return neutral;
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
    half3 DirectBRDF(Light light,InputData inputData,SurfaceData surfaceData){

        half3 Lo = 0;
        
        float3 halfDir = normalize(light.direction + inputData.viewDirectionWS);

        half nl = saturate(dot(light.direction,inputData.normalWS));
        half nv = saturate(dot(inputData.viewDirectionWS,inputData.normalWS));
        half lh = saturate(dot(light.direction,halfDir));
        half nh = saturate(dot(inputData.normalWS,halfDir));

        half3 radiance = light.color * light.shadowAttenuation * light.distanceAttenuation * nl * 4;

        half3 F0 = lerp((half3)0.04,surfaceData.albedo ,surfaceData.metallic) ;
        half3 F = F_Schlick(lh,F0) ;
        half3 kD = (half3)(1-F)*(1-surfaceData.metallic);
        
        // half3 specular  = ggxDirect( light.direction , light.color ,inputData.normalWS,  inputData.viewDirectionWS,F0 ,  (surfaceData.smoothness) * (surfaceData.smoothness)) ;
        half3 diffuse   = DisneyDiffuseTerm(nv, nl, lh,surfaceData.smoothness , surfaceData.albedo);
       
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
    half3 DirectBRDFCartoon(Light light,InputData inputData,SurfaceData surfaceData){

        half3 Lo = 0;
        
        float3 halfDir = normalize(light.direction + inputData.viewDirectionWS);

        half nl = saturate(dot(light.direction,inputData.normalWS));
        half nv = saturate(dot(inputData.viewDirectionWS,inputData.normalWS));
        half lh = saturate(dot(light.direction,halfDir));
        half nh = saturate(dot(inputData.normalWS,halfDir));

        half3 radiance = light.shadowAttenuation * light.distanceAttenuation * nl ;
        radiance = light.color  *(1-step(radiance,0));
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
    half3 DirectBRDFLow(Light light,InputData inputData,SurfaceData surfaceData){

        half3 Lo = 0;
        
        float3 halfDir = normalize(light.direction + inputData.viewDirectionWS);

        half nl = saturate(dot(light.direction,inputData.normalWS));
        half nv = saturate(dot(inputData.viewDirectionWS,inputData.normalWS));
        half lh = saturate(dot(light.direction,halfDir));
        half nh = saturate(dot(inputData.normalWS,halfDir));

        half3 radiance = light.color * light.shadowAttenuation * light.distanceAttenuation * nl * 4;

        half3 F0 = lerp((half3)0.04,surfaceData.albedo ,surfaceData.metallic) ;
        half3 F = F_Schlick(lh,F0) ;
        half3 kD = (half3)(1-F)*(1-surfaceData.metallic);
        
        half3 diffuse   = DisneyDiffuseTerm(nv, nl, lh,surfaceData.smoothness , surfaceData.albedo);

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

    float3 FrontLightFunction(InputData inputData,SurfaceData surfaceData,ExternData exData){
        float3 matcap = _Matcap_FrontFacet.Sample(sampler_LinearClamp, exData.matcapUV) ;
        matcap = pow(matcap,(1 / min(1,(surfaceData.smoothness + 0.1))));
        matcap = saturate(matcap);
        return _CharacterFrontLightWeight * matcap * surfaceData.albedo;
    }

    half3 IridescenceRaddiance(InputData inputData,SurfaceData surfaceData,ExternData exData){
        half3 iridescence = 0;

        #ifdef _IRIDESCENCE_ENABLE
            half nv = saturate(dot(inputData.normalWS,inputData.viewDirectionWS));
            iridescence = _IridescenceRamp.Sample(sampler_LinearClamp,nv).rgb ;
            //iridescence *= exData.iridescenceMap ;
            iridescence *= exData.iridescence;
        #endif

        return iridescence;
    }
    
    float3 JDMFragmentCartoon(InputData inputData,SurfaceData surfaceData,ExternData exData){
        float3 Lo = 0;

        float3 reflDirWS = normalize(reflect(-inputData.viewDirectionWS,inputData.normalWS));
        half nv = saturate(dot(inputData.normalWS,inputData.viewDirectionWS));
        //half nr = saturate(dot(inputData.normalWS,reflDirWS));

        half3 F0 = lerp(0.04,surfaceData.albedo,surfaceData.metallic) ;
        half3 F = fresnelSchlickRoughness(1,F0  ,surfaceData.smoothness) ;
        half3 kD = (1-F) * (1 - surfaceData.metallic) ;

        half envMip = ComputeEnvMapMipFromRoughness(surfaceData.smoothness);

        half4 hdri_reflect =    SampleOctaheral_Reflect(reflDirWS,envMip);
        half4 hdri_diffuse =    SampleOctaheral_Diffuse(inputData.normalWS);

        half3 envSpecular = hdri_reflect.rgb * EnvBRDF(F, surfaceData.smoothness, nv) * saturate((1-surfaceData.smoothness)) ;
        half3 envDiffuse = kD * surfaceData.albedo * hdri_diffuse.rgb ;

        Light mainLight = GetMainLight(inputData.shadowCoord, inputData.positionWS, 0);
        Lo += RimLightBRDFRaddiance(mainLight,inputData,surfaceData,exData) * exData.rimWeight/ 4;
        Lo +=  DirectBRDFCartoon(mainLight,inputData,surfaceData);
        Lo += (kD * inputData.vertexLighting * surfaceData.albedo);
        Lo *= _CharacterDirectWeight;
        Lo += (envDiffuse + envSpecular * exData.specularWeight ) * surfaceData.occlusion;

        // matcap scope
        half3 matcap = 0;

     

        #ifdef _MATCAP_ENABLE
           #ifndef NO_FRONT_LIGHT_PBR
                half3 frontRaddiance = FrontLightFunction(inputData,surfaceData,exData); 
                matcap += frontRaddiance * _MatcapWeight.y;
            #endif
            half3 highlight = (1-surfaceData.smoothness) * (1-surfaceData.smoothness) * exData.highlightMatcap ;
            highlight = saturate(kD) *  lerp(highlight,highlight * surfaceData.albedo, exData.highlightTint) * _CharacterEnvironmentTint.rgb ;
            matcap += highlight * _MatcapWeight.z;
            matcap += exData.matcapReflection * surfaceData.albedo * saturate(1-kD) * _CharacterEnvironmentTint.rgb * _MatcapWeight.w;
            Lo += matcap * _MatcapWeight.x;
        #endif

        // matcap scope


        #ifdef _IRIDESCENCE_ENABLE
            Lo = lerp(Lo,_CharacterIridescenceWeight *  (Lo +  Lo * IridescenceRaddiance(inputData,surfaceData,exData)/2), exData.iridescenceMask.r);
        #endif
        return Lo;
    }

    #ifdef _USE_SCATTER
        half3 JDMFragmentSSS(InputData inputData,SurfaceData surfaceData,ExternData exData){
            half3 Lo = 0;
            Light mainLight = GetMainLight(inputData.shadowCoord, inputData.positionWS, 0);

            //Lo += DirectBRDF(mainLight,inputData,surfaceData) 
            Lo += LightSSSRaddiance(mainLight,inputData,surfaceData) ;
            Lo += RimLightBRDFRaddiance(mainLight,inputData,surfaceData,exData) * mainLight.shadowAttenuation / 4;
            Lo += inputData.vertexLighting * surfaceData.albedo;
            Lo *= _CharacterDirectWeight;
            
            half3 F0 = lerp(0.04,surfaceData.albedo,surfaceData.metallic);
            half3 F = fresnelSchlickRoughness(1,F0 ,surfaceData.smoothness) ;
            half3 kD = (1-F) * (1 - surfaceData.metallic);
			 
            #ifndef NO_FRONT_LIGHT_PBR
                surfaceData.smoothness = 1;
                half3 frontRaddiance = FrontLightFunction(inputData,surfaceData,exData); 
                Lo += frontRaddiance;
            #endif
            //Lo += RimLightBRDFRaddiance(frontLight,inputData,surfaceData,exData) * exData.rimWeight;

            half3 hdri = SampleOctaheral_SSS(inputData.normalWS).rgb;
            Lo += hdri.rgb * surfaceData.albedo  * 2;


                

            return Lo;
        }
    #endif

#endif