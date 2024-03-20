using System.Collections.Generic;
using System.IO;
using UnityEditor;
using UnityEditorInternal;
using UnityEngine;

public class CombineRGBACtl : ITextureBakerCtl
{
    private TextureBakerData data;
    private ReorderableList reorderableList;

    private string[] str = { "R (ID Map)", "G (Iridescence Map)", "B (Emission Map)", "(A)" };

    private Texture BakeRGB()
    {
        var output = TextureBaker.CombineRGBA(data.resolution, data.inputTextures.ToArray());
        string path = EditorUtility.SaveFilePanelInProject("Save baked File", "New File", "png", "png");

        if (!string.IsNullOrEmpty(path))
        {
            File.WriteAllBytes(path, output.EncodeToPNG());
        }
        AssetDatabase.Refresh();

        return output;
    }
    public CombineRGBACtl(TextureBakerData textureBakerData)
    {
        this.data = textureBakerData;
    }
    public void Init()
    {
        data.inputTextures = new List<Texture2D>()
        {
            default,
            default,
            default,
            default
        };
        ReorderableList list = new ReorderableList(data.inputTextures, typeof(Texture2D));

        list.displayAdd = false;
        list.displayRemove = false;
        list.draggable = true;
        list.elementHeight = 16;

        list.drawHeaderCallback += (Rect rect) =>
        {
            EditorGUI.LabelField(rect, new GUIContent("RGB(A) Texture Combine"));
        };

        list.drawElementCallback += (Rect rect, int index, bool isActive, bool isFocused) =>
        {
            Texture2D current = list.list[index] as Texture2D;
            list.list[index] = EditorGUI.ObjectField(rect, str[index % (str.Length)], list.list[index] as Texture2D, typeof(Texture2D), false) as Texture2D;
        };
        list.onAddCallback += (ReorderableList list) =>
        {
            data.inputTextures.Add(default);
        };
        list.onRemoveCallback += (ReorderableList list) =>
        {
            var ls = list.list as List<Texture2D>;
            List<Texture2D> removeablePasses = new List<Texture2D>();
            foreach (var item in list.selectedIndices)
            {
                removeablePasses.Add(ls[item]);
            }
            foreach (var item in removeablePasses)
            {
                data.inputTextures.Remove(item);
            }
        };
        reorderableList = list;
    }
    public void DoGUILayout()
    {
        EditorGUILayout.LabelField("Bake IDE Map", EditorStyles.boldLabel);
        reorderableList.DoLayoutList();
        for (int i = 0; i < data.inputTextures.Count; i++)
        {
            if (data.inputTextures[i] == null)
            {
                EditorGUILayout.HelpBox($"Bake Texture chennel \"{str[i % (str.Length)]}\" is missing!, bake texture channel will be default color", MessageType.Warning);
                break;
            }
        }
        EditorGUI.indentLevel++;
        EditorGUILayout.LabelField("Bake Parameters", EditorStyles.boldLabel);
        EditorGUI.indentLevel++;
        data.resolution = (TextureBaker.Resolution)EditorGUILayout.EnumPopup("Resolution", data.resolution);
        EditorGUI.indentLevel--;
        EditorGUI.indentLevel--;
        if (GUILayout.Button("bake"))
        {
            data.outputTexture = BakeRGB();
        }
        GUILayout.Box(data.outputTexture, GUIStyle.none);
    }
}
