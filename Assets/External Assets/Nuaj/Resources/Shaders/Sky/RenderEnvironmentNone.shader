// This shader is responsible for rendering 3 tiny environment maps
// . The first map renders the sky without the clouds and is used to compute the ambient sky light for clouds
// . The second map renders the sky with the clouds and is used to compute the ambient sky light for the scene
// . The third map renders the sun with the clouds and is used to compute the directional sun light to use for the scene
//
Shader "Hidden/Nuaj/RenderSkyEnvironmentNone"
{
	Properties
	{
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
			#include "AerialPerspectiveNoneInc.cginc"

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
			#include "AerialPerspectiveNoneInc.cginc"

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

			#define CLOUD_LAYERS 4
			#define RENDER_SUN

			#include "../Header.cginc"
			#include "AerialPerspectiveNoneInc.cginc"

			half4	PS( PS_IN _In ) : COLOR	{ return RenderSkyEnvironment( _In ); }
			ENDCG
		}
	}
	Fallback off
}
