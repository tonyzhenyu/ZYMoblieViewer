#ifndef INCLUDE_ENV_PASS
#define INCLUDE_ENV_PASS          

    uniform half4 _DetailColor00;
    uniform half4 _DetailColor01;
    uniform half4 _DetailColor02;
    uniform half4 _DetailColor03;

    uniform half4 _Detail00_ST;
    uniform half4 _Detail01_ST;
    uniform half4 _Detail02_ST;
    uniform half4 _Detail03_ST;

    #include "../lib/JDM_UnityInput.hlsl"
    #include "../lib/JDM_IBL.hlsl"
    #include "../lib/JDM_Layering.hlsl"
    #include "../lib/JDM_Lighting.hlsl"

    struct Attributes{
        float4 positionOS : POSITION;
        half2 uv : TEXCOORD0;
        half2 uv1 : TEXCOORD1;
        float3 normal : NORMAL;
        float4 tangent : TANGENT;
        float4 color : COLOR;
    };
    struct FragmentOutput{
        half4 color : SV_Target0;
        half4 emission : SV_Target1;
    };
    struct Varyings{
        half4 uv : TEXCOORD0;
        
        float4 positionCS : SV_POSITION;
        float3 positionWS : TEXCOORD4;
        half3 positionVS : TEXCOORD7;

        half3 normalWS : TEXCOORD1;
        half3 tangentWS : TEXCOORD2;
        half3 biTangent : TEXCOORD3;

        half3 vertexLighting: TEXCOORD5;
        half3 viewDirectionWS:TEXCOORD6;
        float4 fog : TEXCOORD8;
    };

    cbuffer UnityPerMaterial{
        half4 _BaseMap_ST;
        half4 _BaseColor;
        half _BumpScale;
        half _Occlusion;
        half _Smoothness;
    };

    Texture2D _BaseMap;
    Texture2D _BumpMap;
    Texture2D _PBRMap;
    Texture2D _LightMap;

    Texture2D _EnvReflectMap;
    Texture2D _EnvDiffuseMap;

    sampler sampler_BaseMap;
    sampler sampler_LightMap;


    Varyings vert(Attributes input)
    {
        Varyings output = (Varyings)0;

        output.positionWS = mul(UNITY_MATRIX_M,input.positionOS).xyz;
        output.positionCS = mul(UNITY_MATRIX_MVP,input.positionOS);

        output.normalWS = mul(UNITY_MATRIX_M,input.normal);

        real sign = input.tangent.w * GetOddNegativeScale();
        float3 normalWS = TransformObjectToWorldNormal(input.normal);
        float3 tangentWS = TransformObjectToWorldDir(input.tangent);
        float3 bitangentWS = cross(normalWS, tangentWS) * sign;

        float3 viewDirectionWS = UNITY_CAM_POS - output.positionWS;
        output.viewDirectionWS = viewDirectionWS;

        output.uv.xy = input.uv * _BaseMap_ST.xy + _BaseMap_ST.zw;
        output.uv.zw = input.uv1;

        float3 positionVS = mul(UNITY_MATRIX_V , -float4(output.positionWS,1));
        output.positionVS = positionVS;
        return output;
    }

    float3 hdrremap(float3 input){
        return input / (1-input + 0.01);
    }
    float3 sdrRemap(float3 input){
        
        return input / (1+input );
    }

    float4 frag(Varyings input) :SV_Target0{

        input.fog.x = FogGeneration(input.positionVS.xyz);

        half4 basemap = _BaseMap.Sample(sampler_BaseMap,input.uv.xy);
        half4 mixmap = _PBRMap.Sample(sampler_BaseMap,input.uv.xy);

        half4 lm = _LightMap.Sample(sampler_LightMap,input.uv.zw);

            half3 normalTS = UnpackNormalScale(_BumpMap.Sample(sampler_BaseMap, input.uv),_BumpScale);

        InputData inputData = (InputData)0;
        inputData.normalWS = normalize(normalTS.x * input.tangentWS + normalTS.y * input.biTangent + normalTS.z * input.normalWS);
        inputData.viewDirectionWS = normalize(input.viewDirectionWS);
        inputData.positionWS = input.positionWS;
        //inputData.shadowCoord = input.shadowCoord;
        //inputData.vertexLighting = input.vertexLighting;

        SurfaceData surfaceData = (SurfaceData)0;
        surfaceData.albedo = basemap.rgb * _BaseColor.rgb;
        surfaceData.occlusion =lerp( 1,mixmap.r,_Occlusion) *_Occlusion;
        surfaceData.smoothness = lerp( mixmap.g,1,_Smoothness);
        surfaceData.metallic = mixmap.b;
        surfaceData.alpha = basemap.a;


        float3 perfectNormal = normalize(mul(UNITY_MATRIX_V,float4(inputData.normalWS,0)).xyz);
        float3 reflDirWS = normalize(reflect(-inputData.viewDirectionWS,inputData.normalWS));

        float2 refUV = OctahedralMapping(reflDirWS);
        float2 difUV = OctahedralMapping(perfectNormal);

        half nv = saturate(dot(inputData.normalWS,inputData.viewDirectionWS));
        float3 refractWS = normalize(refract(-inputData.viewDirectionWS,inputData.normalWS,0.95));
        half3 F0 = lerp(0.04,surfaceData.albedo,surfaceData.metallic) ;
        half3 F = fresnelSchlickRoughness(1,F0  ,surfaceData.smoothness) ;
        half3 kD = (1-F) * (1 - surfaceData.metallic) ;

        half envMip = ComputeEnvMapMipFromRoughness(surfaceData.smoothness);

        half4 hdri_reflect =    _EnvReflectMap.SampleLevel(sampler_LightMap,refUV,envMip);
        half4 hdri_diffuse =    _EnvDiffuseMap.Sample(sampler_LightMap,difUV);

        half3 envSpecular = hdri_reflect.rgb * EnvBRDF(F, surfaceData.smoothness, nv) ;
        half3 envDiffuse = kD * surfaceData.albedo * hdri_diffuse.rgb ;


        half3 radiance = 0;

        half3 bakeGI = kD * lm * surfaceData.albedo;
        radiance += (bakeGI + (envDiffuse + envSpecular)/2) * surfaceData.occlusion;
        //radiance = sdrRemap(radiance);
        radiance = radiance;
        radiance = FogBlending(radiance,input.fog.x);

        half4 finnalColor = half4(radiance,1);

        return finnalColor;
    }

#endif