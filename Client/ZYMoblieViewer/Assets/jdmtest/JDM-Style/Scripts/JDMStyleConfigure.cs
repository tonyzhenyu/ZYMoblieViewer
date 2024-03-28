using System;
using UnityEngine;



public static class JDMStyleConfigure
{
    public static MashUpModule mashUpModule;
    public static RuntimeParam runtimeParam;
    public static EnvironmentRuntimeParam environmentRuntimeParam;
    public static GlobalTextures textures;
    public static FeverParam feverParam;

    [Range(0,1)]public static float Weight = 0;

    [Serializable]public struct EnvironmentRuntimeParam
    {
        public Color ambient;
    }

    [Serializable]public struct RuntimeParam
    {
        public DirectLighting directLighting;
        public EnvironmentLighting environmentLighting;
        public MatcapLighting matcapLighting;
        public Fog fog;
    }
    [Serializable]public struct FeverParam
    {
        [ColorUsage(true,true)] public Color feverColor;
    }
    [Serializable]public struct GlobalTextures
    {
        public Texture irrdescenceRamp;
        public Texture diffusionProfileRamp;//sss
        public Texture environmentTexture;
    }

    [Serializable]public struct DirectLighting
    {
        [Range(0, 8)] public float characterDirectLightIntensity;
        [Range(0, 8)] public float characterFrontLightWeight;
    }
    [Serializable]public struct EnvironmentLighting
    {
        [Range(0, 8)] public float characterEnvironmentIntensity;
        [Range(0, 1)] public float characterIridescenceWeight;
        public Color characterEnvironmentTint;
    }
    [Serializable]public struct MatcapLighting
    {
        [Range(0, 1)] public float matcapWeight;

        //[Min(0)] public float frontLightWeight;
        [Min(0)] public float highlightWeight;
        [Min(0)] public float metalReflectWeight;
        
    }
    [Serializable]public struct Fog
    {
        public bool useFog;
        public Color color;
        public float start;
        public float end;
        [Range(0,1)]public float fogweight;
    }
}
