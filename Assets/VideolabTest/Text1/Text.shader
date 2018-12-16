Shader "VideolabTest/Text"
{
    Properties
    {
        _Speed("Speed", Float) = 8
        _Deform("Deformation", Float) = 0
        _Freq("Frequency", Float) = 1
    }
    CGINCLUDE

    #include "UnityCG.cginc"
    #include "../Common/Shader/Common.hlsl"
    #include "../Common/Shader/SimplexNoise2D.hlsl"

    half _Speed;
    half _Deform;
    half _Freq;

    float4 Vertex(float4 position : POSITION) : SV_Position
    {
        float nx = position.x * _Freq + position.z - _Speed * _Time.y;
        float ny = position.y * _Freq;
        position.xy += snoise_grad(float2(nx, ny)).xy * _Deform;
        return UnityObjectToClipPos(position);
    }

    fixed4 Fragment(float4 position : SV_Position) : SV_Target
    {
        return 1;
    }

    ENDCG

    SubShader
    {
        Pass
        {
            Tags { "LightMode"="ShadowCaster" }
            CGPROGRAM
            #pragma vertex Vertex
            #pragma fragment Fragment
            ENDCG
        }
    }
}
