Shader "VideolabTest/Peeler"
{
    Properties
    {
        _FillColor("Fill Color", Color) = (1, 1, 1, 1)
        _LineColor("Line Color", Color) = (0, 0, 0, 1)
        _Deform1("Deform 1", Float) = 0.5
        _Deform2("Deform 2", Float) = 0.5
        _CutOff1("CutOff 1", Range(0, 1)) = 0.5
        _CutOff2("CutOff 2", Range(0, 1)) = 0.5
    }
    CGINCLUDE

    #include "UnityCG.cginc"
    #include "../Common/Shader/Common.hlsl"
    #include "../Common/Shader/SimplexNoise3D.hlsl"

    half3 _LightColor0;

    fixed3 _FillColor, _LineColor;
    fixed _Deform1, _CutOff1;
    fixed _Deform2, _CutOff2;

    float3 Deform(float3 p)
    {
        float3 np = p * 3 + float3(0, 2, 0) * _Time.y;
        return p * (1 + _Deform1 * snoise(np) + _Deform2 * snoise(np * 3));
    }

    void Vertex(
        float4 position : POSITION,
        float4 texcoord0 : TEXCOORD,
        float4 texcoord1 : TEXCOORD1,
        out float4 cs_position : SV_Position,
        out float3 os_position : TEXCOORD,
        out half3 ws_normal : NORMAL,
        out fixed3 bc_coord : COLOR
    )
    {
        uint vid = texcoord1.w;
        float3 p0 = Deform(position.xyz);
        float3 p1 = Deform(texcoord0.xyz);
        float3 p2 = Deform(texcoord1.xyz);
        half3 n0 = normalize(cross(p1 - p0, p2 - p0));

        cs_position = UnityObjectToClipPos(float4(p0, 1));
        os_position = position.xyz;
        ws_normal = UnityObjectToWorldNormal(n0);
        bc_coord = fixed3(vid == 0, vid == 1, vid == 2);
    }

    fixed4 Fragment(
        float4 cs_position : SV_Position,
        float3 os_position : TEXCOORD,
        half3 ws_normal : NORMAL,
        fixed3 bc_coord : COLOR,
        half vface : VFACE
    ) : SV_Target
    {
        bool flip = vface < 0;

        float3 np1 = os_position * float3(1, 10, 1) + float3(2, 0, 0) * _Time.y;
        float3 np2 = os_position * float3(10, 1, 1) + float3(0, 2, 0) * _Time.y;
        half2 pot = half2(snoise(np1), snoise(np2)) + 1 - half2(_CutOff1, _CutOff2) * 2;

        clip(max(pot.x, pot.y));

        half3 ep = bc_coord / fwidth(bc_coord);
        half2 pp = pot / fwidth(pot * 2);
        half edge = saturate(1 - min(min(min(ep.x, ep.y), ep.z), max(pp.x, pp.y)));

        half3 nrm = normalize((flip ? -1 : 1) * ws_normal);
        half l = dot(_WorldSpaceLightPos0.xyz, nrm) * 0.5 + 0.5;

        half3 c = lerp(_FillColor, _LineColor, edge);
        c *= _LightColor0 * l * (flip ? 0.5 : 1);

        return half4(c, 1);
    }

    ENDCG

    SubShader
    {
        Pass
        {
            Cull Off
            Tags { "LightMode" = "ForwardBase" }
            CGPROGRAM
            #pragma vertex Vertex
            #pragma fragment Fragment
            ENDCG
        }
    }
}
