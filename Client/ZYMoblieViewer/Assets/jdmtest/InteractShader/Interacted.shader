Shader "Hidden/Interacted"
{
    properties
    {
        _position("positions",vector) = (0,0,0,0)
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
            #include "InteractedPass.hlsl"
            ENDHLSL
        }
    }
}
