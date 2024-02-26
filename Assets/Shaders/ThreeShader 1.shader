Shader "Unlit/WindShader"
{
    Properties
    {
        _MainTex("Texture", 2D) = "white" {}
        _WindDirection("Wind Direction", Vector) = (0, 0, 1)
        _RainbowSpeed("Rainbow Speed", Float) = 1.0 // Speed of rainbow interpolation
        _WindSpeedMultiplier("Wind Speed Multiplier", Float) = 2.0 // Multiplier for wind speed variation
    }
        SubShader
        {
            Tags { "RenderType" = "Opaque" }
            LOD 100

            CGPROGRAM
            #pragma surface surf Lambert vertex:vert
            #pragma target 3.0

            sampler2D _MainTex;
            float3 _WindDirection;
            float _RainbowSpeed;
            float _WindSpeedMultiplier;

            struct Input
            {
                float2 uv_MainTex;
            };

            void vert(inout appdata_full v)
            {
                // Calculate wind effect using a sine wave
                float windFactor = sin(_Time.y * _WindSpeedMultiplier);

                // Move vertex along the wind direction with reduced displacement
                v.vertex.xyz += _WindDirection * windFactor * 0.05;
            }

            void surf(Input IN, inout SurfaceOutput o)
            {
                // Sample the main texture
                fixed4 texColor = tex2D(_MainTex, IN.uv_MainTex);

                // Check if the pixel is green
                if (texColor.g > texColor.r && texColor.g > texColor.b)
                {
                    // If the pixel is green, keep its original color
                    o.Albedo = texColor.rgb;
                }
                else
                {
                    // If the pixel is not green, lerp between colors of the rainbow
                    float rainbowFactor = (sin(_Time.y * _RainbowSpeed) + 1.0) * 0.5; // Map sin wave to [0, 1] range
                    fixed3 rainbowColor = lerp(fixed3(1, 0, 0), fixed3(0, 0, 1), rainbowFactor); // Lerp between red and yellow
                    o.Albedo = rainbowColor;
                }

                // Set alpha to 1 for opaque objects
                o.Alpha = 1.0;
            }
            ENDCG
        }
}
