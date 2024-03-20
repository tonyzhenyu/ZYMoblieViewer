using UnityEditor;

public class TextureBakerWindow : EditorWindow
{
    public static ITextureBakerCtl[] textureBakerCtls;
    public static TextureBakerData textureBakerData =
    new TextureBakerData()
    {
        resolution = TextureBaker.Resolution._512x512,
    };
    [MenuItem("Tools/Texture Baker Window")]
    public static void ShowWindow()
    {
        GetWindow<TextureBakerWindow>("Texture Baker Window");
        textureBakerCtls = new ITextureBakerCtl[]
        {
            new CombineRGBACtl(textureBakerData),
            new PackMultiTextureCtl(textureBakerData)
        };
        foreach (var item in textureBakerCtls)
        {
            item.Init();
        }
    }
    private void OnGUI()
    {
        textureBakerCtls[0].DoGUILayout();
    }

}
