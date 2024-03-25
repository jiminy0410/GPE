Shader "Unlit/MudShader"
{
    Properties
    {
        _vertexoffset("vertexoffset", Float) = 0.015
        _TextureMud("MudBase", 2D) = "white" {}
        _MudPower("MudPower", Float) = 2
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
                sampler2D _RenderTexture;
                sampler2D _TextureNoice;
                float _MudScale;
                float _vertexoffset;
                float _MudPower;
                float _MudBrightness;
                float _DentColor;

                v2f vert(appdata v)
                {
                    v2f o;
                    o.uv = v.uv;
                    float xNoice = tex2Dlod(_TextureNoice, float4(o.uv.xy, 0, 1)) * -_MudPower;
                    float xMod = tex2Dlod(_RenderTexture, float4(o.uv.xy, 0, 1))*-_DentColor;
                    float3 vert = v.vertex;
                    vert.y = (xMod + xNoice)/2;
                    float4 worldPos = mul(unity_ObjectToWorld, vert);
                    worldPos.y += _vertexoffset;
                    vert = mul(unity_WorldToObject, worldPos);
                    o.vertex = UnityObjectToClipPos(vert);
                    UNITY_TRANSFER_FOG(o, o.vertex);
                    return o;
                }

                fixed4 frag(v2f i) : SV_Target
                {
                    // Sample the mud texture
                    fixed4 mudColor = tex2D(_TextureMud, i.uv);

                    // Sample the render texture to get information about dents
                    fixed4 dentInfo = tex2D(_RenderTexture, i.uv)*-1;

                    // Adjust the mud color based on dent information
                    mudColor.rgb -= _MudScale * dentInfo.rgb;

                    // Apply fog
                    UNITY_APPLY_FOG(i.fogCoord, mudColor);

                    return mudColor;
            }
            ENDCG
        }
        }
}
