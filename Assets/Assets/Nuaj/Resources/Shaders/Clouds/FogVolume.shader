// This shader renders low-frequency volumetric fog
//
Shader "Hidden/Nuaj/Fog"
{
	Properties
	{
		_MainTex( "Base (RGB)", 2D ) = "white" {}
		_TexDownsampledZBuffer( "Base (RGB)", 2D ) = "black" {}
		_TexShadowMap( "Base (RGB)", 2D ) = "white" {}
		_TexShadowEnvMapSkyTop( "Base (RGB)", 2D ) = "white" {}
		_TexShadowEnvMapSkyBottom( "Base (RGB)", 2D ) = "white" {}
		_TexLayeredDensity( "Base (RGB)", 2D ) = "white" {}
		_TexDensity( "Base (RGB)", 2D ) = "white" {}
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
		// Pass #0 Computes fog shadowing for layer 0
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
			#include "FogVolumeInc.cginc"

			float4	PS( PS_IN _In ) : COLOR	{ return ComputeFogShadow( _In ); }
			ENDCG
		}

		//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		// Pass #1 Computes fog shadowing for layer 1
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
			#include "FogVolumeInc.cginc"

			float4	PS( PS_IN _In ) : COLOR	{ return ComputeFogShadow( _In ); }
			ENDCG
		}

		//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		// Pass #2 Computes fog shadowing for layer 2
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
			#include "FogVolumeInc.cginc"

			float4	PS( PS_IN _In ) : COLOR	{ return ComputeFogShadow( _In ); }
			ENDCG
		}

		//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		// Pass #3 Computes fog shadowing for layer 3
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
			#include "FogVolumeInc.cginc"

			float4	PS( PS_IN _In ) : COLOR	{ return ComputeFogShadow( _In ); }
			ENDCG
		}

		//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		// Pass #4 computes the actual fog lighting
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
			#include "../Header.cginc"
			#include "FogVolumeInc.cginc"

			uniform float	_UseSceneZ;

			float4	PS( PS_IN_AMBIENT_SUN _In ) : COLOR		{ return ComputeFogColor( _In, lerp( _CameraData.w, ReadDownsampledDepthMax( _TexDownsampledZBuffer, _In.UV ), _UseSceneZ ) ); }
			ENDCG
		}

		//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		// Pass #5 computes environment lighting (this is simply the fog rendered into a small map)
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
			#include "../Header.cginc"
			#include "FogVolumeInc.cginc"

			float4	PS( PS_IN_AMBIENT_SUN _In ) : COLOR
			{
				// Sample Sun & Sky colors
				float3	SkyAmbientTop, SkyAmbientBottom;
				ComputeShadowedAmbientTerm( SkyAmbientTop, SkyAmbientBottom );
				float3	SunColor = ComputeSunExtinction( _PlanetRadiusKm + _FogAltitudeKm.y );	// Get sun color at the top of the fog

				// Build position/view
				float3	ProbePositionKm, View;
				ComputeEnvironmentPositionViewSky( _In.UV.xy, ProbePositionKm, View );

				float	FogHitDistanceBottomKm = ComputeSphereIntersection( ProbePositionKm, View, _PlanetCenterKm, _PlanetRadiusKm + _FogAltitudeKm.x );
				float	FogHitDistanceTopKm = ComputeSphereIntersection( ProbePositionKm, View, _PlanetCenterKm, _PlanetRadiusKm + _FogAltitudeKm.y );

				// Order min/max
				float2	FogHitDistancesKm = float2(
					min( FogHitDistanceBottomKm, FogHitDistanceTopKm ),
					max( FogHitDistanceBottomKm, FogHitDistanceTopKm ) );

				FogHitDistancesKm.x = max( 0.0, FogHitDistancesKm.x );	// Don't start before camera position
				if ( FogHitDistancesKm.x > FogHitDistancesKm.y )
					return float4( 0.0, 0.0, 0.0, 1.0 );				// Above that layer or not looking at it ?

				// Compute potential intersection with earth's shadow
				float2	EarthShadowDistancesKm = ComputePlanetShadow( ProbePositionKm, View, _SunDirection );

				// Compute lighting
				return ComputeFogLighting( ProbePositionKm, View, FogHitDistancesKm, EarthShadowDistancesKm, SkyAmbientTop, SkyAmbientBottom, SunColor, _StepsCount );
			}
			ENDCG
		}

		//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		// Pass #6 computes environment lighting in the Sun's direction (this is simply the fog rendered into a 1x1 map)
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
			#include "../Header.cginc"
			#include "FogVolumeInc.cginc"

			float4	PS( PS_IN_AMBIENT_SUN _In ) : COLOR
			{
				// Sample Sun & Sky colors
				float3	SkyAmbientTop, SkyAmbientBottom;
				ComputeShadowedAmbientTerm( SkyAmbientTop, SkyAmbientBottom );
				float3	SunColor = ComputeSunExtinction( _PlanetRadiusKm + _FogAltitudeKm.y );	// Get sun color at the top of the fog

				// Build position/view
				float3	ProbePositionKm, View;
				ComputeEnvironmentPositionViewSun( ProbePositionKm, View );

				float	FogHitDistanceBottomKm = ComputeSphereIntersection( ProbePositionKm, View, _PlanetCenterKm, _PlanetRadiusKm + _FogAltitudeKm.x );
				float	FogHitDistanceTopKm = ComputeSphereIntersection( ProbePositionKm, View, _PlanetCenterKm, _PlanetRadiusKm + _FogAltitudeKm.y );

				// Order min/max
				float2	FogHitDistancesKm = float2(
					min( FogHitDistanceBottomKm, FogHitDistanceTopKm ),
					max( FogHitDistanceBottomKm, FogHitDistanceTopKm ) );

				FogHitDistancesKm.x = max( 0.0, FogHitDistancesKm.x );	// Don't start before camera position
				if ( FogHitDistancesKm.x > FogHitDistancesKm.y )
					return float4( 0.0, 0.0, 0.0, 1.0 );				// Above that layer or not looking at it ?

				// Compute potential intersection with earth's shadow
				float2	EarthShadowDistancesKm = ComputePlanetShadow( ProbePositionKm, View, _SunDirection );

				// Compute lighting
				return ComputeFogLighting( ProbePositionKm, View, FogHitDistancesKm, EarthShadowDistancesKm, SkyAmbientTop, SkyAmbientBottom, SunColor, _StepsCount );
			}
			ENDCG
		}

		//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		// Pass #7 mixes the lowest layer's density texture with our fog layered-density
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
			#include "../Header.cginc"
			#include "FogVolumeInc.cginc"

			uniform sampler2D	_MainTex;

			float4	PS( PS_IN_AMBIENT_SUN _In ) : COLOR
			{
				float3	WorldPositionKm = DensityUV2World( _In.UV );
				float	LocalCoverage = GetLocalCoverage( WorldPositionKm, _FogLayerIndex );
				return LocalCoverage * _DensityFactor * (_DensityOffset + _tex2Dlod( _MainTex, _In.UV ));
 			}
 			ENDCG
		}

		//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		// Pass #8 Upsamples the rendering using ACCURATE technique
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
			#include "../Header.cginc"
			#include "FogVolumeInc.cginc"

			uniform sampler2D	_MainTex;
			uniform float3		_ZBufferDiscrepancyThreshold;
			uniform float4		_dUV;		// 1/SourceSize
			uniform float4		_InvdUV;	// SouceSize

			float4	PS( PS_IN_AMBIENT_SUN _In ) : COLOR
			{
				float	SceneZ = ReadDepth( _In.UV );

				float4	TempUV = _In.UV - 0.5 * _dUV;
				float2	uv = frac( TempUV.xy * _InvdUV.xy );

				float	FogZ0 = ReadDownsampledDepthMax( _TexDownsampledZBuffer, TempUV );	TempUV.xy += _dUV.xz;
				float	FogZ1 = ReadDownsampledDepthMax( _TexDownsampledZBuffer, TempUV );	TempUV.xy += _dUV.zy;
				float	FogZ2 = ReadDownsampledDepthMax( _TexDownsampledZBuffer, TempUV );	TempUV.xy -= _dUV.xz;
				float	FogZ3 = ReadDownsampledDepthMax( _TexDownsampledZBuffer, TempUV );	TempUV.xy -= _dUV.zy;
				float	FogZ = lerp( lerp( FogZ0, FogZ1, uv.x ), lerp( FogZ2, FogZ3, uv.x ), uv.y );

				float4	FogColor = 0.0;
//				if ( abs(SceneZ - FogZ) > _ZBufferDiscrepancyThreshold.x && FogZ < 0.5 * _CameraData.w )
//				if ( abs(SceneZ - FogZ) > _ZBufferDiscrepancyThreshold.x )
//				if ( FogZ - SceneZ > _ZBufferDiscrepancyThreshold.x && !IsZInfinity( SceneZ ) )	// Working!
				if ( ZErrorMetric( SceneZ, FogZ ) > 0.01 * _ZBufferDiscrepancyThreshold.x )		// Latest version with new relative error metric
					FogColor = lerp( ComputeFogColor( _In, SceneZ ), float4( 0.0, 0.0, 1.0, 0.0 ), _ZBufferDiscrepancyThreshold.y );
				else
				{
					float4	FogColor0 = _tex2Dlod( _MainTex, TempUV );	TempUV.xy += _dUV.xz;
					float4	FogColor1 = _tex2Dlod( _MainTex, TempUV );	TempUV.xy += _dUV.zy;
					float4	FogColor2 = _tex2Dlod( _MainTex, TempUV );	TempUV.xy -= _dUV.xz;
					float4	FogColor3 = _tex2Dlod( _MainTex, TempUV );	TempUV.xy -= _dUV.zy;
					FogColor = lerp( lerp( FogColor0, FogColor1, uv.x ), lerp( FogColor2, FogColor3, uv.x ), uv.y );
				}

				return FogColor;
			}
			ENDCG
		}

		//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		// Pass #9 Upscales the rendering using the SMART technique
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
			#include "../Header.cginc"
			#include "FogVolumeInc.cginc"

			uniform sampler2D	_MainTex;
			uniform float3		_ZBufferDiscrepancyThreshold;
			uniform float4		_dUV;		// 1/SourceSize
			uniform float4		_InvdUV;	// SouceSize

			float4	PS( PS_IN_AMBIENT_SUN _In ) : COLOR
			{
				float3	CameraPositionKm, View;
				float	Depth2Distance;
				ComputeCameraPositionViewKm( _In.UV.xy, CameraPositionKm, View, Depth2Distance );

				float	SceneZ = ReadDepth( _In.UV );

				// Sample the 4 values where the cloud was computed
				_In.UV -= 0.5 * _dUV;

				float2	uv = frac( _In.UV.xy * _InvdUV.xy );	// Default UV interpolants for a normal bilinear interpolation

				float4	FogZ, V[4];
						FogZ.x = ReadDownsampledDepthMax( _TexDownsampledZBuffer, _In.UV ); V[0] = _tex2Dlod( _MainTex, _In.UV );	_In.UV.xy += _dUV.xz;
						FogZ.y = ReadDownsampledDepthMax( _TexDownsampledZBuffer, _In.UV ); V[1] = _tex2Dlod( _MainTex, _In.UV );	_In.UV.xy += _dUV.zy;
						FogZ.z = ReadDownsampledDepthMax( _TexDownsampledZBuffer, _In.UV ); V[3] = _tex2Dlod( _MainTex, _In.UV );	_In.UV.xy -= _dUV.xz;
						FogZ.w = ReadDownsampledDepthMax( _TexDownsampledZBuffer, _In.UV ); V[2] = _tex2Dlod( _MainTex, _In.UV );	_In.UV.xy -= _dUV.zy;

				// Compute bias weights toward each sample based on Z discrepancies
// 				float	ZFactor = _ZBufferDiscrepancyThreshold.y;
// 				float4	DeltaZ = ZFactor * abs(SceneZ - FogZ);
// 				float4	Weights = saturate( _ZBufferDiscrepancyThreshold.x / (1.0 + DeltaZ) );
				float4	Weights = 1.0 - saturate( _ZBufferDiscrepancyThreshold.x * ZErrorMetric( SceneZ.xxxx, FogZ ) );		// Latest version with new relative error metric

				// This vector gives the bias toward one of the UV corners. It lies in [-1,+1]
				// For equal weights, the bias sums to 0 so the UVs won't be influenced and normal bilinear filtering is applied
				// Otherwise, the UVs will tend more or less strongly toward one of the corners of the big pixel where values were sampled
				//
				// Explicit code would be :
				// float2	uv_bias  = Weights.x * float2( -1.0, -1.0 )		// Bias toward top-left
				// 					 + Weights.y * float2( +1.0, -1.0 )		// Bias toward top-right
				// 					 + Weights.z * float2( +1.0, +1.0 )		// Bias toward bottom-right
				// 					 + Weights.w * float2( -1.0, +1.0 );	// Bias toward bottom-left
				float2	uv_bias  = float2( Weights.y + Weights.z - Weights.x - Weights.w, Weights.z + Weights.w - Weights.x - Weights.y );

				// Now, we need to apply the actual UV bias.
				//
				// Explicit code would be :
				// 	uv.x = uv_bias.x < 0.0 ? lerp( uv.x, 0.0, -uv_bias.x ) : lerp( uv.x, 1.0, uv_bias.x );
				// 	uv.y = uv_bias.y < 0.0 ? lerp( uv.y, 0.0, -uv_bias.y ) : lerp( uv.y, 1.0, uv_bias.y );
				//
				// Unfortunately, using branching 1) is bad and 2) yields some infinite values for some obscure reason !
				// So we need to remove the branching.
				// The idea here is to perform biasing toward top-left & bottom-right independently then choose which bias direction
				//	is actually needed, based on the sign of the uv_bias vector
				//
				float2	uv_topleft = lerp( uv, 0.0, saturate(-uv_bias) );		// Bias toward top-left corner (works if uv_bias is negative)
				float2	uv_bottomright = lerp( uv, 1.0, saturate(uv_bias) );	// Bias toward bottom-right corner (works if uv_bias is positive)
				float2	ChooseDirection = saturate( 10000.0 * uv_bias );		// Isolate the sign of the uv_bias vector so negative gives 0 and positive gives 1
				uv = lerp( uv_topleft, uv_bottomright, ChooseDirection );		// Final bias will choose the appropriate direction based on the sign of the bias

				// Perform normal bilinear filtering with biased UV interpolants
				float4	FogColor = lerp( lerp( V[0], V[1], uv.x ), lerp( V[2], V[3], uv.x ), uv.y );

				// Final biasing based on average deltaZ
				float	Cutout = saturate( _ZBufferDiscrepancyThreshold.z * ZErrorMetric( SceneZ, 0.25 * (FogZ.x + FogZ.y + FogZ.z + FogZ.w) ) );
 				FogColor = lerp( FogColor, float4( 0, 0, 0, 1 ), Cutout );

				return FogColor;
			}
			ENDCG
		}

		//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		// Pass #10 Upsamples the rendering using the CUTOUT technique
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
			#include "../Header.cginc"
			#include "FogVolumeInc.cginc"

			uniform sampler2D	_MainTex;
			uniform float4		_dUV;		// 1/SourceSize
			uniform float4		_InvdUV;	// SouceSize

			float4	PS( PS_IN_AMBIENT_SUN _In ) : COLOR
			{
				float3	CameraPositionKm, View;
				float	Depth2Distance;
				ComputeCameraPositionViewKm( _In.UV.xy, CameraPositionKm, View, Depth2Distance );

				float	SceneZ = ReadDepth( _In.UV );

				// Compute scene distance
				float	PlanetHitDistanceKm = ComputeSphereEnterIntersection( CameraPositionKm, View, _PlanetCenterKm, _PlanetRadiusKm );
						PlanetHitDistanceKm = lerp( PlanetHitDistanceKm, INFINITY, saturate( -10000.0 * PlanetHitDistanceKm ) );	// If looking up, discard hit...
				float	ZBufferDistanceKm = SceneZ * Depth2Distance * _WorldUnit2Kilometer;	// Scene distance from the Z buffer
				float	SceneDistanceKm = lerp( ZBufferDistanceKm, PlanetHitDistanceKm, SaturateInfinity( SceneZ ) );	// Either planet hit or scene hit

				// Compute fog distance
				float	FogRadiusBottomKm = _PlanetRadiusKm + _FogAltitudeKm.x;
				float2	FogHitDistanceBottomKm = ComputeBothSphereIntersections( CameraPositionKm, View, _PlanetCenterKm, FogRadiusBottomKm );
				float	FogRadiusTopKm = _PlanetRadiusKm + _FogAltitudeKm.y;
				float2	FogHitDistanceTopKm = ComputeBothSphereIntersections( CameraPositionKm, View, _PlanetCenterKm, FogRadiusTopKm );

				// Order min/max
				float3	Center2Camera = CameraPositionKm - _PlanetCenterKm;
				float	CameraRadiusKm = length( Center2Camera );
						Center2Camera /= CameraRadiusKm;
				float2	FogHitDistancesKm;
				if ( CameraRadiusKm < FogRadiusBottomKm )
				{	// Below
					FogHitDistancesKm = float2( FogHitDistanceBottomKm.y, FogHitDistanceTopKm.y );	// View up
				}
				else if ( CameraRadiusKm > FogRadiusTopKm )
				{	// Above
					if ( FogHitDistanceBottomKm.x < HALF_INFINITY )
						FogHitDistancesKm = float2( FogHitDistanceTopKm.x, FogHitDistanceBottomKm.x );
					else
						FogHitDistancesKm = float2( 0.0, -1.0 );	// No hit
				}
				else
				{	// Inside
					if ( FogHitDistanceBottomKm.x < 0.0 )
						FogHitDistancesKm = float2( 0.0, FogHitDistanceTopKm.y );		// We hit top fog first
					else
						FogHitDistancesKm = float2( 0.0, FogHitDistanceBottomKm.x );	// We hit bottom fog first
				}

				FogHitDistancesKm.x = max( 0.0, FogHitDistancesKm.x );				// Don't start before camera position
				FogHitDistancesKm.y = min( SceneDistanceKm, FogHitDistancesKm.y );	// Don't end after scene position
  				if ( FogHitDistancesKm.x > FogHitDistancesKm.y )
  					return float4( 0.0, 0.0, 0.0, 1.0 );							// Above that layer or not looking at it ?

				return _tex2Dlod( _MainTex, _In.UV );
			}
			ENDCG
		}
	}
	Fallback off
}
