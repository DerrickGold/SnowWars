// Main computation routine for simple sky color model
//
#ifndef AERIAL_PERSPECTIVE_SIMPLE_SUPPORT_INCLUDED
#define AERIAL_PERSPECTIVE_SIMPLE_SUPPORT_INCLUDED

#include "../PlanetDataInc.cginc"
#include "../LightSupportInc.cginc"
#include "../ShadowMapInc.cginc"

static const float	H0_AIR = 7.994;						// Altitude scale factor for air molecules
static const float	H0_AEROSOLS = 1.200;				// Altitude scale factor for aerosols

static const float	SCALE_RAYLEIGH = 0.1;				// Rayleigh & Mie coefficients need to be scaled to look more like the complex model
static const float	SCALE_MIE = 0.25;

uniform float3		_Sigma_Rayleigh;					// 4.0 * PI * _DensitySeaLevel_Rayleigh / WAVELENGTHS_POW4;
uniform float		_Sigma_Mie;							// 4.0 * PI * _DensitySeaLevel_Mie;
uniform float		_MiePhaseAnisotropy;				// Phase anisotropy factor in [-1,+1]
uniform sampler2D	_TexDensity;
uniform sampler2D	_TexCloudLayer0;
uniform sampler2D	_TexCloudLayer1;
uniform sampler2D	_TexCloudLayer2;
uniform sampler2D	_TexCloudLayer3;
uniform sampler2D	_TexBackground;

uniform sampler2D	_TexDownsampledZBuffer;

uniform float		_LuminanceScale;					// This is the luminance to scale by when storing environment colors since we pack the luminance in alpha and that luminance needs to be in [0,1] for readback

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

// Computes the optical depth along the ray
//	_RadiusKm, the radius of the sphere to which to project the position to (including the Earth radius)
// Returns :
//	X,Y = rho( h(_ViewPosition) ), the density of air molecules (i.e. Rayleigh) and aerosols (i.e. Mie) respectively, at view position's altitude
//	Z,W = rho(s,s') = Integral[s,s']( rho(h(l)) dl ), the optical depth of air moleculs and aerosols respectively, from view position's altitude to the upper atmosphere
//
float4	ComputeOpticalDepth( float _RadiusKm, float3 _ViewDirection )
{
	// Normalize altitude
	float	Altitude = (_RadiusKm - _PlanetRadiusKm) / (_PlanetAtmosphereRadiusKm - _PlanetRadiusKm);

	// Actual view direction
	float	CosTheta = dot( _ViewDirection, _PlanetNormal );

	float4	UV = float4( 0.5 * (1.0 - CosTheta), Altitude, 0.0, 0.0 );
	float4	OpticalDepth = _tex2Dlod( _TexDensity, UV );

	return OpticalDepth;
}

// Analytically computes the density of air molecules and aerosols at view position's altitude
// (remarks: this method does NOT tap into the density texture)
// Returns :
//  X,Y = rho(h(_RadiusKm)), the density of air molecules (i.e. Rayleigh) and aerosols (i.e. Mie) respectively, at specified radius
//
float2	ComputeAirDensity( float _RadiusKm )
{
	float	Altitude = _RadiusKm - _PlanetRadiusKm;
	return exp( -float2( Altitude / H0_AIR, Altitude / H0_AEROSOLS ) );
}

// This computes the Sun's extinction through the atmosphere at the given altitude
//	_RadiusKm, the altitude in kilometers that needs to be lit by the Sun (including the Earth's radius)
float3	ComputeSunExtinction( float _RadiusKm )
{
	float4	OpticalDepth = ComputeOpticalDepth( _RadiusKm, _SunDirection );
	float3	SunExtinction = exp( -_Sigma_Rayleigh * OpticalDepth.z - _Sigma_Mie * OpticalDepth.w );
	return _SunColor * SunExtinction;
}

