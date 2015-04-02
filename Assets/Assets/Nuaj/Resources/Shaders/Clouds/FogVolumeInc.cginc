// Main computation routines for volume fog
//
#ifndef VOLUME_FOG_SUPPORT_INCLUDED
#define VOLUME_FOG_SUPPORT_INCLUDED

#include "../PlanetDataInc.cginc"
#include "../LightSupportInc.cginc"
#include "../ShadowMapInc.cginc"
#include "../LocalVariationsInc.cginc"
#include "../Sky/AerialPerspectiveComplexInc.cginc"
#include "Noise3DSupportInc.cginc"

#define USE_GOD_RAYS

uniform float2		_RenderTargetInvSize;
uniform float		_StepsCount;
uniform float		_MaxStepSizeKm;

// Fog parameters
uniform float4		_FogAltitudeKm;				// X=Low Altitude Y=Top Altitude Z=Thickness W=1/Thickness
uniform float		_FogLayerIndex;

// Density map parameters
uniform float4		_DensityOffset;
uniform float4		_DensityFactor;
uniform float4x4	_Density2World;
uniform float4x4	_World2Density;
uniform sampler2D	_TexLayeredDensity;

// Noise parameters
uniform float2		_NoiseTiling;
uniform float		_NoiseAmplitude;
uniform float		_NoiseOffset;
uniform float3		_NoisePosition;
uniform float		_FogTraceLimiter;
uniform float2		_FogPosition;

// Lighting parameters
uniform float3		_FogColor;
uniform float		_MieDensityFactor;
uniform float		_DensityRatioBottom;
uniform float		_FogMaxDistance;
uniform float		_IsotropicSkyFactor;


// ===================================================================================
// Special vertex shader that computes the ambient Sky and Sun color arriving at fog

struct	PS_IN_AMBIENT_SUN
{
	float4	Position			: POSITION;
	float4	UV					: TEXCOORD0;
};

PS_IN_AMBIENT_SUN VS_WITH_AMBIENT( appdata_img _In )
{
	PS_IN_AMBIENT_SUN	Out;
						Out.Position = mul( UNITY_MATRIX_MVP, _In.vertex );
						Out.UV = float4( MultiplyUV( UNITY_MATRIX_TEXTURE0, _In.texcoord ).xy, 0, 0 );
	return Out;
}

// ===================================================================================
// Fog Noise & Density Computation

// Transforms a world position in kilometers into a UV set that can be directly used to sample the density texture
float4	World2DensityUV( float3 _WorldPositionKm )
{
	return float4( 0.5 * (1.0 + mul( _World2Density, float4( _Kilometer2WorldUnit * _WorldPositionKm, 1.0 ) ).xz), 0.0, 0.0 );
}

// Transforms an UV set from density texture space into a world position in kilometers
float3	DensityUV2World( float4 _UV )
{
	_UV.xy = 2.0 * _UV.xy - 1.0;
	return _WorldUnit2Kilometer * mul( _Density2World, float4( _UV.x, 0.0, _UV.y, 1.0 ) ).xyz;
}

float3	World2NoiseUVW( float3 _WorldPositionKm, out float _HeightInFogKm )
{
	float	FogRadiusKm = _PlanetRadiusKm + _FogAltitudeKm.x;
	_HeightInFogKm = length( _WorldPositionKm - _PlanetCenterKm ) - FogRadiusKm;	// Vertical position in [0,_FogThicknessKm]

	return _WorldPositionKm.xzy * _NoiseTiling.xxy + _NoisePosition;
}

// Bevels the density at the top of the fog
float	Bevel( float _HeightInFogKm )
{
	float	t = saturate( _HeightInFogKm * _FogAltitudeKm.w );
	t = t * t;	// ^2
	t = t * t;	// ^4
	t = t * t;	// ^8
	t = t * t;	// ^16

	return 1.0 - t;
}

