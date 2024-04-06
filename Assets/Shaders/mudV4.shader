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
        _MudScaleRT("MudScaleRT", Float) = 100
        _avgTextureColor("avgTextureColor", Color) = (0, 0, 0, 0)
        [NoScaleOffset] _RenderTexture("RenderTexture", 2D) = "white" {}
        _ColorBrightness("ColorBrightness", Float) = 0.6
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

                    // Calculate the new normals
                    float3 objNormal = mul((float3x3)unity_WorldToObject, v.normal);
                    o.normal = normalize(objNormal);

                    o.vertex = UnityObjectToClipPos(vert);
                    UNITY_TRANSFER_FOG(o, o.vertex);
                    return o;
                }

                fixed4 frag(v2f i) : SV_Target
                {
                    // Sample the textures separately
                    fixed4 textureMudSideTexX = tex2D(_TextureMudSide, i.uv);
                    fixed4 textureMudTexY = tex2D(_TextureMud, i.uv);
                    fixed4 textureMudSideTexZ = tex2D(_TextureMudSide, i.uv);

                    // Blend textures based on normal
                    float3 absNormal = abs(i.normal);
                    float3 blendFactors = absNormal / (absNormal.x + absNormal.y + absNormal.z);

                    fixed4 finalColor = textureMudSideTexX * blendFactors.x + textureMudTexY * blendFactors.y + textureMudSideTexZ * blendFactors.z;

                    // Adjust the mud color based on dent information
                    finalColor.rgb += _ColorBrightness;

                    // Apply fog
                    UNITY_APPLY_FOG(i.fogCoord, finalColor);

                    return finalColor;
                }
            ENDCG
            }
        }
}