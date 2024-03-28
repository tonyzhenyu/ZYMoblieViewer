#ifndef INCLUDE_JDM_POST_EFFEECT
#define INCLUDE_JDM_POST_EFFEECT

    #include "../dataStruct/JDM_ExternalData.hlsl"
    // -------------------------------------
    // FinnalColor Blending function
    // -------------------------------------
    half4 AlphaBlending(half3 raddiance,half alpha){
        half4 finnalColor = 0;
        #if defined(ALPHA_PREMULTIPLY) 
            finnalColor = half4(raddiance * alpha,alpha);
        #elif defined(ALPHA_PREMULTIPLY_INVERT)
            finnalColor = half4(lerp(1,raddiance, alpha) ,alpha);
        #else
            finnalColor = half4(raddiance,alpha);
        #endif
        return finnalColor;
    }
    // -------------------------------------
    // Post FX Function
    // -------------------------------------
    uniform half4 _FeverEmissionColor;

    half3 Fever(half3 input, half3 feverEmissionMap){
        #if _FEVER_ENABLE
            return lerp(input,_FeverEmissionColor.rgb, feverEmissionMap.r * _FeverEmissionColor.a);
        #else
            return input;
        #endif
    }

    // -------------------------------------
    // Post FX Function
    // -------------------------------------
    half4 MashUp(ExternData exData){
        half4 mashUp = SampleMashUpMap(exData.positionVS.xyz);
        return mashUp;
    }

    half3 JDMPostFX(half3 neutral,half4 mashUp,InputData inputData){
        half3 output = neutral;
        output = lerp(neutral,mashUp.rgb,mashUp.a);
        return output;
    }

    half3 JDMPixelToneMapping(half3 input){
        half3 neutral = NeutralTonemap(max(0,input));
        return neutral;
    }
    half3 JDMSkinPixelToneMapping(half3 input,half blendWeight){
        half3 neutral = NeutralTonemap(input);
        half3 x = neutral;
        x = pow(x,2) / (sqrt(x) + 0.0001);
        neutral = lerp(neutral,x,blendWeight);

        return neutral;
    }
#endif