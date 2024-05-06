Shader "Hidden/CopyVertexToTex_Flatten"
{
    properties
    {
        _Width("Width",float) = 1
        _Height("Height",float) = 1
    }
    SubShader
    {
        Pass
        {
            Tags{
                "LightMode" = "UniversalForward" 
            }
            ZWrite on
            cull back
            ZTest LEqual
            Blend one zero
            
            
            HLSLPROGRAM
            
            #pragma vertex vert
            #pragma fragment frag
            
            #include "CopyVertexToTex_FlattenPass.hlsl"
            ENDHLSL
        }
    }
}
