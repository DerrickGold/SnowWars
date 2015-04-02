// This shader renders layers of dense and thick volumetric clouds
//
Shader "Hidden/Nuaj/Volume"
{
	Properties
	{
		_MainTex( "Base (RGB)", 2D ) = "white" {}
		_TexDownsampledZBuffer( "Base (RGB)", 2D ) = "black" {}
		_TexDeepShadowMap0( "Base (RGB)", 2D ) = "white" {}
		_TexDeepShadowMap1( "Base (RGB)", 2D ) = "white" {}
		_TexDeepShadowMap2( "Base (RGB)", 2D ) = "white" {}
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
		// Pass #0 computes the actual cloud lighting for a downsampled buffer
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
			#include "CloudVolumeInc.cginc"

			uniform float	_UseSceneZ;

			float4	PS( PS_IN_AMBIENT_SUN _In ) : COLOR		{ return ComputeCloudColor( _In, lerp( _CameraData.w, ReadDownsampledDepthMax( _TexDownsampledZBuffer, _In.UV ), _UseSceneZ ) ); }
			ENDCG
		}

		//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		// Pass #1 upsamples cloud rendering to actual screen resolution using ACCURATE technique
		// It's quite expensive since it involves recomputing the clouds for pixels with too much Z discrepancy
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
			#include "CloudVolumeInc.cginc"

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

				float4	TempUV = _In.UV - 0.5 * _dUV;
				float2	uv = frac( TempUV.xy * _InvdUV.xy );

				float	CloudZ0 = ReadDownsampledDepthMax( _TexDownsampledZBuffer, TempUV );	TempUV.xy += _dUV.xz;
				float	CloudZ1 = ReadDownsampledDepthMax( _TexDownsampledZBuffer, TempUV );	TempUV.xy += _dUV.zy;
				float	CloudZ3 = ReadDownsampledDepthMax( _TexDownsampledZBuffer, TempUV );	TempUV.xy -= _dUV.xz;
				float	CloudZ2 = ReadDownsampledDepthMax( _TexDownsampledZBuffer, TempUV );	TempUV.xy -= _dUV.zy;
				float	CloudZ = lerp( lerp( CloudZ0, CloudZ1, uv.x ), lerp( CloudZ2, CloudZ3, uv.x ), uv.y );

				float4	CloudColor = 0.0;
//				if ( abs(SceneZ - CloudZ) > _ZBufferDiscrepancyThreshold.x && CloudZ < 0.5 * _CameraData.w )
//				if ( abs(SceneZ - CloudZ) > _ZBufferDiscrepancyThreshold.x )
//				if ( CloudZ - SceneZ > _ZBufferDiscrepancyThreshold.x && !IsZInfinity( SceneZ ) )	// Working!
				if ( ZErrorMetric( SceneZ, CloudZ ) > 0.01 * _ZBufferDiscrepancyThreshold.x )		// Latest version with new relative error metric
				{	// Recompute accurate cloud
					CloudColor = lerp( ComputeCloudColor( _In, SceneZ ), float4( 0.0, 1.0, 0.0, 0.0 ), _ZBufferDiscrepancyThreshold.y );
				}
				else
				{	// Simply read back and bilerp
					float4	CloudColor0 = _tex2Dlod( _MainTex, TempUV );	TempUV.xy += _dUV.xz;
					float4	CloudColor1 = _tex2Dlod( _MainTex, TempUV );	TempUV.xy += _dUV.zy;
					float4	CloudColor3 = _tex2Dlod( _MainTex, TempUV );	TempUV.xy -= _dUV.xz;
					float4	CloudColor2 = _tex2Dlod( _MainTex, TempUV );	TempUV.xy -= _dUV.zy;
					CloudColor = lerp( lerp( CloudColor0, CloudColor1, uv.x ), lerp( CloudColor2, CloudColor3, uv.x ), uv.y );
				}

				return CloudColor;
			}
			ENDCG
		}

		//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		// Pass #2 upsamples cloud rendering to actual screen resolution using SMART technique
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
			#include "CloudVolumeInc.cginc"

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

				float4	CloudZ, V[4];
						CloudZ.x = ReadDownsampledDepthMax( _TexDownsampledZBuffer, _In.UV ); V[0] = _tex2Dlod( _MainTex, _In.UV );	_In.UV.xy += _dUV.xz;
						CloudZ.y = ReadDownsampledDepthMax( _TexDownsampledZBuffer, _In.UV ); V[1] = _tex2Dlod( _MainTex, _In.UV );	_In.UV.xy += _dUV.zy;
						CloudZ.z = ReadDownsampledDepthMax( _TexDownsampledZBuffer, _In.UV ); V[3] = _tex2Dlod( _MainTex, _In.UV );	_In.UV.xy -= _dUV.xz;
						CloudZ.w = ReadDownsampledDepthMax( _TexDownsampledZBuffer, _In.UV ); V[2] = _tex2Dlod( _MainTex, _In.UV );	_In.UV.xy -= _dUV.zy;

				// Compute bias weights toward each sample based on Z discrepancies
