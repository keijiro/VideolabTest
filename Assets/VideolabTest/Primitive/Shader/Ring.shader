Shader "VideolabTest/Ring"
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
    #include "../../Common/Shader/Common.hlsl"

    float _Radius;
    float _Width;
    fixed4 _Color;
    uint _PolyCount;

    float4 Vertex(uint vertexID : SV_VertexID) : SV_Position
    {
        uint pidx = vertexID / 3;        // Primitive (triangle) index
        uint vidx = vertexID - pidx * 3; // Vertex index (0, 1, 2)

        // Mask to hide triangles when _Width == 0.0
        float mask = smoothstep(0, 0.001, _Width);

        // Inside or outside?
        float io = (vidx == 1 ^ (pidx & 1)) ? 1 : -1;

        // Polar coodinates
        float phi = (pidx + vidx * mask) * UNITY_PI * 2 / _PolyCount;
        float l = _Radius + _Width * io * 0.5;

        // Apply transform
        float4 pos = float4(cos(phi) * l, -sin(phi) * l, 0, 1);
        return UnityObjectToClipPos(pos);
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
