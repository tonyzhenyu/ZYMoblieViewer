#ifndef INCLUDE_JDM_CHARACTERLITFUNC
#define INCLUDE_JDM_CHARACTERLITFUNC

    #ifndef INCLUDE_JDM_SAMPLER
    #define INCLUDE_JDM_SAMPLER
        SAMPLER(sampler_LinearClamp);
        SAMPLER(sampler_PointClamp);
    #endif

    #include "dataStruct/JDM_ExternalData.hlsl"

    #include "JDM_IBL.hlsl"
    #include "JDM_Lighting.hlsl"

    // -------------------------------------
    // JDM Cartoon parallax eye lit shading function
    // -------------------------------------
    float3 JDMFragmentParallaxEye(InputData inputData,SurfaceData surfaceData,ExternData exData){
        return 0;
    }

    // -------------------------------------
    // JDM Cartoon lit shading function
    // -------------------------------------
    float3 JDMFragmentCartoon(InputData inputData,SurfaceData surfaceData,ExternData exData){
        float3 Lo = 0;
        
        float3 reflDirWS = normalize(reflect(-inputData.viewDirectionWS,inputData.normalWS));
        half nv = saturate(dot(inputData.normalWS,inputData.viewDirectionWS));
        float3 refractWS = normalize(refract(-inputData.viewDirectionWS,inputData.normalWS,0.95));
        half3 F0 = lerp(0.04,surfaceData.albedo,surfaceData.metallic) ;
        half3 F = fresnelSchlickRoughness(1,F0  ,surfaceData.smoothness) ;
        half3 kD = (1-F) * (1 - surfaceData.metallic) ;

        half envMip = ComputeEnvMapMipFromRoughness(surfaceData.smoothness);

        half4 hdri_reflect =    SampleOctaheral_Reflect(reflDirWS,envMip);
        half4 hdri_diffuse =    SampleOctaheral_Diffuse(inputData.normalWS);
        half4 hdri_refract =    SampleOctaheral_Refract(refractWS,envMip);

        half3 envSpecular = hdri_reflect.rgb * EnvBRDF(F, surfaceData.smoothness, nv) * saturate((1-surfaceData.smoothness)) ;
        half3 envRefract = hdri_refract.rgb *  EnvBRDF(F, surfaceData.smoothness, nv) * saturate((1-surfaceData.smoothness)) ;
        half3 envDiffuse = kD * surfaceData.albedo * hdri_diffuse.rgb ;

        Light mainLight = GetMainLight(inputData.shadowCoord, inputData.positionWS, 0);
        Lo += RimLightBRDFRaddiance(mainLight,inputData,surfaceData,exData) * exData.rimWeight/ 4;
        Lo += DirectBRDFCartoon(mainLight,inputData,surfaceData);
        Lo += (kD * inputData.vertexLighting * surfaceData.albedo);
        Lo *= _CharacterDirectWeight;
        Lo += (envDiffuse + envSpecular * exData.specularWeight + envRefract) * surfaceData.occlusion;

        #ifndef NO_FRONT_LIGHT_PBR
            half3 frontRaddiance = FrontLightFunction(inputData,surfaceData,exData); 
        #endif
        Lo += frontRaddiance;
        // matcap scope
        half3 matcap = 0;
        #ifdef _MATCAP_ENABLE

            half3 highlight = (1-surfaceData.smoothness) * (1-surfaceData.smoothness) * exData.highlightMatcap ;
            highlight = saturate(kD) *  lerp(highlight,highlight * surfaceData.albedo, exData.highlightTint) * _CharacterEnvironmentTint.rgb ;
            matcap += highlight * _MatcapWeight.z;
            matcap += exData.matcapReflection * surfaceData.albedo * saturate(1-kD) * _CharacterEnvironmentTint.rgb * _MatcapWeight.w;
            Lo += matcap * _MatcapWeight.x;
        #endif

        // _IRIDESCENCE_ENABLE
        #ifdef _IRIDESCENCE_ENABLE
            Lo = lerp(Lo,_CharacterIridescenceWeight *  (Lo +  Lo * IridescenceRaddiance(inputData,surfaceData,exData)/2), exData.iridescenceMask);
        #endif
        return Lo;
    }
    // -------------------------------------
    // JDM Cartoon skin shading function
    // -------------------------------------
    #ifdef _SUBSURFACE_ENABLE
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