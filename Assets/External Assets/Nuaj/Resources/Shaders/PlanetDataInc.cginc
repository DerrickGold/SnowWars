// Common header for shaders that need planet helpers
//
#ifndef PLANET_SUPPORT_INCLUDED
#define PLANET_SUPPORT_INCLUDED

//#define USE_LERP_INSTEAD_OF_CONDITION	//###

static const float	INFINITY = 1e6;
static const float	HALF_INFINITY = 0.5 * INFINITY;

uniform float3		_PlanetCenterKm;				// Center of the planet in WORLD space in kilometers
uniform float3		_PlanetNormal;					// Normal to the planet's surface where the camera is standing
uniform float3		_PlanetTangent;					// Tangent to the planet's surface where the camera is standing
uniform float3		_PlanetBiTangent;				// BiTangent to the planet's surface where the camera is standing
uniform float		_PlanetRadiusKm;				// Radius of the planet in kilometers
uniform float		_PlanetRadiusOffsetKm;			// Small radius nudge we authorize below the actual radius to allow to offset the horizon line
uniform float		_PlanetAtmosphereAltitudeKm;	// Altitude to the top of the planet's atmosphere, in kilometers
uniform float		_PlanetAtmosphereRadiusKm;		// Radius of the top of the planet's atmosphere, in kilometers (this is the planet radius + atmosphere altitude really)
uniform float		_WorldUnit2Kilometer;			// World scale factor from WORLD units to kilometers
uniform float		_Kilometer2WorldUnit;			// World scale factor from kilometers to WORLD units
uniform float		_bComputePlanetShadow;			// True to enable planet shadow computation

// Compute the forward intersection of a ray with a sphere
//	_PositionKm, the current view position in kilometers
//	_Direction, the current view direction (assuming it's NORMALIZED)
// Returns -1 if no forward hit
float	ComputeSphereIntersection( float3 _PositionKm, float3 _Direction, float3 _SphereCenter, float _SphereRadius )
{
	float3	D = _PositionKm - _SphereCenter;
	float	b = dot( _Direction, D );
	float	c = dot( D, D ) - _SphereRadius*_SphereRadius;
	float	Delta = b*b - c;
	if ( Delta < 0.0 )
		return 0.0;

	Delta = sqrt( Delta );

	float	t0 = -b-Delta;
	float	t1 = -b+Delta;

	if ( t1 < 0.0 )
		return 0.0;	// Both hits stand behind start position
	if ( t0 < 0.0 )
		return t1;	// First hit stands behind start position

	return t0;
}

// Computes both entry & exit intersections without any check
float2	ComputeBothSphereIntersections( float3 _PositionKm, float3 _Direction, float3 _SphereCenter, float _SphereRadius )
{
	float3	D = _PositionKm - _SphereCenter;
	float	b = dot( _Direction, D );
	float	c = dot( D, D ) - _SphereRadius*_SphereRadius;
	float	Delta = b*b - c;

#ifdef USE_LERP_INSTEAD_OF_CONDITION
	float	SqrtDelta = sqrt(Delta);
	return lerp( float2( -b-SqrtDelta, -b+SqrtDelta), float2( +INFINITY, -INFINITY ), saturate( -10000.0 * Delta ) );
#else
	if ( Delta < 0.0 )
		return float2( +INFINITY, -INFINITY );	// No intersection : infinity !

	Delta = sqrt( Delta );

	return float2( -b-Delta, -b+Delta );
#endif
}

// Compute the entry point with a sphere
float	ComputeSphereEnterIntersection( float3 _PositionKm, float3 _Direction, float3 _SphereCenter, float _SphereRadius )
{
	float3	D = _PositionKm - _SphereCenter;
	float	b = dot( _Direction, D );
	float	c = dot( D, D ) - _SphereRadius*_SphereRadius;
	float	Delta = b*b - c;
#ifdef USE_LERP_INSTEAD_OF_CONDITION
	return lerp( -b-sqrt(Delta), INFINITY, saturate( -10000.0 * Delta ) );
#else
	if ( Delta < 0.0 )
		return INFINITY;

	Delta = sqrt( Delta );

	return -b-Delta;
#endif
}

// Compute the exit point with a sphere
float	ComputeSphereExitIntersection( float3 _PositionKm, float3 _Direction, float3 _SphereCenter, float _SphereRadius )
{
	float3	D = _PositionKm - _SphereCenter;
	float	b = dot( _Direction, D );
	float	c = dot( D, D ) - _SphereRadius*_SphereRadius;
	float	Delta = b*b - c;
#ifdef USE_LERP_INSTEAD_OF_CONDITION
	return lerp( -b+sqrt(Delta), INFINITY, saturate( -10000.0 * Delta ) );
#else
	if ( Delta < 0.0 )
		return -INFINITY;

	Delta = sqrt( Delta );

	return -b+Delta;
#endif
}

