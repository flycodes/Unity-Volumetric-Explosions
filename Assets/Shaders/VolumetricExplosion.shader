﻿Shader "Custom/Volumetric Explosion"
{
    Properties
    {
        _RampTex ("Color Ramp", 2D) = "white" {}
        _DispTex ("Displacement Texture", 2D) = "gray" {}
        _Displacement ("Displacement", Range(0, 1.0)) = 0.1
        _ChannelFactor ("ChannelFactor (r,g,b)", Vector) = (1.0, 0, 0)
        _Range ("Color Range", Vector) = (0, 0.5, 0)
        _ClipRange ("Clip Value", Range(0, 1)) = 0.8
        _Alpha ("Alpha", Range(0, 1)) = 0.8
    }

    SubShader
    {
        Tags { "RenderType" = "Transparent" }
        Cull Off
        LOD 300

        CGPROGRAM
        #pragma vertex vert
        #pragma surface surf Lambert
//        #pragma nolightmap
        #pragma target 3.0
        #pragma glsl

        sampler2D _DispTex;
        float _Displacement;
        float3 _ChannelFactor;
        float2 _Range;
        float _ClipRange;
        float _Alpha;

        struct Input
        {
            float2 uv_DispTex;
        };

        void vert (inout appdata_full v)
        {
            float3 dcolor = tex2Dlod (_DispTex, float4(v.texcoord.xy,0,0));
            float d = (dcolor.r * _ChannelFactor.r + dcolor.g * _ChannelFactor.g + dcolor.b * _ChannelFactor.b);
            v.vertex.xyz += v.normal * d * _Displacement;
        }

        sampler2D _RampTex;

        void surf (Input IN, inout SurfaceOutput o)
        {
            float3 dcolor = tex2D (_DispTex, IN.uv_DispTex);
            float d = (dcolor.r * _ChannelFactor.r + dcolor.g * _ChannelFactor.g + dcolor.b * _ChannelFactor.b) * (_Range.y-_Range.x) + _Range.x;
            clip (d - _ClipRange);
            half4 c = tex2D (_RampTex, float2(d, 0.5));
            o.Albedo = c.rgb;
            o.Alpha = _Alpha;
            o.Emission = c.rgb * c.a;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
