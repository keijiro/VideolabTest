using UnityEngine;
using UnityEditor;
using System.Collections.Generic;
using System.IO;
using System.Linq;

class TripMeshConverter
{
    [MenuItem("Assets/Convert To TripMesh")]
    static void GenerateTripMesh()
    {
        var meshes = Selection.GetFiltered<Mesh>(SelectionMode.Unfiltered);

        foreach (var mesh in meshes)
        {
            AssetDatabase.CreateAsset(
                ConvertMesh(mesh),
                MakeTripMeshFilePath(AssetDatabase.GetAssetPath(mesh))
            );
        }
    }

    [MenuItem("Assets/Convert To TripMesh", true)]
    static bool ValidateGenerateTripMesh()
    {
        var meshes = Selection.GetFiltered<Mesh>(SelectionMode.Unfiltered);
        return meshes.Length > 0;
    }

    static string MakeTripMeshFilePath(string originalPath)
    {
        var dir = Path.GetDirectoryName(originalPath);
        var name = Path.GetFileNameWithoutExtension(originalPath);
        var path = Path.Combine(dir, name + "_TripMesh.asset");
        return AssetDatabase.GenerateUniqueAssetPath(path);
    }

    static Vector4 Vector3AddW(Vector3 v, float w)
    {
        return new Vector4(v.x, v.y, v.z, w);
    }

    static Mesh ConvertMesh(Mesh mesh)
    {
        var src_vtx = mesh.vertices;
        var src_idx = mesh.GetIndices(0);

        var vtx = new List<Vector3>();
        var uv0 = new List<Vector4>();
        var uv1 = new List<Vector4>();

        for (var i = 0; i < src_idx.Length; i += 3)
        {
            var pid = i / 3;

            var i0 = src_idx[i + 0];
            var i1 = src_idx[i + 1];
            var i2 = src_idx[i + 2];

            vtx.Add(src_vtx[i0]);
            vtx.Add(src_vtx[i1]);
            vtx.Add(src_vtx[i2]);

            uv0.Add(Vector3AddW(src_vtx[i1], pid));
            uv0.Add(Vector3AddW(src_vtx[i2], pid));
            uv0.Add(Vector3AddW(src_vtx[i0], pid));

            uv1.Add(Vector3AddW(src_vtx[i2], 0));
            uv1.Add(Vector3AddW(src_vtx[i0], 1));
            uv1.Add(Vector3AddW(src_vtx[i1], 2));
        }

        var tripMesh = new Mesh();
        tripMesh.SetVertices(vtx);
        tripMesh.SetUVs(0, uv0);
        tripMesh.SetUVs(1, uv1);
        tripMesh.SetIndices(
            Enumerable.Range(0, vtx.Count).ToArray(),
            MeshTopology.Triangles, 0
        );
        tripMesh.subMeshCount = 1;
        tripMesh.UploadMeshData(true);
        return tripMesh;
    }
}
