Shader "Custom/Noise_Effect"
{
    Properties
    {
        _Progress  ("Progress",    Range(0,1))   = 0
        _Scale     ("Noise Scale", Float)        = 4.0
        _EdgeWidth ("Edge Width",  Range(0,0.2)) = 0.05
        _EdgeColor ("Edge Color",  Color)        = (1, 0.3, 0.0, 1)
        _MainColor ("Main Color",  Color)        = (0.0, 0.0, 0.0, 1)
    }

    SubShader
    {
        Tags { "Queue"="Overlay" }
        Blend SrcAlpha OneMinusSrcAlpha
        ZTest Always
        ZWrite Off
        Cull Off

        Pass
        {
            CGPROGRAM
            #pragma vertex   vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            struct Attributes { float4 vertex : POSITION; float2 uv : TEXCOORD0; };
            struct Varyings   { float4 pos    : SV_POSITION; float2 uv : TEXCOORD0; };

            float  _Progress, _Scale, _EdgeWidth;
            float4 _EdgeColor, _MainColor;

            // ── Hash ─────────────────────────────────────────────
            float Hash(float2 p)
            {
                return frac(sin(dot(p, float2(127.1, 311.7))) * 43758.5453);
            }

            float ValueNoise(float2 uv)
            {
                float2 i = floor(uv);
                float2 f = frac(uv);
                float2 u = f * f * (3.0 - 2.0 * f); 

                float a = Hash(i + float2(0,0));
                float b = Hash(i + float2(1,0));
                float c = Hash(i + float2(0,1));
                float d = Hash(i + float2(1,1));

                return lerp(lerp(a, b, u.x), lerp(c, d, u.x), u.y);
            }

            float Fbm(float2 uv)
            {
                float value = 0.0;
                float amp   = 0.5;

                value += ValueNoise(uv * 1.0) * amp; amp *= 0.5;
                value += ValueNoise(uv * 2.0) * amp; amp *= 0.5;
                value += ValueNoise(uv * 4.0) * amp;

                return value;
            }

            Varyings vert(Attributes IN)
            {
                Varyings OUT;
                OUT.pos = UnityObjectToClipPos(IN.vertex);
                OUT.uv  = IN.uv;
                return OUT;
            }

            half4 frag(Varyings IN) : SV_Target
            {
                if (_Progress <= 0.001) discard;

                float noise = Fbm(IN.uv * _Scale);
                if (noise > _Progress) discard;

                float edge = smoothstep(_Progress - _EdgeWidth, _Progress, noise);
                half4 col  = lerp(_MainColor, _EdgeColor, edge);
                col.a = 1.0;
                return col;
            }
            ENDCG
        }
    }
}
