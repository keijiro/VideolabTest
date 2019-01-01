Shader "VideolabTest/Stripe"
{
    Properties
    {
        _Color1("Color 1", Color) = (1, 1, 1, 1)
        _Color2("Color 2", Color) = (0, 0, 0, 1)
        _Rows("Row Count", Float) = 10
        _Seed("Seed", Float) = 0
        _Threshold("Threshold", Float) = 0
        _Rotation("Rotation", Float) = 0

        [Header(Deformation Parameters)]
        _Deform("Deformation", Float) = 0
    }
    CGINCLUDE

    #include "UnityCG.cginc"
    #include "../Common/Shader/Common.hlsl"
    #include "../Common/Shader/SimplexNoise2D.hlsl"

    half _Deform;

    half4 _Color1;
    half4 _Color2;
    half _Rows;
    float _Seed;
    half _Threshold;
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
        // Screen center origined UV coordinates
        float2 uv = position.xy * (_ScreenParams.z - 1);
        uv -= float2(0.5, 0.5 * (_ScreenParams.z - 1) * _ScreenParams.y);

        // Rotation
        float rot_sin = sin(_Rotation);
        float rot_cos = cos(_Rotation);
        uv = mul(float2x2(rot_cos, -rot_sin, rot_sin, rot_cos), uv);

        float y = uv.y * _Rows * 2 + 1;
        float ln = floor(y);

        uint id0 = ln + floor(_Seed    ) * 30;
        uint id1 = ln + floor(_Seed + 1) * 30;

        float x0 = (uv.x + Random(id0 + 12345)) * lerp(0, 20, Random(id0));
        float x1 = (uv.x + Random(id1 + 12345)) * lerp(0, 20, Random(id1));

        float p = frac(_Seed);
        float3 n = snoise_grad(float2(lerp(x0, x1, p), ln * 100 + 50));

        half cp1 = (n.z - _Threshold) * 100;
        half cp2 = (1 - abs(y - ln - 0.5) * 2.1) / (fwidth(y) * 2);

        return lerp(_Color1, _Color2, min(saturate(cp1), saturate(cp2)));
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
