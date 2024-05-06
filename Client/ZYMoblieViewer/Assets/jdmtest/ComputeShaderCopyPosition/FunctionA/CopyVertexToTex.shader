Shader "Hidden/CopyVertexToTex"
{
    properties
    {

    }
    SubShader
    {
        Pass
        {
            Tags{
                "LightMode" = "UniversalForward" 
            }
            ZWrite on
            cull off
            ZTest off
            Blend one one
            
            
            HLSLPROGRAM
            
            #pragma vertex vert
            #pragma fragment frag
            
            #include "CopyVertexToTexPass.hlsl"
            ENDHLSL
        }
    }
}
