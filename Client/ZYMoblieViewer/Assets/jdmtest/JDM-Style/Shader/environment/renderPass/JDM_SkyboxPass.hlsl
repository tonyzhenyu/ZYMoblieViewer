#ifndef INCLUDE_ENV_PASS
#define INCLUDE_ENV_PASS           

    #include "../lib/JDM_UnityInput.hlsl"
    #include "../lib/JDM_IBL.hlsl"
    struct Attributes{
        float4 positionOS : POSITION;
        half2 uv : TEXCOORD0;
        float3 normal : NORMAL;
        float4 color : COLOR;
    };
    struct FragmentOutput{
        half4 color : SV_Target0;
        half4 emission : SV_Target1;
    };
    struct Varyings{
        half2 uv : TEXCOORD0;
        
        float4 positionCS : SV_POSITION;
        float3 positionWS : TEXCOORD4;
        half3 positionVS : TEXCOORD7;
        half3 normalWS : TEXCOORD1;
        half3 viewDirectionWS : TEXCOORD2;
        half4 fog: TEXCOORD3;// x,y
    };

    cbuffer UnityPerMaterial{
        half4 _BaseMap_ST;
        half4 _BaseColor;
        half3 _Rotation;
        half _Horizon;
    };

    Texture2D _BaseMap;
    sampler sampler_BaseMap;
    
    half3x3 GetRotationMatrix(float3 input){
                
        half3x3 rotateX;
        rotateX[0] = half3(1,0,0);
        rotateX[1] = half3(0,cos(input.x),-sin(input.x));
        rotateX[2] = half3(0,sin(input.x),cos(input.x));

        half3x3 rotateY;
        rotateY[0] = half3(cos(input.y),0,sin(input.y));
        rotateY[1] = half3(0,1,0);
        rotateY[2] = half3(-sin(input.y),0,cos(input.y));

        half3x3 rotateZ;
        rotateZ[0] = half3(cos(input.z),-sin(input.z),0);
        rotateZ[1] = half3(sin(input.z),cos(input.z),0);
        rotateZ[2] = half3(0,0,1);
        
        return mul(mul(rotateX,rotateY),rotateZ);
    }
    float3 sdrRemap(float3 input){
        
        return input / (1+input );
    }
    Varyings vert(Attributes input)
    {
        Varyings output = (Varyings)0;

        output.positionWS = mul(UNITY_MATRIX_M,input.positionOS).xyz;
        output.positionCS = mul(UNITY_MATRIX_MVP,input.positionOS);
        float3 viewDirectionWS = UNITY_CAM_POS - output.positionWS;
        output.viewDirectionWS = viewDirectionWS;
        output.normalWS = mul(UNITY_MATRIX_M,input.normal);
        output.normalWS = mul(GetRotationMatrix(_Rotation),input.normal);

        output.uv.xy = input.uv ;

        output.positionVS = mul(UNITY_MATRIX_V , -float4(output.positionWS,1));
        output.fog.x = FogGeneration(output.positionVS.xyz);
        
        return output;
    }

    float3 hdrremap(float3 input){
        return input / (1-input + 0.01);
    }

    float4 frag(Varyings input) :SV_Target0{

        
        half2 octUV = OctahedralMapping(normalize(input.normalWS));

        half4 basemap = _BaseMap.SampleLevel(sampler_BaseMap,octUV,0);
        basemap.xyz =  hdrremap(basemap.xyz).xyz;

        half3 radiance = 0;

        radiance = basemap;
        radiance = sdrRemap(radiance);
        input.fog.y = FogGeneration(input.viewDirectionWS.y * _Horizon + _Horizon);
        radiance= FogBlending(radiance,input.fog.y);
        radiance= FogBlending(radiance,input.fog.x);

        half4 finnalColor = half4(radiance,1);

        return finnalColor;
    }

#endif