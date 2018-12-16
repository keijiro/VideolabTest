Shader "VideolabTest/Text2"
{
    Properties
    {
        [Header(Deformation Parameters)]
        _Deform("Deformation", Float) = 0

        [Header(Pattern Parameters)]
        [KeywordEnum(Dots, Bars)]
        _Type("Type", Float) = 0
        _Color1("Color 1", Color) = (1, 1, 1, 1)
        _Color2("Color 2", Color) = (0, 0, 0, 1)
        _Size("Size", Float) = 1

        [Header(Pattern Transformation)]
        _Offset("Offset (X,Y,0,0)", Vector) = (0, 0, 0, 0)
        _Scale("Scale (X,Y,0,0)", Vector) = (1, 1, 0, 0)
        _Rotation("Rotation", Float) = 0
    }
    CGINCLUDE

    #include "UnityCG.cginc"
    #include "../Common/Shader/Common.hlsl"
    #include "../Common/Shader/SimplexNoise2D.hlsl"

    half _Deform;

    half4 _Color1;
    half4 _Color2;
    half _Size;

    half2 _Offset;
    half2 _Scale;
    half _Rotation;

    float4 Vertex(float4 position : POSITION) : SV_Position
    {
        float nx = position.x * 10 + position.z - _Time.y * 2;
        float ny = position.y * 10;
        position.xy += snoise_grad(float2(nx, ny)).xy * _Deform;
        return UnityObjectToClipPos(position);
    }

    fixed4 Fragment(float4 position : SV_Position) : SV_Target
    {
        // Center-origined UV coordinates
        float2 uv = position.xy * (_ScreenParams.z - 1);
        uv -= float2(0.5, 0.5 * (_ScreenParams.z - 1) * _ScreenParams.y);

        // Scale
        uv *= _Scale;

        // Rotation
        float rot_sin = sin(_Rotation);
        float rot_cos = cos(_Rotation);
        uv = mul(float2x2(rot_cos, -rot_sin, rot_sin, rot_cos), uv);

        // Offset
        uv += _Offset * half2(-1, 1);

        #if defined(_TYPE_DOTS)

        float y = uv.y;
        float x = uv.x + 0.5 * (frac(uv.y / 2) > 0.5);

        float fy = frac(y);
        float fx = frac(x);

        float n = snoise(float2(x - fx, y - fy) * 0.1 + _Time.y * 0.6);

        float d = length(float2(fx, fy) - 0.5);
        float fw = max(fwidth(uv.x), fwidth(uv.y));
        float cp = saturate((_Size * (0.3 + 0.2 * n) - d) / fw);

        #elif defined(_TYPE_BARS)

        float n = snoise(float2(uv.x, _Time.y));
        float fw = fwidth(uv.x) * 2;
        float cp = saturate(1 - (abs(n) - _Size + fw) / (fw * (1 + fw)));

        #endif

        return lerp(_Color1, _Color2, cp);
    }

    ENDCG

    SubShader
    {
        Pass
        {
            Cull Off
            CGPROGRAM
            #pragma multi_compile _TYPE_DOTS _TYPE_BARS
            #pragma vertex Vertex
            #pragma fragment Fragment
            ENDCG
        }
    }
}
