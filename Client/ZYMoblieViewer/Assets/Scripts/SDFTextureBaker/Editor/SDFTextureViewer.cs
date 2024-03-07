using UnityEditor;
using UnityEngine;
using UnityEngine.Rendering;

public class SDFTextureViewer : EditorWindow
{
    [MenuItem("Tool/SDFTexture Preview Window")]
    public static void ShowWindow()
    {
        GetWindow<SDFTextureViewer>("Model Preview");
    }
    float minvalue=0;
    float maxvalue=1;

    void OnGUI()
    {
        EditorGUILayout.MinMaxSlider(ref minvalue, ref maxvalue, 0, 1);
        if (Selection.activeObject != null)
        {
            ShowView(Selection.activeObject as Texture, minvalue, maxvalue);
            GUI.DrawTexture(new Rect(0, 0, this.position.width, this.position.height),rt,ScaleMode.ScaleToFit);
        }
        else
        {
            EditorGUILayout.HelpBox("Drag and drop a model prefab into the field above.", MessageType.Info);
        }
    }
    private void OnDestroy()
    {
        cmd.Release();
        rt.Release();
    }
    RenderTexture rt;
    CommandBuffer cmd;
    void ShowView(Texture texture,float minvalue,float maxvalue)
    {
        if (rt == null)
        {
            rt = RenderTexture.GetTemporary(new RenderTextureDescriptor((int)this.position.width, (int)this.position.width, RenderTextureFormat.ARGB32, 16, 0));
        }
        if (cmd == null)
        {
            cmd = CommandBufferPool.Get();
        }

        cmd.SetRenderTarget(rt);
        cmd.ClearRenderTarget(true, true, Color.clear);

        var cube = Matrix4x4.TRS(new Vector3(0, 0, 0), Quaternion.Euler(0, 0, 0), new Vector3(1, -1, 1));
        cmd.SetViewProjectionMatrices(cube, GL.GetGPUProjectionMatrix(Matrix4x4.Ortho(-0.5f, 0.5f, -0.5f, 0.5f, 0.01f, 100f), true));

        var mat = new Material(Shader.Find("Hiden/SDFViewRGB(A)"));
        mat.SetTexture("_MainTex", texture);
        mat.SetFloat("_minValue", minvalue);
        mat.SetFloat("_maxValue", maxvalue);
        cmd.DrawMesh(new Mesh().Get_Cube(), Matrix4x4.identity, mat);
        Graphics.ExecuteCommandBuffer(cmd);
    }

}