Shader "UnityGpuSandbox/VertexParticle/Point"
{
    CGINCLUDE
    #include "UnityCG.cginc"

    sampler2D _PositionBuffer;

    struct appdata
    {
        float4 v : POSITION;
        float4 color: COLOR;
    };
    
    struct v2f
    {
        float4 vertex : SV_POSITION;
        float4 color : COLOR;
        float size : PSIZE;
        float3 worldPos : TEXCOORD0;
    };
    
    v2f vert(appdata v)
    {
        float4 p = tex2Dlod(_PositionBuffer, v.v);

        v2f o;
        o.vertex = UnityObjectToClipPos(p);
        o.color = v.color;
        o.size = 1;
        o.worldPos = mul(unity_ObjectToWorld, p).xyz; 
        return o;
    }
    
    float4 frag(v2f o) : COLOR
    {
        return lerp(float4(0.59, 0.27, 0.59, 1),
                    float4(0.35, 0.35, 0.98, 1),
                    o.worldPos.y * 0.2);
    }
    ENDCG

    SubShader
    {
        Pass
        {
            Tags {
                "Queue" = "Transparent"
                "IgnoreProjector" = "True"
                "RenderType" = "Transparent"
            }

            LOD 200
            
            CGPROGRAM
            #pragma target 3.0
            #pragma vertex vert
            #pragma fragment frag
            ENDCG
        }
    }
}
