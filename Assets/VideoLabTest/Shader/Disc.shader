Shader "VideoLabTest/Disc"
{
    Properties
    {
        _Radius("Radius", Float) = 1
        _Color("Color", Color) = (0.5, 0.5, 0.5, 1)
        _PolyCount("Poly Count", Int) = 256
    }

    CGINCLUDE

    #include "UnityCG.cginc"
    #include "Common.hlsl"

    float _Radius;
    fixed4 _Color;
    uint _PolyCount;

    float4 Vertex(uint vertexID : SV_VertexID) : SV_Position
    {
        uint pidx = vertexID / 3;        // Primitive (triangle) index
        uint vidx = vertexID - pidx * 3; // Vertex index (0, 1, 2)

        // Polar coodinates
        float phi = (pidx + (vidx == 2)) * UNITY_PI * 2 / _PolyCount;
        float l = _Radius * (vidx > 0);

        float rand = Random(pidx);
        l *= lerp(1 - rand * 5, 1, rand > 0.1);

        // Apply transform
        float4 p = float4(cos(phi) * l, -sin(phi) * l, 0, 1);
        return UnityObjectToClipPos(p);
    }

    fixed4 Fragment(float4 position : SV_Position) : SV_Target
    {
        return _Color;
    }

    ENDCG

    SubShader
    {
        Pass
        {
            CGPROGRAM
            #pragma vertex Vertex
            #pragma fragment Fragment
            ENDCG
        }
    }
}
