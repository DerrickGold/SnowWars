// Main computation routine for sky color
//
#ifndef AERIAL_PERSPECTIVE_SUPPORT_INCLUDED
#define AERIAL_PERSPECTIVE_SUPPORT_INCLUDED

#include "../PlanetDataInc.cginc"
#include "../LightSupportInc.cginc"
#include "../ShadowMapInc.cginc"

static const float	H0_AIR = 7.994;						// Altitude scale factor for air molecules
static const float	H0_AEROSOLS = 1.200;				// Altitude scale factor for aerosols
static const float3	INV_WAVELENGTHS_POW4 = float3( 5.6020447463324113301354994573019, 9.4732844379230354373782268493533, 19.643802610477206282947491194819 );	// 1/lambda^4 

static const int	ENVIRONMENT_STEPS_COUNT = 32;		// The amount of trace steps for environment sky rendering

uniform float		_DensitySeaLevel_Rayleigh;			// Molecular density at sea level constant
uniform float3		_Sigma_Rayleigh;					// 4.0 * PI * _DensitySeaLevel_Rayleigh / WAVELENGTHS_POW4;
uniform float		_DensitySeaLevel_Mie;				// Aerosols density at sea level constant
uniform float		_Sigma_Mie;							// 4.0 * PI * _DensitySeaLevel_Mie;
uniform float		_MiePhaseAnisotropy;				// Phase anisotropy factor in [-1,+1]
uniform float2		_ScatteringBoost;					// A boost factor for light scattering & extinction
uniform sampler2D	_TexDensity;
uniform sampler2D	_TexCloudLayer0;
uniform sampler2D	_TexCloudLayer1;
uniform sampler2D	_TexCloudLayer2;
uniform sampler2D	_TexCloudLayer3;
uniform sampler2D	_TexBackground;

uniform float		_SkyStepsCount;
uniform float		_UnderCloudsMinStepsCount;
uniform float		_bGodRays;

uniform sampler2D	_TexDownsampledZBuffer;

// Layers ordering data
uniform float4		_CaseSwizzle;							// Helps determining which layer's intersection will be used to determine the up/down view case
uniform float		_CasePreventInfinity;					// 1 to prevent infinity hits
uniform float4		_SwizzleExitUp0;						// Helps determining what the first crossed layer will be viewing up
uniform float4		_SwizzleExitUp1;						// Helps determining what the second crossed layer will be viewing up
uniform float4		_SwizzleExitUp2;						// Helps determining what the third crossed layer will be viewing up
uniform float4		_SwizzleExitUp3;						// Helps determining what the last crossed layer will be viewing up
uniform float4		_SwizzleEnterDown0;						// Helps determining what the first crossed layer will be viewing down
uniform float4		_SwizzleEnterDown1;						// Helps determining what the second crossed layer will be viewing down
uniform float4		_SwizzleEnterDown2;						// Helps determining what the third crossed layer will be viewing down
uniform float4		_SwizzleEnterDown3;						// Helps determining what the last crossed layer will be viewing down
uniform float4		_IsGodRaysLayerUp, _IsGodRaysLayerDown;	// Helps determining what ordered layer the godrays are standing in
uniform float2		_IsGodRaysLayerUpDown;					// Same, but for the 5th slice that doesn't fit into a float4

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
	float	PhaseMie = ComputeMiePhase( CosTheta, _MiePhaseAnisotropy );

	return INV_4PI * float2( PhaseRayleigh, PhaseMie );
}

