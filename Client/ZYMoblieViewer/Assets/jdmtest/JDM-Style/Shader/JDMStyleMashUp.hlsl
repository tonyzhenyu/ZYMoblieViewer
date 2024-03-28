#ifndef INCLUDE_JDM_SYTLE_MASHUP
#define INCLUDE_JDM_SYTLE_MASHUP
  
    //#pragma multi_compile _ _MASH_UP_01 _MASH_UP_02

    // -------------------------------------
    // MashUp Parameters
    // -------------------------------------
    TEXTURE2D(_MashUpMaskMap);
    TEXTURE2D(_MashUpMap);
    SAMPLER(sampler_MashUpMap);
    half4 _MashUpParam;

        // maskMapParam.x = size;
        // maskMapParam.y = offset;
        // maskMapParam.z = width;
        // maskMapParam.w = softness;

    half4 _MashUpColor;

    // -------------------------------------
    // MashUp Function
    // -------------------------------------
    #if defined(_MASH_UP_01) 
        
        #define SAMPLE_MASHUP(input) SampleMashUpMap(input)
        half4 SampleMashUpMap(half3 input){
            
            half4 maskmap = _MashUpMaskMap.Sample(sampler_LinearRepeat,input.xy).rgba;
            half4 mashupMap = _MashUpMap.Sample(sampler_LinearRepeat,input.xy).rgba;

            half state = 1 - _MashUpColor.a;
            
            half alphaOutput = smoothstep(state,state + _MashUpParam.z,maskmap.a);

            half3 output = mashupMap.rgb * _MashUpColor.rgb;
            return half4(output,alphaOutput );
        }

    #elif defined(_MASH_UP_02)


        #define SAMPLE_MASHUP(input) SampleMashUpMap(input)
        half4 SampleMashUpMap(half3 input){
            
            half4 value = _MashUpMaskMap.Sample(sampler_LinearRepeat,input.xy).rgba;
            
            half3 output = _MashUpColor.rgb * value.rgb;
            half state = 1-_MashUpColor.a;
            
            half clipValue = smoothstep(state ,state + _MashUpParam.x,value.a);
            clip(clipValue - _MashUpParam.x * state);

            half mx = _MashUpParam.z - _MashUpParam.y;

            half ax = _MashUpParam.z + _MashUpParam.w ;
            half alphaOutput = 1 - smoothstep(state ,state + _MashUpParam.z,value.a - _MashUpParam.y * state);
            alphaOutput = saturate(pow(alphaOutput*2,1/_MashUpParam.w));
            return half4(output,alphaOutput );
        }
    #endif  

    #ifndef SAMPLE_MASHUP
    #define SAMPLE_MASHUP(input) SampleMashUpMap(input)
        half4 SampleMashUpMap(half3 input){
            return 0;
        }
    #endif
    
#endif