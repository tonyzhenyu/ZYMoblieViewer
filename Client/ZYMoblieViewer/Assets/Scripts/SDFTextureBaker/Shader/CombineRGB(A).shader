Shader "Hiden/CombineRGBA"
{
    properties{
        [PerRendererData] _Tex0("_Tex0", 2D) = "black" {}
        [PerRendererData] _Tex1("_Tex1", 2D) = "black" {}
        [PerRendererData] _Tex2("_Tex2", 2D) = "black" {}
        [PerRendererData] _Tex3("_Tex3", 2D) = "white" {}
    }
    SubShader
    {            
        Pass
        {
            ZWrite on
            cull off
            Blend one one,one one

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            Texture2D _Tex0;
            Texture2D _Tex1;
            Texture2D _Tex2;
            Texture2D _Tex3;

            sampler sampler_Tex0;
            sampler sampler_Tex1;
            sampler sampler_Tex2;
            sampler sampler_Tex3;

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
                float r = _Tex0.Sample(sampler_Tex0,input.uv).r;
                float g = _Tex1.Sample(sampler_Tex0,input.uv).r;
                float b = _Tex2.Sample(sampler_Tex0,input.uv).r;
                float a = _Tex3.Sample(sampler_Tex0,input.uv).r;

                return float4(r,g,b,a);
            }
            ENDHLSL
        }
    }
}
