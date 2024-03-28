#ifndef INCLUDE_JDM_UNITYINPUT
#define INCLUDE_JDM_UNITYINPUT
    //-----------------------------------------------------
    // input scope
    //-----------------------------------------------------
    #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Common.hlsl"
    #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Packing.hlsl"

    #if defined(SHADER_API_MOBILE) && (defined(SHADER_API_GLES) || defined(SHADER_API_GLES30))
        #define MAX_VISIBLE_LIGHTS 16
    #elif defined(SHADER_API_MOBILE) || (defined(SHADER_API_GLCORE) && !defined(SHADER_API_SWITCH)) || defined(SHADER_API_GLES) || defined(SHADER_API_GLES3) // Workaround for bug on Nintendo Switch where SHADER_API_GLCORE is mistakenly defined
        #define MAX_VISIBLE_LIGHTS 32
    #else
        #define MAX_VISIBLE_LIGHTS 256
    #endif

    half4 _AdditionalLightsCount;

    float4 _AdditionalLightsPosition[MAX_VISIBLE_LIGHTS];
    half4 _AdditionalLightsColor[MAX_VISIBLE_LIGHTS];
    half4 _AdditionalLightsAttenuation[MAX_VISIBLE_LIGHTS];
    half4 _AdditionalLightsSpotDir[MAX_VISIBLE_LIGHTS];
    half4 _AdditionalLightsOcclusionProbes[MAX_VISIBLE_LIGHTS];

    // Must match Universal ShaderGraph master node
    struct SurfaceData
    {
        half3 albedo;
        half3 specular;
        half  metallic;
        half  smoothness;
        half3 normalTS;
        half3 emission;
        half  occlusion;
        half  alpha;
        half  clearCoatMask;
        half  clearCoatSmoothness;
    };
    struct InputData
    {
        float3  positionWS;
        half3   normalWS;
        half3   viewDirectionWS;
        float4  shadowCoord;
        half    fogCoord;
        half3   vertexLighting;
        half3   bakedGI;
        float2  normalizedScreenSpaceUV;
        half4   shadowMask;
    };
    struct ExternData{
        half iridescence;
        half iridescenceMask;
        half3 vertexNormal;
        half specularWeight;
        half rimWeight;
        half3 positionVS;
        half2 matcapUV;
        half3 highlightMatcap;
        half highlightTint;
        half3 matcapReflection;
        half3 KD;
    };

    //float3 _WorldSpaceCameraPos;


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
    #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/SpaceTransforms.hlsl"
#endif