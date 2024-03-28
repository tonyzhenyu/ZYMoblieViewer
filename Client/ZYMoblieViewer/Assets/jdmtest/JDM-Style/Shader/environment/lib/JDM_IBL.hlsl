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
    // Octahedral Mapping Function
    // -------------------------------------

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