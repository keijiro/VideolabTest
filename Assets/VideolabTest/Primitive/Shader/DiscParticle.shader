Shader "VideolabTest/DiscParticle"
{
    CGINCLUDE

    #include "UnityCG.cginc"

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
        float a = length(uv - 0.5) < 0.49;
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
