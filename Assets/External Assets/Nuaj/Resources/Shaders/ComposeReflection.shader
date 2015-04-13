// This shader initializes the camera rendering with sky reflection
//
Shader "Hidden/Nuaj/ComposeReflection"
{
	Properties
	{
		_MainTex( "Base (RGB)", 2D ) = "white" {}
		_TexScattering( "Base (RGB)", 2D ) = "Black" {}
	}

	SubShader
	{
		ZTest Off
		Cull Off
		ZWrite Off
		Fog { Mode off }
		AlphaTest Off
		Blend Off
		ColorMask RGBA

		Pass
		{
			CGPROGRAM
			#pragma target 3.0
			#pragma vertex VS
			#pragma fragment PS
			#pragma glsl
			#pragma only_renderers d3d9 d3d11 opengl

			#include "Header.cginc"
			#include "ToneMappingInc.cginc"

			#include "PlanetDataInc.cginc"
			#include "LightSupportInc.cginc"

			uniform float4x4	_Camera2World;
			uniform float4x4	_World2Camera;

 			uniform float4x4	_BelowCamera2World;		// Camera2World for camera below water
 			uniform float4		_BelowCameraData;		// Camera data for camera below water

			uniform float4x4	_Water2World;			// Water plane

			uniform float4		_BackgroundColorKey;

			uniform float		_DummyCloudHeightKm;	// Dummy cloud layer altitude

			float4	PS( PS_IN _In ) : COLOR
			{
				float4	ReflectedSceneColor = _tex2Dlod( _MainTex, _In.UV );
				float3	Distance2Key = ReflectedSceneColor.xyz - _BackgroundColorKey.xyz;
 				if ( dot( Distance2Key, Distance2Key ) > 1e-3 )
 					return ReflectedSceneColor;	// Opaque background takes over !

				// Build the view ray starting from the mirror camera (below the water plane)
				float3	Pos = _BelowCamera2World._m03_m13_m23;
				float3	View = normalize( mul( _BelowCamera2World, float4( _CameraData.xy * (2.0 * _In.UV.xy - 1.0), -1.0, 0.0 ) ).xyz );

				// Compute the ray intersection with the water plane
				float3	WaterPosition = _Water2World._m03_m13_m23;
				float3	WaterNormal = _Water2World._m01_m11_m21;
				float	HitDistance	= -dot( Pos - WaterPosition, WaterNormal ) / dot( View, WaterNormal );
				float3	WaterIntersection = Pos + HitDistance * View;

				// Build the ray from original camera to intersection point
				Pos = _Camera2World._m03_m13_m23;
				View = normalize( WaterIntersection - Pos );

				// Build the reflected the ray
				Pos = WaterIntersection;
				View = reflect( View, WaterNormal );

				// Compute the intersection with a dummy cloud at 2km high
				float3	Center = _Kilometer2WorldUnit * _PlanetCenterKm;
				float	Radius = _Kilometer2WorldUnit * (_PlanetRadiusKm + _DummyCloudHeightKm);

				float	CloudHitDistance = ComputeSphereExitIntersection( Pos, View, Center, Radius );
				float3	CloudHitPos = Pos + CloudHitDistance * View;

				// Compute the ray leading to this cloud position in camera space
				View = mul( _World2Camera, float4( CloudHitPos, 1.0 ) ).xyz;
				View /= -View.z;

				// Retrieve UVs
				float2	HitUV = 0.5 * (1.0 + View.xy / _CameraData.xy);

				// Make sure UVs stay in [0,1] by mirroring the coordinates when they exceed the range
				HitUV = fmod( 2.0 + HitUV, 2.0 );	// Now in [0,2[
 				HitUV = 1.0 - abs( 1.0 - HitUV );	// Now in [0,1], mirrored...

				// Sample atmosphere data
				float3	Scattering, Extinction;
				UnPack2Colors( _tex2Dlod( _TexScattering, float4( HitUV, 0.0, 0.0 ) ), Scattering, Extinction );

				return float4( Scattering, 0.0 );
			}
			ENDCG
		}
	}
	Fallback off
}
