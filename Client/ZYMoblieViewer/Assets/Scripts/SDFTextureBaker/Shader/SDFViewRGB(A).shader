Shader "Hiden/SDFViewRGB(A)"
{
    properties{
        [PerRendererData] _MainTex ("Texture (RGB)", 2D) = "white" {}
    }
    SubShader
    {            
        Pass
        {
            ZWrite on
            cull off
            Blend SrcAlpha OneMinusSrcAlpha

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            Texture2D _MainTex;
            Texture2D _SecTex;

            sampler sampler_MainTex;

                float4x4 unity_MatrixVP;
                float4x4 unity_ObjectToWorld;

            cbuffer UnityPerMaterial {
                float4 _MainTex_ST;

                float _minValue;
                float _maxValue;
            }

            struct Attributes{
                float4 positionOS : POSITION;
                float2 uv : TEXCOORD0;
                float4 color : COLOR;
            };
            struct Varyings{
                float4 positionCS : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 positionWS : TEXCOORD4;
                float4 color : TEXCOORD1;
            };

            Varyings vert(Attributes input)
            {
                Varyings output = (Varyings)0;
                output.positionWS = input.positionOS.xyz;

                matrix mvp = mul(unity_MatrixVP, unity_ObjectToWorld);
                output.positionCS = mul(mvp,input.positionOS);
                output.uv = input.uv.xy * _MainTex_ST.xy + _MainTex_ST.zw;
                output.color = input.color.rgba ;
                return output;
            }
            float4 frag(Varyings input) : SV_Target
            {
                float4 baseColor = _MainTex.Sample(sampler_MainTex,input.uv).rgba * input.color.rgba;
                float4 finnalColor = smoothstep(_minValue,_maxValue,baseColor.a);

                return 1-finnalColor;
            }
            ENDHLSL
        }
    }
}