// Computes the fog density at current position and the optical depth the Sun has to traverse to reach the position
float2	ComputeFogDensity( float3 _WorldPositionKm, out float _HeightInFogKm )
{
	float3	NoiseUVW = World2NoiseUVW( _WorldPositionKm, _HeightInFogKm );
	float	Noise = _NoiseAmplitude * (_NoiseOffset + 2.0 * (SampleNoiseTexture( NoiseUVW, 0.0 ) - 0.5));

	float4	DensityRGBA = _DensityFactor * (_DensityOffset + _tex2Dlod( _TexLayeredDensity, World2DensityUV( _WorldPositionKm ) ));
	DensityRGBA *= Bevel( _HeightInFogKm );

	// Compute single density
	float	NormalizedHeight = 3.0 * saturate( _HeightInFogKm * _FogAltitudeKm.w );	// bottom=0 top=4
	float2	Above = step( float2( 1.0, 2.0 ), NormalizedHeight.xx );
	float3	IsSlice = float3( 1.0 - Above.x, Above.x * (1.0 - Above.y), Above.y );
	float	DensitySlice = dot( IsSlice, lerp( DensityRGBA.xyz, DensityRGBA.yzw, NormalizedHeight.xxx - float3( 0.0, 1.0, 2.0 ) ) );

	float	Density = max( 0.0, Noise + DensitySlice );

	// Compute optical depth
	float	TopHitDistanceKm = (_FogAltitudeKm.z - _HeightInFogKm) / max( 0.01, dot( _SunDirection, _PlanetNormal ) );	// Approximate distance at which the Sun ray hits the top of the fog layer (assuming a plane layer in that case)

	float3	t = saturate( float3( 1.0, 2.0, 3.0 ) - NormalizedHeight.xxx );
	float3	D = 0.5 * (DensityRGBA.xyz - DensityRGBA.yzw);

	float3	OffsetDensity = DensityRGBA.yzw + D * t;
	float	SumDensity = dot( t, OffsetDensity );

	float	OpticalDepth = SumDensity * TopHitDistanceKm;

	float	Factor = _MieDensityFactor * lerp( _DensityRatioBottom, 1.0, 0.3333 * NormalizedHeight );
	return Factor * float2( Density, OpticalDepth );
}

float3	ComputeStepScattering( float3 _WorldPositionKm, float3 _View, float _StepSizeKm, float3 _SunLight, float3 _SkyAmbientTop, float3 _SkyAmbientBottom, float _HeightKm, float _Phase )
{
	// =============================================
	// Invent a scattered light based on traversed cloud depth
	float	Sigma_isotropic_top = 0.6 * _Sigma_Mie;
	float	IsotropicSphereRadiusTopKm = _FogAltitudeKm.z - _HeightKm;
 	float3	IsotropicScatteringTop = Sigma_isotropic_top * _SkyAmbientTop * exp( -Sigma_isotropic_top * IsotropicSphereRadiusTopKm );
 	float3	IsotropicScattering = _IsotropicSkyFactor * IsotropicScatteringTop;

	// =============================================
	// Compute in-scattered direct light
//	float3	Density_Mie = _MieDensityFactor * _DensitySeaLevel_Mie;
//	return Density_Mie * (_Phase * _SunLight + 1000.0 * ComputeLightningColor( _WorldPositionKm, _View, _MiePhaseAnisotropy )) + IsotropicScattering;

	float3	Density_Mie = 12.566370614359172953850573533118 * _MieDensityFactor * _DensitySeaLevel_Mie;	// 4PI * MieDensity@SeaLevel
	return Density_Mie * (_Phase * _SunLight + ComputeLightningColor( _WorldPositionKm, _View, _MiePhaseAnisotropy )) + IsotropicScattering;
}

