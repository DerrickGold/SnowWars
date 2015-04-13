// This shader renders the volume clouds deep shadow maps
//
Shader "Hidden/Nuaj/CloudVolumeShadow"
{
	Properties
	{
		_MainTex( "Base (RGB)", 2D ) = "white" {}
		_TexNoise3D0( "Base (RGB)", 2D ) = "white" {}
		_TexNoise3D1( "Base (RGB)", 2D ) = "white" {}
		_TexNoise3D2( "Base (RGB)", 2D ) = "white" {}
		_TexNoise3D3( "Base (RGB)", 2D ) = "white" {}
		_TexShadowMap( "Base (RGB)", 2D ) = "white" {}
		_TexDeepShadowMap0( "Base (RGB)", 2D ) = "white" {}
		_TexShadowEnvMapSkyTop( "Base (RGB)", 2D ) = "white" {}
		_TexShadowEnvMapSkyBottom( "Base (RGB)", 2D ) = "white" {}
		_TexDeepShadowMapPreviousLayer( "Base (RGB)", 2D ) = "white" {}
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
			#define GL_ARB_shader_texture_lod 1
			#pragma fragmentoption ARB_shader_texture_lod
			#include "../Header.cginc"
			#include "CloudVolumeInc.cginc"

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
			#define GL_ARB_shader_texture_lod 1
			#pragma fragmentoption ARB_shader_texture_lod
			#include "../Header.cginc"
			#include "CloudVolumeInc.cginc"

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
			#define GL_ARB_shader_texture_lod 1
			#pragma fragmentoption ARB_shader_texture_lod
			#include "../Header.cginc"
			#include "CloudVolumeInc.cginc"

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
			#define GL_ARB_shader_texture_lod 1
			#pragma fragmentoption ARB_shader_texture_lod
			#include "../Header.cginc"
			#include "CloudVolumeInc.cginc"

			float4	PS( PS_IN _In ) : COLOR	{ return ComputeCloudShadow( _In ); }
			ENDCG
		}

		//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		// Pass #4 is the initial step that takes into account any previous shadowing from clouds above our own cloud
		Pass
		{
			CGPROGRAM
			#pragma vertex VS_VIEWPORT
			#pragma fragment PS
			#pragma target 3.0
			#pragma glsl
			#pragma only_renderers d3d9 d3d11 opengl

#define CLOUD_SHADOW

			#include "../Header.cginc"
			#include "CloudVolumeInc.cginc"

			uniform float	_ShadowOpacity;
			uniform float3	_ShadowStepsCount;		// X=This pass steps count Y=Total amount of shadow steps Z=Pass steps / 4

			float	SingleStep( float3 _CloudPositionKm, float _Distance2CameraKm, float _Coverage )
			{
				float	HeightInCloudsKm;
				return ComputeCloudDensity( float4( _CloudPositionKm, _Distance2CameraKm ), _Coverage, 0.0, HeightInCloudsKm );
			}

			float4	PS( PS_IN _In ) : COLOR
			{
				if ( BorderFade( _In.UV ) < 0.0 )
					return 0.0;

				float	RadiusBottomKm = _PlanetRadiusKm + _CloudAltitudeKm.x;
				float	RadiusTopKm = _PlanetRadiusKm + _CloudAltitudeKm.y;

				// Compute initial shadowing from any above cloud
				float4	CloudPositionKm = float4( Shadow2CloudPosition( _In.UV.xy, RadiusTopKm ), 0.0 );
				float	InitialAltitudeKm = length( CloudPositionKm.xyz - _PlanetCenterKm ) - _PlanetRadiusKm;
				float	InitialOpacity = GetShadowAtAltitude( _In.UV.xy, InitialAltitudeKm );		// Shadowing from clouds above

				float	InitialOpticalDepth = log( 1e-3 + InitialOpacity );

				// Compute only a single distance to camera
				float3	CameraPositionKm = _Camera2WorldKm._m03_m13_m23;
				float	Distance2CameraKm = length(CloudPositionKm.xyz - CameraPositionKm);

				// Compute shadow step
				float	OutDistanceKm = ComputeSphereIntersection( CloudPositionKm.xyz, -_SunDirection, _PlanetCenterKm, RadiusBottomKm );
				float	ShadowStepSizeKm = OutDistanceKm / _ShadowStepsCount.y;
				float4	ShadowStepKm = ShadowStepSizeKm * float4( -_SunDirection, 1.0 );
				CloudPositionKm += 0.25 * ShadowStepKm;	// Start half a step inside the cloud

				// Compute local coverage
				float	LocalCoverage = GetLocalCoverage( CloudPositionKm.xyz, _CloudLayerIndex );

				// Step through our cloud
				float4	FinalDensities = 0.0;
				float4	MaxDistances = ShadowStepSizeKm * _ShadowStepsCount.z * float4( 1.0, 2.0, 3.0, 4.0 );
				for ( float StepIndex=0.0; StepIndex < _ShadowStepsCount.x; StepIndex++ )
				{
					float	StepDensity = SingleStep( CloudPositionKm.xyz, Distance2CameraKm, LocalCoverage );
					FinalDensities += StepDensity * saturate( MaxDistances - CloudPositionKm.wwww );	// Only accumulate density if in the proper interval
					CloudPositionKm += ShadowStepKm;
				}

				// Finalize opacities
				FinalDensities *= _CloudSigma_t * _ShadowOpacity * ShadowStepKm.w;	// We're storing optical depth here
				FinalDensities -= InitialOpticalDepth;								// Add initial optical depth
				return FinalDensities;
			}
			ENDCG
		}


		//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		// Pass #5 is the following steps for deep shadow maps that have more than one layer.
		// It samples the previous layer of the deep shadow map for initial shadowing
		Pass
		{
			CGPROGRAM
			#pragma vertex VS_VIEWPORT
			#pragma fragment PS
			#pragma target 3.0
			#pragma glsl
			#pragma only_renderers d3d9 d3d11 opengl

#define CLOUD_SHADOW

			#include "../Header.cginc"
			#include "CloudVolumeInc.cginc"

			uniform float	_ShadowOpacity;
			uniform float3	_ShadowStepsCount;		// X=This pass steps count Y=Total amount of shadow steps Z=Pass steps / 4
			uniform float	_ShadowLayerIndex;		// Step offset (4 for 2nd layer, 8 for 3rd layer, etc.)

			uniform sampler2D	_TexDeepShadowMapPreviousLayer;
			float	SingleStep( float3 _CloudPositionKm, float _Distance2CameraKm, float _Coverage )
			{
				float	HeightInCloudsKm;
				return ComputeCloudDensity( float4( _CloudPositionKm, _Distance2CameraKm ), _Coverage, 0.0, HeightInCloudsKm );
			}

			float4	PS( PS_IN _In ) : COLOR
			{
				if ( BorderFade( _In.UV ) < 0.0 )
					return 0.0;

				float	RadiusBottomKm = _PlanetRadiusKm + _CloudAltitudeKm.x;
				float	RadiusTopKm = _PlanetRadiusKm + _CloudAltitudeKm.y;

				// Compute initial shadowing from previous deep layer
				float4	CloudPositionKm = float4( Shadow2CloudPosition( _In.UV.xy, RadiusTopKm ), 0.0 );
				float	InitialOpticalDepth = _tex2Dlod( _TexDeepShadowMapPreviousLayer, _In.UV ).w;

				// Compute only a single distance to camera
				float3	CameraPositionKm = _Camera2WorldKm._m03_m13_m23;
				float	Distance2CameraKm = length(CloudPositionKm.xyz - CameraPositionKm);

				// Compute shadow step
				float	OutDistanceKm = ComputeSphereIntersection( CloudPositionKm.xyz, -_SunDirection, _PlanetCenterKm, RadiusBottomKm );
				float	ShadowStepSizeKm = OutDistanceKm / _ShadowStepsCount.y;
				float4	ShadowStepKm = ShadowStepSizeKm * float4( -_SunDirection, 1.0 );
				CloudPositionKm += (0.25 + _ShadowLayerIndex * _ShadowStepsCount.x) * ShadowStepKm;	// March to skip already performed steps

				// Compute local coverage
				float	LocalCoverage = GetLocalCoverage( CloudPositionKm.xyz, _CloudLayerIndex );

				// Step through our cloud
				float4	FinalDensities = 0.0;
				float4	MaxDistances = ShadowStepSizeKm * _ShadowStepsCount.z * (4.0 * _ShadowLayerIndex + float4( 1.0, 2.0, 3.0, 4.0 ));
				for ( float StepIndex=0.0; StepIndex < _ShadowStepsCount.x; StepIndex++ )
				{
					float	StepDensity = SingleStep( CloudPositionKm.xyz, Distance2CameraKm, LocalCoverage );
					FinalDensities += StepDensity * saturate( MaxDistances - CloudPositionKm.wwww );	// Only accumulate density if in the proper interval
					CloudPositionKm += ShadowStepKm;
				}

				// Finalize opacities
				FinalDensities *= _CloudSigma_t * _ShadowOpacity * ShadowStepKm.w;	// We're storing optical depth here
				FinalDensities += InitialOpticalDepth;								// Add initial optical depth
				return FinalDensities;
			}
			ENDCG
		}

		// Pass #6 This is used to smooth out the shadow map using a simple gaussian blur
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

			uniform float4		_dUV;
			uniform sampler2D	_MainTex;

			half4	PS( PS_IN _In ) : COLOR
			{
				float4	UV2 = _In.UV;
				float4	Vp0 = _tex2Dlod( _MainTex, _In.UV );	_In.UV += _dUV;
				float4	Vp1 = _tex2Dlod( _MainTex, _In.UV );	_In.UV += _dUV;
				float4	Vp2 = _tex2Dlod( _MainTex, _In.UV );	UV2 -= _dUV;
				float4	Vm1 = _tex2Dlod( _MainTex, UV2 );		UV2 -= _dUV;
				float4	Vm2 = _tex2Dlod( _MainTex, UV2 );

				return 0.0625 * (6.0 * Vp0 + 4.0 * (Vp1 + Vm1) + Vp2 + Vm2);
			}
			ENDCG
		}

		//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		// Pass #7 renders the deep shadow map used by the sky environment rendering
		Pass
		{
			CGPROGRAM
			#pragma vertex VS
			#pragma fragment PS
			#pragma target 3.0
			#pragma glsl
			#pragma only_renderers d3d9 d3d11 opengl

#define CLOUD_SHADOW

			#include "../Header.cginc"
			#include "CloudVolumeInc.cginc"

			uniform float	_ShadowOpacity;

			float	SingleStep( inout float4 _CloudPositionKm, float _Distance2CameraKm, float _Coverage, float4 _ShadowStepKm )
			{
				float	HeightInCloudsKm;
				float	Density = ComputeCloudDensity( float4( _CloudPositionKm.xyz, _Distance2CameraKm ), _Coverage, 0.0, HeightInCloudsKm );
				_CloudPositionKm += _ShadowStepKm;
				return Density;
			}

			float4	PS( PS_IN _In ) : COLOR
			{
				float3	ProbePositionKm, View;
				ComputeEnvironmentPositionViewSky( _In.UV.xy, ProbePositionKm, View );

				float	RadiusBottomKm = _PlanetRadiusKm + _CloudAltitudeKm.x;
				float	RadiusTopKm = _PlanetRadiusKm + _CloudAltitudeKm.y;

				// Compute initial position at cloud top
				float	Distance2CloudKm = ComputeSphereIntersection( ProbePositionKm, View, _PlanetCenterKm, RadiusBottomKm );				// Compute distance to cloud bottom first
				float3	CloudPositionBottomKm = ProbePositionKm + Distance2CloudKm * View;
				float	OutDistanceKm = ComputeSphereExitIntersection( CloudPositionBottomKm, _SunDirection, _PlanetCenterKm, RadiusTopKm );	// Compute distance to cloud top, following Sun direction
				float4	CloudPositionKm = float4( CloudPositionBottomKm + OutDistanceKm * _SunDirection, 0.0 );

				float3	CameraPositionKm = _Camera2WorldKm._m03_m13_m23;
				float3	Camera2Cloud = CloudPositionKm.xyz - CameraPositionKm;
				float	Distance2CameraKm = length( Camera2Cloud );

				// Compute shadow step
				float	ShadowStepSizeKm = 0.25 * OutDistanceKm;
				float4	ShadowStepKm = float4( -_SunDirection * 0.25 * OutDistanceKm, ShadowStepSizeKm );

				// Compute local coverage
				float3	SamplePositionKm = CloudPositionKm.xyz - 0.5 * OutDistanceKm * _SunDirection;
				float	LocalCoverage = GetLocalCoverage( SamplePositionKm, _CloudLayerIndex );

				// Compute cloud densities
 				CloudPositionKm += 0.5 * ShadowStepKm;	// Start half a step inside the cloud

				float4	Densities = float4(	SingleStep( CloudPositionKm, Distance2CameraKm, LocalCoverage, ShadowStepKm ),
											SingleStep( CloudPositionKm, Distance2CameraKm, LocalCoverage, ShadowStepKm ),
											SingleStep( CloudPositionKm, Distance2CameraKm, LocalCoverage, ShadowStepKm ),
											SingleStep( CloudPositionKm, Distance2CameraKm, LocalCoverage, ShadowStepKm ) 
										  );

				// Finalize opacities
				Densities *= _CloudSigma_t * _ShadowOpacity * ShadowStepKm.w;	// We're storing optical depth here
				return Densities;
			}
			ENDCG
		}

		//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		// Pass #8 computes environment lighting for the sky (this is simply the cloud rendered into a small map)
		Pass
		{
			CGPROGRAM
			#pragma vertex VS_WITH_AMBIENT
			#pragma fragment PS
			#pragma target 3.0
			#pragma glsl
			#pragma only_renderers d3d9 d3d11 opengl
			#define GL_ARB_shader_texture_lod 1
			#pragma fragmentoption ARB_shader_texture_lod

#define ENVIRONMENT_RENDERING	// So we use the environment deep shadow map

			#include "../Header.cginc"
			#include "CloudVolumeInc.cginc"

			float4	PS( PS_IN_AMBIENT_SUN _In ) : COLOR
			{
				// Sample Sun & Sky colors
				float3	SkyAmbientTop, SkyAmbientBottom;
				ComputeShadowedAmbientTerm( SkyAmbientTop, SkyAmbientBottom );
				float3	SunColor = ComputeSunExtinction( _PlanetRadiusKm + _CloudAltitudeKm.y );

				// Build position/view
				float3	ProbePositionKm, View;
				ComputeEnvironmentPositionViewSky( _In.UV.xy, ProbePositionKm, View );

				float	CloudHitDistanceBottomKm = ComputeSphereIntersection( ProbePositionKm, View, _PlanetCenterKm, _PlanetRadiusKm + _CloudAltitudeKm.x );
				float	CloudHitDistanceTopKm = ComputeSphereIntersection( ProbePositionKm, View, _PlanetCenterKm, _PlanetRadiusKm + _CloudAltitudeKm.y );

				// Order min/max
				float2	CloudHitDistancesKm = float2(
					min( CloudHitDistanceBottomKm, CloudHitDistanceTopKm ),
					max( CloudHitDistanceBottomKm, CloudHitDistanceTopKm ) );

				CloudHitDistancesKm.x = max( 0.0, CloudHitDistancesKm.x );	// Don't start before camera position
				if ( CloudHitDistancesKm.x > CloudHitDistancesKm.y )
					return float4( 0.0, 0.0, 0.0, 1.0 );				// Above that layer or not looking at it ?

				// Compute potential intersection with earth's shadow
				float2	EarthShadowDistancesKm = ComputePlanetShadow( ProbePositionKm, View, _SunDirection );

				// Compute mip level at hit position
				float	MipLevel = GetEnvironmentMipLevel( ProbePositionKm + CloudHitDistancesKm.x * View, ProbePositionKm, _PlanetNormal );

				// Compute lighting
				float4	CloudColor = ComputeCloudLighting( ProbePositionKm, View, CloudHitDistancesKm, EarthShadowDistancesKm, SkyAmbientTop, SkyAmbientBottom, SunColor, MipLevel, _In.UV, _StepsCount );

				// Modulate color by sky extinction
				CloudColor.xyz *= ComputeSkyExtinctionSimple( float2( length( ProbePositionKm - _PlanetCenterKm ), length( ProbePositionKm + CloudHitDistancesKm.x * View - _PlanetCenterKm ) ), CloudHitDistancesKm.x );

				return CloudColor;
			}
			ENDCG
		}
	}
	Fallback off
}
