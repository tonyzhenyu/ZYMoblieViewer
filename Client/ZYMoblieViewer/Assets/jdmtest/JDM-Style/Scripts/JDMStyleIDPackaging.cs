using UnityEngine;

public struct JDMStyleIDPackaging
{
    public static int id_irRamp = Shader.PropertyToID("_IridescenceRamp");
    public static int id_brdfRamp = Shader.PropertyToID("_BrdfSliceRamp");
    public static int id_diffRamp = Shader.PropertyToID("_DiffSliceRamp");
    public static int id_envtex = Shader.PropertyToID("_Envtex");
    public static int id_Matcap_FrontFacet= Shader.PropertyToID("_Matcap_FrontFacet");
    public static int id_EnvironmentIntensity = Shader.PropertyToID("_CharacterEnvironmentWeight");
    public static int id_DirectIntensity = Shader.PropertyToID("_CharacterDirectWeight");
    public static int id_FrontLightIntensity = Shader.PropertyToID("_CharacterFrontLightWeight");
    public static int id_SHTint = Shader.PropertyToID("_CharacterEnvironmentTint");

    public static int id_UnscaledTime = Shader.PropertyToID("_UnscaledTime");

    public static int id_CharacterFogColor = Shader.PropertyToID("_CharacterFogColor");
    public static int id_CharacterFogWeight = Shader.PropertyToID("_CharacterFogWeight");

    public static int id_Character_IridescenceWeight = Shader.PropertyToID("_CharacterIridescenceWeight");

    public static int id_MatcapWeight = Shader.PropertyToID("_MatcapWeight");
    public static int id_EnvironmentAmbient = Shader.PropertyToID("_EnvironmentColorTint");

    public static int id_FeverEmissionColor = Shader.PropertyToID("_FeverEmissionColor");
}