// Computes Rayleigh and Mie phase functions
float2	ComputeSkyPhases( float3 _View, float3 _SunDirection )
{
	float	CosTheta = dot( _View, _SunDirection );
	float	PhaseRayleigh = 0.75 * (1.0 + CosTheta*CosTheta);
// 	float	OnePlusG = 1.0 + _MiePhaseAnisotropy;
// 	float	PhaseMie = OnePlusG * OnePlusG / pow( 1.0 + _MiePhaseAnisotropy*_MiePhaseAnisotropy + 2.0 * _MiePhaseAnisotropy * CosTheta, 1.5 );
	float	PhaseMie = ComputeMiePhase( CosTheta, _MiePhaseAnisotropy );

	return INV_4PI * float2( PhaseRayleigh, PhaseMie );
}

// Computes simple sky extinction by interpolating Rayleigh & Mie densities along a single large slice of air
//	_RadiusKm, the radii at which the ray starts and ends
//	_DistanceKm, the length of the slice to compute extinction for
float3	ComputeSkyExtinctionSimple( float2 _RadiusKm, float _DistanceKm )
{
	float2	AirDensityStart = ComputeAirDensity( _RadiusKm.x );
	float2	AirDensityEnd = ComputeAirDensity( _RadiusKm.y );
	float2	AverageDensity = 0.5 * (AirDensityStart + AirDensityEnd);

AverageDensity.x *= 0.25;	// Artificially decrease air density to avoid a too redish tint at horizon

	return exp( -(_Sigma_Rayleigh * AverageDensity.x + _Sigma_Mie * AverageDensity.y) * _DistanceKm );
}

// Samples a cloud layer's extinction that will attenuate the sky's scattering
float	SampleCloudLayerExtinction( sampler2D _TexCloudLayer, float4 _UV )
{
	// Sample next cloud layer (the one closer to camera that will attenuate what we're about to compute)
	return _tex2Dlod( _TexCloudLayer, _UV ).w;
}

// Perform simple sky color computation
void	ComputeSkyColor( float3 _PositionKm, float3 _View, float2 _DistancesKm, float2 _EarthShadowDistancesKm, float2 _Phases, float3 _SliceSigmaRayleigh, float _SliceSigmaMie, float3 _SunColor0, float3 _SunColor1, out float3 _Scattering, inout float3 _Extinction )
{
	float	LengthMeters = abs( _DistancesKm.y - _DistancesKm.x );
	float3	ExtinctionCoeff = _SliceSigmaRayleigh + _SliceSigmaMie;
	float3	InvExtinctionCoeff = 1.0 / ExtinctionCoeff;

	float3	SliceExtinction = exp( -ExtinctionCoeff * LengthMeters );
	_Extinction *= SliceExtinction;

 	float3	ScatteringFactor = (_SliceSigmaRayleigh * _Phases.x + _SliceSigmaMie * _Phases.y) * InvExtinctionCoeff;
//	_Scattering = ScatteringFactor * (1.0.xxx - SliceExtinction) * _SunColor0;
//	_Scattering = ScatteringFactor * ((1.0 - SliceExtinction) * _SunColor0 + (_SunColor1 - _SunColor0) * InvExtinctionCoeff * (1.0 - SliceExtinction * ((_SliceSigmaRayleigh + _SliceSigmaMie) * LengthMeters + 1.0)));

	float3	DeltaSunColor = (_SunColor1 - _SunColor0) / LengthMeters;
	float	EarthShadow = IsInShadow( _DistancesKm.x, _DistancesKm.y, _EarthShadowDistancesKm );
	_Scattering = EarthShadow * ScatteringFactor * InvExtinctionCoeff * ((ExtinctionCoeff * _SunColor0 + DeltaSunColor) - SliceExtinction * (ExtinctionCoeff * _SunColor1 + DeltaSunColor));
}

