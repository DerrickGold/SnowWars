// This shader performs luminance sampling on the scattering buffer
// Unity doesn't render in HDR but we do. The difficulty lies in combining a HDR buffer with a LDR rendering.
// For this purpose, we tone map the HDR light sources to obtain a LDR light source Unity can use.
// And for tone mapping, we map the LDR-lit scene to a HDR scene using the inverse of the tone map factor.
// This way, we can mix the LDR scene with our HDR rendering all into a single HDR scene + atmosphere, that
//	we use for tone mapping.
//
// Basically, we downsample the HDR scattering buffer and read back the 1x1 end-mipmap to tone-map the result,
//	the tone mapped image will yield an average luminance that we also use to configure the Sun light and
//	ambient Sky light so the LDR rendering in Unity is coherent with our lighting.
//
// Of course, the LDR lighting has already occurred since we're a post-process, so the Sun & Ambient
//	light configuration is set for the next frame, hoping the light doesn't change too much from one
//	frame to the next...
//
Shader "Hidden/ImageScalerLog"
{
	Properties
	{
		_MainTex( "Base (RGB)", 2D ) = "white" {}
		_TexScattering( "Base (RGB)", 2D ) = "white" {}
		_TexDownsampledZBuffer( "Base (RGB)", 2D ) = "white" {}
	}

	SubShader
	{
		ZTest Off
		Cull Off
		ZWrite Off
		Fog { Mode off }

		// This pass downsamples the main texture to a buffer at most 2x smaller and computes the log of the luminance
		// It also assumes the scene was rendered in LDR
		//
		Pass
		{
			CGPROGRAM
			#pragma target 3.0
			#pragma vertex VS
			#pragma fragment PS
			#pragma glsl
			#pragma only_renderers d3d9 d3d11 opengl

			#include "../Header.cginc"

			uniform float		_LerpAvgMax;
			uniform float3		_dUV;
			uniform float		_SceneDirectionalLuminanceFactor;
			uniform float		_SceneAmbientLuminanceLDR;
			uniform float		_SceneAmbientLuminanceLDR2HDR;
			uniform sampler2D	_MainTex;
			uniform sampler2D	_TexScattering;

			float4	PS( PS_IN _In ) : COLOR
			{
				float3	SceneColor = _tex2Dlod( _MainTex, _In.UV ).xyz;

				_In.UV -= 0.5 * _dUV.xyzz;

				float3	Extinction[4], Scattering[4];
				UnPack2Colors( _tex2Dlod( _TexScattering, _In.UV ), Scattering[0], Extinction[0] );	_In.UV += _dUV.xzzz;
				UnPack2Colors( _tex2Dlod( _TexScattering, _In.UV ), Scattering[1], Extinction[1] );	_In.UV += _dUV.zyzz;
				UnPack2Colors( _tex2Dlod( _TexScattering, _In.UV ), Scattering[2], Extinction[2] );	_In.UV -= _dUV.xzzz;
				UnPack2Colors( _tex2Dlod( _TexScattering, _In.UV ), Scattering[3], Extinction[3] );

				// Compute scene luminance
				float3	Ex = 0.25 * (Extinction[0] + Extinction[1] + Extinction[2] + Extinction[3]);
				SceneColor *= Ex;	// Apply extinction
				float	SceneLuminanceLDR = dot( SceneColor, LUMINANCE );
				float	SceneAmbientLuminanceLDR = min( SceneLuminanceLDR, _SceneAmbientLuminanceLDR );
						SceneLuminanceLDR = max( 0.0, SceneLuminanceLDR - SceneAmbientLuminanceLDR );

				float	SceneAmbientLuminanceHDR = _SceneAmbientLuminanceLDR2HDR * SceneAmbientLuminanceLDR;
				float	SceneLuminanceHDR = _SceneDirectionalLuminanceFactor * SceneLuminanceLDR + SceneAmbientLuminanceHDR;

				// Compute atmosphere luminance
				float	LumAvg = dot( 0.25 * (Scattering[0] + Scattering[1] + Scattering[2] + Scattering[3]), LUMINANCE );
				float	LumMax = dot( max( max( max( Scattering[0], Scattering[1] ), Scattering[2] ), Scattering[3] ), LUMINANCE );

				return log( 0.0001 + SceneLuminanceHDR + lerp( LumAvg, LumMax, _LerpAvgMax ) );
			}
			ENDCG
		}

		// This pass downsamples the main texture to a buffer at most 2x smaller and computes the log of the luminance
		// It also assumes the scene was rendered in HDR
		//
		Pass
		{
			CGPROGRAM
			#pragma target 3.0
			#pragma vertex VS
			#pragma fragment PS
			#pragma glsl
			#pragma only_renderers d3d9 d3d11 opengl

			#include "../Header.cginc"

			uniform float		_LerpAvgMax;
			uniform float3		_dUV;
			uniform float		_SceneDirectionalLuminanceFactor;
			uniform float		_SceneAmbientLuminanceLDR;
			uniform float		_SceneAmbientLuminanceLDR2HDR;
			uniform sampler2D	_MainTex;
			uniform sampler2D	_TexScattering;

			float4	PS( PS_IN _In ) : COLOR
			{
				float3	SceneColor = _tex2Dlod( _MainTex, _In.UV ).xyz;

				_In.UV -= 0.5 * _dUV.xyzz;

				float3	Extinction[4], Scattering[4];
				UnPack2Colors( _tex2Dlod( _TexScattering, _In.UV ), Scattering[0], Extinction[0] );	_In.UV += _dUV.xzzz;
				UnPack2Colors( _tex2Dlod( _TexScattering, _In.UV ), Scattering[1], Extinction[1] );	_In.UV += _dUV.zyzz;
				UnPack2Colors( _tex2Dlod( _TexScattering, _In.UV ), Scattering[2], Extinction[2] );	_In.UV -= _dUV.xzzz;
				UnPack2Colors( _tex2Dlod( _TexScattering, _In.UV ), Scattering[3], Extinction[3] );

				// Apply extinction to scene color
				SceneColor *= 0.25 * (Extinction[0] + Extinction[1] + Extinction[2] + Extinction[3]);

				// Add atmosphere scattering
				float3	ScatteringAvg = 0.25 * (Scattering[0] + Scattering[1] + Scattering[2] + Scattering[3]);
				float3	ScatteringMax = max( max( max( Scattering[0], Scattering[1] ), Scattering[2] ), Scattering[3] );
				SceneColor += lerp( ScatteringAvg, ScatteringMax, _LerpAvgMax );

				// Return luminance
				return log( 0.0001 + dot( SceneColor, LUMINANCE ) );
			}
			ENDCG
		}

		// This pass downsamples the main texture to a buffer at most 2x smaller
		//
		Pass
		{
			CGPROGRAM
			#pragma target 3.0
			#pragma vertex VS
			#pragma fragment PS
			#pragma glsl
			#pragma only_renderers d3d9 d3d11 opengl

			#include "../Header.cginc"

			uniform float		_LerpAvgMax;
			uniform float3		_dUV;
			uniform sampler2D	_MainTex;

			float4	PS( PS_IN _In ) : COLOR
			{
				_In.UV -= 0.5 * _dUV.xyzz;
				float	Cl = _tex2Dlod( _MainTex, _In.UV ).x;	_In.UV += _dUV.xzzz;
				float	Cr = _tex2Dlod( _MainTex, _In.UV ).x;	_In.UV += _dUV.zyzz;
				float	Ct = _tex2Dlod( _MainTex, _In.UV ).x;	_In.UV -= _dUV.xzzz;
				float	Cb = _tex2Dlod( _MainTex, _In.UV ).x;

				float	LumAvg = 0.25 * (Cl+Cr+Ct+Cb);					// Average
				float	LumMax = max( max( max( Cl, Cr ), Ct ), Cb );	// Max
				return lerp( LumAvg, LumMax, _LerpAvgMax );
			}
			ENDCG
		}

		// This pass is the last one and downsamples the main texture down to a 1x1 and takes the exp of the result
		// It also compacts the luminance so it's readable by the CPU as a LDR color
		// It's a shame we have to lock a 1x1 target because that eats a lot (!!) of time
		//	as it can stall the GPU altogether due to the synch with the CPU.
		// The ideal solution would be to provide the 1x1 HDR target as a global value
		//	and the users would sample it in their vertices to correctly light their scene
		// This would also imply rewriting ALL the shaders used in a scene and I'm not sure
		//	Unity users are up to do this... (as far as I know, most of them already have
		//	a hard time figuring out how to write simple surface shaders)
		//	
		Pass
		{
			CGPROGRAM
			#pragma target 3.0
			#pragma vertex VS
			#pragma fragment PS
			#pragma glsl
			#pragma only_renderers d3d9 d3d11 opengl

			#include "../Header.cginc"

			uniform float		_LerpAvgMax;
			uniform sampler2D	_MainTex;

			float4	PS( PS_IN _In ) : COLOR
			{
				float	Cl = _tex2Dlod( _MainTex, float4( 0.25, 0.25, 0, 0 ) ).x;
				float	Cr = _tex2Dlod( _MainTex, float4( 0.75, 0.25, 0, 0 ) ).x;
				float	Ct = _tex2Dlod( _MainTex, float4( 0.25, 0.75, 0, 0 ) ).x;
				float	Cb = _tex2Dlod( _MainTex, float4( 0.75, 0.75, 0, 0 ) ).x;
				float	LumAvg = exp( 0.25 * (Cl+Cr+Ct+Cb) );					// Exp(average)
				float	LumMax = exp( max( max( max( Cl, Cr ), Ct ), Cb ) );	// Exp(max)
				float	Lum = lerp( LumAvg, LumMax, _LerpAvgMax );

				Lum *= 256.0;	// For <1 precision

				// Now, the last mip map will be read back by the CPU
				// As Unity only allows to read back RGBA32 textures, we need to encode our HDR luminance into 8bits precision
				float4	Result;
				Lum /= 256.0; Result.x = frac( Lum ); Lum -= Result.x;	// LSB
				Lum /= 256.0; Result.y = frac( Lum ); Lum -= Result.y;
				Lum /= 256.0; Result.z = frac( Lum ); Lum -= Result.z;
				Lum /= 256.0; Result.w = frac( Lum );

				return Result;
			}
			ENDCG
		}
	}
	Fallback off
}
