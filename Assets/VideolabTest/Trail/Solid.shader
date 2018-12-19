Shader "VideolabTest/Solid"
{
    Properties
    {
        _FillColor("Color (fill)", Color) = (1, 0, 0, 1)
        _ShadowColor("Color (shadow)", Color) = (0, 0, 0, 1)
    }

    CGINCLUDE

    #include "UnityCG.cginc"
    #include "../Common/Shader/Common.hlsl"

    half4 _FillColor;
    half4 _ShadowColor;

    float4 VertexFill(
        float4 position : POSITION,
        inout half3 normal : NORMAL,
        out float elevation : TEXCOORD
    ) : SV_Position
    {
        float4 wp = mul(unity_ObjectToWorld, position);
        elevation = wp.y;
        normal = UnityObjectToWorldNormal(normal);
        return UnityWorldToClipPos(wp);
    }

    half4 FragmentFill(
        float4 position : SV_Position,
        half3 normal : NORMAL,
        float elevation : TEXCOORD
    ) : SV_Target
    {
        clip(elevation);
        half d = dot(_WorldSpaceLightPos0.xyz, normalize(normal));
        return d < 0 ? _ShadowColor : lerp(_FillColor, 1, (d > 0.9) * 0.5);
    }

    float4 VertexShadow(
        float4 position : POSITION,
        out float elevation : TEXCOORD
    ) : SV_Position
    {
        float4 wp = mul(unity_ObjectToWorld, position);
        elevation = wp.y;
        wp.xz -= _WorldSpaceLightPos0.xz * wp.y / _WorldSpaceLightPos0.y;
        wp.y = 0;
        return UnityWorldToClipPos(wp);
    }

    half4 FragmentShadow(
        float4 position : SV_Position,
        float elevation : TEXCOORD
    ) : SV_Target
    {
        clip(elevation);
        return _ShadowColor;
    }

    ENDCG

    SubShader
    {
        Pass
        {
            Tags { "LightMode" = "ForwardBase" }
            CGPROGRAM
            #pragma vertex VertexFill
            #pragma fragment FragmentFill
            ENDCG
        }
        Pass
        {
            Tags { "LightMode" = "ForwardBase" }
            CGPROGRAM
            #pragma vertex VertexShadow
            #pragma fragment FragmentShadow
            ENDCG
        }
    }
}
