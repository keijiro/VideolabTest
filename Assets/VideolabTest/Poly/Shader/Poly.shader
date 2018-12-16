Shader "VideolabTest/Poly"
{
    Properties
    {
        [KeywordEnum(Stretch, Spike, Twist, Bend)]
        _ModType("Type", Float) = 0
        _ModAmount("Amount", Float) = 0
        _ModOrigin("Origin", Vector) = (0, 0, 0, 0)
        _ModParam("Parameter", Float) = 1
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }

        CGPROGRAM

        #pragma surface surf Lambert vertex:vert addshadow exclude_path:deferred exclude_path:prepass nolightmap
        #pragma multi_compile _MODTYPE_STRETCH _MODTYPE_SPIKE _MODTYPE_TWIST _MODTYPE_BEND
        #pragma target 3.0

        #include "../../Common/Shader/Common.hlsl"

        float _ModAmount;
        float3 _ModOrigin;
        float _ModParam;

        struct Input { float4 color : COLOR; };

        float2 cossin(float phi)
        {
            return float2(cos(phi), sin(phi));
        }

        float3 Modifier(float3 p)
        {
        #ifdef _MODTYPE_STRETCH
            p -= _ModOrigin;

            float e = _ModAmount / 2;
            float d = (p.y / _ModParam - 0.5) * 2;

            p.y *= 1 + _ModAmount;
            p.xz *= 1 - e * (1 - d * d);

            p += _ModOrigin;
        #endif

        #ifdef _MODTYPE_SPIKE
            float rand = Random((p.x + p.y + p.z + _ModParam) * 1000);
            p += normalize(p - _ModOrigin) * rand * _ModAmount * (rand > 0.8);
        #endif

        #ifdef _MODTYPE_TWIST
            float phi = lerp(0.5, 1, Random(_ModParam * 2));
            phi *= Random(_ModParam * 2 + 1) > 0.5 ? 1 : -1;
            phi *= (p.y - _ModOrigin.y) * _ModAmount;

            float2x2 rot = float2x2(cos(phi), -sin(phi), sin(phi), cos(phi));
            p.xz = mul(rot, p.xz - _ModOrigin.xz) + _ModOrigin.xz;
        #endif

        #ifdef _MODTYPE_BEND
            half yaw = Random(_ModParam) * UNITY_PI * 2;

            float4 cs = cossin(yaw).xyxy * float4(1, 1, -1, -1);
            float2x2 rot = float2x2(cs.xw, cs.yx);
            float2x2 irot = float2x2(cs.xy, cs.wx);

            float d = 1 / max(abs(_ModAmount), 1e-4);

            p -= _ModOrigin;
            p.xz = mul(rot, p.xz);
            p.z += d;

            p.zy = cossin(p.y / d) * p.z;

            p.z -= d;
            p.xz = mul(irot, p.xz);
            p += _ModOrigin;
        #endif

            return p;
        }

        void vert(inout appdata_full v)
        {
            float3 p0 = Modifier(v.vertex.xyz);
            float3 p1 = Modifier(v.texcoord.xyz);
            float3 p2 = Modifier(v.texcoord1.xyz);
            v.vertex.xyz = p0;
            v.normal = normalize(cross(p1 - p0, p2 - p0));
        }

        void surf(Input IN, inout SurfaceOutput o)
        {
            o.Albedo = IN.color.rgb;
            o.Alpha = IN.color.a;
        }

        ENDCG
    }
    FallBack "Diffuse"
}
