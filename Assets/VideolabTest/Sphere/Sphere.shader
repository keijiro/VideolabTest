Shader "VideolabTest/Sphere"
{
    Properties
    {
        _Deform("Deformation", Float) = 0
        _Effect1("Effect 1", Range(0, 1)) = 0
        _Effect2("Effect 2", Range(0, 1)) = 0
        _Effect3("Effect 3", Range(0, 1)) = 0
        _Effect4("Effect 4", Range(0, 1)) = 0
        _Effect5("Effect 5", Range(0, 1)) = 0
        _Effect6("Effect 5", Range(0, 1)) = 0
        _Effect7("Effect 5", Range(0, 1)) = 0
        _Effect8("Effect 5", Range(0, 1)) = 0
        _LineColor("Line Color", Color) = (1, 0, 0, 1)
    }
    CGINCLUDE

    #include "UnityCG.cginc"
    #include "../Common/Shader/Common.hlsl"
    #include "../Common/Shader/SimplexNoise3D.hlsl"

    half _Deform;
    fixed _Effect1, _Effect2, _Effect3, _Effect4;
    fixed _Effect5, _Effect6, _Effect7, _Effect8;
    fixed4 _LineColor;

    float3 Deform(float3 p)
    {
        return p * (1 + 0.1 * snoise(p * 10 + _Time.y));
    }

    float4 Vertex(
        float4 position : POSITION,
        float4 texcoord0 : TEXCOORD,
        float4 texcoord1 : TEXCOORD1,
        out half3 bcoord : NORMAL,
        out fixed4 color : COLOR
    ) : SV_Position
    {
        uint pid = texcoord0.w * 65536;
        uint vid = texcoord1.w;

        float3 p0 = Deform(position.xyz);
        float3 p1 = Deform(texcoord0.xyz);
        float3 p2 = Deform(texcoord1.xyz);

        bcoord = half3(vid == 0, vid == 1, vid == 2);

        uint group = Hash(pid) & 7;

        color.a =
            (group == 0) * _Effect1 +
            (group == 1) * _Effect2 +
            (group == 2) * _Effect3 +
            (group == 3) * _Effect4 +
            (group == 4) * _Effect5 +
            (group == 5) * _Effect6 +
            (group == 6) * _Effect7 +
            (group == 7) * _Effect8;

        half3 n0 = normalize(cross(p1 - p0, p2 - p0));
        color.rgb = (n0.y + 1) / 2;

        return UnityObjectToClipPos(float4(p0, 1));
    }

    fixed4 Fragment(
        float4 position : SV_Position,
        half3 bcoord : NORMAL,
        fixed4 color : COLOR
    ) : SV_Target
    {
        half3 edge = bcoord / fwidth(bcoord);
        half e = saturate(1 - min(min(edge.x, edge.y), edge.z));
        return fixed4(color.rgb * color.a + e * (1 - color.a) * 0.5, 1);
    }

    ENDCG

    SubShader
    {
        Pass
        {
            Blend One One
            CGPROGRAM
            #pragma vertex Vertex
            #pragma fragment Fragment
            ENDCG
        }
    }
}
