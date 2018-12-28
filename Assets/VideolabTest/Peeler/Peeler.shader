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
        _Group1("Highlight Group 1", Range(0, 1)) = 0
        _Group2("Highlight Group 2", Range(0, 1)) = 0
        _Group3("Highlight Group 3", Range(0, 1)) = 0
        _Group4("Highlight Group 4", Range(0, 1)) = 0
    }

    CGINCLUDE

    #include "UnityCG.cginc"
    #include "../Common/Shader/Common.hlsl"
    #include "../Common/Shader/SimplexNoise3D.hlsl"

    half3 _LightColor0;

    fixed3 _FillColor, _LineColor;
    fixed _Deform1, _CutOff1;
    fixed _Deform2, _CutOff2;
    fixed _Group1, _Group2, _Group3, _Group4;

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
        out fixed4 params : COLOR // bc_coord.xyz, hightlight
    )
    {
        uint pid = texcoord0.w;
        uint vid = texcoord1.w;
        uint group = Hash(pid) & 3;

        float3 p0 = Deform(position.xyz);
        float3 p1 = Deform(texcoord0.xyz);
        float3 p2 = Deform(texcoord1.xyz);

        half3 n0 = normalize(cross(p1 - p0, p2 - p0));

        half hl = saturate(
            (group == 0 ? 1.0 : 0.0) * _Group1 +
            (group == 1 ? 1.0 : 0.0) * _Group2 +
            (group == 2 ? 1.0 : 0.0) * _Group3 +
            (group == 3 ? 1.0 : 0.0) * _Group4
        );

        cs_position = UnityObjectToClipPos(float4(p0, 1));
        os_position = position.xyz;
        ws_normal = UnityObjectToWorldNormal(n0);
        params = fixed4(vid == 0, vid == 1, vid == 2, hl);
    }

    fixed4 Fragment(
        float4 cs_position : SV_Position,
        float3 os_position : TEXCOORD,
        half3 ws_normal : NORMAL,
        fixed4 params : COLOR,
        half vface : VFACE
    ) : SV_Target
    {
        // Workaround for issue #926424
        #if UNITY_VERSION < 570 && defined(SHADER_API_MOBILE)
        bool flip = vface > 0;
        #else
        bool flip = vface < 0;
        #endif

        // Highlighting
        half hl = params.w * 1.1 - min(min(params.x, params.y), params.z) * 3;

        // Noise field potential
        float3 np1 = os_position * float3(1, 10, 1) + float3(2, 0, 0) * _Time.y;
        float3 np2 = os_position * float3(10, 1, 1) + float3(0, 2, 0) * _Time.y;
        half2 npot = half2(snoise(np1), snoise(np2)) + 1 - half2(_CutOff1, _CutOff2) * 2;

        // Cutout
        clip(max(hl, max(npot.x, npot.y)));

        // Edge detection
        half3 e1 = params.xyz / fwidth(params.xyz);
        half2 e2 = npot / fwidth(npot * 2);
        half edge = saturate(1 - min(min(min(e1.x, e1.y), e1.z), max(e2.x, e2.y)));
        edge = max(edge, smoothstep(0, 0.1, hl));

        // Lighting
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
