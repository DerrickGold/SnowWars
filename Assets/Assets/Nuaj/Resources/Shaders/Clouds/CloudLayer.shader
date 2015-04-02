// This shader renders layers of flat, high-altitude clouds
//
Shader "Hidden/Nuaj/Layer"
{
	Properties
	{
		_TexPhaseMie( "Base (RGB)", 2D ) = "black" {}
		_TexNoise0( "Base (RGB)", 2D ) = "white" {}
		_TexNoise1( "Base (RGB)", 2D ) = "white" {}
		_TexNoise2( "Base (RGB)", 2D ) = "white" {}
		_TexNoise3( "Base (RGB)", 2D ) = "white" {}
		_TexShadowMap( "Base (RGB)", 2D ) = "white" {}
		_TexShadowEnvMapSkyTop( "Base (RGB)", 2D ) = "white" {}
		_TexShadowEnvMapSkyBottom( "Base (RGB)", 2D ) = "white" {}
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
		ColorMask RGBA		// Write ALL


		//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		// Pass #0 Computes cloud shadowing for layer 0
		Pass
		{
			ColorMask R	// Only write RED

			CGPROGRAM
			#pragma vertex VS_VIEWPORT
			#pragma fragment PS
			#pragma target 3.0
			#pragma glsl
			#pragma only_renderers d3d9 d3d11 opengl
			#include "../Header.cginc"
			#include "CloudLayerInc.cginc"

			float4	PS( PS_IN _In ) : COLOR	{ return ComputeCloudShadow( _In ); }
			ENDCG
		}

		//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		// Pass #1 Computes cloud shadowing for layer 1
		Pass
		{
			ColorMask G	// Only write GREEN

			CGPROGRAM
			#pragma vertex VS_VIEWPORT
			#pragma fragment PS
			#pragma target 3.0
			#pragma glsl
			#pragma only_renderers d3d9 d3d11 opengl
			#include "../Header.cginc"
			#include "CloudLayerInc.cginc"

			float4	PS( PS_IN _In ) : COLOR	{ return ComputeCloudShadow( _In ); }
			ENDCG
		}

		//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		// Pass #2 Computes cloud shadowing for layer 2
		Pass
		{
			ColorMask B	// Only write BLUE

			CGPROGRAM
			#pragma vertex VS_VIEWPORT
			#pragma fragment PS
			#pragma target 3.0
			#pragma glsl
			#pragma only_renderers d3d9 d3d11 opengl
			#include "../Header.cginc"
			#include "CloudLayerInc.cginc"

			float4	PS( PS_IN _In ) : COLOR	{ return ComputeCloudShadow( _In ); }
			ENDCG
		}

		//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		// Pass #3 Computes cloud shadowing for layer 3
		Pass
		{
			ColorMask A	// Only write ALPHA

			CGPROGRAM
			#pragma vertex VS_VIEWPORT
			#pragma fragment PS
			#pragma target 3.0
			#pragma glsl
			#pragma only_renderers d3d9 d3d11 opengl
			#include "../Header.cginc"
			#include "CloudLayerInc.cginc"

			float4	PS( PS_IN _In ) : COLOR	{ return ComputeCloudShadow( _In ); }
			ENDCG
		}

		//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		// Pass #4 computes the actual cloud lighting
		Pass
		{
			CGPROGRAM
			#pragma vertex VS_WITH_AMBIENT
			#pragma fragment PS
			#pragma target 3.0
			#pragma glsl
			#pragma only_renderers d3d9 d3d11 opengl
			#include "../Header.cginc"
			#include "CloudLayerInc.cginc"


			float4	PS( PS_IN_AMBIENT_SUN _In ) : COLOR
			{
				// Sample Sun & Sky colors
				float3	SkyAmbientTop, SkyAmbientBottom;
				ComputeShadowedAmbientTerm( SkyAmbientTop, SkyAmbientBottom );
				float3	SunColor = ComputeSunExtinction( _PlanetRadiusKm + _CloudAltitudeKm.x );

				float3	CameraPositionKm, View;
				float	Depth2Distance;
				ComputeCameraPositionViewKm( _In.UV.xy, CameraPositionKm, View, Depth2Distance );
				float	Z = ReadDepth( _In.UV );

				float	PlanetHitDistanceKm = ComputeSphereEnterIntersection( CameraPositionKm, View, _PlanetCenterKm, _PlanetRadiusKm );

				PlanetHitDistanceKm = lerp( PlanetHitDistanceKm, 0.5 * INFINITY, saturate( -10000.0 * PlanetHitDistanceKm ) );	// If looking up, the planet hit stands behind us so we bring it back to infinity...
				PlanetHitDistanceKm = min( PlanetHitDistanceKm, 0.5 * INFINITY );												// If there is no hit, the intersection stands at infinity but we need to bring it back to a lower value for later comparisons with infinity

				float	SceneDistanceKm = lerp( _WorldUnit2Kilometer * Depth2Distance * Z, PlanetHitDistanceKm, StepInfinity( Z ) );

				// Compute cloud hit distance
				float	CameraRadiusKm = length( CameraPositionKm - _PlanetCenterKm );
				float	CloudRadiusKm = _PlanetRadiusKm + _CloudAltitudeKm.x;

				float2	CloudHitDistancesKm = ComputeBothSphereIntersections( CameraPositionKm, View, _PlanetCenterKm, CloudRadiusKm );
				float	CloudHitDistanceKm = lerp( CloudHitDistancesKm.y, CloudHitDistancesKm.x, saturate( 10000.0 * (CameraRadiusKm - CloudRadiusKm) ) );	// Use Exit intersection if below the layer, Enter intersection otherwise

//###This causes nasty lines with infinite values on Mac that make the clouds crash the tone mapping
//				if ( CloudHitDistanceKm < 0.0 || CloudHitDistanceKm > SceneDistanceKm )
// 					return float4( 0.0, 0.0, 0.0, 1.0 );	// No intersection or scene in front ?

				// Check if we're in shadow
				SunColor *= IsInShadowSoft( CloudHitDistanceKm, ComputePlanetShadow( CameraPositionKm, View, _SunDirection ) );

				// Compute lighting
 				float3	HitPositionCloudKm = CameraPositionKm + CloudHitDistanceKm * View;
				float4	CloudColor = ComputeCloudLighting( HitPositionCloudKm, CameraPositionKm, View, SkyAmbientTop, SkyAmbientBottom, SunColor, GetMipLevel( HitPositionCloudKm, CameraPositionKm, _PlanetNormal ) );

				// Modulate color by sky extinction
				CloudColor.xyz *= ComputeSkyExtinctionSimple( float2( CameraRadiusKm, length( HitPositionCloudKm - _PlanetCenterKm ) ), CloudHitDistanceKm );

				//### Lerp with empty clouds if no hit or hitting the scene first
				CloudColor = lerp( CloudColor, float4( 0.0, 0.0, 0.0, 1.0 ), saturate( saturate( -10000.0 * CloudHitDistanceKm ) + saturate( 10000.0 * (CloudHitDistanceKm - SceneDistanceKm) ) ) );

				return CloudColor;
			}
			ENDCG
		}

		//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		// Pass #5 computes environment lighting (this is simply the cloud rendered into a small map)
		Pass
		{
			CGPROGRAM
			#pragma vertex VS_WITH_AMBIENT
			#pragma fragment PS
			#pragma target 3.0
			#pragma glsl
			#pragma only_renderers d3d9 d3d11 opengl
			#include "../Header.cginc"
			#include "CloudLayerInc.cginc"

			float4	PS( PS_IN_AMBIENT_SUN _In ) : COLOR
			{
				// Sample Sun & Sky colors
				float3	SkyAmbientTop, SkyAmbientBottom;
				ComputeShadowedAmbientTerm( SkyAmbientTop, SkyAmbientBottom );
				float3	SunColor = ComputeSunExtinction( _PlanetRadiusKm + _CloudAltitudeKm.x );

				// Build position/view
				float3	ProbePositionKm, View;
				ComputeEnvironmentPositionViewSky( _In.UV.xy, ProbePositionKm, View );

				float	CloudHitDistanceKm = ComputeSphereIntersection( ProbePositionKm, View, _PlanetCenterKm, _PlanetRadiusKm + _CloudAltitudeKm.x );
				if ( CloudHitDistanceKm <= 0.01 )
					return float4( 0.0, 0.0, 0.0, 1.0 );	// Above that layer or not looking at it ?

				// Compute lighting
 				float3	HitPositionCloudKm = ProbePositionKm + CloudHitDistanceKm * View;
				float4	CloudColor = ComputeCloudLighting( HitPositionCloudKm, ProbePositionKm, View, SkyAmbientTop, SkyAmbientBottom, SunColor, GetEnvironmentMipLevel( HitPositionCloudKm, ProbePositionKm, _PlanetNormal ) );

				// Modulate color by sky extinction
				CloudColor.xyz *= ComputeSkyExtinctionSimple( float2( length( ProbePositionKm - _PlanetCenterKm ), length( HitPositionCloudKm - _PlanetCenterKm ) ), CloudHitDistanceKm );

				return CloudColor;
			}
			ENDCG
		}

		//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		// Pass #6 computes environment lighting in the Sun's direction (this is simply the cloud rendered into a 1x1 map)
		Pass
		{
			CGPROGRAM
			#pragma vertex VS_WITH_AMBIENT
			#pragma fragment PS
			#pragma target 3.0
			#pragma glsl
			#pragma only_renderers d3d9 d3d11 opengl
			#include "../Header.cginc"
			#include "CloudLayerInc.cginc"

			float4	PS( PS_IN_AMBIENT_SUN _In ) : COLOR
			{
				// Sample Sun & Sky colors
				float3	SkyAmbientTop, SkyAmbientBottom;
				ComputeShadowedAmbientTerm( SkyAmbientTop, SkyAmbientBottom );
				float3	SunColor = ComputeSunExtinction( _PlanetRadiusKm + _CloudAltitudeKm.x );

				// Build position/view
				float3	ProbePositionKm, View;
				ComputeEnvironmentPositionViewSun( ProbePositionKm, View );

				float	CloudHitDistanceKm = ComputeSphereIntersection( ProbePositionKm, View, _PlanetCenterKm, _PlanetRadiusKm + _CloudAltitudeKm.x );
				if ( CloudHitDistanceKm <= 0.01 )
					return float4( 0.0, 0.0, 0.0, 1.0 );	// Above that layer or not looking at it ?

				// Compute lighting
 				float3	HitPositionCloudKm = ProbePositionKm + CloudHitDistanceKm * View;
				float4	CloudColor = ComputeCloudLighting( HitPositionCloudKm, ProbePositionKm, View, SkyAmbientTop, SkyAmbientBottom, SunColor, GetEnvironmentMipLevel( HitPositionCloudKm, ProbePositionKm, _PlanetNormal ) );

				// Modulate color by sky extinction
				CloudColor.xyz *= ComputeSkyExtinctionSimple( float2( length( ProbePositionKm - _PlanetCenterKm ), length( HitPositionCloudKm - _PlanetCenterKm ) ), CloudHitDistanceKm );

				return CloudColor;
			}
			ENDCG
		}
	}
	Fallback off
}
