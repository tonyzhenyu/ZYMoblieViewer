using System.Collections.Generic;
using UnityEngine;

public struct TextureBakerData
{
    public float width;
    public float height;
    public TextureBaker.Resolution resolution;
    public TextureBaker.Padding padding;
    public List<Texture2D> inputTextures;
    public Texture outputTexture;
}
