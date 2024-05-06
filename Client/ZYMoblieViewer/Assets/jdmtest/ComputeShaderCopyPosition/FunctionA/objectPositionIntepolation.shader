Shader "Hidden/objectPositionIntepolation"
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
            ZWrite on
            cull off
            ZTest lequal
            Blend one zero
            
            
            HLSLPROGRAM
            
            #pragma vertex vert
            #pragma fragment frag
            
            #include "objectPositionIntepolationPass.hlsl"
            ENDHLSL
        }
    }
}
