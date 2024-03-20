using System.Collections.Generic;
using System.IO;
using UnityEditor;
using UnityEditorInternal;
using UnityEngine;

public class PackMultiTextureCtl : ITextureBakerCtl
{
    public TextureBaker.Padding padding = TextureBaker.Padding._0;
    public List<Texture2D> textures;
    public TextureBaker.Resolution resolution = TextureBaker.Resolution._64x64;

    public Texture output;

    private ReorderableList reorderableList;

    private void Pack(int padding)
    {
        var output = TextureBaker.Bake(resolution, (int)padding, Color.clear, textures.ToArray(), new Material(Shader.Find("Hiden/BakeTexture")));
        string path = EditorUtility.SaveFilePanelInProject("Save baked File", "New File", "png", "png");

        if (!string.IsNullOrEmpty(path))
        {
            File.WriteAllBytes(path, output.EncodeToPNG());
        }
        AssetDatabase.Refresh();
    }
    public PackMultiTextureCtl(TextureBakerData textureBakerData)
    {

    }
    public void Init()
    {

    }
    public void DoGUILayout()
    {

    }
}
