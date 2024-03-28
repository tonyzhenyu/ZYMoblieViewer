using UnityEngine;
using UnityEngine.Rendering;

public class JDMStyleRuntimeParamController
{
    public struct Keywords
    {
        public static string FogKeyword = "_FOG_ENABLE";
    }
    public void UpdateData(CommandBuffer cmd, JDMStyleConfigure.RuntimeParam data)
    {
        if (data.fog.fogweight <= 0 || data.fog.useFog == false)
        {
            cmd.DisableShaderKeyword(Keywords.FogKeyword);
        }
        else
        {
            cmd.EnableShaderKeyword(Keywords.FogKeyword);
        }
        if (JDMStyleConfigure.Weight <= 0)
        {

            cmd.SetGlobalFloat(JDMStyleIDPackaging.id_DirectIntensity,data.directLighting.characterDirectLightIntensity);
            cmd.SetGlobalFloat(JDMStyleIDPackaging.id_FrontLightIntensity, data.directLighting.characterFrontLightWeight);

            cmd.SetGlobalFloat(JDMStyleIDPackaging.id_EnvironmentIntensity, data.environmentLighting.characterEnvironmentIntensity);


            cmd.SetGlobalColor(JDMStyleIDPackaging.id_SHTint, data.environmentLighting.characterEnvironmentTint);

            cmd.SetGlobalFloat(JDMStyleIDPackaging.id_Character_IridescenceWeight, data.environmentLighting.characterIridescenceWeight);

            cmd.SetGlobalColor(JDMStyleIDPackaging.id_CharacterFogColor, data.fog.color);
            cmd.SetGlobalVector(JDMStyleIDPackaging.id_CharacterFogWeight, new Vector4(data.fog.start, data.fog.end, data.fog.fogweight));

            cmd.SetGlobalVector(JDMStyleIDPackaging.id_MatcapWeight, new Vector4(data.matcapLighting.matcapWeight, data.directLighting.characterFrontLightWeight, data.matcapLighting.highlightWeight, data.matcapLighting.metalReflectWeight));

        }
        else
        {

            var runtimeParam = JDMStyleConfigure.runtimeParam;
            var Weight = JDMStyleConfigure.Weight;


            var directIntensity = Mathf.Lerp(data.directLighting.characterDirectLightIntensity, runtimeParam.directLighting.characterDirectLightIntensity, Weight);
            cmd.SetGlobalFloat(JDMStyleIDPackaging.id_DirectIntensity, directIntensity);

            var frontIntensity = Mathf.Lerp(data.directLighting.characterFrontLightWeight, runtimeParam.directLighting.characterFrontLightWeight, Weight);
            cmd.SetGlobalFloat(JDMStyleIDPackaging.id_FrontLightIntensity, frontIntensity);

            var intensity = Mathf.Lerp(data.environmentLighting.characterEnvironmentIntensity, runtimeParam.environmentLighting.characterEnvironmentIntensity, Weight);
            cmd.SetGlobalFloat(JDMStyleIDPackaging.id_EnvironmentIntensity, intensity);

            var irweight = Mathf.Lerp(data.environmentLighting.characterIridescenceWeight, runtimeParam.environmentLighting.characterIridescenceWeight, Weight);
            cmd.SetGlobalFloat(JDMStyleIDPackaging.id_Character_IridescenceWeight, irweight);

            Color envirotmenttint = Color.Lerp(data.environmentLighting.characterEnvironmentTint, runtimeParam.environmentLighting.characterEnvironmentTint, Weight);
            cmd.SetGlobalColor(JDMStyleIDPackaging.id_SHTint, envirotmenttint);

            Color fogTint = Color.Lerp(data.fog.color, runtimeParam.fog.color, Weight);
            cmd.SetGlobalColor(JDMStyleIDPackaging.id_CharacterFogColor, fogTint);

            Vector4 fogWeight = Vector4.Lerp(new Vector4(data.fog.start, data.fog.end, data.fog.fogweight), new Vector4(runtimeParam.fog.start, runtimeParam.fog.end, runtimeParam.fog.fogweight), Weight);
            cmd.SetGlobalVector(JDMStyleIDPackaging.id_CharacterFogWeight, fogWeight);


            cmd.SetGlobalVector(JDMStyleIDPackaging.id_MatcapWeight, new Vector4(data.matcapLighting.matcapWeight, data.directLighting.characterFrontLightWeight, data.matcapLighting.highlightWeight, data.matcapLighting.metalReflectWeight));

        }

    }
}
