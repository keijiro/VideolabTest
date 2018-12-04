using UnityEditor;
using UnityEngine;
using System.Collections.Generic;
using System.Linq;

namespace VideoLabTest
{
    static class MeshGenerator
    {
        [MenuItem("Assets/Generate Mesh")]
        static void GenerateMesh()
        {
            for (var i = 1; i < 15; i++)
            {
                var count = (int)Mathf.Pow(2, i);
                var path = "Assets/VideoLabTest/Mesh/Mesh" + count + ".asset";
                AssetDatabase.CreateAsset(CreateMesh(count), path);
            }
        }

        static Mesh CreateMesh(int polyCount)
        {
            var vtx = new List<Vector3>();
            var nrm = new List<Vector3>();
            var tex = new List<Vector2>();

            for (var i = 0; i < polyCount; i++)
            {
                vtx.Add(new Vector3(0, 0, i));
                vtx.Add(new Vector3(1, 1, i));
                vtx.Add(new Vector3(2, 0, i));

                nrm.Add(Vector3.right);
                nrm.Add(Vector3.up);
                nrm.Add(Vector3.forward);

                var uv = new Vector2((float)i / polyCount, 0);
                tex.Add(uv);
                tex.Add(uv);
                tex.Add(uv);
            }

            var idx = Enumerable.Range(0, polyCount * 3).ToArray();

            var mesh = new Mesh();
            mesh.SetVertices(vtx);
            mesh.SetNormals(nrm);
            mesh.SetUVs(0, tex);
            mesh.SetIndices(idx, MeshTopology.Triangles, 0);
            mesh.bounds = new Bounds(Vector3.zero, Vector3.one * 1000);

            mesh.UploadMeshData(true);

            return mesh;
        }
    }
}
