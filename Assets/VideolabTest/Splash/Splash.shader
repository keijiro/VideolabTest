Shader "VideoLabTest/Splash"
{
    CGINCLUDE

    #include "UnityCG.cginc"
    #include "../Common/Shader/SimplexNoise2D.hlsl"

    // Hash function from H. Schechter & R. Bridson, goo.gl/RXiKaH
    uint Hash(uint s)
    {
        s ^= 2747636419u;
        s *= 2654435769u;
        s ^= s >> 16;
        s *= 2654435769u;
        s ^= s >> 16;
        s *= 2654435769u;
        return s;
    }

    float Random(uint seed)
    {
        return float(Hash(seed)) / 4294967295.0; // 2^32-1
    }

    float4 Vertex(
        float4 position : POSITION,
        inout float4 texcoord : TEXCOORD,
        inout half4 color : COLOR
    ) : SV_Position
    {
        return UnityObjectToClipPos(position);
    }

    half4 Fragment(
        float4 position : SV_Position,
        float4 texcoord : TEXCOORD,
        half4 color : COLOR
    ) : SV_Target
    {
        // Parameters from the particle system
        float seed = texcoord.z;
        float time = texcoord.w;

        // Animated radius parameter
        float tp = 1 - time;
        float radius = 1 - tp * tp * tp * tp;

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

        // Antialiased thresholding
        float l = length(uv);
        float a = smoothstep(l - 0.01, l, p);

        return half4(color.rgb, color.a * a);
    }

    ENDCG

    SubShader
    {
        Pass
        {
            ZWrite Off
            Blend SrcAlpha One
            CGPROGRAM
            #pragma vertex Vertex
            #pragma fragment Fragment
            ENDCG
        }
    }
}
