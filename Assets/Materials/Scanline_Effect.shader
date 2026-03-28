Shader "Custom/Scanline"
{
     Properties
    {
        _Progress      ("Progress",       Range(0,1))  = 0
        _MainColor     ("Main Color",     Color)       = (0.0, 0.0, 0.0, 1)
        _ScanColor     ("Scanline Color", Color)       = (0.0, 1.0, 0.8, 1)
        _LineCount     ("Line Count",     Float)       = 80.0
        _LineSharpness ("Line Sharpness", Range(1,20)) = 8.0
        _GlowWidth     ("Glow Width",     Range(0,0.3))= 0.12
        _ScrollSpeed   ("Scroll Speed",   Float)       = 1.5
        _Flicker       ("Flicker",        Range(0,1))  = 0.3
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

            float  _Progress, _LineCount, _LineSharpness, _GlowWidth, _ScrollSpeed, _Flicker;
            float4 _MainColor, _ScanColor;

            float Hash(float2 p)
            {
                return frac(sin(dot(p, float2(127.1, 311.7))) * 43758.5453);
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

                float t   = _Time.y;
                float2 uv = IN.uv;

                float jitterRow    = floor(uv.y * 40.0);
                float jitterAmount = Hash(float2(jitterRow, floor(t * 12.0)));
                jitterAmount       = pow(jitterAmount, 6.0) * 0.015 * _Progress;
                uv.x              += jitterAmount;

                float scanProgress = uv.y + (1.0 - _Progress) * (1.0 + _GlowWidth);
                float scanPos      = frac(scanProgress - t * _ScrollSpeed * (1.0 - _Progress));

                float sweepLine = 1.0 - _Progress;
                if (uv.y > sweepLine + _GlowWidth) discard;

                float bands     = sin(uv.y * _LineCount * UNITY_PI);
                float scanline  = pow(saturate(bands), _LineSharpness);

                float glow      = smoothstep(sweepLine + _GlowWidth, sweepLine, uv.y);
                glow            = pow(glow, 2.0);

                float flicker   = 1.0 - Hash(float2(floor(t * 20.0), 0.0)) * _Flicker * 0.15;

                half4 col       = _MainColor;
                col.rgb        += _ScanColor.rgb * scanline * 0.15 * _Progress * flicker;
                col.rgb        += _ScanColor.rgb * glow * 0.6 * flicker;
                col.a           = 1.0;

                return col;
            }
            ENDCG
        }
    }
}
