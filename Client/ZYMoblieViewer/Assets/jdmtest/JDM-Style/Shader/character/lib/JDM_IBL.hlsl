#ifndef INCLUDE_JDMSTYLE_ENVIRONMENT
#define INCLUDE_JDMSTYLE_ENVIRONMENT

    // -------------------------------------
    // constant buffer struct
    // -------------------------------------
    cbuffer JDMGlobalParams{
        // #ifdef _MATCAP_ENABLE
             half4 _MatcapWeight; // x = weight, y = frontlight,z = highlight,w = reflection
        // #endif

        // #ifdef _IRIDESCENCE_ENABLE
             float _CharacterIridescenceWeight;
        // #endif

        // #ifdef _ENVIRONMENT_ENABLE
             half _CharacterEnvironmentWeight;
             half _CharacterDirectWeight;
             half _CharacterFrontLightWeight;
             half4 _CharacterEnvironmentTint;
        // #endif

        // #ifdef _FOG_ENABLE
            half4 _CharacterFogColor = half4(1,1,1,1);
            half4 _CharacterFogWeight;// x = start , y = end , z = weight
        // #endif
    };

    // -------------------------------------
    // Texture Packaging function
    // -------------------------------------
    #ifdef _IRIDESCENCE_ENABLE
        TEXTURE2D(_IridescenceRamp);
    #endif
  
    half3 IridescenceRaddiance(InputData inputData,SurfaceData surfaceData,ExternData exData){
        half3 iridescence = 0;
        #ifdef _IRIDESCENCE_ENABLE
            half nv = saturate(dot(inputData.normalWS,inputData.viewDirectionWS));
            iridescence = _IridescenceRamp.Sample(sampler_LinearClamp,nv).rgb ;
            iridescence *= exData.iridescence;
        #endif
        return iridescence;
    }
    // -------------------------------------
    // Matcap function
    // -------------------------------------
    #ifdef _MATCAP_ENABLE
        half2 GetMatcapUV(half3 positionVS,half3 normalWS){
            positionVS = - positionVS;
            half3 normalVS = mul(UNITY_MATRIX_V,float4(normalWS,0)).xyz;
            half3 tangentVS = cross(-positionVS,half3(0,1,0));
            half3 binormalVS = cross(positionVS,tangentVS);

            half2 matcapUV = half2(dot(tangentVS,normalVS),dot(binormalVS,normalVS)) * 0.495 + 0.5;
            
            return matcapUV;
        }
    #endif

    // -------------------------------------
    // Octahedral Mapping Function
    // -------------------------------------
    #ifdef _ENVIRONMENT_ENABLE
        TEXTURE2D(_Envtex);
        SAMPLER(sampler_Envtex);
        inline half2 OctahedralMapping(half3 inputVector){
            half2 output = 0;
            half3 n = abs(inputVector.x) +abs(inputVector.y)+abs(inputVector.z);
            output.xy = inputVector.xy * (1/n.xy);
            if(inputVector.z < 0 ){
                output = (1.0 - abs(output.yx)) * sign(output.xy);
            }
            output.xy += 1;
            output.xy /= 2;

            return output.xy;
        }

        half4 SampleOctaheral_Diffuse(half3 normalWS){
            half2 octahedralUV = (OctahedralMapping(normalWS))/2;
            half4 hdri = _Envtex.SampleLevel(sampler_Envtex,octahedralUV,0);
            return hdri * _CharacterEnvironmentTint * _CharacterEnvironmentWeight;
        }
        half4 SampleOctaheral_Reflect(half3 reflectWS,half mip){
            half2 octahedralUV = (OctahedralMapping(reflectWS) + half2(1,0))/2;
            half4 hdri = _Envtex.SampleLevel(sampler_Envtex,octahedralUV,mip);
            return hdri * _CharacterEnvironmentTint * _CharacterEnvironmentWeight;
        }
        half4 SampleOctaheral_Refract(half3 refractWS,half mip){
            half2 octahedralUV = (OctahedralMapping(refractWS) + half2(1,0))/2;
            half4 hdri = _Envtex.SampleLevel(sampler_Envtex,octahedralUV,mip);
            return hdri * _CharacterEnvironmentTint * _CharacterEnvironmentWeight;
        }
        half4 SampleOctaheral_SSS(half3 normalWS){
            half2 octahedralUV = (OctahedralMapping(normalWS) + half2(0,1))/2;
            half4 hdri = _Envtex.SampleLevel(sampler_Envtex,octahedralUV,0);
            return hdri * _CharacterEnvironmentTint * _CharacterEnvironmentWeight;
        }
        half4 SampleOctaheral_Velvet(half3 reflectWS,half gamma){
            half2 octahedralUV = (OctahedralMapping(reflectWS) + half2(1,1))/2;
            half4 hdri = _Envtex.SampleLevel(sampler_Envtex,octahedralUV,0);
            return pow(saturate(hdri),gamma) * _CharacterEnvironmentTint * _CharacterEnvironmentWeight;
        }
    #endif

    // -------------------------------------
    // FOG Function
    // -------------------------------------
    //vertex function
    float FogGeneration(float3 positionVS){
        float output = 0;
        #ifdef _FOG_ENABLE
            float depth = positionVS.z;
            float fog = (_CharacterFogWeight.x - depth) / (_CharacterFogWeight.x - _CharacterFogWeight.y);
            fog = saturate(fog);
            fog *= _CharacterFogColor.a * _CharacterFogWeight.z;
            output = fog;
        #endif
        return output;
    }
    //fragment function
    half3 FogBlending(half3 color,half dist){
        half3 output = color;

        #ifdef _FOG_ENABLE
            half3 c = lerp(color,_CharacterFogColor.rgb,dist);
            output = c; 
        #endif

        return output;
    }

#endif