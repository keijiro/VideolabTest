using UnityEditor;
using UnityEngine;
using System.Collections.Generic;
using System.IO;
using System.Linq;

namespace VideolabTest
{
    static class MeshGenerator
    {
        [MenuItem("Assets/Generate Mesh")]
        static void GenerateMesh()
        {
            for (var i = 1; i < 9; i++)
            {
                var count = (int)Mathf.Pow(2, i);
                var path = MakePath("Mesh" + count);
                if (File.Exists(path)) continue;
                AssetDatabase.CreateAsset(CreateGenericMesh(count), path);
            }

            {
                var path = MakePath("Tube_16x256");
                if (!File.Exists(path))
                    AssetDatabase.CreateAsset(CreateTubeMesh(16, 256), path);
            }
        }

        static string MakePath(string filename)
        {
            return "Assets/VideolabTest/Common/Mesh/" + filename + ".asset";
        }

        static Mesh CreateGenericMesh(int polyCount)
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

        static Mesh CreateTubeMesh(int verticesPerRing, int ringCount)
        {
            var vtx = new List<Vector3>();

            for (var ri = 0; ri < ringCount; ri++)
            {
                for (var i = 0 ; i < verticesPerRing; i++)
                {
                    var x = (float)i / verticesPerRing;
                    var y = (float)ri / (ringCount - 1);
                    vtx.Add(new Vector3(x, y, 0));
                }
            }

            var idx = new List<int>();

            for (var ri = 0; ri < ringCount - 1; ri++)
            {
                for (var i = 0 ; i < verticesPerRing - 1; i++)
                {
                    var v = ri * verticesPerRing + i;

                    idx.Add(v);
                    idx.Add(v + 1);
                    idx.Add(v + verticesPerRing);

                    idx.Add(v + 1);
                    idx.Add(v + verticesPerRing + 1);
                    idx.Add(v + verticesPerRing);
                }

                {
                    var v = ri * verticesPerRing;

                    idx.Add(v + verticesPerRing - 1);
                    idx.Add(v);
                    idx.Add(v + verticesPerRing * 2 - 1);

                    idx.Add(v);
                    idx.Add(v + verticesPerRing);
                    idx.Add(v + verticesPerRing * 2 - 1);
                }
            }

            var mesh = new Mesh();
            mesh.SetVertices(vtx);
            mesh.SetIndices(idx.ToArray(), MeshTopology.Triangles, 0);
            mesh.bounds = new Bounds(Vector3.zero, Vector3.one * 1000);

            mesh.UploadMeshData(true);

            return mesh;
        }
    }
}
