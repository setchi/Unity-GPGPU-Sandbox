Shader "UnityGpuSandbox/CubeWave/Opaque"
{
    Properties
    {
        [HideInInspector]
        _PositionBuffer ("-", 2D) = "black"{}
        [HideInInspector]
        _RotationBuffer ("-", 2D) = "red"{}

        _Metallic   ("Metalic", Range(0,1)) = 0.5
        _Smoothness ("Smoothness", Range(0,1)) = 0.5

        _MainTex      ("MainTex", 2D) = "white"{}
        _NormalMap    ("NormalMap", 2D) = "bump"{}
        _NormalScale  ("NormalScale", Range(0,2)) = 1
        _OcclusionMap ("OcclusionMap", 2D) = "white"{}
        _OcclusionStr ("OcclusionStr", Range(0,1)) = 1

        [HDR] _Emission ("Emission", Color) = (0, 0, 0)
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }

        CGPROGRAM

        #pragma surface surf Standard vertex:vert nolightmap addshadow
        #pragma shader_feature _COLORMODE_RANDOM
        #pragma shader_feature _ALBEDOMAP
        #pragma shader_feature _NORMALMAP
        #pragma shader_feature _OCCLUSIONMAP
        #pragma shader_feature _EMISSION
        #pragma target 3.0

        sampler2D _PositionBuffer;
        sampler2D _RotationBuffer;
        float2 _BufferOffset;

        half _Metallic;
        half _Smoothness;

        sampler2D _MainTex;
        sampler2D _NormalMap;
        half _NormalScale;
        sampler2D _OcclusionMap;
        half _OcclusionStr;
        half3 _Emission;

        struct Input
        {
            float2 uv_MainTex;
            half4 color : COLOR;
        };

        void vert(inout appdata_full v)
        {
            float4 uv = float4(v.texcoord1.xy + _BufferOffset, 0, 0);
            float4 p = tex2Dlod(_PositionBuffer, uv);
            v.vertex.xyz *= 0.3;
            v.vertex.xyz += p.xyz;
        }

        void surf(Input IN, inout SurfaceOutputStandard o)
        {
        #if _ALBEDOMAP
            half4 c = tex2D(_MainTex, IN.uv_MainTex);
            o.Albedo = IN.color.rgb * c.rgb;
        #else
            o.Albedo = IN.color.rgb;
        #endif

        #if _NORMALMAP
            half4 n = tex2D(_NormalMap, IN.uv_MainTex);
            o.Normal = UnpackScaleNormal(n, _NormalScale);
        #endif

        #if _OCCLUSIONMAP
            half4 occ = tex2D(_OcclusionMap, IN.uv_MainTex);
            o.Occlusion = lerp((half4)1, occ, _OcclusionStr);
        #endif

        #if _EMISSION
            o.Emission = _Emission;
        #endif

            o.Metallic = _Metallic;
            o.Smoothness = _Smoothness;
        }

        ENDCG
    }
}
