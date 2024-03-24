Shader "Unlit/MudShaderV3"
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
        _MudScale("MudScale", Float) = 100
        [NoScaleOffset] _RenderTexture("RenderTexture", 2D) = "white" {}
        _DentColor("DentColor", Float) = 0.6
        _MudBrightness("MudBrightness", Float) = 1
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
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
            };

            sampler2D _TextureMud;
            sampler2D _TextureMudSide;
            sampler2D _RenderTexture;
            sampler2D _TextureNoice;
            float _MudScale;
            float _SwithHight;
            float _vertexoffset;
            float _MudPower;
            float _MudBrightness;
            float _DentColor;
            float _SwithAmount;
            float4 OutMultiply;

            v2f vert(appdata v)
            {
                v2f o;
                o.uv = v.uv;
                float xNoice = tex2Dlod(_TextureNoice, float4(o.uv.xy, 0, 1)) * -_MudPower;
                float xMod = tex2Dlod(_RenderTexture, float4(o.uv.xy, 0, 1)) * -_MudScale;
                float3 vert = v.vertex;
                vert.z = (xMod + xNoice) / 2;

                float4 worldPos = mul(unity_ObjectToWorld, vert);
                worldPos.y += _vertexoffset;

                // Sample the render texture to get information about the player's position
                float4 renderTexColor = tex2D(_RenderTexture, o.uv);

                // Convert from camera render texture to normal texture
                float3 normalTexCoords = (renderTexColor.rgb - 0.5) * 2.0;

                // Convert from tangent space to world space direction
                float3 worldDirection = mul(float3x3(unity_WorldToObject[0].xyz, unity_WorldToObject[1].xyz, unity_WorldToObject[2].xyz), normalTexCoords);

                // Split and take only the Y axis
                float yPosition = worldDirection.y;
        
                // Calculate OutMultiply based on the first smoothstep
                float OutMultiply1 = smoothstep((_SwithHight - 1), (_SwithHight + 1), abs(worldPos.y) * yPosition); // Smoothstep based on absolute world space position

                // Calculate OutMultiply based on the second smoothstep using _SwithAmount
                OutMultiply = smoothstep(0, (1 - _SwithAmount), OutMultiply1);

                vert = mul(unity_WorldToObject, worldPos);
                o.vertex = UnityObjectToClipPos(vert);
                UNITY_TRANSFER_FOG(o, o.vertex);
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                // Sample the textures separately
                fixed4 textureMudSideColor = tex2D(_TextureMudSide, i.uv);
                fixed4 textureMudColor = tex2D(_TextureMud, i.uv);

                // Lerp between the sampled textures based on OutMultiply
                fixed4 lerpedColor = lerp(textureMudSideColor, textureMudColor, OutMultiply);

                // Sample the render texture to get information about dents
                fixed4 dentInfo = tex2D(_RenderTexture, i.uv) * -1;

                // Adjust the mud color based on dent information
                lerpedColor.rgb -= _DentColor * dentInfo.rgb;

                // Apply fog
                UNITY_APPLY_FOG(i.fogCoord, lerpedColor);

                return lerpedColor;
            }
        ENDCG
        }
    }
}