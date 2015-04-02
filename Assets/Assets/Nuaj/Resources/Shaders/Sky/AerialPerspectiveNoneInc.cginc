// Main computation routine for empty sky color model
//
#ifndef AERIAL_PERSPECTIVE_NONE_SUPPORT_INCLUDED
#define AERIAL_PERSPECTIVE_NONE_SUPPORT_INCLUDED

#include "../PlanetDataInc.cginc"
#include "../LightSupportInc.cginc"
#include "../ShadowMapInc.cginc"

uniform sampler2D	_TexCloudLayer0;
uniform sampler2D	_TexCloudLayer1;
uniform sampler2D	_TexCloudLayer2;
uniform sampler2D	_TexCloudLayer3;
uniform sampler2D	_TexBackground;

uniform float		_LuminanceScale;						// This is the luminance to scale by when storing environment colors since we pack the luminance in alpha and that luminance needs to be in [0,1] for readback

// Layers ordering data
uniform float4		_CaseSwizzle;							// Helps determining which layer's intersection will be used to determine the up/down view case
uniform float4		_SwizzleExitUp0;						// Helps determining what the first crossed layer will be viewing up
uniform float4		_SwizzleExitUp1;						// Helps determining what the second crossed layer will be viewing up
uniform float4		_SwizzleExitUp2;						// Helps determining what the third crossed layer will be viewing up
uniform float4		_SwizzleExitUp3;						// Helps determining what the last crossed layer will be viewing up
uniform float4		_SwizzleEnterDown0;						// Helps determining what the first crossed layer will be viewing down
uniform float4		_SwizzleEnterDown1;						// Helps determining what the second crossed layer will be viewing down
uniform float4		_SwizzleEnterDown2;						// Helps determining what the third crossed layer will be viewing down
uniform float4		_SwizzleEnterDown3;						// Helps determining what the last crossed layer will be viewing down

// =============================================================================================================================================

////////////////////////////////////////////////////////////////////////////////////
// The routine that should be called by the PS to render the sky's environment
half4	RenderSkyEnvironment( PS_IN _In )
{
	float3	CameraPositionKm, View;
	ComputeEnvironmentPositionViewSky( _In.UV.xy, CameraPositionKm, View );

#ifdef RENDER_SUN
	View = _SunDirection;
#endif

	// Compose clouds
#if CLOUD_LAYERS > 0
	float4	CloudColor0 = _tex2Dlod( _TexCloudLayer0, _In.UV );
	float4	CloudColor1 = _tex2Dlod( _TexCloudLayer1, _In.UV );
	float4	CloudColor2 = _tex2Dlod( _TexCloudLayer2, _In.UV );
	float4	CloudColor3 = _tex2Dlod( _TexCloudLayer3, _In.UV );
	float4	CloudColor = CloudColor0 + CloudColor0.w * (CloudColor1 + CloudColor1.w * (CloudColor2 + CloudColor2.w * CloudColor3));
			CloudColor.w = CloudColor0.w * CloudColor1.w * CloudColor2.w * CloudColor3.w;
#else
	float4	CloudColor = float4( 0, 0, 0, 1 );
#endif

#ifdef RENDER_SUN
	float3	FinalColor = _SunColor * CloudColor.w;
#else
	// Compute background
	float3	BackgroundColor = _tex2Dlod( _TexBackground, _In.UV ).xyz;
	float3	FinalColor = BackgroundColor * CloudColor.w + CloudColor.xyz;
#endif

	// Check if we need luminance packing
	if ( _LuminanceScale < 1e-3 )
		return float4( FinalColor, 1.0 );

	// "Normalize" resulting color & store normalized luminance in alpha
	float	MaxRGB = max( max( FinalColor.x, FinalColor.y ), FinalColor.z );
	return float4( FinalColor / MaxRGB, MaxRGB * _LuminanceScale );
}

