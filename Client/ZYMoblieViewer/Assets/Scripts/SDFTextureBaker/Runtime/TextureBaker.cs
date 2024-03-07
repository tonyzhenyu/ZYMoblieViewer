using UnityEngine;
using UnityEngine.Rendering;

public class TextureBaker
{
    public enum Resolution
    {
        _32x32 = 32,
        _64x64 = 64,
        _128x128 = 128,
        _256x256 = 256,
        _512x512 = 512,
        _1024x1024 = 1024,
        _2048x1024 = 2048,
    }
    public enum QMesh
    {
        cube,
        quad,
        octahedral
    }

    /// <summary>
    /// multi textures 
    /// </summary>
    /// <param name="resolution"></param>
    /// <param name="padding"></param>
    /// <param name="bgColor"></param>
    /// <param name="textures"></param>
    /// <param name="material"></param>
    /// <returns></returns>
    public static Texture2D Bake(Resolution resolution,int padding ,Color bgColor, Texture2D[] textures,Material material)
    {
        var active = RenderTexture.active;
        RenderTexture rt = RenderTexture.GetTemporary(new RenderTextureDescriptor((int)resolution, (int)resolution, RenderTextureFormat.ARGB32, 16, 0));
        RenderTexture.active = rt;

        var cmd = CommandBufferPool.Get();
        cmd.SetRenderTarget(rt);
        cmd.ClearRenderTarget(true, true, bgColor);

        var cube = Matrix4x4.TRS(new Vector3(0,0,0), Quaternion.Euler(0, 0, 0), new Vector3(1, -1, 1));
        var ts = Matrix4x4.Translate(new Vector3(0.5f, 0.5f, 0));
        cmd.SetViewProjectionMatrices(cube * ts.inverse, GL.GetGPUProjectionMatrix(Matrix4x4.Ortho(-0.5f,0.5f, -0.5f, 0.5f, 0.01f, 100f), true));

        int n = 0;

        while (true)
        {
            if ((n * n) <= textures.Length)
            {
                n += 1;
            }
            else
            {
                break;
            }
        }


        for (int i = 0; i < textures.Length; i++)
        {
            float nf = 1/(float)n ;
            //nf /= 2;
            float x = nf + (i % n) * nf * 2;
            float y = nf + Mathf.Floor((float)i / (float)n) * nf *2;

            Vector3 pos = new Vector3(x /2,y /2 , -1f);

            float scalar = (float)n;
            var m = Matrix4x4.TRS(pos, Quaternion.identity, Vector3.one / scalar * (1 - (float)padding * 4 / (float)resolution));

            var mat = new Material(material);
            mat.SetTexture("_MainTex", textures[i]);
            cmd.DrawMesh(new Mesh().Get_Cube(),m  , mat);

        }
        Graphics.ExecuteCommandBuffer(cmd);

        Texture2D output = new Texture2D(rt.width, rt.height, TextureFormat.RGBA32, false);
        output.ReadPixels(new Rect(0, 0, RenderTexture.active.width, RenderTexture.active.height), 0, 0);
        output.Apply();

        RenderTexture.active = active;
        cmd.Release();
        rt.Release();

        return output;
    }
    /// <summary>
    /// Single Texture bakery
    /// </summary>
    /// <param name="resolution"></param>
    /// <param name="padding"></param>
    /// <param name="bgColor"></param>
    /// <param name="material"></param>
    /// <returns></returns>
    public static Texture2D Bake(Resolution resolution, Texture texture, Color bgColor, Material material)
    {
        var active = RenderTexture.active;
        RenderTexture rt = RenderTexture.GetTemporary(new RenderTextureDescriptor((int)resolution, (int)resolution, RenderTextureFormat.ARGB32, 16, 0));
        RenderTexture.active = rt;

        var cmd = CommandBufferPool.Get();
        cmd.SetRenderTarget(rt);
        cmd.ClearRenderTarget(true, true, bgColor);

        var cube = Matrix4x4.TRS(new Vector3(0, 0, 0), Quaternion.Euler(0, 0, 0), new Vector3(1, -1, 1));
        cmd.SetViewProjectionMatrices(cube , GL.GetGPUProjectionMatrix(Matrix4x4.Ortho(-0.5f, 0.5f, -0.5f, 0.5f, 0.01f, 100f), true));

        var mat = new Material(material);
        mat.SetTexture("_MainTex", texture);
        cmd.DrawMesh(new Mesh().Get_Cube(), Matrix4x4.identity, mat);
        Graphics.ExecuteCommandBuffer(cmd);

        Texture2D output = new Texture2D(rt.width, rt.height, TextureFormat.RGBA32, false);
        output.ReadPixels(new Rect(0, 0, RenderTexture.active.width, RenderTexture.active.height), 0, 0);
        output.Apply();

        RenderTexture.active = active;
        cmd.Release();
        rt.Release();

        return output;
    }

