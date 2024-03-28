#ifndef GGXBRDF_INCLUDE
#define GGXBRDF_INCLUDE

    half3 DisneyDiffuseTerm(half NdotV, half NdotL, half LdotH, half perceptualRoughness, half3 baseColor)
    {
        half fd90 = 0.5 + 2 * LdotH * LdotH * perceptualRoughness;
        // Two schlick fresnel term
        half lightScatter = (1 + (fd90 - 1) * pow(1 - NdotL, 5));
        half viewScatter = (1 + (fd90 - 1) * pow(1 - NdotV, 5));
        return baseColor * INV_PI * lightScatter * viewScatter;
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
  
    // [Schlick 1994, "An Inexpensive BRDF Model for Physically-Based Rendering"]
    float3 F_Schlick(float HdotV, float3 F0)
    {
        return F0 + (1 - F0) * pow(1 - HdotV, 5);
    }
    // GGX BRDF
    float ggxNormalDistribution( float NdotH, float roughness )
    {
        float a2 = roughness * roughness;
        float d = ((NdotH * a2 - NdotH) * NdotH + 1);
        return a2 / (d * d * PI);
    }
    float schlickMaskingTerm(float NdotL, float NdotV, float roughness)
    {
        // Karis notes they use alpha / 2 (or roughness^2 / 2)
        float k = roughness*roughness / 2;

        // Compute G(v) and G(l).  These equations directly from Schlick 1994
        //     (Though note, Schlick's notation is cryptic and confusing.)
        float g_v = NdotV / (NdotV*(1 - k) + k);
        float g_l = NdotL / (NdotL*(1 - k) + k);
        return g_v * g_l;
    }
    float3 schlickFresnel(float3 f0, float lDotH)
    {
        return f0 + (float3(1.0f, 1.0f, 1.0f) - f0) * pow(1.0f - lDotH, 5.0f);
    }
    float3 fresnelSchlickRoughness(float cosTheta, half3 F0, float roughness)
    {
        return F0 + (max(half3(roughness,roughness,roughness), F0) - F0) * pow(1.0 - cosTheta, 5.0);
    }   

    // This from Schlick 1994, modified as per Karas in SIGGRAPH 2013 "Physically Based Shading" course
    //
    // This function can be used for "G" in the Cook-Torrance model:  D*G*F / (4*NdotL*NdotV)
    float ggxSchlickMaskingTerm(float NdotL, float NdotV, float roughness)
    {
        // Karis notes they use alpha / 2 (or roughness^2 / 2)
        float k = roughness*roughness / 2;

        // Karis also notes they can use the following equation, but only for analytical lights
        //float k = (roughness + 1)*(roughness + 1) / 8; 

        // Compute G(v) and G(l).  These equations directly from Schlick 1994
        //     (Though note, Schlick's notation is cryptic and confusing.)
        float g_v = NdotV / (NdotV*(1 - k) + k);
        float g_l = NdotL / (NdotL*(1 - k) + k);

        // Return G(v) * G(l)
        return g_v * g_l;
    }

    float3 ggxDirect(half3 lightDirection ,half3 lightcolor ,float3 N, float3 V,
                  float3 spec, float rough)
    {
        float3 lightIntensity = lightcolor;
        float3 L = lightDirection;

        // Compute our lambertion term (N dot L)
        float NdotL = saturate(dot(N, L));

        // Compute half vectors and additional dot products for GGX
        float3 H = normalize(V + L);
        float NdotH = saturate(dot(N, H));
        float LdotH = saturate(dot(L, H));
        float NdotV = saturate(dot(N, V));
        rough += 0.005;
        // Evaluate terms for our GGX BRDF model
        float  D = ggxNormalDistribution(NdotH, rough);
        float  G = ggxSchlickMaskingTerm(NdotL, NdotV, rough );
        float3 F = F_Schlick(LdotH,spec);

        // Evaluate the Cook-Torrance Microfacet BRDF model
        //     Cancel NdotL here to avoid catastrophic numerical precision issues.
        float3 ggxTerm = D * G * F / (4 * NdotV + 0.0005 /* * NdotL */);

        //return F;
        // Compute our final color (combining diffuse lobe plus specular GGX lobe)
        return lightIntensity * ( /* NdotL * */ ggxTerm);

    }


// vec4 shade(vec3 albedo,float metallic, float roughness,in vec3 WorldPos,in vec3 dir){
//         float ao = 1.0;
// 		vec3 Lo = vec3(0.0);
//     	vec3 N = estimateNormal(WorldPos);
//     	vec3 V = normalize(-dir);
//         vec3 R = reflect(-V, N); 

        
//         vec3 F0 = vec3(0.04); 
// 			F0 = mix(F0, albedo, metallic);
       
//         for(int i = 0; i < 1; ++i) 
//         {
//             vec3 L = normalize(lightPositions[i] - WorldPos);
//             vec3 H = normalize(V + L);
//             float distance = length(lightPositions[i] - WorldPos);
//             float attenuation = 1.0 / (distance * distance);
//             vec3 radiance = vec3(1.,1.,1.) * attenuation;
            
//             // Cook-Torrance BRDF
//             float NDF = DistributionGGX(N, H, roughness);
//             float G   = GeometrySmith(N, V, L, roughness);  
//             vec3 F    = fresnelSchlick(max(dot(H, V), 0.0), F0);
//             vec3 nominator    = NDF * G * F;
//             float denominator = 4. * max(dot(N, V), 0.0) * max(dot(N, L), 0.0) + 0.001; // 0.001 to prevent divide by zero.
//             vec3 specular = nominator / denominator;

//             vec3 kS = F;
//             vec3 kD = vec3(1.0) - kS;
//             kD *= 1.0 - metallic;
//             float NdotL = max(dot(N, L), 0.0);
//             Lo += (kD * albedo / PI + specular) * radiance * NdotL;
//         }
        
//         vec3 F = fresnelSchlickRoughness(max(dot(N, V), 0.0), F0, roughness); 
//         vec3 kS = F;
//         vec3 kD = 1.0 - kS;
//         vec3 irradiance =  sample_equirectangular_map(N,iChannel2,0.0).rgb;
//         vec3 diffuse    = irradiance * albedo;

//         // sample both the pre-filter map and the BRDF lut and combine them together as per the Split-Sum approximation to get the IBL specular part.
//         vec3 prefilteredColor = sample_equirectangular_map(R,iChannel1,0.0).rgb;   
//        	vec2 brdf  = texture(iChannel0, vec2(max(dot(N, V), 0.0), roughness)).rg;
//     	vec3 specular = prefilteredColor * (F * brdf.x + brdf.y);
        
//         vec3 ambient = (kD * diffuse + specular) * ao;
 
//         vec3 color = ambient + Lo;
//         return vec4(color,1.0);
// }

#endif