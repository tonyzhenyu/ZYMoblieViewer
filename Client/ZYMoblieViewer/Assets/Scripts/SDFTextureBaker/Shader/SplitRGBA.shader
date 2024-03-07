Shader "Hiden/SplitRGBA"
{
    properties{
        [PerRendererData] _MainTex ("Texture (RGB)", 2D) = "white" {}
        [PerRendererData] _SecTex ("Texture (Alpha)", 2D) = "white" {}
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
            sampler sampler_SecTex;

                float4x4 unity_MatrixVP;
                float4x4 unity_ObjectToWorld;

            cbuffer UnityPerMaterial {
                float4 _MainTex_ST;
            }

            struct Attributes{
                float4 positionOS : POSITION;
                float2 uv : TEXCOORD0;
            };
            struct Varyings{
                float4 positionCS : SV_POSITION;
                float2 uv : TEXCOORD0;
            };

            Varyings vert(Attributes input)
            {
                Varyings output = (Varyings)0;
                output.positionCS = mul(mul(unity_MatrixVP, unity_ObjectToWorld),input.positionOS);
                output.uv = input.uv.xy ;
                return output;
            }
            float4 frag(Varyings input) : SV_Target
            {
                float4 baseColor = _MainTex.Sample(sampler_MainTex,input.uv).rgba;
                float4 alpha = _SecTex.Sample(sampler_SecTex,input.uv).rgba;
                float a = (alpha.r + alpha.g + alpha.b )/3;
                float4 finnalColor = float4(baseColor.rgb,a);
                return finnalColor;
            }
            ENDHLSL
        }
    }
}
