#ifndef INCLUDE_UNITY_INPUTS
#define INCLUDE_UNITY_INPUTS

    //-----------------------------------------------------
    // input scope
    //-----------------------------------------------------
    #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Common.hlsl"
    #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Packing.hlsl"

    // x = width
    // y = height
    // z = 1 + 1.0/width
    // w = 1 + 1.0/height
    float4 _ScreenParams;

    float3 _WorldSpaceCameraPos;
    // Time (t = time since current level load) values from Unity
    float4 _Time; // (t/20, t, t*2, t*3)
    float4 _SinTime; // sin(t/8), sin(t/4), sin(t/2), sin(t)
    float4 _CosTime; // cos(t/8), cos(t/4), cos(t/2), cos(t)
    float4 unity_DeltaTime; // dt, 1/dt, smoothdt, 1/smoothdt
    float4 _TimeParameters; // t, sin(t), cos(t)

    #define UNITY_MATRIX_M     unity_ObjectToWorld
    #define UNITY_MATRIX_I_M   unity_WorldToObject
    #define UNITY_MATRIX_V     unity_MatrixV
    #define UNITY_MATRIX_I_V   unity_MatrixInvV
    #define UNITY_MATRIX_P     OptimizeProjectionMatrix(glstate_matrix_projection)
    #define UNITY_MATRIX_I_P   unity_MatrixInvP
    #define UNITY_MATRIX_VP    unity_MatrixVP
    #define UNITY_MATRIX_I_VP  unity_MatrixInvVP
    #define UNITY_MATRIX_MV    mul(UNITY_MATRIX_V, UNITY_MATRIX_M)
    #define UNITY_MATRIX_T_MV  transpose(UNITY_MATRIX_MV)
    #define UNITY_MATRIX_IT_MV transpose(mul(UNITY_MATRIX_I_M, UNITY_MATRIX_I_V))
    #define UNITY_MATRIX_MVP   mul(UNITY_MATRIX_VP, UNITY_MATRIX_M)
    
    #define UNITY_CAM_POS      UNITY_MATRIX_I_V._14_24_34

    float4x4 glstate_matrix_projection;
    float4x4 unity_MatrixV;
    float4x4 unity_MatrixInvV;
    float4x4 unity_MatrixInvP;
    float4x4 unity_MatrixVP;
    float4x4 unity_MatrixInvVP;

    #define UNITY_PREV_MATRIX_M 0 
    #define UNITY_PREV_MATRIX_I_M 0
    // // Block Layout should be respected due to SRP Batcher
    CBUFFER_START(UnityPerDraw)

    // Space block Feature
    float4x4 unity_ObjectToWorld;
    float4x4 unity_WorldToObject;
    float4 unity_LODFade; // x is the fade value ranging within [0,1]. y is x quantized into 16 levels
    real4 unity_WorldTransformParams; // w is usually 1.0, or -1.0 for odd-negative scale transforms

    // // Light Indices block feature
    // // These are set internally by the engine upon request by RendererConfiguration.
    // real4 unity_LightData;
    // real4 unity_LightIndices[2];

    CBUFFER_END

    


    float4x4 OptimizeProjectionMatrix(float4x4 M)
    {
        // Matrix format (x = non-constant value).
        // Orthographic Perspective  Combined(OR)
        // | x 0 0 x |  | x 0 x 0 |  | x 0 x x |
        // | 0 x 0 x |  | 0 x x 0 |  | 0 x x x |
        // | x x x x |  | x x x x |  | x x x x | <- oblique projection row
        // | 0 0 0 1 |  | 0 0 x 0 |  | 0 0 x x |
        // Notice that some values are always 0.
        // We can avoid loading and doing math with constants.
        M._21_41 = 0;
        M._12_42 = 0;
        return M;
    }

    // -------------------------------------
    // snap function
    // -------------------------------------
    float Snap(float value,float increcement)
    {
        return floor(value / increcement) * increcement;
    }
    float2 Snap(float2 value,float2 increcement)
    {
        return floor(value / increcement) * increcement;
    }
    float3 Snap(float3 value,float3 increcement)
    {
        return floor(value / increcement) * increcement;
    }
    float4 Snap(float4 value,float4 increcement)
    {
        return floor(value / increcement) * increcement;
    }

    #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/SpaceTransforms.hlsl"

    struct Attributes{
        float4 positionOS : POSITION;
        half2 uv : TEXCOORD0;
        uint id : SV_VertexID;
    };
    struct Varyings{
        half2 uv : TEXCOORD0;
        float4 positionCS : SV_POSITION;
        float3 positionWS : TEXCOORD4;
        nointerpolation float id : TEXCOORD2;
    };

    cbuffer UnityPerMaterial{
        float _Height;
        float _Width;
    };

    #if defined(SHADER_API_D3D11) || defined(SHADER_API_METAL)
        #define STOP_COUNT 8
    #else 
        #define STOP_COUNT 6
    #endif

    Varyings vert(Attributes input)
    {
        Varyings output = (Varyings)0;
        output.positionWS = mul(UNITY_MATRIX_M,input.positionOS).xyz ;
        output.uv = 0;
        output.id = (float)input.id;

        output.positionCS = float4(0,0,0,1);

        if(input.id > STOP_COUNT){
            return output;
        }
        if((float)input.id % 4 == 0){
            output.positionCS = float4(-1,-1,1,1);
            output.uv = float2(0,0);
            return output;
        }
        if((float)input.id % 4 == 1){
            output.positionCS = float4(1,-1,1,1);
            output.uv = float2(1,0);
            return output;
        }
        if((float)input.id % 4 == 2){
            output.positionCS = float4(-1,1,1,1);
            output.uv = float2(0,1);
            return output;
        }
        if((float)input.id % 4 == 3){
            output.positionCS = float4(1,1,1,1);
            output.uv = float2(1,1);
            return output;
        }
        return output;
    }


    // #define TOLERANCE_X 1/_ScreenParams.x
    // #define TOLERANCE_Y 1/_ScreenParams.y
    // float GetPixelByIndex(uint index,){
        
    //     float2 decodedIndex = float2(index )

    //     float2 screen = float2(decodedIndex.x/_ScreenParams.x,decodedIndex.y / _ScreenParams.y);
        
    //     float maskX = 0;
    //     float maskY = 0;
    //     if(input.uv.x <= screen.x + TOLERANCE_X && input.uv.x > screen.x - TOLERANCE_X){
    //         maskX = 1;
    //     }
    //     if(input.uv.y <= screen.y + TOLERANCE_Y && input.uv.y > screen.y - TOLERANCE_Y){
    //         maskY = 1;
    //     }
    //     float output = min(maskX,maskY);
    //     return output;
    // }

    #define TOLERANCE 2
    
    float GetPixelByIndex(float index,float pixelSize,float2 uv){
        float2 scale = 1 / pixelSize;
        float2 newUV = Snap(uv,scale);
        float output = newUV.y + newUV.x * scale.x;
        output *= 100;

        float i = ceil(index);
        if((i <= output + TOLERANCE) && (i > output - TOLERANCE))
        {
            return 1;
        }
        return 0;
    }

    float4 frag(Varyings input) :SV_Target0{


        float2 index = float2(_Width,_Height);

        float mask = GetPixelByIndex((float)input.id,5,input.uv);

        float3 positionWSValue = mask * input.positionWS;

        clip(mask-1);
        return float4(positionWSValue,1);
            //return float4(input.uv,0,1);

    }
#endif