Shader "VideolabTest/TiltBrush"
{
    Properties
    {
        _Deform("Deformation", Float) = 0
        _Effect1("Effect 1", Range(0, 10)) = 0
        _Effect2("Effect 2", Range(0, 10)) = 0
        _Effect3("Effect 3", Range(0, 10)) = 0
        _Effect4("Effect 4", Range(0, 10)) = 0
        _Effect5("Effect 5", Range(0, 10)) = 0
        _LineColor("Line Color", Color) = (1, 0, 0, 1)
    }
    CGINCLUDE

    #include "UnityCG.cginc"
    #include "../../Common/Shader/Common.hlsl"

    half _Deform;
    fixed _Effect1, _Effect2, _Effect3, _Effect4, _Effect5;
    fixed4 _LineColor;

    uint HashColor(fixed4 color)
    {
        uint3 i = color.xyz * 16;
        return i.x + i.y * 16 + i.z * 256;
    }

    fixed Range(fixed lo, fixed hi, fixed x)
    {
        return (lo <= x) * (x < hi);
    }

    float4 Vertex(
        float4 position : POSITION,
        inout float2 uv : TEXCOORD,
        inout fixed4 color : COLOR
    ) : SV_Position
    {
        float r = Random(HashColor(color));

        float phi = (r * 2 + uv.x + _Time.y * 3) * UNITY_PI;
        position.z += sin(phi) * _Deform;

        color.rgb = LinearToGammaSpace(color.rgb);

        color.rgb *= 1 +
            Range(0.0, 0.2, r) * _Effect1 +
            Range(0.2, 0.4, r) * _Effect2 +
            Range(0.4, 0.6, r) * _Effect3 +
            Range(0.6, 0.8, r) * _Effect4 +
            Range(0.8, 1.0, r) * _Effect5;

        return UnityObjectToClipPos(position);
    }

    fixed4 Fragment(
        float4 position : SV_Position,
        float2 uv : TEXCOORD,
        fixed4 color : COLOR
    ) : SV_Target
    {
        fixed i1 = sin(uv.y * UNITY_PI);
        fixed i2 = (cos(uv.x * 3) + 1) / 2;
        color *= 0.7 + i1 * i2 * 0.5;

        half fw = fwidth(uv.y);
        half ln = saturate(1 - min(uv.y, 1 - uv.y) / fw);
        return lerp(color, _LineColor, ln * _LineColor.a);
    }

    ENDCG

    SubShader
    {
        Pass
        {
            //ZWrite Off Blend One One
            CGPROGRAM
            #pragma vertex Vertex
            #pragma fragment Fragment
            ENDCG
        }
    }
}
