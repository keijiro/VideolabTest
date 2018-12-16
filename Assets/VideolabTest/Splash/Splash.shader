Shader "VideolabTest/Splash"
{
    Properties
    {
        _Color("Color", Color) = (1, 0, 0, 1)
    }

    CGINCLUDE

    #include "UnityCG.cginc"
    #include "../Common/Shader/Common.hlsl"
    #include "../Common/Shader/SimplexNoise2D.hlsl"

    half4 _Color;

    float4 Vertex(
        float4 position : POSITION,
        inout float4 texcoord : TEXCOORD
    ) : SV_Position
    {
        return UnityObjectToClipPos(position);
    }

    half4 Fragment(
        float4 position : SV_Position,
        float4 texcoord : TEXCOORD
    ) : SV_Target
    {
        // Parameters from the particle system
        float seed = texcoord.z;
        float time = texcoord.w;

        // Animated radius parameter
        float tp = 1 - time;
        float radius = 1 - tp * tp * tp * tp * tp * tp * tp * tp;

        // Zero centered UV
        float2 uv = texcoord.xy - 0.5;

        // Noise 1 - Radial curve
        float freq = lerp(1.2, 2.7, Random(seed * 48923.23));
        float n1 = snoise(atan2(uv.x, uv.y) * freq + seed * 764.2174);

        // I prefer steep curves, so use sixth power.
        float n1p = n1 * n1;
        n1p = n1p * n1p * n1p;

        // Noise 2 - Small dot
        float n2 = snoise(uv * 8 / radius + seed * 1481.28943);

        // Potential = radius + noise * radius ^ 3;
        float p = radius * (0.23 + radius * radius * (n1p * 0.9 + n2 * 0.07));

        // Slitline pattern
        float sp = abs(1 - frac(uv.y * 16) * 2);

        // Cutout
        clip(min(p - length(uv), sp + 4 - time * 5));

        return _Color;
    }

    ENDCG

    SubShader
    {
        Tags { "Queue" = "AlphaTest" }
        Pass
        {
            CGPROGRAM
            #pragma vertex Vertex
            #pragma fragment Fragment
            ENDCG
        }
    }
}
