Shader "VideolabTest/Shutter"
{
    Properties
    {
        _Color1("Color 1", Color) = (1, 0, 0, 1)
        _Color2("Color 2", Color) = (0, 0, 1, 1)
        _Repeat("Repeat", Float) = 10
        _Angle("Angle", Float) = 0
        _Threshold("Threshold", Range(0, 1)) = 0.5
        _Border("Border", Float) = 0.1
    }

    CGINCLUDE

    #include "UnityCG.cginc"
    #include "../Common/Shader/Common.hlsl"

    half4 _Color1;
    half4 _Color2;
    half _Repeat;
    half _Angle;
    half _Threshold;
    half _Border;

    float4 Vertex(float4 position : POSITION) : SV_Position
    {
        return UnityObjectToClipPos(position);
    }

    half4 Fragment(float4 position : SV_Position) : SV_Target
    {
        // Center-origined UV coordinates
        float2 uv = position.xy * (_ScreenParams.z - 1);
        uv -= float2(0.5, 0.5 * (_ScreenParams.z - 1) * _ScreenParams.y);

        // Potential value
        float p = dot(uv, float2(cos(_Angle), sin(_Angle))) * _Repeat;
        float fw = fwidth(p);

        // Remap threshold to cover AA
        float th = _Threshold * (1 + fw) - fw;

        // Color parameter
        float i = saturate((abs(frac(p) - 0.5) * 2 - th) / fw);

        // Border
        float bd = _Border * _ScreenParams.x;
        i += any(position.xy < bd) + any(position.xy > _ScreenParams.xy - bd);

        return lerp(_Color2, _Color1, saturate(i));
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