    /// <summary>
    /// Combine 2 Texture 
    /// </summary>
    /// <param name="resolution"></param>
    /// <param name="sourceRGB"></param>
    /// <param name="sourceAlpha"></param>
    /// <returns></returns>
    public static Texture2D SplitRGBA(Resolution resolution, Texture sourceRGB,Texture sourceAlpha)
    {
        var active = RenderTexture.active;
        RenderTexture rt = RenderTexture.GetTemporary(new RenderTextureDescriptor((int)resolution, (int)resolution, RenderTextureFormat.ARGB32, 16, 0));
        RenderTexture.active = rt;

        var cmd = CommandBufferPool.Get();
        cmd.SetRenderTarget(rt);
        cmd.ClearRenderTarget(true, true, Color.clear);

        var cube = Matrix4x4.TRS(new Vector3(0, 0, 0), Quaternion.Euler(0, 0, 0), new Vector3(1, -1, 1));
        cmd.SetViewProjectionMatrices(cube, GL.GetGPUProjectionMatrix(Matrix4x4.Ortho(-0.5f, 0.5f, -0.5f, 0.5f, 0.01f, 100f), true));

        var mat = new Material(Shader.Find("Hiden/SplitRGBA"));
        mat.SetTexture("_MainTex", sourceRGB);
        mat.SetTexture("_SecTex", sourceAlpha);
        cmd.DrawMesh(new Mesh().Get_Cube(), Matrix4x4.identity, mat);
        Graphics.ExecuteCommandBuffer(cmd);

        Texture2D output = new Texture2D(rt.width, rt.height, TextureFormat.RGBA32, false);
        output.ReadPixels(new Rect(0, 0, RenderTexture.active.width, RenderTexture.active.height), 0, 0);
        output.Apply();

        RenderTexture.active = active;
        cmd.Release();
        rt.Release();

        return output;
    }    
    /// <summary>
    /// Combine 2 Texture 
    /// </summary>
    /// <param name="resolution"></param>
    /// <param name="sourceRGB"></param>
    /// <param name="sourceAlpha"></param>
    /// <returns></returns>
    public static Texture2D SplitRGBA(Texture sourceRGB,Texture sourceAlpha)
    {
        var active = RenderTexture.active;
        RenderTexture rt = RenderTexture.GetTemporary(new RenderTextureDescriptor((int)sourceAlpha.width, (int)sourceAlpha.height, RenderTextureFormat.ARGB32, 16, 0));
        RenderTexture.active = rt;

        var cmd = CommandBufferPool.Get();
        cmd.SetRenderTarget(rt);
        cmd.ClearRenderTarget(true, true, Color.clear);

        var cube = Matrix4x4.TRS(new Vector3(0, 0, 0), Quaternion.Euler(0, 0, 0), new Vector3(1, -1, 1));
        cmd.SetViewProjectionMatrices(cube, GL.GetGPUProjectionMatrix(Matrix4x4.Ortho(-0.5f, 0.5f, -0.5f, 0.5f, 0.01f, 100f), true));

        var mat = new Material(Shader.Find("Hiden/SplitRGBA"));
        mat.SetTexture("_MainTex", sourceRGB);
        mat.SetTexture("_SecTex", sourceAlpha);
        cmd.DrawMesh(new Mesh().Get_Cube(), Matrix4x4.identity, mat);
        Graphics.ExecuteCommandBuffer(cmd);

        Texture2D output = new Texture2D(rt.width, rt.height, TextureFormat.RGBA32, false);
        output.ReadPixels(new Rect(0, 0, RenderTexture.active.width, RenderTexture.active.height), 0, 0);
        output.Apply();

        RenderTexture.active = active;
        cmd.Release();
        rt.Release();

        return output;
    }
}
