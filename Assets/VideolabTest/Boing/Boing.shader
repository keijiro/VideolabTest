Shader "VideolabTest/Boing"
{
    Properties
    {
        _Color("Color", Color) = (1, 1, 1, 1)
        [KeywordEnum(Boing, Boom, Tschak)]
        _Type("Deformation Type", Float) = 0
        _Deform("Parameter", Range(0, 1)) = 0
    }

    CGINCLUDE

    #include "UnityCG.cginc"
    #include "../Common/Shader/Common.hlsl"
    #include "../Common/Shader/SimplexNoise2D.hlsl"

    fixed _Deform;
    half4 _Color;

    float4 Vertex(float4 position : POSITION) : SV_Position
    {
#if defined(_TYPE_BOING)
        float2 np = position.xy * 10 + float2(1, 8) * _Time.y;
        position.xy *= 1 + snoise(np) * _Deform;
#elif defined(_TYPE_BOOM)
        float phase = saturate(_Deform * 1.3 - abs(position.x * 0.2));
        position.y *= smoothstep(0, 1, sin(phase * UNITY_PI));
#elif defined(_TYPE_TSCHAK)
        uint id = dot(position.xy, float2(10000, 100)) + 1000000;
        float2 dp = float2(Random(id), Random(id + 1)) * 2 - 1;
        position.xy += dp * _Deform;
#endif
        return UnityObjectToClipPos(position);
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
            Cull Off
            CGPROGRAM
            #pragma vertex Vertex
            #pragma fragment Fragment
            #pragma multi_compile _TYPE_BOING _TYPE_BOOM _TYPE_TSCHAK
            ENDCG
        }
    }
}
