// Performs aerial perspective computations taking up to 4 cloud layers into account
//
Shader "Hidden/Nuaj/AerialPerspectiveSimple"
{
	Properties
	{
		_MainTex( "Base (RGB)", 2D ) = "white" {}
		_TexDownsampledZBuffer( "Base (RGB)", 2D ) = "black" {}
		_TexDensity( "Base (RGB)", 2D ) = "black" {}
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
		// Pass #0 renders sky with NO cloud layer
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
			#include "AerialPerspectiveSimpleInc.cginc"

			half4	PS( PS_IN _In ) : COLOR	{ return RenderSky( _In, ReadDownsampledDepthMax( _TexDownsampledZBuffer, _In.UV ) ); }
			ENDCG
		}

		//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		// Pass #1 renders sky with 1 cloud layer
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
			#include "AerialPerspectiveSimpleInc.cginc"

			half4	PS( PS_IN _In ) : COLOR	{ return RenderSky( _In, ReadDownsampledDepthMax( _TexDownsampledZBuffer, _In.UV ) ); }
			ENDCG
		}

		//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		// Pass #2 renders sky with 2 cloud layers
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
			#include "AerialPerspectiveSimpleInc.cginc"

			half4	PS( PS_IN _In ) : COLOR	{ return RenderSky( _In, ReadDownsampledDepthMax( _TexDownsampledZBuffer, _In.UV ) ); }
			ENDCG
		}

		//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		// Pass #3 renders sky with 3 cloud layers
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
			#include "AerialPerspectiveSimpleInc.cginc"

			half4	PS( PS_IN _In ) : COLOR	{ return RenderSky( _In, ReadDownsampledDepthMax( _TexDownsampledZBuffer, _In.UV ) ); }
			ENDCG
		}

		//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		// Pass #4 renders sky with 4 cloud layers
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
			#include "AerialPerspectiveSimpleInc.cginc"

			half4	PS( PS_IN _In ) : COLOR	{ return RenderSky( _In, ReadDownsampledDepthMax( _TexDownsampledZBuffer, _In.UV ) ); }
			ENDCG
		}

//// THIS IS THE FIRST SET OF SHADERS THAT USE ACCURATE REFINEMENT

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
			#define ACCURATE_REFINE

			#include "../Header.cginc"
			#include "AerialPerspectiveSimpleInc.cginc"
			#include "SkyCompositionInc.cginc"

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
			#define ACCURATE_REFINE

			#include "../Header.cginc"
			#include "AerialPerspectiveSimpleInc.cginc"
			#include "SkyCompositionInc.cginc"

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
			#define ACCURATE_REFINE

			#include "../Header.cginc"
			#include "AerialPerspectiveSimpleInc.cginc"
			#include "SkyCompositionInc.cginc"

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
			#define ACCURATE_REFINE

			#include "../Header.cginc"
			#include "AerialPerspectiveSimpleInc.cginc"
			#include "SkyCompositionInc.cginc"

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
			#define ACCURATE_REFINE

			#include "../Header.cginc"
			#include "AerialPerspectiveSimpleInc.cginc"
			#include "SkyCompositionInc.cginc"

			half4	PS( PS_IN _In ) : COLOR	{ return ComposeSkyAndClouds( _In ); }
			ENDCG
		}

//// THIS IS THE SECOND SET OF SHADERS THAT USE SMART REFINEMENT

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
			#define SMART_REFINE

			#include "../Header.cginc"
			#include "AerialPerspectiveSimpleInc.cginc"
			#include "SkyCompositionInc.cginc"

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
			#define SMART_REFINE

			#include "../Header.cginc"
			#include "AerialPerspectiveSimpleInc.cginc"
			#include "SkyCompositionInc.cginc"

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
			#define SMART_REFINE

			#include "../Header.cginc"
			#include "AerialPerspectiveSimpleInc.cginc"
			#include "SkyCompositionInc.cginc"

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
			#define SMART_REFINE

			#include "../Header.cginc"
			#include "AerialPerspectiveSimpleInc.cginc"
			#include "SkyCompositionInc.cginc"

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
			#define SMART_REFINE

			#include "../Header.cginc"
			#include "AerialPerspectiveSimpleInc.cginc"
			#include "SkyCompositionInc.cginc"

			half4	PS( PS_IN _In ) : COLOR	{ return ComposeSkyAndClouds( _In ); }
			ENDCG
		}

//// THIS IS THE THIRD SET OF SHADERS THAT USE CUTOUT REFINEMENT

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
			#define CUTOUT_REFINE

			#include "../Header.cginc"
			#include "AerialPerspectiveSimpleInc.cginc"
			#include "SkyCompositionInc.cginc"

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
			#define CUTOUT_REFINE

			#include "../Header.cginc"
			#include "AerialPerspectiveSimpleInc.cginc"
			#include "SkyCompositionInc.cginc"

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
			#define CUTOUT_REFINE

			#include "../Header.cginc"
			#include "AerialPerspectiveSimpleInc.cginc"
			#include "SkyCompositionInc.cginc"

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
			#define CUTOUT_REFINE

			#include "../Header.cginc"
			#include "AerialPerspectiveSimpleInc.cginc"
			#include "SkyCompositionInc.cginc"

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
			#define CUTOUT_REFINE

			#include "../Header.cginc"
			#include "AerialPerspectiveSimpleInc.cginc"
			#include "SkyCompositionInc.cginc"

			half4	PS( PS_IN _In ) : COLOR	{ return ComposeSkyAndClouds( _In ); }
			ENDCG
		}

//// THIS IS THE FOURTH SET OF SHADERS THAT USE BILINEAR REFINEMENT

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
			#include "AerialPerspectiveSimpleInc.cginc"
			#include "SkyCompositionInc.cginc"

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
			#include "AerialPerspectiveSimpleInc.cginc"
			#include "SkyCompositionInc.cginc"

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
			#include "AerialPerspectiveSimpleInc.cginc"
			#include "SkyCompositionInc.cginc"

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
			#include "AerialPerspectiveSimpleInc.cginc"
			#include "SkyCompositionInc.cginc"

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
			#include "AerialPerspectiveSimpleInc.cginc"
			#include "SkyCompositionInc.cginc"

			half4	PS( PS_IN _In ) : COLOR	{ return ComposeSkyAndClouds( _In ); }
			ENDCG
		}
	}
	Fallback off
}
