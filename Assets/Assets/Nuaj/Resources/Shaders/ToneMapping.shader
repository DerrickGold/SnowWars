// This shader is responsible for applying tone mapping to the scene
//
Shader "Hidden/Nuaj/ComposeAtmosphere"
{
	Properties
	{
		_MainTex( "Base (RGB)", 2D ) = "white" {}
	}

	SubShader
	{
		ZTest Off
		Cull Off
		ZWrite Off
		Fog { Mode off }
		AlphaTest Off
		Blend Off
		ColorMask RGBA

		// Filmic
		Pass
		{
			CGPROGRAM
			#pragma target 3.0
			#pragma vertex VS_TONEMAP
			#pragma fragment PS
			#pragma glsl
			#pragma only_renderers d3d9 d3d11 opengl

			#include "Header.cginc"
			#include "ToneMappingInc.cginc"

			#include "PlanetDataInc.cginc"
			#include "LightSupportInc.cginc"

			float4	PS( PS_IN_TONEMAP _In ) : COLOR
			{
				float4	SourceColor = _tex2Dlod( _MainTex, _In.MainTexUV );

				float	GlowAlpha;
				SourceColor.xyz = ToneMapFilmic( SourceColor.xyz, GlowAlpha );

				return float4( SourceColor.xyz, CombineGlowAlpha( SourceColor.w, GlowAlpha ) );
			}
			ENDCG
		}

		// Reinhard
		Pass
		{
			CGPROGRAM
			#pragma target 3.0
			#pragma vertex VS_TONEMAP
			#pragma fragment PS
			#pragma glsl
			#pragma only_renderers d3d9 d3d11 opengl

			#include "Header.cginc"
			#include "ToneMappingInc.cginc"

			float4	PS( PS_IN_TONEMAP _In ) : COLOR
			{
				float4	SourceColor = _tex2Dlod( _MainTex, _In.MainTexUV );

				float	GlowAlpha;
				SourceColor.xyz = ToneMapReinhard( SourceColor.xyz, GlowAlpha );

				return float4( SourceColor.xyz, CombineGlowAlpha( SourceColor.w, GlowAlpha ) );
			}
			ENDCG
		}

		// Drago
		Pass
		{
			CGPROGRAM
			#pragma target 3.0
			#pragma vertex VS_TONEMAP
			#pragma fragment PS
			#pragma glsl
			#pragma only_renderers d3d9 d3d11 opengl

			#include "Header.cginc"
			#include "ToneMappingInc.cginc"

			float4	PS( PS_IN_TONEMAP _In ) : COLOR
			{
				float4	SourceColor = _tex2Dlod( _MainTex, _In.MainTexUV );

				float	GlowAlpha;
				SourceColor.xyz = ToneMapDrago( SourceColor.xyz, GlowAlpha );

				return float4( SourceColor.xyz, CombineGlowAlpha( SourceColor.w, GlowAlpha ) );
			}
			ENDCG
		}

		// Exponential
		Pass
		{
			CGPROGRAM
			#pragma target 3.0
			#pragma vertex VS_TONEMAP
			#pragma fragment PS
			#pragma glsl
			#pragma only_renderers d3d9 d3d11 opengl

			#include "Header.cginc"
			#include "ToneMappingInc.cginc"

			float4	PS( PS_IN_TONEMAP _In ) : COLOR
			{
				float4	SourceColor = _tex2Dlod( _MainTex, _In.MainTexUV );

				float	GlowAlpha;
				SourceColor.xyz = ToneMapExponential( SourceColor.xyz, GlowAlpha );

				return float4( SourceColor.xyz, CombineGlowAlpha( SourceColor.w, GlowAlpha ) );
			}
			ENDCG
		}

		// Linear
		Pass
		{
			CGPROGRAM
			#pragma target 3.0
			#pragma vertex VS_TONEMAP
			#pragma fragment PS
			#pragma glsl
			#pragma only_renderers d3d9 d3d11 opengl

			#include "Header.cginc"
			#include "ToneMappingInc.cginc"

			float4	PS( PS_IN_TONEMAP _In ) : COLOR
			{
				float4	SourceColor = _tex2Dlod( _MainTex, _In.MainTexUV );

				float	GlowAlpha;
				SourceColor.xyz = ToneMapLinear( SourceColor.xyz, GlowAlpha );

				return float4( SourceColor.xyz, CombineGlowAlpha( SourceColor.w, GlowAlpha ) );
			}
			ENDCG
		}

		// Disabled
		Pass
		{
			CGPROGRAM
			#pragma target 3.0
			#pragma vertex VS_TONEMAP
			#pragma fragment PS
			#pragma glsl
			#pragma only_renderers d3d9 d3d11 opengl

			#include "Header.cginc"
			#include "ToneMappingInc.cginc"

			float4	PS( PS_IN_TONEMAP _In ) : COLOR
			{
				// Sample scene & atmosphere data
				float4	SourceColor = _tex2Dlod( _MainTex, _In.MainTexUV );

				float	GlowAlpha = ComputeGlowAlpha( dot( SourceColor.xyz, LUMINANCE ) );

				return float4( SourceColor.xyz, CombineGlowAlpha( SourceColor.w, GlowAlpha ) );
			}
			ENDCG
		}
	}
	Fallback off
}
