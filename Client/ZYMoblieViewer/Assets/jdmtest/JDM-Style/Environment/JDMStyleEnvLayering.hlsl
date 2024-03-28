#ifndef JDMSTYLE_ENV_LAYERING
#define JDMSTYLE_ENV_LAYERING

    #ifdef DONOT_BATCH
    //Material Layers Properties
    half4 _NormalOpacityTexture_1_ST;
    half4 _NormalOpacityTexture_2_ST;
    half4 _NormalOpacityTexture_3_ST;
    half4 _NormalOpacityTexture_4_ST;
    half4 _NormalOpacityTexture_5_ST;

    half _BumpScale_1;
    half _BumpScale_2;
    half _BumpScale_3;
    half _BumpScale_4;
    half _BumpScale_5;

    half _MatcapWeight_01;
    half _MatcapWeight_02;

    #endif

    
    TEXTURE2D(_IDTexture);
    TEXTURE2D(_NormalOpacityTexture_1);
    TEXTURE2D(_NormalOpacityTexture_2);
    TEXTURE2D(_NormalOpacityTexture_3);
    TEXTURE2D(_NormalOpacityTexture_4);
    TEXTURE2D(_NormalOpacityTexture_5);

    // TEXTURE2D(_Matcap_02);
    static half tolerance = 0.1;

    half3 NormalDetailLayering(half3 normalTS,half2 uv ){
        
        half3 layer = _IDTexture.Sample(sampler_LinearRepeat, uv).rgb;

        if (layer.x > 1.0 - tolerance) {
        }

        else 
        if ((layer.x <= 0.8 + tolerance) && (layer.x > 0.8 - tolerance)) {//0.8
            half2 uvTrans = TRANSFORM_TEX(uv, _NormalOpacityTexture_5);
            half4 NO = _NormalOpacityTexture_5.Sample(sampler_LinearRepeat, uvTrans); 
            half3 normalNew = UnpackNormalScale(NO, _BumpScale_5);
            normalTS = normalize(half3(normalTS.xy + normalNew.xy, normalTS.z*normalNew.z)); 
        }
        else if ((layer.x <= 0.6 + tolerance) && (layer.x > 0.6 - tolerance)) {//0.6
            half2 uvTrans = TRANSFORM_TEX(uv, _NormalOpacityTexture_4);
            half4 NO = _NormalOpacityTexture_4.Sample(sampler_LinearRepeat, uvTrans); 
            half3 normalNew = UnpackNormalScale(NO, _BumpScale_4);
            normalTS = normalize(half3(normalTS.xy + normalNew.xy, normalTS.z*normalNew.z));
        }
        else if ((layer.x <= 0.4 + tolerance) && (layer.x > 0.4 - tolerance)) {
            half2 uvTrans = TRANSFORM_TEX(uv, _NormalOpacityTexture_3);
            half4 NO = _NormalOpacityTexture_3.Sample(sampler_LinearRepeat, uvTrans); 
            half3 normalNew = UnpackNormalScale(NO, _BumpScale_3);
            normalTS = normalize(half3(normalTS.xy + normalNew.xy, normalTS.z*normalNew.z));
        }
        else if ((layer.x <= 0.2 + tolerance) && (layer.x > 0.2 - tolerance)) {
            half2 uvTrans = TRANSFORM_TEX(uv, _NormalOpacityTexture_2);
            half4 NO = _NormalOpacityTexture_2.Sample(sampler_LinearRepeat, uvTrans); 
            half3 normalNew = UnpackNormalScale(NO, _BumpScale_2);
            normalTS = normalize(half3(normalTS.xy + normalNew.xy, normalTS.z*normalNew.z));
        }
        else {
            half2 uvTrans = TRANSFORM_TEX(uv, _NormalOpacityTexture_1);
            half4 NO = _NormalOpacityTexture_1.Sample(sampler_LinearRepeat, uvTrans); 
            half3 normalNew = UnpackNormalScale(NO, _BumpScale_1);
            normalTS = normalize(half3(normalTS.xy + normalNew.xy, normalTS.z*normalNew.z));
        }

        return normalTS;
    }

    half3 ColorDetailLayering(half3 color,half2 uv ){
        
        half3 layer = _IDTexture.Sample(sampler_LinearRepeat, uv).rgb;

        if (layer.x > 1.0 - tolerance) {
        }

        else 
        if ((layer.x <= 0.8 + tolerance) && (layer.x > 0.8 - tolerance)) {//0.8
            half2 uvTrans = TRANSFORM_TEX(uv, _NormalOpacityTexture_5);
            half4 NO = _NormalOpacityTexture_5.Sample(sampler_LinearRepeat, uvTrans); 
            color = lerp(color,NO,_BumpScale_5 * NO.a);
        }
        else if ((layer.x <= 0.6 + tolerance) && (layer.x > 0.6 - tolerance)) {//0.6
            half2 uvTrans = TRANSFORM_TEX(uv, _NormalOpacityTexture_4);
            half4 NO = _NormalOpacityTexture_4.Sample(sampler_LinearRepeat, uvTrans); 
            color = lerp(color,NO ,_BumpScale_4 * NO.a);
        }
        else if ((layer.x <= 0.4 + tolerance) && (layer.x > 0.4 - tolerance)) {
            half2 uvTrans = TRANSFORM_TEX(uv, _NormalOpacityTexture_3);
            half4 NO = _NormalOpacityTexture_3.Sample(sampler_LinearRepeat, uvTrans); 
            color = lerp(color,NO ,_BumpScale_3 * NO.a);
        }
        else if ((layer.x <= 0.2 + tolerance) && (layer.x > 0.2 - tolerance)) {
            half2 uvTrans = TRANSFORM_TEX(uv, _NormalOpacityTexture_2);
            half4 NO = _NormalOpacityTexture_2.Sample(sampler_LinearRepeat, uvTrans); 
            color = lerp(color,NO ,_BumpScale_2 * NO.a);
        }
        else {
            half2 uvTrans = TRANSFORM_TEX(uv, _NormalOpacityTexture_1);
            half4 NO = _NormalOpacityTexture_1.Sample(sampler_LinearRepeat, uvTrans); 
            color = lerp(color,NO  ,_BumpScale_1 * NO.a);
        }

        return color;
    }



#endif