Shader "Hidden/InterpolationVertexPosition"
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
                "LightMode" = "UniversalForward" 
            }
            ZWrite off
            cull off
            ZTest off
            Blend one one
            
            
            HLSLPROGRAM
            
            #pragma vertex vert
            #pragma fragment frag
            
            #include "InterpolationVertexPositionPass.hlsl"
            ENDHLSL
        }
    }
}
