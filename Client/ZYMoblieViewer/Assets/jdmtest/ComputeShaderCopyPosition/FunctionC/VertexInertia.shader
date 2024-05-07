Shader "Hidden/VertexInertia2022"
{
    properties
    {
        _Speed("Speed",float) = 1
    }
    SubShader
    {
        Pass
        {
            Tags{
                "LightMode" = "Always" 
            }
            ZWrite on
            cull off
            ZTest lequal
            Blend one zero
            
            
            HLSLPROGRAM
            
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 5.0
            #include "VertexInertiaPass.hlsl"
            ENDHLSL
        }
    }
}
