Shader "Hidden/VertexInertia"
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
            ZTest lequal
            Blend one zero
            
            
            HLSLPROGRAM
            
            #pragma vertex vert
            #pragma fragment frag
            
            #include "VertexInertiaPass.hlsl"
            ENDHLSL
        }
    }
}
