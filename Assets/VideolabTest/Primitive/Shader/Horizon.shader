Shader "VideolabTest/Horizon"
{
    Properties
    {
        _Noise("Noise", Float) = 1
        _Color("Color", Color) = (0.5, 0.5, 0.5, 1)
        _PolyCount("Poly Count", Int) = 256
    }

    CGINCLUDE

    #include "UnityCG.cginc"
    #include "../../Common/Shader/Common.hlsl"
    #include "../../Common/Shader/SimplexNoise2D.hlsl"

    float _Noise;
    fixed4 _Color;
    uint _PolyCount;

    float4 Vertex(uint vid : SV_VertexID) : SV_Position
    {
        uint pidx = vid / 3;
        uint vidx = vid - pidx * 3;

        float mask = (vidx == 1);
        float t = _Time.y * 3.1;

        float x = ((float)pidx + vidx) / (_PolyCount + 1);
        x += mask * snoise(float2(vid * 22.23, t)) * 0.1;

        float y = mask * snoise(float2(vid * 31.74, t)) * _Noise;

        float4 p = float4(x * 2 - 1, y, 0, 1);
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