void	RenderSky( float3 _CameraPosKm, float3 _View, float2 _NearFarKm, float4 _UV, out float3 _Scattering, out float3 _Extinction )
{
	// Compute potential intersection with earth's shadow
	float2	EarthShadowDistancesKm = ComputePlanetShadow( _CameraPosKm, _View, _SunDirection );

	////////////////////////////////////////////////////////////////////////////////
	// Compute hit distance for each slice
	float2	SliceHitDistancesKm[4] =
	{
		ComputeBothSphereIntersections( _CameraPosKm, _View, _PlanetCenterKm, _PlanetRadiusKm + _ShadowAltitudesMaxKm.x ),
		ComputeBothSphereIntersections( _CameraPosKm, _View, _PlanetCenterKm, _PlanetRadiusKm + _ShadowAltitudesMaxKm.y ),
		ComputeBothSphereIntersections( _CameraPosKm, _View, _PlanetCenterKm, _PlanetRadiusKm + _ShadowAltitudesMaxKm.z ),
		ComputeBothSphereIntersections( _CameraPosKm, _View, _PlanetCenterKm, _PlanetRadiusKm + _ShadowAltitudesMaxKm.w ),
	};

	////////////////////////////////////////////////////////////////////////////////
	// Compute ordered distance of each layer
	float4	SliceHitDistancesEnterKm = float4(
		ComputeSphereEnterIntersection( _CameraPosKm, _View, _PlanetCenterKm, _PlanetRadiusKm + _ShadowAltitudesMaxKm.x ),
		ComputeSphereEnterIntersection( _CameraPosKm, _View, _PlanetCenterKm, _PlanetRadiusKm + _ShadowAltitudesMaxKm.y ),
		ComputeSphereEnterIntersection( _CameraPosKm, _View, _PlanetCenterKm, _PlanetRadiusKm + _ShadowAltitudesMaxKm.z ),
		ComputeSphereEnterIntersection( _CameraPosKm, _View, _PlanetCenterKm, _PlanetRadiusKm + _ShadowAltitudesMaxKm.w ) );

	float4	SliceHitDistancesExitKm = float4(
		ComputeSphereExitIntersection( _CameraPosKm, _View, _PlanetCenterKm, _PlanetRadiusKm + _ShadowAltitudesMinKm.x ),
		ComputeSphereExitIntersection( _CameraPosKm, _View, _PlanetCenterKm, _PlanetRadiusKm + _ShadowAltitudesMinKm.y ),
		ComputeSphereExitIntersection( _CameraPosKm, _View, _PlanetCenterKm, _PlanetRadiusKm + _ShadowAltitudesMinKm.z ),
		ComputeSphereExitIntersection( _CameraPosKm, _View, _PlanetCenterKm, _PlanetRadiusKm + _ShadowAltitudesMinKm.w ) );

	float	CaseChoice = step( dot( SliceHitDistancesExitKm, _CaseSwizzle ), 0.0 );	// 1 if viewing "up", 0 if viewing "down"

	// Re-order layer distances
	float	SliceDistances[6];
	SliceDistances[0] = _NearFarKm.x;
	SliceDistances[1] = clamp( lerp( dot( _SwizzleEnterDown0, SliceHitDistancesEnterKm ), dot( _SwizzleExitUp0, SliceHitDistancesExitKm ), CaseChoice ), _NearFarKm.x, _NearFarKm.y );
	SliceDistances[2] = clamp( lerp( dot( _SwizzleEnterDown1, SliceHitDistancesEnterKm ), dot( _SwizzleExitUp1, SliceHitDistancesExitKm ), CaseChoice ), SliceDistances[1], _NearFarKm.y );
	SliceDistances[3] = clamp( lerp( dot( _SwizzleEnterDown2, SliceHitDistancesEnterKm ), dot( _SwizzleExitUp2, SliceHitDistancesExitKm ), CaseChoice ), SliceDistances[2], _NearFarKm.y );
	SliceDistances[4] = clamp( lerp( dot( _SwizzleEnterDown3, SliceHitDistancesEnterKm ), dot( _SwizzleExitUp3, SliceHitDistancesExitKm ), CaseChoice ), SliceDistances[3], _NearFarKm.y );
	SliceDistances[5] = _NearFarKm.y;

	////////////////////////////////////////////////////////////////////////////////
	// Trace each sky layer from front to back
	float3	SliceScattering[5];

	float2	Phases = ComputeSkyPhases( _View, _SunDirection );
	float3	Planet2CameraKm = _CameraPosKm - _PlanetCenterKm;

	float3	ScaledSigma_Rayleigh = SCALE_RAYLEIGH * _Sigma_Rayleigh;
	float	ScaledSigma_Mie = SCALE_MIE * _Sigma_Mie;

	_Extinction = 1.0;
	_Scattering = 0.0;

	float	PreviousDistance;
	float	CurrentDistance = SliceDistances[0];
	float3	PreviousSunColor = 0.0;
	float3	CurrentSunColor = ComputeSunExtinction( length( Planet2CameraKm + _View * CurrentDistance ) );

	for ( int SliceIndex=0; SliceIndex < 5; SliceIndex++ )
	{
		PreviousDistance = CurrentDistance;
		PreviousSunColor = CurrentSunColor;

		CurrentDistance = SliceDistances[SliceIndex+1];
//		CurrentSunColor = ComputeSunExtinction( length( Planet2CameraKm + _View * CurrentDistance ) );

		ComputeSkyColor( _CameraPosKm, _View, float2( PreviousDistance, CurrentDistance ), EarthShadowDistancesKm, Phases, ScaledSigma_Rayleigh, ScaledSigma_Mie, PreviousSunColor, CurrentSunColor, SliceScattering[SliceIndex], _Extinction );
	}

	////////////////////////////////////////////////////////////////////////////////
	// Combine slices and cloud layers in the correct order based on view direction
	float4	CloudExtinctions = 1.0;
#if CLOUD_LAYERS > 0
	CloudExtinctions.x = SampleCloudLayerExtinction( _TexCloudLayer0, _UV );
#endif
#if CLOUD_LAYERS > 1
	CloudExtinctions.y = SampleCloudLayerExtinction( _TexCloudLayer1, _UV );
#endif
#if CLOUD_LAYERS > 2
	CloudExtinctions.z = SampleCloudLayerExtinction( _TexCloudLayer2, _UV );
#endif
#if CLOUD_LAYERS > 3
	CloudExtinctions.w = SampleCloudLayerExtinction( _TexCloudLayer3, _UV );
#endif

	// Order cloud extinctions
	float4	Swizzle0 = lerp( _SwizzleEnterDown0, _SwizzleExitUp0, CaseChoice );
	float4	Swizzle1 = lerp( _SwizzleEnterDown1, _SwizzleExitUp1, CaseChoice );
	float4	Swizzle2 = lerp( _SwizzleEnterDown2, _SwizzleExitUp2, CaseChoice );
	float4	Swizzle3 = lerp( _SwizzleEnterDown3, _SwizzleExitUp3, CaseChoice );

	float4	OrderedCloudExtinctions = float4(
		dot( CloudExtinctions, Swizzle0 ),
		dot( CloudExtinctions, Swizzle1 ),
		dot( CloudExtinctions, Swizzle2 ),
		dot( CloudExtinctions, Swizzle3 ) );

	// Patch invalid extinctions
	// This will place 1 if an extinction swizzle is invalid (i.e. swizzle = 0)
	float4	InvalidExtinctions = float4( dot( Swizzle0, Swizzle0 ), dot( Swizzle1, Swizzle1 ), dot( Swizzle2, Swizzle2 ), dot( Swizzle3, Swizzle3 ) );
	OrderedCloudExtinctions = lerp( 1.0.xxxx, OrderedCloudExtinctions, InvalidExtinctions );

	_Scattering = (((SliceScattering[4] * OrderedCloudExtinctions.w	// Farthest slice attenuated by farthest cloud
				+ SliceScattering[3]) * OrderedCloudExtinctions.z
				+ SliceScattering[2]) * OrderedCloudExtinctions.y
				+ SliceScattering[1]) * OrderedCloudExtinctions.x	// Nearest slice attenuated by nearest cloud
				+ SliceScattering[0];								// Un-attenuated first slice
}

