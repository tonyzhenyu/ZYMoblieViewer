#ifndef JDMSTYLE_LAYERING
#define JDMSTYLE_LAYERING

    // #ifdef _DETAIL_TEXTURE_ENABLE
        Texture2D _DetailTextureMap;
        sampler sampler_DetailTextureMap;

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
            map = _DetailTextureMap.Sample(sampler_DetailTextureMap, uvTrans).r; 
            output = lerp(input,map * _DetailColor00.rgb,map * _DetailColor00.a).rgb;
        }
        else if ((layer <= 0.5 + tolerance) && (layer > 0.5 - tolerance))
         {//0.5
            uvTrans = uv * _Detail01_ST.xy + _Detail01_ST.zw;
            map = _DetailTextureMap.Sample(sampler_DetailTextureMap, uvTrans).g; 
            output = lerp(input,map * _DetailColor01.rgb,map * _DetailColor01.a).rgb;
        }
        else if ((layer <= 0.25 + tolerance) && (layer > 0.25 - tolerance)) 
        {//0.25
            uvTrans = uv * _Detail02_ST.xy + _Detail02_ST.zw;
            map = _DetailTextureMap.Sample(sampler_DetailTextureMap, uvTrans).b; 
            output = lerp(input,map * _DetailColor02.rgb,map * _DetailColor02.a).rgb;
        }
        else 
        {//0
            uvTrans = uv * _Detail03_ST.xy + _Detail03_ST.zw;
            map = _DetailTextureMap.Sample(sampler_DetailTextureMap, uvTrans).a; 
            output = lerp(input,map * _DetailColor03.rgb,map * _DetailColor03.a).rgb;
        }
        return output;
    }



#endif