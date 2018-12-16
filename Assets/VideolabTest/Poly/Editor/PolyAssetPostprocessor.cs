using UnityEngine;
using UnityEditor;
using System.Collections.Generic;
using System.Linq;

class PolyAssetPostprocessor : AssetPostprocessor
{
    void OnPostprocessModel(GameObject g)
    {
        if (!assetPath.StartsWith("Assets/VideolabTest/Poly/")) return;

        foreach (var mf in g.GetComponentsInChildren<MeshFilter>())
        {
            var mr = mf.gameObject.GetComponent<MeshRenderer>();
            ConvertMesh(mf.sharedMesh, mr.sharedMaterials);
        }
    }

    void ConvertMesh(Mesh mesh, Material[] materials)
    {
        var src_vtx = mesh.vertices;

        var vtx = new List<Vector3>();
        var uv0 = new List<Vector3>();
        var uv1 = new List<Vector3>();
        var col = new List<Color>();

        for (var subMesh = 0; subMesh < mesh.subMeshCount; subMesh++)
        {
            var src_idx = mesh.GetIndices(subMesh);
            var color = materials[subMesh].color;

            for (var i = 0; i < src_idx.Length; i += 3)
            {
                var i0 = src_idx[i + 0];
                var i1 = src_idx[i + 1];
                var i2 = src_idx[i + 2];

                vtx.Add(src_vtx[i0]);
                vtx.Add(src_vtx[i1]);
                vtx.Add(src_vtx[i2]);

                uv0.Add(src_vtx[i1]);
                uv0.Add(src_vtx[i2]);
                uv0.Add(src_vtx[i0]);

                uv1.Add(src_vtx[i2]);
                uv1.Add(src_vtx[i0]);
                uv1.Add(src_vtx[i1]);

                col.Add(color);
                col.Add(color);
                col.Add(color);
            }
        }

        mesh.SetVertices(vtx);
        mesh.normals = null;
        mesh.SetUVs(0, uv0);
        mesh.SetUVs(1, uv1);
        mesh.SetColors(col);
        mesh.SetIndices(
            Enumerable.Range(0, vtx.Count).ToArray(),
            MeshTopology.Triangles, 0
        );
        mesh.subMeshCount = 1;
    }
}
