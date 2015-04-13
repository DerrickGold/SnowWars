// This shader simply clears a render texture with either a solid color or another texture...
//
Shader "Hidden/ClearTexture"
{
	Properties
	{
		_ClearTexture( "Base (RGB)", 2D ) = "black" {}
	}

	SubShader
	{
		ZTest Off
		Cull Off
		ZWrite Off
		Fog { Mode off }

		Pass
		{
			CGPROGRAM
			#pragma target 3.0
			#pragma vertex VS
			#pragma fragment PS
			#pragma glsl
			#pragma only_renderers d3d9 d3d11 opengl
			#pragma fragmentoption ARB_shader_texture_lod require

			#include "../Header.cginc"

			uniform float 		_bUseSolidColor;		// If true, use the _ClearColor. Otherwise, use the _ClearTexture
			uniform float		_bInvertTextureAlpha;	// If true, invert the _ClearTexture's alpha
			uniform float4		_ClearColor;
			uniform sampler2D 	_ClearTexture;

			float4 PS( PS_IN _In ) : COLOR
			{
				if ( _bUseSolidColor )
					return _ClearColor;
		
				float4	TextureColor = _tex2Dlod( _ClearTexture, _In.UV );
				return _bInvertTextureAlpha ?
							float4( TextureColor.xyz, 1.0-TextureColor.w ) :
							TextureColor;
			}
			ENDCG
		}

		// Specific scattering/extinction clear
		Pass
		{
			CGPROGRAM
			#pragma target 3.0
			#pragma vertex VS
			#pragma fragment PS
			#pragma glsl
			#pragma only_renderers d3d9 d3d11 opengl

			#include "../Header.cginc"

			half4 PS( PS_IN _In ) : COLOR
			{
				return Pack2Colors( float3( 1, 1, 0 ), float3( 0, 1, 0 ) );
			}
			ENDCG
		}

		// Pipo
		Pass
		{
			CGPROGRAM
			#pragma target 3.0
			#pragma vertex VS
			#pragma fragment PS
			#pragma glsl
			#pragma only_renderers d3d9 d3d11 opengl

			#include "../Header.cginc"

			uniform float	_ValueIndex;

			half4 PS( PS_IN _In ) : COLOR
			{
//				return float4( 0, 0, 0, 0.5 );
//				return float4( 1, 0, 0, 1 );
				if ( _ValueIndex == 0 )
					return float4( 1, 0, 0, 1 );
				else if ( _ValueIndex == 1 )
					return float4( 0, 1, 0, 1 );
				else if ( _ValueIndex == 2 )
					return float4( 0, 0, 1, 1 );

				return float4( 0, 0, 0, 1 );
			}
			ENDCG
		}
	}
	Fallback off
}
