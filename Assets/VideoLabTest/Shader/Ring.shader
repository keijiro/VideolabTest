Shader "VideoLabTest/Ring"
{
    Properties
    {
        _Radius("Radius", Float) = 1.0 
        _Width("Width", Float) = 0.1
        _Color("Color", Color) = (0.5, 0.5, 0.5, 1)
        _PolyCount("Poly Count", Int) = 256
    }

    CGINCLUDE

    #include "UnityCG.cginc"

    float _Radius;
    float _Width;
    fixed4 _Color;
    uint _PolyCount;

    float4 Vertex(uint vid : SV_VertexID) : SV_Position
    {
        uint pidx = vid / 3;
        uint vidx = vid - pidx * 3;

        float phi = (pidx + vidx) * UNITY_PI * 2 / _PolyCount;
        float offs = (vidx == 1 ^ (pidx & 1)) ? 0.5 : -0.5;
        float r = _Radius + offs * _Width;

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
            Cull Off
            CGPROGRAM
            #pragma vertex Vertex
            #pragma fragment Fragment
            ENDCG
        }
    }
}
