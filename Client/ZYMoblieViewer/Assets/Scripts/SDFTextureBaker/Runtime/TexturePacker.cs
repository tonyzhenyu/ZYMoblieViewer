using System.IO;
using UnityEditor;
using UnityEngine;

public class TexturePacker : MonoBehaviour
{
    public Texture2D[] textures;
    public TextureBaker.Resolution resolution;
    [Min(0)]public int padding;

    [ContextMenu("Pack")]
    void Pack()
    {
        var output = TextureBaker.Bake(resolution, padding , Color.clear, textures, new Material(Shader.Find("Hiden/BakeTexture")));
        
        string path = EditorUtility.SaveFilePanelInProject("Save baked File", "New File", "tga", "tga");
        if (!string.IsNullOrEmpty(path))
        {
            File.WriteAllBytes(path, output.EncodeToTGA());
            //// 在控制台中打印保存文件的路径
            //Debug.Log("File saved at: " + path);
        }
        else
        {
            //// 如果用户取消了保存操作
            //Debug.Log("Save operation cancelled.");
        }
        AssetDatabase.Refresh();
    }



}
