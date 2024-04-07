Shader "Unlit/MudShaderV4"
{
    Properties
    {
        _vertexoffset("vertexoffset", Float) = 0.015
        _TextureMud("MudBase", 2D) = "white" {}
        _TextureMudSide("MudSide", 2D) = "white" {}
        _MudPower("MudPower", Float) = 2
        _SwithHight("SwitchHight", Float) = 2
        _SwithAmount("SwithAmount", Float) = 2
        _TextureNoice("Noice", 2D) = "white" {}
        _MudScaleRT("MudScaleRT", Float) = 100
        _avgTextureColor("avgTextureColor", Color) = (0, 0, 0, 0)
        _MudTextureColor("MudTextureColor", Color) = (0, 0, 0, 0)
        _MudSideTextureColor("MudSideTextureColor", Color) = (0, 0, 0, 0)
        _MudColorPower("MudColorPower", Float) = 2
        _MudSideColorPower("MudSideColorPower", Float) = 2
        [NoScaleOffset] _RenderTexture("RenderTexture", 2D) = "white" {}
        _ColorBrightness("ColorBrightness", Float) = 0.6
        _MudBrightness("MudBrightness", Float) = 1
        _SmoothnessMud("SmoothnessMud", Range(0, 1)) = 0.5
        _SmoothnessMudSide("SmoothnessMudSide", Range(0, 1)) = 0.5
    }

    SubShader
    {
        Tags { "RenderType" = "Opaque" "RenderPipeline" = "UniversalPipeline" "Queue" = "AlphaTest+51" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float3 normal : TEXCOORD1;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
            };

            sampler2D _TextureMud;
            sampler2D _TextureMudSide;
            sampler2D _RenderTexture;
            sampler2D _TextureNoice;
            float _MudScaleRT;
            float _SwithHight;
            float _vertexoffset;
            float _MudPower;
            float _MudBrightness;
            float _ColorBrightness;
            float _SwithAmount;
            float4 OutMultiply;
            float4 _avgTextureColor;
            float4 _MudTextureColor;
            float4 _MudSideTextureColor;
            float _MudColorPower;
            float _MudSideColorPower;
            float _SmoothnessMud;
            float _SmoothnessMudSide;

            v2f vert(appdata v)
            {
                v2f o;
                o.uv = v.uv;
                float xNoice = tex2Dlod(_TextureNoice, float4(o.uv.xy, 0, 1)) * _MudPower;
                float xMod = tex2Dlod(_RenderTexture, float4(o.uv.xy, 0, 1)) * _MudScaleRT;
                float3 vert = v.vertex;
                vert.y = (xMod + xNoice) / 2;

                float4 worldPos = mul(unity_ObjectToWorld, vert);
                _avgTextureColor = 0.5 * _MudScaleRT;
                worldPos.y -= _avgTextureColor;
                _avgTextureColor = tex2D(_TextureNoice,o.uv.xy,0,1) * _MudPower;
                worldPos.y -= _avgTextureColor + _vertexoffset;

                vert = mul(unity_WorldToObject, worldPos);

                o.vertex = UnityObjectToClipPos(vert);
                UNITY_TRANSFER_FOG(o, o.vertex);
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                // Sample the mud texture
                fixed4 textureMudTex = tex2D(_TextureMud, i.uv) + _MudTextureColor + _MudColorPower;
                fixed4 textureMudSideTex = tex2D(_TextureMudSide, i.uv) + _MudSideTextureColor + _MudSideColorPower;

                // Sample the render texture to get information about dents
                fixed4 dentInfo = tex2D(_RenderTexture, i.uv)*-1;
                fixed4 NoiceInfo = tex2D(_TextureNoice, i.uv);

                fixed4 dentNoice = (dentInfo + NoiceInfo) * _SwithHight;

                // Calculate grayscale value of dentNoice
                float grayscaleValue = dot(dentNoice.rgb, float3(0.299, 0.587, 0.114));

                // Determine whether it's closer to black or white
                float adjustedValue = (grayscaleValue < _SwithAmount) ? 0 : 1;

                // Set the final color to either black or white
                fixed4 finalColor = fixed4(adjustedValue, adjustedValue, adjustedValue, 1);

                // Sample smoothness values for both textures separately
                textureMudTex.a = _SmoothnessMud;
                textureMudSideTex.a = _SmoothnessMudSide;

                // Blend between mud and mud side texture based on dentNoice
                finalColor = lerp(textureMudSideTex,textureMudTex, finalColor);

                // Apply fog
                UNITY_APPLY_FOG(i.fogCoord, finalColor);
                UNITY_OPAQUE_ALPHA(finalColor.a);
                return finalColor;
            }
            ENDCG
        }
    }
}
