#ifndef INCLUDE_JDMSTYLE_ENVIRONMENT
#define INCLUDE_JDMSTYLE_ENVIRONMENT

    // -------------------------------------
    // Octahedral Mapping Function
    // -------------------------------------
    half _CharacterEnvironmentWeight;
    half _CharacterDirectWeight;
    half _CharacterFrontLightWeight;

    half4 _CharacterEnvironmentTint;

    #ifdef _MATCAP_ENABLE
        half4 _MatcapWeight; // x = weight, y = frontlight,z = highlight,w = reflection
    #endif
    half2 OctahedralMapping(half3 inputVector){
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

    TEXTURE2D(_Envtex);
    SAMPLER(sampler_Envtex);
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
    half4 SampleOctaheral_Refract(half3 reflectWS,half mip){
        half2 octahedralUV = (OctahedralMapping(reflectWS) + half2(1,0))/2;
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


    uniform half4 _CharacterFogColor = half4(1,1,1,1);
    uniform half4 _CharacterFogWeight;// x = start , y = end , z = weight

    half3 FogBlending(half3 color,half3 positionws,half4 fogColor,half4 fogWeight){

        half depth = distance(_WorldSpaceCameraPos,positionws);// problem with screen effect

        half fog = (fogWeight.x - depth) / (fogWeight.x - fogWeight.y);

        half lerpWeight = saturate(fog) * fogWeight.z * fogColor.a;
        half3 c = lerp(color,fogColor.rgb,lerpWeight);
        return c;
    }

#endif