////////////////////////////////////////////////////////////////////////////////////
// The routine that should be called by the PS to compose the sky with clouds
// It supports from 0 to 4 active cloud layers, you have to declare the proper DEFINES for each case
half4	ComposeSkyAndClouds( PS_IN _In )
{
	// Retrieve camera infos
	float3	CameraPositionKm, View;
	float	Depth2Distance;
	ComputeCameraPositionViewKm( _In.UV.xy, CameraPositionKm, View, Depth2Distance );

	//////////////////////////////////////////////////////////////////////////
	// Read the cloud layers
	float4	SliceHitDistancesEnterKm = float4(
		ComputeSphereEnterIntersection( CameraPositionKm, View, _PlanetCenterKm, _PlanetRadiusKm + _ShadowAltitudesMaxKm.x ),
		ComputeSphereEnterIntersection( CameraPositionKm, View, _PlanetCenterKm, _PlanetRadiusKm + _ShadowAltitudesMaxKm.y ),
		ComputeSphereEnterIntersection( CameraPositionKm, View, _PlanetCenterKm, _PlanetRadiusKm + _ShadowAltitudesMaxKm.z ),
		ComputeSphereEnterIntersection( CameraPositionKm, View, _PlanetCenterKm, _PlanetRadiusKm + _ShadowAltitudesMaxKm.w ) );

	float4	SliceHitDistancesExitKm = float4(
		ComputeSphereExitIntersection( CameraPositionKm, View, _PlanetCenterKm, _PlanetRadiusKm + _ShadowAltitudesMinKm.x ),
		ComputeSphereExitIntersection( CameraPositionKm, View, _PlanetCenterKm, _PlanetRadiusKm + _ShadowAltitudesMinKm.y ),
		ComputeSphereExitIntersection( CameraPositionKm, View, _PlanetCenterKm, _PlanetRadiusKm + _ShadowAltitudesMinKm.z ),
		ComputeSphereExitIntersection( CameraPositionKm, View, _PlanetCenterKm, _PlanetRadiusKm + _ShadowAltitudesMinKm.w ) );

	float4	CloudColorR = 0.0;
	float4	CloudColorG = 0.0;
	float4	CloudColorB = 0.0;
	float4	CloudColorA = 1.0;
#if CLOUD_LAYERS > 0
//	if ( SliceHitDistancesEnterKm.x < HALF_INFINITY )
	{
		float4	LayerColor = _tex2Dlod( _TexCloudLayer0, _In.UV );
		CloudColorR.x = LayerColor.x;
		CloudColorG.x = LayerColor.y;
		CloudColorB.x = LayerColor.z;
		CloudColorA.x = LayerColor.w;
	}
#endif
#if CLOUD_LAYERS > 1
//	if ( SliceHitDistancesEnterKm.y < HALF_INFINITY )
	{
		float4	LayerColor = _tex2Dlod( _TexCloudLayer1, _In.UV );
		CloudColorR.y = LayerColor.x;
		CloudColorG.y = LayerColor.y;
		CloudColorB.y = LayerColor.z;
		CloudColorA.y = LayerColor.w;
	}
#endif
#if CLOUD_LAYERS > 2
//	if ( SliceHitDistancesEnterKm.z < HALF_INFINITY )
	{
		float4	LayerColor = _tex2Dlod( _TexCloudLayer2, _In.UV );
		CloudColorR.z = LayerColor.x;
		CloudColorG.z = LayerColor.y;
		CloudColorB.z = LayerColor.z;
		CloudColorA.z = LayerColor.w;
	}
#endif
#if CLOUD_LAYERS > 3
//	if ( SliceHitDistancesEnterKm.w < HALF_INFINITY )
	{
		float4	LayerColor = _tex2Dlod( _TexCloudLayer3, _In.UV );
		CloudColorR.w = LayerColor.x;
		CloudColorG.w = LayerColor.y;
		CloudColorB.w = LayerColor.z;
		CloudColorA.w = LayerColor.w;
	}
#endif

	float	CaseChoice = step( dot( SliceHitDistancesExitKm, _CaseSwizzle ), 0.0 );	// 1 if viewing "up", 0 if viewing "down"

	float4	Swizzle0 = lerp( _SwizzleEnterDown0, _SwizzleExitUp0, CaseChoice );
	float4	Swizzle1 = lerp( _SwizzleEnterDown1, _SwizzleExitUp1, CaseChoice );
	float4	Swizzle2 = lerp( _SwizzleEnterDown2, _SwizzleExitUp2, CaseChoice );
	float4	Swizzle3 = lerp( _SwizzleEnterDown3, _SwizzleExitUp3, CaseChoice );

	// Re-order cloud colors
	float4	CloudExtinctions = float4(
			dot( CloudColorA, Swizzle0 ),
			dot( CloudColorA, Swizzle1 ),
			dot( CloudColorA, Swizzle2 ),
			dot( CloudColorA, Swizzle3 ) );

	// Patch invalid extinctions
	// This will place 1 if an extinction swizzle is invalid (i.e. swizzle = 0)
	float4	InvalidExtinctions = float4( dot( Swizzle0, Swizzle0 ), dot( Swizzle1, Swizzle1 ), dot( Swizzle2, Swizzle2 ), dot( Swizzle3, Swizzle3 ) );
	CloudExtinctions = lerp( 1.0.xxxx, CloudExtinctions, InvalidExtinctions );

	float3	CloudColor0 = float3( dot( CloudColorR, Swizzle0 ), dot( CloudColorG, Swizzle0 ), dot( CloudColorB, Swizzle0 ) );
	float3	CloudColor1 = float3( dot( CloudColorR, Swizzle1 ), dot( CloudColorG, Swizzle1 ), dot( CloudColorB, Swizzle1 ) );
	float3	CloudColor2 = float3( dot( CloudColorR, Swizzle2 ), dot( CloudColorG, Swizzle2 ), dot( CloudColorB, Swizzle2 ) );
	float3	CloudColor3 = float3( dot( CloudColorR, Swizzle3 ), dot( CloudColorG, Swizzle3 ), dot( CloudColorB, Swizzle3 ) );

	float4	CloudColor;
	CloudColor.xyz = CloudColor0 + CloudExtinctions.x * (CloudColor1 + CloudExtinctions.y * (CloudColor2 + CloudExtinctions.z * CloudColor3));
	CloudColor.w = CloudExtinctions.x * CloudExtinctions.y * CloudExtinctions.z * CloudExtinctions.w;

	//////////////////////////////////////////////////////////////////////////
	// Compute background color
	float	SceneZ = ReadDepth( _In.UV );
	float3	BackgroundColor = IsZInfinity( SceneZ ) ? _tex2Dlod( _TexBackground, _In.UV ).xyz : 0.0.xxx;	// MARCHE PAS SUR MAC ! => faire un _tex2Dlod inconditionnel

	//////////////////////////////////////////////////////////////////////////
	// Compose
	return Pack2Colors( BackgroundColor * CloudColor.w + CloudColor.xyz, CloudColor.www );
}

#endif

