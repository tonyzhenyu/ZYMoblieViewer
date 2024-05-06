using UnityEngine;

public static class MeshExtension
{ 
    public static Mesh Get_Quad(this Mesh mesh)
    {
        Mesh quadMesh = mesh;

        // 定义四个顶点的位置
        Vector3[] vertices = new Vector3[4]
        {
            new Vector3(-0.5f, 0.5f, 0), // 左上角
            new Vector3(0.5f, 0.5f, 0),  // 右上角
            new Vector3(-0.5f, -0.5f, 0), // 左下角
            new Vector3(0.5f, -0.5f, 0)   // 右下角
        };

        // 定义顶点的UV坐标
        Vector2[] uv = new Vector2[4]
        {
            new Vector2(0, 1), // 左上角
            new Vector2(1, 1), // 右上角
            new Vector2(0, 0), // 左下角
            new Vector2(1, 0)  // 右下角
        };

        // 定义四个顶点的顺序以创建两个三角形
        int[] triangles = new int[6] { 0, 1, 2, 2, 1, 3 };

        // 设置Mesh的顶点、UV和三角形
        quadMesh.vertices = vertices;
        quadMesh.uv = uv;
        quadMesh.triangles = triangles;

        return quadMesh;
    }
    public static Mesh Get_Cube(this Mesh mesh)
    {
        Mesh cubeMesh = mesh;

        // 定义Cube的顶点坐标
        Vector3[] vertices = new Vector3[]
        {
            new Vector3(-0.5f, -0.5f, -0.5f), // 0
            new Vector3( 0.5f, -0.5f, -0.5f), // 1
            new Vector3( 0.5f,  0.5f, -0.5f), // 2
            new Vector3(-0.5f,  0.5f, -0.5f), // 3
            new Vector3(-0.5f, -0.5f,  0.5f), // 4
            new Vector3( 0.5f, -0.5f,  0.5f), // 5
            new Vector3( 0.5f,  0.5f,  0.5f), // 6
            new Vector3(-0.5f,  0.5f,  0.5f)  // 7
        };

        // 定义Cube的三角形顶点顺序
        int[] triangles = new int[]
        {
            0, 2, 1, // Front
            0, 3, 2,
            4, 5, 6, // Back
            4, 6, 7,
            0, 1, 5, // Left
            0, 5, 4,
            2, 3, 7, // Right
            2, 7, 6,
            1, 2, 6, // Top
            1, 6, 5,
            0, 4, 7, // Bottom
            0, 7, 3
        };
        // 定义Cube的UV坐标
        Vector2[] uv = new Vector2[]
        {
            new Vector2(0, 0), // Front Bottom Left
            new Vector2(1, 0), // Front Bottom Right
            new Vector2(1, 1), // Front Top Right
            new Vector2(0, 1), // Front Top Left
            new Vector2(0, 0), // Back Bottom Left
            new Vector2(1, 0), // Back Bottom Right
            new Vector2(1, 1), // Back Top Right
            new Vector2(0, 1), // Back Top Left
        };
        // 设置Mesh的顶点和三角形
        cubeMesh.vertices = vertices;
        cubeMesh.triangles = triangles;
        cubeMesh.uv = uv;
        // 计算法线，这是为了使光照效果正确
        cubeMesh.RecalculateNormals();
        return cubeMesh;
    }
    public static Mesh Get_Octahedral(this Mesh mesh)
    {
        Mesh octahedralMesh = mesh;

        // 定义八面体的顶点坐标
        Vector3[] vertices = new Vector3[]
        {
            // 下半部分的顶点
            new Vector3(0f, -1f, 0f), // 0
            new Vector3(1f, 0f, 0f), // 1
            new Vector3(0f, 0f, 1f), // 2
            new Vector3(-1f, 0f, 0f), // 3
            new Vector3(0f, 0f, -1f), // 4
            // 上半部分的顶点
            new Vector3(0f, 1f, 0f), // 5
        };

        // 定义八面体的三角形顶点顺序
        int[] triangles = new int[]
        {
            // 下半部分的三角形
            0, 1, 2,
            0, 2, 3,
            0, 3, 4,
            0, 4, 1,
            // 上半部分的三角形
            5, 2, 1,
            5, 3, 2,
            5, 4, 3,
            5, 1, 4
        };

        // 定义UV坐标
        Vector2[] uv = new Vector2[]
        {
            // 下半部分的UV坐标
            new Vector2(0.5f, 0f), // 0
            new Vector2(1f, 0.5f), // 1
            new Vector2(0.5f, 1f), // 2
            new Vector2(0f, 0.5f), // 3
            new Vector2(0.5f, 0.5f), // 4
            // 上半部分的UV坐标
            new Vector2(0.5f, 1f)  // 5
        };

        // 设置Mesh的顶点、三角形和UV坐标
        octahedralMesh.vertices = vertices;
        octahedralMesh.triangles = triangles;
        octahedralMesh.uv = uv;

        // 计算法线，这是为了使光照效果正确
        
        return octahedralMesh;
    }
}
