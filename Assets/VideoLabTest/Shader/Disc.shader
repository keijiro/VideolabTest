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

    float _Radius;
    fixed4 _Color;
    uint _PolyCount;

    float4 Vertex(uint vid : SV_VertexID) : SV_Position
    {
        uint pidx = vid / 3;
        uint vidx = vid - pidx * 3;

        float phi = (pidx + (vidx == 2)) * UNITY_PI * 2 / _PolyCount;
        float r = _Radius * (vidx > 0);

        float4 p = float4(cos(phi) * r, -sin(phi) * r, 0, 1);
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
