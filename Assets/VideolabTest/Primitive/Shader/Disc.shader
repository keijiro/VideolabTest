Shader "VideolabTest/Disc"
{
    Properties
    {
        _Radius("Radius", Float) = 1
        _NoiseFreq("Noise Frequency", Float) = 10
        _NoiseAmp("Noise Amplitude", Float) = 0.1
        _Color("Color", Color) = (0.5, 0.5, 0.5, 1)
        _PolyCount("Poly Count", Int) = 256
    }

    CGINCLUDE

    #include "UnityCG.cginc"
    #include "../../Common/Shader/Common.hlsl"
    #include "../../Common/Shader/ClassicNoise2D.hlsl"

    float _Radius;
    float _NoiseFreq;
    half _NoiseAmp;
    fixed4 _Color;
    uint _PolyCount;

    float4 Vertex(uint vertexID : SV_VertexID) : SV_Position
    {
        uint pidx = vertexID / 3;        // Primitive (triangle) index
        uint vidx = vertexID - pidx * 3; // Vertex index (0, 1, 2)

        // Polar coodinates
        float phi01 = (float)(pidx + (vidx == 2)) / _PolyCount;
        float phi = phi01 * UNITY_PI * 2;
        float l = _Radius * (vidx > 0);

        // Noise
        half n = pnoise(float2(phi01 * _NoiseFreq, _Time.y * 10), _NoiseFreq);
        l *= 1 + n * _NoiseAmp;

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
