Shader "VideolabTest/RingParticle"
{
    Properties
    {
        _Width("Width", Float) = 1
    }

    CGINCLUDE

    #include "UnityCG.cginc"

    half _Width;

    float4 Vertex(
        float4 position : POSITION,
        inout float2 uv : TEXCOORD,
        inout fixed4 color : COLOR
    ) : SV_Position
    {
        return UnityObjectToClipPos(position);
    }

    fixed4 Fragment(
        float4 position : SV_Position,
        float2 uv : TEXCOORD,
        fixed4 color : COLOR
    ) : SV_Target
    {
        float l = length(uv - 0.5);
        float a = (1 - abs(l - 0.46) / (fwidth(uv) * _Width));
        return fixed4(color.rgb, color.a * a);
    }

    ENDCG

    SubShader
    {
        Pass
        {
            ZWrite Off
            Blend SrcAlpha OneMinusSrcAlpha
            CGPROGRAM
            #pragma vertex Vertex
            #pragma fragment Fragment
            ENDCG
        }
    }
}
