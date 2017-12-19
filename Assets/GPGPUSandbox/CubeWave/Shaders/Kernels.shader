Shader "UnityGpuSandbox/CubeWave/Kernels"
{
    Properties
    {
        _PositionBuffer ("-", 2D) = ""{}
    }

    CGINCLUDE

    #include "UnityCG.cginc"

    sampler2D _PositionBuffer;

    fixed2 random2(fixed2 st)
    {
        st = fixed2(dot(st, fixed2(127.1, 311.7)),
                    dot(st, fixed2(269.5, 183.3)));
        return -1.0 + 2.0 * frac(sin(st) * 43758.5453123);
    }

    float perlin_noise(fixed2 st) 
    {
        fixed2 p = floor(st);
        fixed2 f = frac(st);
        fixed2 u = f * f * (3.0 - 2.0 * f);

        float v00 = random2(p + fixed2(0, 0));
        float v10 = random2(p + fixed2(1, 0));
        float v01 = random2(p + fixed2(0, 1));
        float v11 = random2(p + fixed2(1, 1));

        return lerp(lerp(dot(v00, f - fixed2(0, 0)), dot(v10, f - fixed2(1, 0) ), u.x),
                    lerp(dot(v01, f - fixed2(0, 1)), dot(v11, f - fixed2(1, 1) ), u.x), 
                    u.y) + 0.5f;
    }
    
    float4 frag_init_position(v2f_img i) : SV_Target
    {
        i.uv -= 0.5;
        i.uv *= 150;
        return float4(i.uv.x, 0, i.uv.y, 1);
    }
    
    float4 frag_update_position(v2f_img i) : SV_Target
    {
        float4 p = tex2D(_PositionBuffer, i.uv);
        p.y = perlin_noise(fixed2(i.uv.x * 10, i.uv.y * 10 + _Time.x * 10)) * 10;
        return p;
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
            #pragma fragment frag_update_position
            ENDCG
        }
    }
}
