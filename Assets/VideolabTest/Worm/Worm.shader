Shader "VideolabTest/Worm"
{
    Properties
    {
        _Color1("Color 1", Color) = (1, 0, 0, 1)
        _Color2("Color 2", Color) = (0, 0, 1, 1)
        _Repeat("Repeat", Float) = 10
        _Lissajous("Lissajous", Vector) = (4.21, 6.23, 7.43, 2.12)
        _Radius("Radius", Float) = 0.2
    }

    CGINCLUDE

    #include "UnityCG.cginc"

    half4 _Color1;
    half4 _Color2;
    half _Repeat;
    half4 _Lissajous;
    half _Radius;

    // Lissajous curve function
    float3 Curve(float z)
    {
        float t = z + _Time.y;
        return sin(_Lissajous.xyz * t) * sin(_Lissajous.w * t) * 2;
    }

    // Construct a Frenet-Serret TNB frame with a series of points on a curve.
    // p0: position at t - dt
    // p1: position at t
    // p2: position at t + dt
    float4x4 FrenetSerret(float3 p0, float3 p1, float3 p2)
    {
        float3 T = normalize(p2 - p0);
        //float3 N = normalize(normalize(p2 - p1) - normalize(p1 - p0));
        // We don't use an actual Frenet-Serret to avoid twisting.
        float3 N = normalize(cross(float3(1, 0, 0), T));
        float3 B = normalize(cross(T, N));
        return transpose(float4x4(N, 0, B, 0, T, 0, p1, 1));
    }

    float4 VertexFill(
        float4 position : POSITION,
        out half3 normal : NORMAL,
        out float stripe : TEXCOORD
    ) : SV_Position
    {
        const float cap_range = 0.05;

        float phi = position.x * UNITY_PI * 2;
        float z = saturate(position.y * (1 + cap_range * 2) - cap_range);
        float cap = min(1, min(position.y, 1 - position.y) / cap_range);
        cap *= UNITY_PI / 2;

        float r = _Radius * sin(cap);
        float gx = r * cos(phi);
        float gy = r * sin(phi);
        float gz = _Radius * cos(cap) * (z < 0.5 ? -1 : 1);

        z += 0.2 * gz;

        const float dz = 1e-2;
        float4x4 m = FrenetSerret(Curve(z - dz), Curve(z), Curve(z + dz));

        normal = UnityObjectToWorldNormal(mul((float3x3)m, half3(gx, gy ,gz)));
        stripe = z * _Repeat;
        return UnityObjectToClipPos(mul(m, float4(gx, gy, 0, 1)));
    }

    half4 FragmentFill(
        float4 position : SV_Position,
        half3 normal : NORMAL,
        float stripe : TEXCOORD
    ) : SV_Target
    {
        half4 c = frac(stripe) < 0.5 ? _Color1 : _Color2;
        half d = dot(_WorldSpaceLightPos0.xyz, normalize(normal));
        return lerp(0, lerp(c, 1, (d > 0.9) * 0.5), 0.3 + (d > -0.1) * 0.7);
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
    }
}