// Samples a cloud layer's extinction that will attenuate the sky's scattering
float	SampleCloudLayerExtinction( sampler2D _TexCloudLayer, float4 _UV )
{
	// Sample next cloud layer (the one closer to camera that will attenuate what we're about to compute)
	return _tex2Dlod( _TexCloudLayer, _UV ).w;
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

// Actual sky color computation that samples the shadow map for godrays
// Note that we trace backward so we do the following operations :
//
//		StepExtinction = exp( -Extinction * StepSize );							// Current step's extinction
//		StepScattering = incoming scattered light at position					// Current step's scattering
//		Scattering(x) = StepScattering + StepExtinction * Scattering(x+DeltaX)	// Attenuate previous scattering and add this step's scattering
//		Extinction(x) *= Extinction(x+DeltaX)									// Attenuate previous extinction
//
//	With Scattering/Extinction(x+DeltaX) being the scattering/extinction from previous step.
//
//	_PositionKm, the start position in kilometers
//	_View, the normalized view direction
//	_DistanceKm, the start/end distances to trace
//	_EarthShadowDistancesKm, the [Start,End] distances of Earth shadow. The Earth casts a cylindrical shadow volume when the Sun goes below the horizon.
//		These are the distance at which we enter and exit the volume. During the day, these distances are -oo
//	_Phases, the Rayleigh and Mie phases in X and Y respectively
//	_Scattering, the current value of scattering, updated by the computation
//	_Extinction,the current value of extinction, updated by the computation
//
void	ComputeSingleStep( float3 _PositionKm, float3 _View, inout float _DistanceKm, float _DistanceStepKm, float2 _EarthShadowDistancesKm, float2 _Phases, bool _bGodRays, inout float3 _Scattering, inout float3 _Extinction )
{
	// Compute current position and altitude
	float3	CurrentPositionKm = _PositionKm + _DistanceKm * _View;
	float	CurrentRadiusKm = length( CurrentPositionKm - _PlanetCenterKm );

	// =============================================
	// Sample density at current altitude and optical depth in Sun direction
	float4	OpticalDepth = ComputeOpticalDepth( CurrentRadiusKm, _SunDirection );
	float	DensityRayleigh = OpticalDepth.x;
	float	DensityMie = OpticalDepth.y;

	// =============================================
	// Retrieve sun light attenuated when passing through the atmosphere
	float	NextDistanceKm = _DistanceKm + _DistanceStepKm;
	float	InvStepSizeKm = 1.0 / _DistanceStepKm;
	float3	SunExtinction = exp( -_Sigma_Rayleigh * OpticalDepth.z - _Sigma_Mie * OpticalDepth.w );
	float	EarthShadow = IsInShadow( _DistanceKm, NextDistanceKm, InvStepSizeKm, _EarthShadowDistancesKm );
	float3	Light = _ScatteringBoost.x * SunExtinction * EarthShadow * _SunColor;

	if ( _bGodRays )
	{	// Sample shadow map
		float2	ShadowUV = WorldPosition2Shadow( CurrentPositionKm );
		Light *= GetShadowAtAltitude( ShadowUV, CurrentRadiusKm - _PlanetRadiusKm );
	}

	// =============================================
	// Compute in-scattered light
	float3	ScatteringRayleigh = DensityRayleigh * _DensitySeaLevel_Rayleigh * INV_WAVELENGTHS_POW4 * _Phases.x;
	float	ScatteringMie = DensityMie * _DensitySeaLevel_Mie * _Phases.y;
	float3	StepScattering = Light * (ScatteringRayleigh + ScatteringMie);
			StepScattering += DensityMie * _DensitySeaLevel_Mie * ComputeLightningColor( CurrentPositionKm, _View, _MiePhaseAnisotropy );
			StepScattering += _AmbientNightSky;

	// =============================================
	// Accumulate in-scattered light with extinction along the ray
	_Scattering += StepScattering * _DistanceStepKm * _Extinction;

	// =============================================
	// Accumulate extinction along view
	_Extinction *= exp( -(_Sigma_Rayleigh * DensityRayleigh + _Sigma_Mie * DensityMie) * _ScatteringBoost.y * _DistanceStepKm );

	// =============================================
	// March one step
	_DistanceKm = NextDistanceKm;
}

// Perform the sky color computation by ray-marching several steps
void	ComputeSkyColor( float3 _PositionKm, float3 _View, inout float _DistanceKm, float _DistanceStepKm, float2 _EarthShadowDistancesKm, float2 _Phases, bool _bGodRays, out float3 _Scattering, inout float3 _Extinction, const float _StepsCount )
{
	_Scattering = 0.0;
	if ( _StepsCount <= 0.0 )
		return;	// Absolutely nothing to do !

	// Ray-march the view ray
	int	IntStepsCount = int( floor( _StepsCount ) );
	for ( int StepIndex=0; StepIndex < IntStepsCount; StepIndex++ )
		ComputeSingleStep( _PositionKm, _View, _DistanceKm, _DistanceStepKm, _EarthShadowDistancesKm, _Phases, _bGodRays, _Scattering, _Extinction );

	// Perform the last, non-integer step
 	float	Remainder = _StepsCount - IntStepsCount;
	ComputeSingleStep( _PositionKm, _View, _DistanceKm, Remainder * _DistanceStepKm, _EarthShadowDistancesKm, _Phases, _bGodRays, _Scattering, _Extinction );
}

void	RenderSky( float3 _CameraPositionKm, float3 _View, float2 _NearFarKm, float4 _UV, float _StepsCount, bool _bGodRays, out float3 _Scattering, out float3 _Extinction )
{
	// Compute potential intersection with earth's shadow
	float2	EarthShadowDistancesKm = ComputePlanetShadow( _CameraPositionKm, _View, _SunDirection );

	////////////////////////////////////////////////////////////////////////////////
	// Compute ordered distance of each layer
	float4	SliceHitDistancesEnterKm = float4(
		ComputeSphereEnterIntersection( _CameraPositionKm, _View, _PlanetCenterKm, _PlanetRadiusKm + _ShadowAltitudesMaxKm.x ),
		ComputeSphereEnterIntersection( _CameraPositionKm, _View, _PlanetCenterKm, _PlanetRadiusKm + _ShadowAltitudesMaxKm.y ),
		ComputeSphereEnterIntersection( _CameraPositionKm, _View, _PlanetCenterKm, _PlanetRadiusKm + _ShadowAltitudesMaxKm.z ),
		ComputeSphereEnterIntersection( _CameraPositionKm, _View, _PlanetCenterKm, _PlanetRadiusKm + _ShadowAltitudesMaxKm.w ) );

	float4	SliceHitDistancesExitKm = float4(
		ComputeSphereExitIntersection( _CameraPositionKm, _View, _PlanetCenterKm, _PlanetRadiusKm + _ShadowAltitudesMinKm.x ),
		ComputeSphereExitIntersection( _CameraPositionKm, _View, _PlanetCenterKm, _PlanetRadiusKm + _ShadowAltitudesMinKm.y ),
		ComputeSphereExitIntersection( _CameraPositionKm, _View, _PlanetCenterKm, _PlanetRadiusKm + _ShadowAltitudesMinKm.z ),
		ComputeSphereExitIntersection( _CameraPositionKm, _View, _PlanetCenterKm, _PlanetRadiusKm + _ShadowAltitudesMinKm.w ) );


	// Determine if we're viewing up or down depending if we missed the intersection with the "case layer"
	float	CaseLayerHitDistance = dot( SliceHitDistancesExitKm, _CaseSwizzle );
	float	CaseChoice = saturate( step( CaseLayerHitDistance, 0.0 ) + _CasePreventInfinity * step( 0.5 * INFINITY, CaseLayerHitDistance ) );	// 1 if viewing "up", 0 if viewing "down"

	// This clever line handles the case where the ray looking down misses the bottom layer so the ray is
	//	still limited by the layer above...
	SliceHitDistancesEnterKm.xyz = min( SliceHitDistancesEnterKm.xyz, SliceHitDistancesExitKm.yzw );

	// Re-order layer distances
	float	SliceDistances[6];
	SliceDistances[0] = _NearFarKm.x;
	SliceDistances[1] = clamp( lerp( dot( _SwizzleEnterDown0, SliceHitDistancesEnterKm ), dot( _SwizzleExitUp0, SliceHitDistancesExitKm ), CaseChoice ), _NearFarKm.x, _NearFarKm.y );
	SliceDistances[2] = clamp( lerp( dot( _SwizzleEnterDown1, SliceHitDistancesEnterKm ), dot( _SwizzleExitUp1, SliceHitDistancesExitKm ), CaseChoice ), SliceDistances[1], _NearFarKm.y );
	SliceDistances[3] = clamp( lerp( dot( _SwizzleEnterDown2, SliceHitDistancesEnterKm ), dot( _SwizzleExitUp2, SliceHitDistancesExitKm ), CaseChoice ), SliceDistances[2], _NearFarKm.y );
	SliceDistances[4] = clamp( lerp( dot( _SwizzleEnterDown3, SliceHitDistancesEnterKm ), dot( _SwizzleExitUp3, SliceHitDistancesExitKm ), CaseChoice ), SliceDistances[3], _NearFarKm.y );
	SliceDistances[5] = _NearFarKm.y;

	float	MinStepsCount[5] = { 0.0, 0.0, 0.0, 0.0, 0.0 };
	MinStepsCount[0] = _UnderCloudsMinStepsCount * lerp( _IsGodRaysLayerDown.x, _IsGodRaysLayerUp.x, CaseChoice );
	MinStepsCount[1] = _UnderCloudsMinStepsCount * lerp( _IsGodRaysLayerDown.y, _IsGodRaysLayerUp.y, CaseChoice );
	MinStepsCount[2] = _UnderCloudsMinStepsCount * lerp( _IsGodRaysLayerDown.z, _IsGodRaysLayerUp.z, CaseChoice );
	MinStepsCount[3] = _UnderCloudsMinStepsCount * lerp( _IsGodRaysLayerDown.w, _IsGodRaysLayerUp.w, CaseChoice );
	MinStepsCount[4] = _UnderCloudsMinStepsCount * lerp( _IsGodRaysLayerUpDown.y, _IsGodRaysLayerUpDown.x, CaseChoice );


	////////////////////////////////////////////////////////////////////////////////
	// Trace each sky layer from front to back
	float3	SliceScattering[5];

	float2	Phases = ComputeSkyPhases( _View, _SunDirection );

	_Extinction = 1.0;

	float	DeltaRho = SliceDistances[5] - SliceDistances[0];	// We must interpolate between this distance in the amount of steps we were given
	float	InvDeltaRho = _SkyStepsCount / DeltaRho;			// Amount of steps per unit kilometer
	float	GlobalDistanceStep = DeltaRho / _SkyStepsCount;		// Distance of a single step

	for ( int SliceIndex=0; SliceIndex < 5; SliceIndex++ )
	{
		float	CurrentDistance = SliceDistances[SliceIndex];

		float	DeltaDistance = SliceDistances[SliceIndex+1] - CurrentDistance;
		float	SliceStepsCount = DeltaDistance * InvDeltaRho;	// Amount of steps for that slice
 	 	float	SliceDistanceStep = GlobalDistanceStep;

		SliceStepsCount = max( SliceStepsCount, MinStepsCount[SliceIndex] );
		SliceDistanceStep = DeltaDistance / SliceStepsCount;

		ComputeSkyColor( _CameraPositionKm, _View, CurrentDistance, SliceDistanceStep, EarthShadowDistancesKm, Phases, _bGodRays, SliceScattering[SliceIndex], _Extinction, SliceStepsCount );
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
			PlanetHitDistanceKm = lerp( PlanetHitDistanceKm, INFINITY, saturate( -10000.0 * PlanetHitDistanceKm ) );

	float	ZBufferDistanceKm = _Z * Depth2Distance * _WorldUnit2Kilometer;								// Scene distance from the Z buffer
	float	SceneDistanceKm = lerp( ZBufferDistanceKm, PlanetHitDistanceKm, SaturateInfinity( _Z ) );	// Either planet hit or scene hit

	// Compute far distance (i.e. either ZBuffer's distance or top of atmosphere distance)
	float2	AtmosphereHitDistancesKm = ComputeAtmosphereDistance( CameraPositionKm, View );
			AtmosphereHitDistancesKm.x = max( 0.001, AtmosphereHitDistancesKm.x );	// Cannot be 0 as we take the log of that value at some point
			AtmosphereHitDistancesKm.y = min( AtmosphereHitDistancesKm.y, SceneDistanceKm );

	// Render
	float3	Scattering, Extinction;
	RenderSky( CameraPositionKm, View, AtmosphereHitDistancesKm, _In.UV, _SkyStepsCount, _bGodRays, Scattering, Extinction );

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

	////////////////////////////////////////////////////////////////////////////////
	// Compute hit distance of each layer
	float4	SliceHitDistancesKm = float4(
		ComputeSphereExitIntersection( ProbePositionKm, View, _PlanetCenterKm, _PlanetRadiusKm + _ShadowAltitudesMinKm.x ),
		ComputeSphereExitIntersection( ProbePositionKm, View, _PlanetCenterKm, _PlanetRadiusKm + _ShadowAltitudesMinKm.y ),
		ComputeSphereExitIntersection( ProbePositionKm, View, _PlanetCenterKm, _PlanetRadiusKm + _ShadowAltitudesMinKm.z ),
		ComputeSphereExitIntersection( ProbePositionKm, View, _PlanetCenterKm, _PlanetRadiusKm + _ShadowAltitudesMinKm.w ) );

	float2	NearFarKm = float2( 0.0, ComputeAtmosphereDistance( ProbePositionKm, View ).y );

	float	SliceDistances[6];
	SliceDistances[0] = NearFarKm.x;
	SliceDistances[1] = clamp( SliceHitDistancesKm.x, NearFarKm.x, NearFarKm.y );
	SliceDistances[2] = clamp( SliceHitDistancesKm.y, NearFarKm.x, NearFarKm.y );
	SliceDistances[3] = clamp( SliceHitDistancesKm.z, NearFarKm.x, NearFarKm.y );
	SliceDistances[4] = clamp( SliceHitDistancesKm.w, NearFarKm.x, NearFarKm.y );
	SliceDistances[5] = NearFarKm.y;

	////////////////////////////////////////////////////////////////////////////////
	// Render sky
	float3	SkyExtinction = 1.0;
	float3	SliceScattering[5];

	float2	Phases = ComputeSkyPhases( View, _SunDirection );
	float2	EarthShadowDistancesKm = ComputePlanetShadow( ProbePositionKm, View, _SunDirection );

	float	RayLength = SliceDistances[5] - SliceDistances[0];	// We must interpolate between this distance in the amount of steps we were given
	float	InvDeltaRho = ENVIRONMENT_STEPS_COUNT / RayLength;	// Amount of steps per unit kilometer
	float	DistanceStep = RayLength / ENVIRONMENT_STEPS_COUNT;	// Distance of a single step

	for ( int SliceIndex=0; SliceIndex < 5; SliceIndex++ )
	{
		float	CurrentDistance = SliceDistances[SliceIndex];

		float	DeltaDistance = SliceDistances[SliceIndex+1] - CurrentDistance;
		float	SliceStepsCount = DeltaDistance * InvDeltaRho;	// Amount of steps for that slice

		ComputeSkyColor( ProbePositionKm, View, CurrentDistance, DistanceStep, EarthShadowDistancesKm, Phases, _bGodRays, SliceScattering[SliceIndex], SkyExtinction, SliceStepsCount );
	}

#ifdef RENDER_SUN
	return float4( _SunColor * SkyExtinction, dot(SkyExtinction,LUMINANCE) );
#else

	////////////////////////////////////////////////////////////////////////////////
	// Compose with clouds
#if CLOUD_LAYERS > 0
	float4	CloudColor0 = _tex2Dlod( _TexCloudLayer0, _In.UV );
	float4	CloudColor1 = _tex2Dlod( _TexCloudLayer1, _In.UV );
	float4	CloudColor2 = _tex2Dlod( _TexCloudLayer2, _In.UV );
	float4	CloudColor3 = _tex2Dlod( _TexCloudLayer3, _In.UV );

	float3	SkyScattering = (((SliceScattering[4] * CloudColor3.w	// Farthest slice attenuated by farthest cloud
				+ SliceScattering[3]) * CloudColor2.w
				+ SliceScattering[2]) * CloudColor1.w
				+ SliceScattering[1]) * CloudColor0.w				// Nearest slice attenuated by nearest cloud
				+ SliceScattering[0];								// Un-attenuated first slice

	float4	CloudColor = CloudColor0 + CloudColor0.w * (CloudColor1 + CloudColor1.w * (CloudColor2 + CloudColor2.w * CloudColor3));
			CloudColor.w = CloudColor0.w * CloudColor1.w * CloudColor2.w * CloudColor3.w;

#else
	float3	SkyScattering = SliceScattering[0] + SliceScattering[1] + SliceScattering[2] + SliceScattering[3] + SliceScattering[4];
	float4	CloudColor = float4( 0.0, 0.0, 0.0, 1.0 );
#endif

	////////////////////////////////////////////////////////////////////////////////
	// Compute final color
	SkyExtinction *= CloudColor.w;

	float3	BackgroundColor = _tex2Dlod( _TexBackground, _In.UV ).xyz;
	float3	FinalColor = BackgroundColor * SkyExtinction + CloudColor.xyz + SkyScattering;

	return float4( FinalColor, dot(SkyExtinction,LUMINANCE) );
#endif
}

#endif
