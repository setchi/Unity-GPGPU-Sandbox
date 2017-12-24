Shader "UnityGpuSandbox/VertexParticle/Kernels"
{
    CGINCLUDE

    #include "UnityCG.cginc"
    #include "SimplexNoise.cginc"

    sampler2D _PositionBuffer;
    sampler2D _VelocityBuffer;

    float4 frag_init_position(v2f_img i) : SV_Target
    {
        i.uv -= 0.5;
        i.uv *= 5;
        return float4(i.uv.x, 0, i.uv.y, 1);
    }

    float4 frag_init_velocity(v2f_img i) : SV_Target
    {
        return float4(0, 0, 0, 1);
    }
    
    float4 frag_update_position(v2f_img i) : SV_Target
    {
        float4 p = tex2D(_PositionBuffer, i.uv);
        float3 v = tex2D(_VelocityBuffer, i.uv).xyz;
        p.xyz += v * unity_DeltaTime.x;
        return p;
    }
    
    float4 frag_update_velocity(v2f_img i) : SV_Target
    {
        float3 p = tex2D(_PositionBuffer, i.uv);
        float3 v = tex2D(_VelocityBuffer, i.uv);

        p *= 0.07;

        float3 n1 = snoise_grad(p);
        float3 n2 = snoise_grad(p + float3(5, 13.28,0));

        v += cross(n1, n2);

        return float4(v, 0);
    }
    ENDCG

    SubShader
    {
        Pass
        {
            CGPROGRAM
            #pragma target 3.0
            #pragma vertex vert_img
            #pragma fragment frag_init_position
            ENDCG
        }

        Pass
        {
            CGPROGRAM
            #pragma target 3.0
            #pragma vertex vert_img
            #pragma fragment frag_init_velocity
            ENDCG
        }

        Pass
        {
            CGPROGRAM
            #pragma target 3.0
            #pragma vertex vert_img
            #pragma fragment frag_update_position
            ENDCG
        }

        Pass
        {
            CGPROGRAM
            #pragma target 3.0
            #pragma vertex vert_img
            #pragma fragment frag_update_velocity
            ENDCG
        }
    }
}