// ===================================================================================
float4	ComputeFogLighting( float3 _CameraPositionKm, float3 _View, float2 _HitDistancesKm, float2 _EarthShadowDistancesKm, float3 _SkyAmbientTop, float3 _SkyAmbientBottom, float3 _SunColor, float _StepsCount )
{
	// STOOPID ATI FIX!
	if ( _StepsCount < 1 )
		_StepsCount = 1;
	// STOOPID ATI FIX!


	float	CosTheta = dot( _View, _SunDirection );
	float	Phase = INV_4PI * ComputeMiePhase( CosTheta, _MiePhaseAnisotropy );

	float	DeltaDistanceKm = _HitDistancesKm.y - _HitDistancesKm.x;
	float	StepSizeKm = DeltaDistanceKm / _StepsCount;
			StepSizeKm = min( _MaxStepSizeKm, StepSizeKm );	// Don't use steps longer than this...

	float3	StepKm = StepSizeKm * _View;
	float	DistanceKm = _HitDistancesKm.x + 0.5 * StepSizeKm;
	float3	WorldPositionKm = _CameraPositionKm + DistanceKm * _View;

	float3	Sigma_Mie = _Sigma_Mie;

	// Sample sun extinction at the middle of the path
#ifndef USE_GOD_RAYS
	_SunColor *= GetShadowAtPosition( _CameraPositionKm + min( 2.0, 0.5 * DeltaDistanceKm ) * _View, _PlanetRadiusKm + _FogAltitudeKm.x );
#endif

	float	AverageDensity = 0.0;
	float3	Extinction = 1.0;
	float3	Scattering = 0.0;
	for ( int StepIndex=0; StepIndex < _StepsCount; StepIndex++ )
	{
		// Compute fog density at position
		float	HeightInFogKm;
		float2	Density = ComputeFogDensity( WorldPositionKm, HeightInFogKm );

		// =============================================
		// Retrieve sun light attenuated when passing through the atmosphere
		float3	SunExtinction = exp( -Sigma_Mie * Density.y );
		float	EarthShadow = IsInShadow( DistanceKm, DistanceKm + StepSizeKm, _EarthShadowDistancesKm );
		float3	Light = SunExtinction * EarthShadow * _SunColor;

#ifdef USE_GOD_RAYS
		Light *= GetShadowAtAltitude( WorldPosition2Shadow( WorldPositionKm ), _FogAltitudeKm.x + HeightInFogKm );
#endif

		// =============================================
		// Accumulate in-scattered light with extinction along the ray
		float3	StepScattering = Density.x * ComputeStepScattering( WorldPositionKm, _View, StepSizeKm, Light, _SkyAmbientTop, _SkyAmbientBottom, HeightInFogKm, Phase );
		Scattering += StepScattering * StepSizeKm * Extinction;

		// =============================================
		// Accumulate extinction along view
		Extinction *= exp( -Sigma_Mie * Density.x * StepSizeKm );

		// March
		WorldPositionKm += StepKm;
		DistanceKm += StepSizeKm;
		AverageDensity += Density.x;
	}

	// Extrapolate extinction for the remainder of the trace
	float	RemainingDistanceKm = min( _FogMaxDistance, _HitDistancesKm.y - DistanceKm );
//	Extinction = pow( Extinction, RemainingDistanceKm / (_StepsCount * StepSizeKm) );	// Continued progression

	AverageDensity /= _StepsCount;														// Average density per step
	Extinction *= exp( -_Sigma_Mie * AverageDensity * RemainingDistanceKm );			// Extrapolated density

	return float4( _FogColor * Scattering, dot(Extinction,LUMINANCE) );
}

// Directly called by the PS for shadow computation
float4	ComputeFogShadow( PS_IN _In )
{
	float3	CloudPositionKm = Shadow2CloudPosition( _In.UV.xy, _PlanetRadiusKm + _FogAltitudeKm.x );	// At the base of the fog
	
	float	HeightInFogKm;
	float	OpticalDepth = ComputeFogDensity( CloudPositionKm, HeightInFogKm ).y;

	return exp( -_Sigma_Mie * OpticalDepth );
}

// Directly called by the PS for fog computation
float4	ComputeFogColor( PS_IN_AMBIENT_SUN _In, float Z )
{
	// Sample Sun & Sky colors
	float3	SkyAmbientTop, SkyAmbientBottom;
	ComputeShadowedAmbientTerm( SkyAmbientTop, SkyAmbientBottom );
	float3	SunColor = ComputeSunExtinction( _PlanetRadiusKm + _FogAltitudeKm.y );	// Get sun color at the top of the fog

	// Build position/view
	float3	CameraPositionKm, View;
	float	Depth2Distance;
	ComputeCameraPositionViewKm( _In.UV.xy, CameraPositionKm, View, Depth2Distance );

	// Compute scene distance
	float	PlanetHitDistanceKm = ComputeSphereEnterIntersection( CameraPositionKm, View, _PlanetCenterKm, _PlanetRadiusKm + _PlanetRadiusOffsetKm );
			PlanetHitDistanceKm = lerp( PlanetHitDistanceKm, INFINITY, saturate( -10000.0 * PlanetHitDistanceKm ) );	// If looking up, discard hit...
	float	ZBufferDistanceKm = Z * Depth2Distance * _WorldUnit2Kilometer;	// Scene distance from the Z buffer
	float	SceneDistanceKm = lerp( ZBufferDistanceKm, PlanetHitDistanceKm, StepInfinity( Z ) );	// Either planet hit or scene hit

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

	FogHitDistancesKm.x = max( 0.0, FogHitDistancesKm.x );					// Don't start before camera position
	FogHitDistancesKm.y = min( SceneDistanceKm, FogHitDistancesKm.y );		// Don't end after scene position
	FogHitDistancesKm.y = min( _FogMaxDistance, FogHitDistancesKm.y );
 	if ( FogHitDistancesKm.x >= FogHitDistancesKm.y )
 		return float4( 0.0, 0.0, 0.0, 1.0 );								// Above that layer or not looking at it?

	// Compute potential intersection with earth's shadow
	float2	EarthShadowDistancesKm = ComputePlanetShadow( CameraPositionKm, View, _SunDirection );

	// Render the fog
	return ComputeFogLighting( CameraPositionKm, View, FogHitDistancesKm, EarthShadowDistancesKm, SkyAmbientTop, SkyAmbientBottom, SunColor, _StepsCount );
}

#endif

