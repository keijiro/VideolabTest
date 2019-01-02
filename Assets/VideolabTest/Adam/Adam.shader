Shader "VideolabTest/Adam"
{
    Properties
    {
        _MainTex("Texture", 2D) = "black"{}

        [Header(Fill Color 1)]
        _Thresh1("Threshold", Range(0, 1)) = 0.5
        _Color1("Color", Color) = (1, 1, 1, 1)

        [Header(Fill Color 2)]
        _Thresh2("Threshold", Range(0, 1)) = 0.75
        _Color2("Color", Color) = (1, 1, 1, 1)

        [Header(Effect 1 (low res))]
        _Effect1("Intensity", Range(0, 1)) = 0

        [Header(Effect 2 (slice))]
        _Effect2("Intensity", Range(0, 1)) = 0
        _Angle2("Angle", Range(-1, 1)) = 0

        [Header(Effect 3 (jitter))]
        _Effect3("Intensity", Range(0, 1)) = 0

        [Header(Effect 4 (Flash))]
        _Effect4("Intensity", Range(0, 1)) = 0
    }

    CGINCLUDE

    #include "UnityCG.cginc"
    #include "../Common/Shader/Common.hlsl"

    sampler2D _MainTex;
    float4 _MainTex_TexelSize;

    float _Thresh1;
    half3 _Color1;

    float _Thresh2;
    half3 _Color2;

    half _Effect1;
    half _Effect2;
    half _Effect3;
    half _Effect4;
    half _Angle2;

    float4 Vertex(
        float4 position : POSITION,
        inout float2 texcoord : TEXCOORD
    ) : SV_Position
    {
        return UnityObjectToClipPos(position);
    }

    half4 Fragment(
        float4 position : SV_Position,
        float2 texcoord : TEXCOORD
    ) : SV_Target
    {
        float2 uv = texcoord;

        float div = lerp(1, 300, _Effect1);

        uv -= 0.5;

        float rot_sin = sin(_Angle2 * UNITY_PI);
        float rot_cos = cos(_Angle2 * UNITY_PI);
        float d = dot(uv, float2(rot_cos, -rot_sin));
        uv += float2(rot_sin, rot_cos) * (Random(d * 20 + 100) - 0.5) * 2 * _Effect2;

        uv = floor(uv * _MainTex_TexelSize.zw / div + 0.5);
        uv *= div * _MainTex_TexelSize.xy;

        uv += 0.5;

        uv.x += (Random(uv.y * _MainTex_TexelSize.w * 1000 + _Time.y * 60) - 0.5) * 0.2 * _Effect3;

        half lm = Luminance(tex2Dlod(_MainTex, float4(uv, 0, 0)).rgb) + _Effect4;
        half3 rgb = lm > _Thresh2 ? _Color2 : (lm > _Thresh1 ? _Color1 : 0);
        return half4(rgb, 1);
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
