Shader "VideolabTest/Sphere"
{
    Properties
    {
        _FillColor("Fill Color", Color) = (1, 1, 1, 1)
        _LineColor("Line Color", Color) = (1, 1, 1, 1)
        _Effect1("Effect 1", Range(0, 1)) = 0
        _Effect2("Effect 2", Range(0, 1)) = 0
        _Effect3("Effect 3", Range(0, 1)) = 0
        _Effect4("Effect 4", Range(0, 1)) = 0
        _Effect5("Effect 5", Range(0, 1)) = 0
        _Effect6("Effect 6", Range(0, 1)) = 0
        _Effect7("Effect 7", Range(0, 1)) = 0
        _Effect8("Effect 8", Range(0, 1)) = 0
    }
    CGINCLUDE

    #include "UnityCG.cginc"
    #include "../Common/Shader/Common.hlsl"
    #include "../Common/Shader/SimplexNoise3D.hlsl"

    fixed3 _FillColor, _LineColor;
    fixed _Effect1, _Effect2, _Effect3, _Effect4;
    fixed _Effect5, _Effect6, _Effect7, _Effect8;

    float3 Deform(float3 p)
    {
        float amp = _Effect1 + _Effect2 + _Effect3 + _Effect4 +
                    _Effect5 + _Effect6 + _Effect7 + _Effect8;
        return p * (1 + 0.2 * amp * snoise(p * 7 + _Time.y * 2));
    }

    float4 Vertex(
        float4 position : POSITION,
        float4 texcoord0 : TEXCOORD,
        float4 texcoord1 : TEXCOORD1,
        out fixed4 params : COLOR // bc_coord.xyz, alpha
    ) : SV_Position
    {
        uint pid = texcoord0.w;
        uint vid = texcoord1.w;
        uint group = Hash(pid) & 7;

        float3 p0 = Deform(position.xyz);
        float3 p1 = Deform(texcoord0.xyz);
        float3 p2 = Deform(texcoord1.xyz);
        half3 normal = normalize(cross(p1 - p0, p2 - p0));

        half alpha = saturate(
            (group == 0 ? 1.0 : 0.0) * _Effect1 +
            (group == 1 ? 1.0 : 0.0) * _Effect2 +
            (group == 2 ? 1.0 : 0.0) * _Effect3 +
            (group == 3 ? 1.0 : 0.0) * _Effect4 +
            (group == 4 ? 1.0 : 0.0) * _Effect5 +
            (group == 5 ? 1.0 : 0.0) * _Effect6 +
            (group == 6 ? 1.0 : 0.0) * _Effect7 +
            (group == 7 ? 1.0 : 0.0) * _Effect8
        );
        alpha *= (dot(_WorldSpaceLightPos0.xyz, normal) + 1) / 2;

        params = half4(vid == 0, vid == 1, vid == 2, alpha);
        return UnityObjectToClipPos(float4(p0, 1));
    }

    fixed4 Fragment(
        float4 position : SV_Position,
        fixed4 params : COLOR
    ) : SV_Target
    {
        half3 bc = params.xyz / fwidth(params.xyz);
        half edge = saturate(1 - min(min(bc.x, bc.y), bc.z));
        return half4(_FillColor * params.w + _LineColor * edge, 1);
    }

    ENDCG

    SubShader
    {
        Pass
        {
            Tags { "LightMode" = "ForwardBase" }
            Blend One One
            ZWrite Off
            CGPROGRAM
            #pragma vertex Vertex
            #pragma fragment Fragment
            ENDCG
        }
    }
}
