Shader "Custom/Glitch_Effect"
{
   Properties
    {
        _Progress       ("Progress",        Range(0,1))   = 0
        _MainColor      ("Main Color",      Color)        = (0,0,0,1)
        _RGBStrength    ("RGB Split",       Range(0,0.05))= 0.02
        _ScanlineSpeed  ("Scanline Speed",  Float)        = 3.0
        _NoiseStrength  ("Noise Strength",  Range(0,1))   = 0.6
    }

    SubShader
    {
        Tags { "Queue"="Overlay" }
        Blend SrcAlpha OneMinusSrcAlpha
        ZTest Always ZWrite Off Cull Off

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            struct Attributes { float4 vertex:POSITION; float2 uv:TEXCOORD0; };
            struct Varyings   { float4 pos:SV_POSITION; float2 uv:TEXCOORD0; };

            float  _Progress, _RGBStrength, _ScanlineSpeed, _NoiseStrength;
            float4 _MainColor;

            float Hash(float2 p)
            {
                return frac(sin(dot(p, float2(127.1, 311.7))) * 43758.5453);
            }

            float SignalNoise(float2 uv, float t)
            {
                float band    = floor(uv.y * 120.0);      
                float flicker = floor(t * _ScanlineSpeed);
                return Hash(float2(band, flicker));
            }

            float2 Distort(float2 uv, float t)
            {
                float row      = floor(uv.y * 60.0 + t * 2.0);  
                float strength = Hash(float2(row, floor(t * 4.0)));
                strength       = pow(strength, 3.0) * _Progress;
                uv.x          += (strength - 0.5) * 0.08 * _Progress;
                return uv;
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

                float  t  = _Time.y;
                float2 uv = Distort(IN.uv, t);

                float noise   = SignalNoise(uv, t);
                float visible = step(1.0 - _Progress, noise * 0.7 + _Progress * 0.4);
                if (visible < 0.5) discard;

                float aberr = _RGBStrength * _Progress;
                float r     = SignalNoise(uv + float2( aberr, 0), t + 0.1);
                float g     = SignalNoise(uv,                      t);
                float b     = SignalNoise(uv + float2(-aberr, 0), t - 0.1);

                float scanline = sin(uv.y * 800.0) * 0.04;

                half4 col  = _MainColor;
                col.rgb   += float3(r, g, b) * 0.08 * _NoiseStrength;
                col.rgb   += scanline;
                col.rgb    = saturate(col.rgb);
                col.a      = 1.0;
                return col;
            }
            ENDCG
        }
    }
}