////////////////////////////////////////////////////////////////////////////////////
// The routine that should be called by the PS to render the entire sky
// It supports from 0 to 4 active cloud layers, you have to declare the proper DEFINES for each case
half4	RenderSky( PS_IN _In, float _Z )
{
	// Retrieve camera infos
	float3	CameraPositionKm, View;
	float	Depth2Distance;
	ComputeCameraPositionViewKm( _In.UV.xy, CameraPositionKm, View, Depth2Distance );

	// Compute scene distance
	float	PlanetHitDistanceKm = ComputeSphereEnterIntersection( CameraPositionKm, View, _PlanetCenterKm, _PlanetRadiusKm + _PlanetRadiusOffsetKm );
	if ( PlanetHitDistanceKm < 0.0 )
		PlanetHitDistanceKm = INFINITY;	// Certainly looking up...
	float	ZBufferDistanceKm = _Z * Depth2Distance * _WorldUnit2Kilometer;	// Scene distance from the Z buffer
	float	SceneDistanceKm = lerp( ZBufferDistanceKm, PlanetHitDistanceKm, StepInfinity( _Z ) );	// Either planet hit or scene hit

	// Compute far distance (i.e. either ZBuffer's distance or top of atmosphere distance)
	float2	AtmosphereHitDistancesKm = ComputeAtmosphereDistance( CameraPositionKm, View );
			AtmosphereHitDistancesKm.x = max( 0.0, AtmosphereHitDistancesKm.x );
//			AtmosphereHitDistancesKm.y = lerp( ZBufferDistanceKm, AtmosphereHitDistancesKm.y, StepInfinity( _Z ) );	// If Z == ZFar then start from top of the atmosphere
			AtmosphereHitDistancesKm.y = min( AtmosphereHitDistancesKm.y, SceneDistanceKm );

	// Render
	float3	Scattering, Extinction;
	RenderSky( CameraPositionKm, View, AtmosphereHitDistancesKm, _In.UV, Scattering, Extinction );

	return Pack2Colors( Scattering, Extinction );
}