// Compute the forward intersection of a ray with the current planet
//	_PositionKm, the current view position in kilometers
// Returns -1 if no forward hit
float	ComputePlanetDistance( float3 _PositionKm, float3 _Direction )
{
	return ComputeSphereIntersection( _PositionKm, _Direction, _PlanetCenterKm, _PlanetRadiusKm );
}

// Compute the intersection distances of a ray with the current planet's atmosphere
//	_PositionKm, the current view position in kilometers
// Returns :
//	X = Nearest hit or 0 if we're inside atmosphere
//	Y = Farthest hit or 0 if no intersection
float2	ComputeAtmosphereDistance( float3 _PositionKm, float3 _Direction )
{
	float3	D = _PositionKm - _PlanetCenterKm;
	float	b = dot( D, _Direction );
	float	c = dot( D, D ) - _PlanetAtmosphereRadiusKm*_PlanetAtmosphereRadiusKm;
	float	Delta = b*b - c;
	if ( Delta < 0.0 )
		return 0.0;	// No intersection

	Delta = sqrt(Delta);

	return float2( max( 0.0, -b-Delta ), max( 0.0, -b+Delta ) );
}

// Computes the potential distances with the shadow cylinder cast by the planet when the Sun is below the horizon
//	_PositionKm, the position on the planet's surface
//	_View, the view direction
// Returns the 2 distances in kilometers (min/max) to the planet's shadow in view direction.
//	During the day, these distances are at (+oo,-oo) respectively
//
float2	ComputePlanetShadow( float3 _PositionKm, float3 _View, float3 _SunDirection )
{
	float3	ToPositionKm = _PositionKm - _PlanetCenterKm;
	float2	ShadowDistancesKm = float2( +INFINITY, -INFINITY );	// oo during the day
	if ( _bComputePlanetShadow && dot( ToPositionKm, _SunDirection ) <= 0.0 )
	{	// Project current position in the 2D plane normal to the light to test the intersection with the shadow cylinder cast by the planet
		float3	D = _PositionKm - _PlanetCenterKm;
		float3	A = cross( D, _SunDirection );
		float3	B = cross( _View, _SunDirection );
		float	a = dot( B, B );
		float	b = dot( A, B );
		float	c = dot( A, A ) - _PlanetRadiusKm*_PlanetRadiusKm;
		float	Delta = b*b - a*c;
		if ( Delta > 0.0 )
		{
			Delta = sqrt(Delta);
			a = 1.0 / a;

			ShadowDistancesKm.x = (-b-Delta) * a;
			ShadowDistancesKm.y = (-b+Delta) * a;
			if ( dot( _PositionKm + ShadowDistancesKm.x * _View - _PlanetCenterKm, _SunDirection ) > 0.0 )
				ShadowDistancesKm = float2( +INFINITY, -INFINITY );	// Bad hit in lit part of the cylinder
		}
	}

	return ShadowDistancesKm;
}

// Returns a value of 0 if if we're in the planet's shadow, 1 otherwise
float	IsInShadow( float _DistanceKm, float2 _ShadowDistancesKm )
{
	return	1.0 - step( _ShadowDistancesKm.x, _DistanceKm ) * step( _DistanceKm, _ShadowDistancesKm.y );
}

// This smoothly interpolates the shadow value given the 2 distances of a trace step
// Returns a value of 0 if if we're in the planet's shadow, 1 otherwise
float	IsInShadow( float _DistanceStartKm, float _DistanceEndKm, float _InvDistanceKm, float2 _ShadowDistancesKm )
{
	return	1.0 - saturate( (_DistanceEndKm - _ShadowDistancesKm.x) * _InvDistanceKm ) * saturate( (_ShadowDistancesKm.y - _DistanceStartKm) * _InvDistanceKm );
}
float	IsInShadow( float _DistanceStartKm, float _DistanceEndKm, float2 _ShadowDistancesKm )
{
	float	InvDistance = 1.0f / (_DistanceEndKm - _DistanceStartKm);
	return	IsInShadow( _DistanceStartKm, _DistanceEndKm, InvDistance, _ShadowDistancesKm );
}

// Returns a value of 0 if if we're in the planet's shadow, 1 otherwise
float	IsInShadowSoft( float _DistanceKm, float2 _ShadowDistancesKm )
{
	return	1.0 - smoothstep( 0.9 * _ShadowDistancesKm.x, 1.1 * _ShadowDistancesKm.x, _DistanceKm ) * smoothstep( 1.1 * _ShadowDistancesKm.y, 0.9 * _ShadowDistancesKm.y, _DistanceKm );
}

#endif

