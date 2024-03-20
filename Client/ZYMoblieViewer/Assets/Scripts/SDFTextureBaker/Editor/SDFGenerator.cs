using System.IO;
using UnityEditor;
using UnityEngine;

#if UNITY_EDITOR
public class SDFGenerator : MonoBehaviour
{
    public Texture2D[] texture;

    Texture2D output;

    [ContextMenu("Run")]
    void Run()
    {
        for (int i = 0; i < texture.Length; i++)
        {
            if (texture[i] == null) continue;
            var tmp = texture[i];
            output = SDFGeneratorCore.CreateSDFTex(texture[i]);
            //output = TextureBaker.SplitRGBA(tmp, output);

            for (int x = 0; x < output.width; x++)
            {
                for(int y = 0; y < output.height; y++)
                {
                    Color source = texture[i].GetPixel(x, y);
                    Color dest = output.GetPixel(x, y);
                    output.SetPixel(x, y, new Color(source.r, source.g, source.b, dest.r));
                }
            }

            byte[] bytes = output.EncodeToPNG();
            string path = Path.GetDirectoryName(AssetDatabase.GetAssetPath(texture[i])) + $"/{texture[i].name}_sdf.png";
            
            Debug.Log(path);
            File.WriteAllBytes(path, bytes);
            
        }
        UnityEditor.AssetDatabase.Refresh();
    }
}
#endif
