// This shader is responsible for rendering 3 tiny environment maps
// . The first map renders the sky without the clouds and is used to compute the ambient sky light for clouds
// . The second map renders the sky with the clouds and is used to compute the ambient sky light for the scene
// . The third map renders the sun with the clouds and is used to compute the directional sun light to use for the scene
//
Shader "Hidden/Nuaj/RenderSkyEnvironmentComplex"
{
	Properties
	{
		_MainTex( "Base (RGB)", 2D ) = "white" {}
		_TexCombineEnvMap( "Base (RGB)", 2D ) = "white" {}
		_TexShadowMap( "Base (RGB)", 2D ) = "white" {}
		_TexCloudLayer0( "Base (RGB)", 2D ) = "white" {}
		_TexCloudLayer1( "Base (RGB)", 2D ) = "white" {}
		_TexCloudLayer2( "Base (RGB)", 2D ) = "white" {}
		_TexCloudLayer3( "Base (RGB)", 2D ) = "white" {}
		_TexBackground( "Base (RGB)", 2D ) = "black" {}
		_TexDensity( "Base (RGB)", 2D ) = "black" {}
	}

	SubShader
	{
		Tags { "Queue" = "Overlay-1" }
		ZTest Off
		Cull Off
		ZWrite Off
		Fog { Mode off }
		AlphaTest Off
		Blend Off


		//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		// Pass #0 renders the sky WITHOUT clouds
		// This envmap value will be used to light clouds
		Pass
		{
			CGPROGRAM
			#pragma vertex VS
			#pragma fragment PS
			#pragma target 3.0
			#pragma glsl
			#pragma only_renderers d3d9 d3d11 opengl

			#define CLOUD_LAYERS 0

			#include "../Header.cginc"
			#include "AerialPerspectiveComplexInc.cginc"

			half4	PS( PS_IN _In ) : COLOR	{ return RenderSkyEnvironment( _In ); }
			ENDCG
		}

		//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		// Pass #1 renders the sky WITH clouds
		// This envmap value will be used as the scene's ambient term
		Pass
		{
			CGPROGRAM
			#pragma vertex VS
			#pragma fragment PS
			#pragma target 3.0
			#pragma glsl
			#pragma only_renderers d3d9 d3d11 opengl

			#define CLOUD_LAYERS 4

			#include "../Header.cginc"
			#include "AerialPerspectiveComplexInc.cginc"

			half4	PS( PS_IN _In ) : COLOR	{ return RenderSkyEnvironment( _In ); }
			ENDCG
		}

		//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		// Pass #2 renders the Sun (i.e. a single pixel in the Sun's direction)
		// This value will be used as the scene's directional term
		Pass
		{
			CGPROGRAM
			#pragma vertex VS
			#pragma fragment PS
			#pragma target 3.0
			#pragma glsl
			#pragma only_renderers d3d9 d3d11 opengl

//###			#define CLOUD_LAYERS 4
			#define CLOUD_LAYERS 0	// NO SHADOWING !
			#define RENDER_SUN

			#include "../Header.cginc"
			#include "AerialPerspectiveComplexInc.cginc"

			half4	PS( PS_IN _In ) : COLOR	{ return RenderSkyEnvironment( _In ); }
			ENDCG
		}

		//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		// Pass #3 is used to compute a simple downsample for the envmaps
		Pass
		{
			CGPROGRAM
			#pragma vertex VS
			#pragma fragment PS
			#pragma target 3.0
			#pragma glsl
			#pragma only_renderers d3d9 d3d11 opengl

			#include "../Header.cginc"

			uniform float3		_dUV;
			uniform sampler2D	_MainTex;
			uniform float4		_EnvironmentAngles;

			half4	PS( PS_IN _In ) : COLOR
			{
				_In.UV.xy -= 0.5 * _dUV.xy;
				float4	C0 = _tex2Dlod( _MainTex, _In.UV ); _In.UV += _dUV.xzzz;
				float4	C1 = _tex2Dlod( _MainTex, _In.UV ); _In.UV += _dUV.zyzz;
				float4	C2 = _tex2Dlod( _MainTex, _In.UV ); _In.UV -= _dUV.xzzz;
				float4	C3 = _tex2Dlod( _MainTex, _In.UV );
				float4	FinalValue = 0.25 * (C0+C1+C2+C3);

				// Since extinction is exponential, we perform a logarithmic average instead
				FinalValue.w = exp( 0.25 * (log( 0.0001 + C0.w ) + log( 0.0001 + C1.w ) + log( 0.0001 + C2.w ) + log( 0.0001 + C3.w )) );

				return FinalValue;
			}
			ENDCG
		}

		//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		// Pass #4 (i.e. Final Downsample Pass) is used to compute a simple downsample for the envmaps but also modulates it (i.e. multiply) with existing value
		Pass
		{
			CGPROGRAM
			#pragma vertex VS
			#pragma fragment PS
			#pragma target 3.0
			#pragma glsl
			#pragma only_renderers d3d9 d3d11 opengl

			#include "../Header.cginc"

			uniform float3		_dUV;
			uniform sampler2D	_MainTex;
			uniform sampler2D	_TexCombineEnvMap;
			uniform float4		_EnvironmentAngles;

			half4	PS( PS_IN _In ) : COLOR
			{
				float4	PreviousValue = _tex2Dlod( _TexCombineEnvMap, _In.UV );

				_In.UV.xy -= 0.5 * _dUV.xy;
				float4	C0 = _tex2Dlod( _MainTex, _In.UV ); _In.UV += _dUV.xzzz;
				float4	C1 = _tex2Dlod( _MainTex, _In.UV ); _In.UV += _dUV.zyzz;
				float4	C2 = _tex2Dlod( _MainTex, _In.UV ); _In.UV -= _dUV.xzzz;
				float4	C3 = _tex2Dlod( _MainTex, _In.UV );
				float4	FinalValue = 0.25 * (C0+C1+C2+C3);

				// Since extinction is exponential, we perform a logarithmic average instead
				FinalValue.w = exp( 0.25 * (log( 0.0001 + C0.w ) + log( 0.0001 + C1.w ) + log( 0.0001 + C2.w ) + log( 0.0001 + C3.w )) );

				// Combine with existing value
 				FinalValue.xyz += PreviousValue.xyz * FinalValue.w;	// Extinction of the previous scattering by this new value
				FinalValue.w *= PreviousValue.w;

				return FinalValue;
			}
			ENDCG
		}

		//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		// Pass #5 (i.e. Final Downsample Pass for CPU) is used to compute a simple downsample for the envmaps AND pack it into a RGBA32 LDR target for CPU readback
		Pass
		{
			CGPROGRAM
			#pragma vertex VS
			#pragma fragment PS
			#pragma target 3.0
			#pragma glsl
			#pragma only_renderers d3d9 d3d11 opengl

			#include "../Header.cginc"

			uniform float3		_dUV;
			uniform sampler2D	_MainTex;
			uniform float4		_EnvironmentAngles;

			uniform float		_LuminanceScale;					// This is the luminance to scale by when storing environment colors since we pack the luminance in alpha and that luminance needs to be in [0,1] for readback

			half4	PS( PS_IN _In ) : COLOR
			{
				_In.UV.xy -= 0.5 * _dUV.xy;
				float4	C0 = _tex2Dlod( _MainTex, _In.UV ); _In.UV += _dUV.xzzz;
				float4	C1 = _tex2Dlod( _MainTex, _In.UV ); _In.UV += _dUV.zyzz;
				float4	C2 = _tex2Dlod( _MainTex, _In.UV ); _In.UV -= _dUV.xzzz;
				float4	C3 = _tex2Dlod( _MainTex, _In.UV );
				float4	FinalColor = 0.25 * (C0+C1+C2+C3);

				// "Normalize" resulting color & store normalized luminance in alpha
				float	MaxRGB = max( 1e-4, max( max( FinalColor.x, FinalColor.y ), FinalColor.z ) );
				return float4( FinalColor.xyz / MaxRGB, MaxRGB * _LuminanceScale );
			}
			ENDCG
		}
	}
	Fallback off
}
