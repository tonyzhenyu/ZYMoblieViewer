#ifndef INCLUDE_JDM_STYLECORE
#define INCLUDE_JDM_STYLECORE

	#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
    
    #ifdef _DETAIL_TEXTURE_ENABLE
        #include "lib/JDM_Layering.hlsl"
    #endif

	#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
    #include "JDM_Mashup.hlsl"
    #include "JDM_PostEffect.hlsl"
    #include "JDM_CharacterLitFunc.hlsl"
#endif