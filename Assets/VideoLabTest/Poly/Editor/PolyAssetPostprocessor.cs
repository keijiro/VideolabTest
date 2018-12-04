using UnityEngine;
using UnityEditor;
using System.Collections.Generic;
using System.Linq;

class PolyAssetPostprocessor : AssetPostprocessor
{
    void OnPostprocessModel(GameObject g)
    {
        if (!assetPath.StartsWith("Assets/VideoLabTest/Poly/")) return;
        foreach (var mf in g.GetComponentsInChildren<MeshFilter>())
            ConvertMesh(mf.sharedMesh);
    }

    void ConvertMesh(Mesh mesh)
    {
        var src_vtx = mesh.vertices;
        var src_uv0 = mesh.uv;
        var hasUV = (src_uv0.Length > 0);

        var vtx = new List<Vector3>();
        var uv0 = new List<Vector2>();
        var uv1 = new List<Vector3>();
        var uv2 = new List<Vector3>();

        var vcounts = new List<int>();

        for (var subMesh = 0; subMesh < mesh.subMeshCount; subMesh++)
        {
            var src_idx = mesh.GetIndices(subMesh);

            for (var i = 0; i < src_idx.Length; i += 3)
            {
                var i0 = src_idx[i + 0];
                var i1 = src_idx[i + 1];
                var i2 = src_idx[i + 2];

                vtx.Add(src_vtx[i0]);
                vtx.Add(src_vtx[i1]);
                vtx.Add(src_vtx[i2]);

                if (hasUV)
                {
                    uv0.Add(src_uv0[i0]);
                    uv0.Add(src_uv0[i1]);
                    uv0.Add(src_uv0[i2]);
                }

                uv1.Add(src_vtx[i1]);
                uv1.Add(src_vtx[i2]);
                uv1.Add(src_vtx[i0]);

                uv2.Add(src_vtx[i2]);
                uv2.Add(src_vtx[i0]);
                uv2.Add(src_vtx[i1]);
            }

            vcounts.Add(src_idx.Length);
        }

        mesh.SetVertices(vtx);
        mesh.normals = null;
        if (hasUV) mesh.SetUVs(0, uv0);
        mesh.SetUVs(1, uv1);
        mesh.SetUVs(2, uv2);

        var acc = 0;
        for (var subMesh = 0; subMesh < mesh.subMeshCount; subMesh++)
        {
            var vc = vcounts[subMesh];
            var idx = Enumerable.Range(acc, vc).ToArray();
            mesh.SetIndices(idx, MeshTopology.Triangles, subMesh);
            acc += vc;
        }
    }
}
