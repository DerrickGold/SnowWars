// Performs empty sky computations and composition taking up to 4 cloud layers into account
//
Shader "Hidden/Nuaj/AerialPerspectiveNone"
{
	Properties
	{
		_MainTex( "Base (RGB)", 2D ) = "white" {}
		_TexDownsampledZBuffer( "Base (RGB)", 2D ) = "black" {}
		_TexDensity( "Base (RGB)", 2D ) = "black" {}
		_TexShadowMap( "Base (RGB)", 2D ) = "white" {}
		_TexCloudLayer0( "Base (RGB)", 2D ) = "white" {}
		_TexCloudLayer1( "Base (RGB)", 2D ) = "white" {}
		_TexCloudLayer2( "Base (RGB)", 2D ) = "white" {}
		_TexCloudLayer3( "Base (RGB)", 2D ) = "white" {}
		_TexBackground( "Base (RGB)", 2D ) = "black" {}
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
		// Pass #0 compose sky with NO cloud layer
		Pass
		{
			CGPROGRAM
			#pragma vertex VS
			#pragma fragment PS
			#pragma target 3.0
			#pragma glsl
			#pragma only_renderers d3d9 d3d11 opengl

			#define CLOUD_LAYERS	0

			#include "../Header.cginc"
			#include "AerialPerspectiveNoneInc.cginc"

			half4	PS( PS_IN _In ) : COLOR	{ return ComposeSkyAndClouds( _In ); }
			ENDCG
		}

		//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		// Pass #1 compose sky with 1 cloud layer
		Pass
		{
			CGPROGRAM
			#pragma vertex VS
			#pragma fragment PS
			#pragma target 3.0
			#pragma glsl
			#pragma only_renderers d3d9 d3d11 opengl

			#define CLOUD_LAYERS	1

			#include "../Header.cginc"
			#include "AerialPerspectiveNoneInc.cginc"

			half4	PS( PS_IN _In ) : COLOR	{ return ComposeSkyAndClouds( _In ); }
			ENDCG
		}

		//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		// Pass #2 compose sky with 2 cloud layers
		Pass
		{
			CGPROGRAM
			#pragma vertex VS
			#pragma fragment PS
			#pragma target 3.0
			#pragma glsl
			#pragma only_renderers d3d9 d3d11 opengl

			#define CLOUD_LAYERS	2

			#include "../Header.cginc"
			#include "AerialPerspectiveNoneInc.cginc"

			half4	PS( PS_IN _In ) : COLOR	{ return ComposeSkyAndClouds( _In ); }
			ENDCG
		}

		//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		// Pass #3 compose sky with 3 cloud layers
		Pass
		{
			CGPROGRAM
			#pragma vertex VS
			#pragma fragment PS
			#pragma target 3.0
			#pragma glsl
			#pragma only_renderers d3d9 d3d11 opengl

			#define CLOUD_LAYERS	3

			#include "../Header.cginc"
			#include "AerialPerspectiveNoneInc.cginc"

			half4	PS( PS_IN _In ) : COLOR	{ return ComposeSkyAndClouds( _In ); }
			ENDCG
		}

		//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		// Pass #4 compose sky with 4 cloud layers
		Pass
		{
			CGPROGRAM
			#pragma vertex VS
			#pragma fragment PS
			#pragma target 3.0
			#pragma glsl
			#pragma only_renderers d3d9 d3d11 opengl

			#define CLOUD_LAYERS	4

			#include "../Header.cginc"
			#include "AerialPerspectiveNoneInc.cginc"

			half4	PS( PS_IN _In ) : COLOR	{ return ComposeSkyAndClouds( _In ); }
			ENDCG
		}
	}
	Fallback off
}
