#ifndef JDMSTYLE_LAYERING
#define JDMSTYLE_LAYERING

    #ifdef CUSTOM_BATCH
        uniform half4 _DetailColor00;
        uniform half4 _DetailColor01;
        uniform half4 _DetailColor02;
        uniform half4 _DetailColor03;

        uniform half4 _Detail00_ST;
        uniform half4 _Detail01_ST;
        uniform half4 _Detail02_ST;
        uniform half4 _Detail03_ST;
    #endif

    // #ifdef _DETAIL_TEXTURE_ENABLE
        TEXTURE2D(_DetailTextureMap);
    // #endif

    static float tolerance = 0.1;
    half3 DetailTexturing(half3 input,half idmask,half2 uv ){
        half layer = idmask;
        half3 output = input;
        half2 uvTrans = 0;
        half map = 0;
        if (layer > 1.0 - tolerance) 
        {

        }
        else 
        if ((layer <= 0.75 + tolerance) && (layer > 0.75 - tolerance)) 
        {//0.75
            uvTrans = uv * _Detail00_ST.xy + _Detail00_ST.zw;
            map = _DetailTextureMap.Sample(sampler_LinearRepeat, uvTrans).r; 
            output = lerp(input,map * _DetailColor00,map);
        }
        else if ((layer <= 0.5 + tolerance) && (layer > 0.5 - tolerance))
         {//0.5
            uvTrans = uv * _Detail01_ST.xy + _Detail01_ST.zw;
            map = _DetailTextureMap.Sample(sampler_LinearRepeat, uvTrans).g; 
            output = lerp(input,map * _DetailColor01,map);
        }
        else if ((layer <= 0.25 + tolerance) && (layer > 0.25 - tolerance)) 
        {//0.25
            uvTrans = uv * _Detail02_ST.xy + _Detail02_ST.zw;
            map = _DetailTextureMap.Sample(sampler_LinearRepeat, uvTrans).b; 
            output = lerp(input,map * _DetailColor02,map);
        }
        else 
        {//0
            uvTrans = uv * _Detail03_ST.xy + _Detail03_ST.zw;
            map = _DetailTextureMap.Sample(sampler_LinearRepeat, uvTrans).a; 
            output = lerp(input,map * _DetailColor03,map);
        }
        return output;
    }



#endif