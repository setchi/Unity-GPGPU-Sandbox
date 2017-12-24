Shader "UnityGpuSandbox/MetaballsGame/Metaballs"
{
    Properties
    {
        _MainTex ("MainTex", 2D) = "white"{}
    }

    CGINCLUDE
    #include "UnityCG.cginc"

    float3 _PlayerPosition;
    bool _GameOver;
    
    float2 random2(float2 st)
    {
        st = float2(dot(st, float2(127.1, 311.7)),
                    dot(st, float2(269.5, 183.3)));
        return -1.0 + 2.0 * frac(sin(st) * 43758.5453123);
    }
    
    float4 frag(v2f_img i) : SV_Target
    {
        float2 st = i.uv;
        st *= 2;

        float2 ist = floor(st);
        float2 fst = frac(st);

        float enemy_distance_exp = 1;
        float enemy_distance = 1;

        for (int y = -1; y <= 1; y++)
        for (int x = -1; x <= 1; x++)
        {
            float2 neighbor = float2(x, y);
            float2 p = 0.5 + 0.5 * sin(_Time.x * 20 + 6.2831 * random2(ist + neighbor));

            float2 diff = neighbor + p - fst;
            enemy_distance_exp = min(enemy_distance_exp, enemy_distance_exp * length(diff) * length(diff));
            enemy_distance = min(enemy_distance, length(diff));
        }

        float player_distance = length(_PlayerPosition.xy - i.uv) * 1;
        float player_distance_exp = enemy_distance * length(player_distance) * length(player_distance);
        float distance_exp = min(enemy_distance_exp, player_distance_exp);

        float near = 0.002;
        float mid = 0.004;
        float far = 0.008;

        if (distance_exp == player_distance_exp && enemy_distance_exp < near && distance_exp < near)
        {
            return float4(1, 0, 0, 1);
        }

        if (distance_exp < near)
        {
            return float4(0, 0, 0, 1);
        }

        if (distance_exp < mid)
        {
            return lerp(float4(1, 1, 1, 1) * 0.7,
                        float4(0, 0, 1, 1) * 0.5,
                        smoothstep(0, player_distance + enemy_distance_exp, player_distance));
        }

        if (distance_exp < far)
        {
            return lerp(float4(1, 1, 1, 1) * 1,
                        float4(0, 1, 1, 1) * 0.5,
                        smoothstep(0, player_distance + enemy_distance_exp, player_distance));
        }

        return float4(1, 1, 1, 1) * 0.2;
    }
    
    ENDCG

    SubShader
    {
        Pass
        {
            CGPROGRAM
            #pragma vertex vert_img
            #pragma fragment frag
            ENDCG
        }
    }
}