// 				float	ZFactor = _ZBufferDiscrepancyThreshold.y;
// 				float4	DeltaZ = ZFactor * abs(SceneZ - CloudZ);
// 				float4	Weights = saturate( _ZBufferDiscrepancyThreshold.x / (1.0 + DeltaZ) );
				float4	Weights = 1.0 - saturate( _ZBufferDiscrepancyThreshold.x * ZErrorMetric( SceneZ.xxxx, CloudZ ) );	// Latest version with new relative error metric

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
				// Unfortunately, using branching 1) is bad and 2) yields some infinite values for some obscure reason!
				// So we need to remove the branching.
				// The idea here is to perform biasing toward top-left & bottom-right independently then choose which bias direction
				//	is actually needed, based on the sign of the uv_bias vector
				//
				float2	uv_topleft = lerp( uv, 0.0, saturate(-uv_bias) );		// Bias toward top-left corner (works if uv_bias is negative)
				float2	uv_bottomright = lerp( uv, 1.0, saturate(uv_bias) );	// Bias toward bottom-right corner (works if uv_bias is positive)
				float2	ChooseDirection = saturate( 10000.0 * uv_bias );		// Isolate the sign of the uv_bias vector so negative gives 0 and positive gives 1
				uv = lerp( uv_topleft, uv_bottomright, ChooseDirection );		// Final bias will choose the appropriate direction based on the sign of the bias

				// Perform normal bilinear filtering with biased UV interpolants
				float4	CloudColor = lerp( lerp( V[0], V[1], uv.x ), lerp( V[2], V[3], uv.x ), uv.y );

				// Final biasing based on average deltaZ
				float	Cutout = saturate( _ZBufferDiscrepancyThreshold.z * ZErrorMetric( SceneZ, 0.25 * (CloudZ.x + CloudZ.y + CloudZ.z + CloudZ.w) ) );
 				CloudColor = lerp( CloudColor, float4( 0, 0, 0, 1 ), Cutout );

				return CloudColor;
			}
			ENDCG
		}

		//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		// Pass #3 upsamples cloud rendering to actual screen resolution using CUTOUT technique
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
			#include "CloudVolumeInc.cginc"

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
						PlanetHitDistanceKm = lerp( PlanetHitDistanceKm, INFINITY, saturate( -10000.0 * PlanetHitDistanceKm ) );	// If we're looking up, consider no hit instead...

				float	ZBufferDistanceKm = SceneZ * Depth2Distance * _WorldUnit2Kilometer;	// Scene distance from the Z buffer
				float	SceneDistanceKm = lerp( ZBufferDistanceKm, PlanetHitDistanceKm, SaturateInfinity( SceneZ ) );	// Either planet hit or scene hit

				// Compute cloud distance
				float	CloudRadiusBottomKm = _PlanetRadiusKm + _CloudAltitudeKm.x;
				float2	CloudHitDistanceBottomKm = ComputeBothSphereIntersections( CameraPositionKm, View, _PlanetCenterKm, CloudRadiusBottomKm );
				float	CloudRadiusTopKm = _PlanetRadiusKm + _CloudAltitudeKm.y;
				float2	CloudHitDistanceTopKm = ComputeBothSphereIntersections( CameraPositionKm, View, _PlanetCenterKm, CloudRadiusTopKm );

				// Order min/max
				float3	Center2Camera = CameraPositionKm - _PlanetCenterKm;
				float	CameraRadiusKm = length( Center2Camera );
						Center2Camera /= CameraRadiusKm;
				float2	CloudHitDistancesKm;
				if ( CameraRadiusKm < CloudRadiusBottomKm )
				{	// Below
					CloudHitDistancesKm = float2( CloudHitDistanceBottomKm.y, CloudHitDistanceTopKm.y );	// View up
				}
				else if ( CameraRadiusKm > CloudRadiusTopKm )
				{	// Above
					if ( CloudHitDistanceBottomKm.x < HALF_INFINITY )
						CloudHitDistancesKm = float2( CloudHitDistanceTopKm.x, CloudHitDistanceBottomKm.x );
					else
						CloudHitDistancesKm = float2( 0.0, -1.0 );	// No hit
				}
				else
				{	// Inside
					if ( CloudHitDistanceBottomKm.x < 0.0 )
						CloudHitDistancesKm = float2( 0.0, CloudHitDistanceTopKm.y );		// We hit top cloud first
					else
						CloudHitDistancesKm = float2( 0.0, CloudHitDistanceBottomKm.x );	// We hit bottom cloud first
				}

				CloudHitDistancesKm.x = max( 0.0, CloudHitDistancesKm.x );				// Don't start before camera position
				CloudHitDistancesKm.y = min( SceneDistanceKm, CloudHitDistancesKm.y );	// Don't end after scene position
 				if ( CloudHitDistancesKm.x > CloudHitDistancesKm.y )
 					return float4( 0.0, 0.0, 0.0, 1.0 );								// Above that layer or not looking at it?

				return _tex2Dlod( _MainTex, _In.UV );
			}
			ENDCG
		}
	}
	Fallback off
}
