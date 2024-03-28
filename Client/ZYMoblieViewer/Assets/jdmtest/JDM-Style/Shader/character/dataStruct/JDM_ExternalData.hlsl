#ifndef INCLUDE_JDM_EXTERNAL_DATA
#define INCLUDE_JDM_EXTERNAL_DATA
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
#endif