////////////////////////////////////////////////////////////////////////////////////
// The routine that should be called by the PS to render the sky's environment
half4	RenderSkyEnvironment( PS_IN _In )
{
	float3	ProbePositionKm, View;
#ifdef RENDER_SUN
	ComputeEnvironmentPositionViewSun( ProbePositionKm, View );
#else
	ComputeEnvironmentPositionViewSky( _In.UV.xy, ProbePositionKm, View );
#endif

	// Compute distance to atmosphere
	float2	AtmosphereHitDistancesKm = ComputeAtmosphereDistance( ProbePositionKm, View );

	// Render sky
	float3	SkyScattering = 0.0, SkyExtinction = 1.0;
	RenderSky( ProbePositionKm, View, AtmosphereHitDistancesKm, _In.UV, SkyScattering, SkyExtinction );

	// Compose with clouds
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
	float3	FinalColor = _SunColor * CloudColor.w * SkyExtinction;
#else
	// Compute background
	float3	BackgroundColor = _tex2Dlod( _TexBackground, _In.UV ).xyz;
	float3	FinalColor = BackgroundColor * CloudColor.w * SkyExtinction + CloudColor.xyz + SkyScattering;
#endif

	// Check if we need luminance packing
	if ( _LuminanceScale < 1e-4 )
		return float4( FinalColor, 1.0 );

	// "Normalize" resulting color & store normalized luminance in alpha
	float	MaxRGB = max( 1e-4, max( max( FinalColor.x, FinalColor.y ), FinalColor.z ) );
	return float4( FinalColor / MaxRGB, MaxRGB * _LuminanceScale );
}

#endif

