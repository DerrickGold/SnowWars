// This shader is responsible for combining the result of the Nuaj' Manager modules with the default rendering without atmospheric effects
// It also manages basic tone mapping
//
Shader "Hidden/Nuaj/ComposeAtmosphere"
{
	Properties
	{
		_MainTex( "Base (RGB)", 2D ) = "white" {}
		_TexScattering( "Base (RGB)", 2D ) = "Black" {}

// Many debug textures for... well... debugging
// _DEBUGTexLuminance0( "Base (RGB)", 2D ) = "Black" {}
// _DEBUGTexLuminance1( "Base (RGB)", 2D ) = "Black" {}
// _DEBUGTexLuminance2( "Base (RGB)", 2D ) = "Black" {}
// _DEBUGTexLuminance3( "Base (RGB)", 2D ) = "Black" {}
// _DEBUGTexLuminance4( "Base (RGB)", 2D ) = "Black" {}
// _DEBUGTexLuminance5( "Base (RGB)", 2D ) = "Black" {}
// _DEBUGTexLuminance6( "Base (RGB)", 2D ) = "Black" {}
// _DEBUGTexLuminance7( "Base (RGB)", 2D ) = "Black" {}
// _DEBUGTexLuminance8( "Base (RGB)", 2D ) = "Black" {}
// _DEBUGTexLuminance9( "Base (RGB)", 2D ) = "Black" {}
// 
// _DEBUGSkyEnvMapMip0( "Base (RGB)", 2D ) = "Black" {}
// _DEBUGSkyEnvMapMip1( "Base (RGB)", 2D ) = "Black" {}
// _DEBUGSkyEnvMapMip2( "Base (RGB)", 2D ) = "Black" {}
// _DEBUGSkyEnvMapMip3( "Base (RGB)", 2D ) = "Black" {}
// _DEBUGSkyEnvMapMip4( "Base (RGB)", 2D ) = "Black" {}
// _DEBUGLayerSkyEnvMap0( "Base (RGB)", 2D ) = "Black" {}
// _DEBUGLayerSkyEnvMap1( "Base (RGB)", 2D ) = "Black" {}
// _DEBUGLayerSkyEnvMap2( "Base (RGB)", 2D ) = "Black" {}
// _DEBUGLayerSkyEnvMap3( "Base (RGB)", 2D ) = "Black" {}
// _DEBUGLayerSkyEnvMapDownsampled0( "Base (RGB)", 2D ) = "Black" {}
// _DEBUGLayerSkyEnvMapDownsampled1( "Base (RGB)", 2D ) = "Black" {}
// _DEBUGLayerSkyEnvMapDownsampled2( "Base (RGB)", 2D ) = "Black" {}
// _DEBUGLayerSkyEnvMapDownsampled3( "Base (RGB)", 2D ) = "Black" {}
// _DEBUGTexDensity( "Base (RGB)", 2D ) = "Black" {}
// 
// _DEBUGLayerCloud0( "Base (RGB)", 2D ) = "Black" {}
// _DEBUGLayerCloud1( "Base (RGB)", 2D ) = "Black" {}
// _DEBUGLayerCloud2( "Base (RGB)", 2D ) = "Black" {}
// _DEBUGLayerCloud3( "Base (RGB)", 2D ) = "Black" {}
// 
// _DEBUGTexPrecisionTest128x128( "Base (RGB)", 2D ) = "Black" {}
// _DEBUGTexPrecisionTest256( "Base (RGB)", 2D ) = "Black" {}
// _DEBUGTexShadowMap( "Base (RGB)", 2D ) = "Black" {}
// _DEBUGTexLightCookie( "Base (RGB)", 2D ) = "Black" {}
// _DEBUGTexCloudVolume( "Base (RGB)", 2D ) = "Black" {}
// _DEBUGTexCloudLayer( "Base (RGB)", 2D ) = "Black" {}
// _DEBUGTexFogLayer( "Base (RGB)", 2D ) = "Black" {}
// _DEBUGTexSky( "Base (RGB)", 2D ) = "Black" {}
// _DEBUGTexBackground( "Base (RGB)", 2D ) = "Black" {}
// _DEBUGTexBackgroundEnvironment( "Base (RGB)", 2D ) = "Black" {}
// _DEBUGTexDeepShadowMap0( "Base (RGB)", 2D ) = "Black" {}
// _DEBUGTexDeepShadowMap1( "Base (RGB)", 2D ) = "Black" {}
// _DEBUGTexDeepShadowMap2( "Base (RGB)", 2D ) = "Black" {}
// _DEBUGTexDeepShadowMapEnvMap( "Base (RGB)", 2D ) = "Black" {}
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

//###DEBUG
// uniform float4	_DEBUGSoftwareSunColor;
// uniform float3	_dUV;
// uniform float3	_InvdUV;

			float4	PS( PS_IN_TONEMAP _In ) : COLOR
			{
//### PRECISION TESTS
//return abs( _In.UV.x - 0.5 * _dUV.x ) < 0.0025 * _dUV.x ? float4( 1, 0, 0, 1 ) : float4( 0, 0, 0, 1 );
//return abs( _In.UV.y - 0.5 * _dUV.y ) < 0.0025 * _dUV.y ? float4( 1, 0, 0, 1 ) : float4( 0, 0, 0, 1 );
//### PRECISION TESTS


				// Sample scene & atmosphere data
				float4	SourceColor = _tex2Dlod( _MainTex, _In.MainTexUV );
//return SourceColor;
//return _tex2Dlod( _DEBUGTexShadowMap, _In.UV );
//return _tex2Dlod( _DEBUGTexLightCookie, _In.UV );
// 
// if ( _In.UV.x < 0.2 && _In.UV.y < 0.2 )
// {
// 	_In.UV /= 0.2;
// 
// //	return _tex2Dlod( _DEBUGTexShadowMap, _In.UV ).x;
// // 	return _tex2Dlod( _DEBUGTexLightCookie, _In.UV );
// //	return _tex2Dlod( _DEBUGLayerCloud0, _In.UV );
// //	return 0.5 * _tex2Dlod( _DEBUGSkyEnvMapMip0, _In.UV );
// //	return _tex2Dlod( _DEBUGSkyEnvMapMip0, _In.UV ).w;
// 	return _tex2Dlod( _DEBUGTexDeepShadowMap0, _In.UV );
// // 	return _tex2Dlod( _DEBUGLayerSkyEnvMap0, _In.UV );
// // 	return _tex2Dlod( _DEBUGTexDeepShadowMapEnvMap, _In.UV );
// //	return _tex2Dlod( _DEBUGLayerSkyEnvMapDownsampled0, _In.UV );
// //	return _tex2Dlod( _DEBUGTexCloudVolume, _In.UV );
// }	 
// if ( _In.UV.x < 0.4 && _In.UV.y < 0.2 )
// {
// 	_In.UV.x -= 0.2;
// 	_In.UV /= 0.2;
// 
// 	return _tex2Dlod( _DEBUGTexShadowMap, _In.UV );
// //	return _tex2Dlod( _DEBUGTexLightCookie, _In.UV );
// }
// 
//return _tex2Dlod( _DEBUGTexLuminance0, _In.UV );
//return 100.0 * _tex2Dlod( _DEBUGTexLuminance1, _In.UV ).x;

				float3	Scattering, Extinction;
				UnPack2Colors( _tex2Dlod( _TexScattering, _In.UV ), Scattering, Extinction );

				float	GlowAlpha;
				Scattering = ToneMapFilmic( Scattering, GlowAlpha );

				return float4( SourceColor.xyz * Extinction + Scattering, CombineGlowAlpha( SourceColor.w, GlowAlpha ) );
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
				// Sample scene & atmosphere data
				float4	SourceColor = _tex2Dlod( _MainTex, _In.MainTexUV );
				float3	Scattering, Extinction;
				UnPack2Colors( _tex2Dlod( _TexScattering, _In.UV ), Scattering, Extinction );

				float	GlowAlpha;
				Scattering = ToneMapReinhard( Scattering, GlowAlpha );

				return float4( SourceColor.xyz * Extinction + Scattering, CombineGlowAlpha( SourceColor.w, GlowAlpha ) );
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
				// Sample scene & atmosphere data
				float4	SourceColor = _tex2Dlod( _MainTex, _In.MainTexUV );
				float3	Scattering, Extinction;
				UnPack2Colors( _tex2Dlod( _TexScattering, _In.UV ), Scattering, Extinction );

				float	GlowAlpha;
				Scattering = ToneMapDrago( Scattering, GlowAlpha );

				return float4( SourceColor.xyz * Extinction + Scattering, CombineGlowAlpha( SourceColor.w, GlowAlpha ) );
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
				// Sample scene & atmosphere data
				float4	SourceColor = _tex2Dlod( _MainTex, _In.MainTexUV );
				float3	Scattering, Extinction;
				UnPack2Colors( _tex2Dlod( _TexScattering, _In.UV ), Scattering, Extinction );

				float	GlowAlpha;
				Scattering = ToneMapExponential( Scattering, GlowAlpha );

				return float4( SourceColor.xyz * Extinction + Scattering, CombineGlowAlpha( SourceColor.w, GlowAlpha ) );
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
				// Sample scene & atmosphere data
				float4	SourceColor = _tex2Dlod( _MainTex, _In.MainTexUV );
				float3	Scattering, Extinction;
				UnPack2Colors( _tex2Dlod( _TexScattering, _In.UV ), Scattering, Extinction );

				float	GlowAlpha;
				Scattering = ToneMapLinear( Scattering, GlowAlpha );

				return float4( SourceColor.xyz * Extinction + Scattering, CombineGlowAlpha( SourceColor.w, GlowAlpha ) );
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
				float3	Scattering, Extinction;
				UnPack2Colors( _tex2Dlod( _TexScattering, _In.UV ), Scattering, Extinction );

				float	GlowAlpha = ComputeGlowAlpha( dot( Scattering, LUMINANCE ) );

				return float4( SourceColor.xyz * Extinction + Scattering, CombineGlowAlpha( SourceColor.w, GlowAlpha ) );
			}
			ENDCG
		}
	}
	Fallback off
}
