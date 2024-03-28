#ifndef INCLUDE_JDM_UNITYINPUT
#define INCLUDE_JDM_UNITYINPUT
    //-----------------------------------------------------
    // input scope
    //-----------------------------------------------------
    #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Common.hlsl"

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

    float4x4 glstate_matrix_projection;
    float4x4 unity_MatrixV;
    float4x4 unity_MatrixInvV;
    float4x4 unity_MatrixInvP;
    float4x4 unity_MatrixVP;
    float4x4 unity_MatrixInvVP;

    // // Block Layout should be respected due to SRP Batcher
    CBUFFER_START(UnityPerDraw)
    // Space block Feature
    float4x4 unity_ObjectToWorld;
    float4x4 unity_WorldToObject;
    float4 unity_LODFade; // x is the fade value ranging within [0,1]. y is x quantized into 16 levels
    real4 unity_WorldTransformParams; // w is usually 1.0, or -1.0 for odd-negative scale transforms

    // Light Indices block feature
    // These are set internally by the engine upon request by RendererConfiguration.
    real4 unity_LightData;
    real4 unity_LightIndices[2];

    CBUFFER_END
    
#endif