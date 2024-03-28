using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;
public enum MashUp
{
    Curtaining, 
    Dissolve // cliptable
}

public struct MashUpModule
{
    public Color tint;
    public Texture maskMap;
    public Texture mashUpMap;
    public Vector4 maskMapParam;
    public bool enabled;
    public MashUp type;
    public struct IDPacking
    {

        public static int id_MashUpMaskMap = Shader.PropertyToID("_MashUpMaskMap");
        public static int id_MashUpMap = Shader.PropertyToID("_MashUpMap");
        public static int id_MashUpColor = Shader.PropertyToID("_MashUpColor");
        public static int id_MashUpParam = Shader.PropertyToID("_MashUpParam");

        public static string[] keywords = { 
            "_MASH_UP_01", 
            "_MASH_UP_02" 
        };
    }
    public void Update(CommandBuffer cmd)
    {
        if (enabled == false)
        {
            foreach (var item in IDPacking.keywords)
            {
                CoreUtils.SetKeyword(cmd, item, false);
            }
        }
        if (enabled == true)
        {
            switch (type)
            {
                case MashUp.Curtaining:
                    CoreUtils.SetKeyword(cmd, IDPacking.keywords[0], true);
                    cmd.SetGlobalColor(IDPacking.id_MashUpColor, tint);
                    cmd.SetGlobalTexture(IDPacking.id_MashUpMaskMap, maskMap);
                    cmd.SetGlobalTexture(IDPacking.id_MashUpMap, mashUpMap);
                    cmd.SetGlobalVector(IDPacking.id_MashUpParam, maskMapParam);
                    break;
                case MashUp.Dissolve:
                    CoreUtils.SetKeyword(cmd, IDPacking.keywords[1], true);
                    cmd.SetGlobalColor(IDPacking.id_MashUpColor, tint);
                    cmd.SetGlobalTexture(IDPacking.id_MashUpMaskMap, maskMap);
                    cmd.SetGlobalVector(IDPacking.id_MashUpParam, maskMapParam);
                    break;
                default:
                    break;
            }
        }
    }
}