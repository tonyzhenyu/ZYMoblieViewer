#ifndef INCLUDE_DEBUG_PASS
#define INCLUDE_DEBUG_PASS            
 
        #include "../lib/JDM_UnityInput.hlsl"
        #include "../lib/JDM_IBL.hlsl"
        struct Attributes{
            float4 positionOS : POSITION;
            half2 uv : TEXCOORD0;
            float3 normal : NORMAL;
            float4 tangent : TANGENT;
        };
        struct FragmentOutput{
            half4 color : SV_Target0;
            half4 emission : SV_Target1;
        };
        struct Varyings{
            float4 positionCS : SV_POSITION;
            half2 uv : TEXCOORD0;
            float3 positionWS : TEXCOORD4;
            half3 normalWS : TEXCOORD1;
            half3 tangentWS : TEXCOORD2;
            half3 biTangent : TEXCOORD3;
            half3 vertexLighting: TEXCOORD5;
            half3 viewDirectionWS:TEXCOORD6;
            half3 positionVS : TEXCOORD7;
        };
        Varyings vert(Attributes input)
        {
            Varyings output = (Varyings)0;

            output.positionWS = mul(UNITY_MATRIX_M,input.positionOS).xyz;
            output.positionCS = mul(UNITY_MATRIX_MVP,input.positionOS);

            return output;
        }
        float4 frag(Varyings input) :SV_Target0{
            return 1;
        }

#endif