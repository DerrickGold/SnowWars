// This adds support for the shadow map
// #requires "PlanetDataInc.cginc"
// #requires "LightSupportInc.cginc"
//
#ifndef SHADOW_MAP_SUPPORT_INCLUDED
#define SHADOW_MAP_SUPPORT_INCLUDED

uniform float4x4	_NuajShadow2World;
uniform float4x4	_NuajWorld2Shadow;
uniform float4		_ShadowAltitudesMinKm;		// RGBA contain each the MIN altitudes for each of the 4 possible cloud layers (from bottom to top)
uniform float4		_ShadowAltitudesMaxKm;		// RGBA contain each the MAX altitudes for each of the 4 possible cloud layers (from bottom to top)
uniform float4		_ShadowMapUVBounds;			// The UV bounds where the shadow is valid
uniform sampler2D 	_TexShadowMap;				// RGBA contain each an extinction value for each of the 4 possible cloud layers (from bottom to top)

// Converts a shadow map UV into a WORLD position in kilometers
// The world position then lies in a plane orthogonal to the light and tangent to the highest cloud plane
//	_UV, the shadow map UV
//
float3	Shadow2WorldPosition( float2 _UV )
{
	_UV = (_UV - _ShadowMapUVBounds.xy) / _ShadowMapUVBounds.zw;
	return mul( _NuajShadow2World, float4( _UV, 0.0, 1.0 ) ).xyz;
}

// Converts a shadow map UV into a WORLD position on a cloud sphere (in kilometers)
//	_UV, the shadow map UV
//	_CloudRadiusKm, the radius of the cloud sphere from Earth's center (in kilometers)
//
float3	Shadow2CloudPosition( float2 _UV, float _CloudRadiusKm )
{
	// Transform UVs into world position
	float3	WorldPositionKm = Shadow2WorldPosition( _UV );

	// Reproject to cloud sphere by following the Sun's direction
	float	Distance2CloudKm = ComputeSphereIntersection( WorldPositionKm, -_SunDirection, _PlanetCenterKm, _CloudRadiusKm );

	// Follow the Sun !
	return WorldPositionKm - Distance2CloudKm * _SunDirection;
}

// Converts a WORLD position (in kilometers) into a shadow map UV
//	_WorldPositionKm, the world position in kilometers
//
float2	WorldPosition2Shadow( float3 _WorldPositionKm )
{
	float2	UV = mul( _NuajWorld2Shadow, float4( _WorldPositionKm, 1.0 ) ).xy;
			UV = 1.0 - abs( fmod( UV + 100.0, 2.0 ) - 1.0 );	// Mirror mode
//			UV = saturate( UV );								// Clamp mode

	// Constrain in shadow bounds where the shadow was computed
	UV = _ShadowMapUVBounds.xy + _ShadowMapUVBounds.zw * UV;

	return UV;
}

// Computes the extinction due to shadowing at given altitude
//	_AltitudeKm, the sampling altitude in kilometers from planet surface (i.e. NOT including earth radius)
float	GetShadowAtAltitude( float2 _ShadowUV, float _AltitudeKm )
{
	if ( _AltitudeKm >= _ShadowAltitudesMaxKm.w )
		return 1.0;	// Above highest cloud layer : no shadow !

	float4	Shadow = _tex2Dlod( _TexShadowMap, float4( _ShadowUV, 0.0, 0.0 ) );
	float4	Weight = smoothstep( _ShadowAltitudesMaxKm, _ShadowAltitudesMinKm, _AltitudeKm.xxxx );	// Gives the weight of shadowing of each layer based on altitude
	float4	Lerp = lerp( 1.0.xxxx, Shadow, Weight );												// Lerps betweeen no- or full-shadowing based on weight
	return Lerp.x * Lerp.y * Lerp.z * Lerp.w;														// Layers modulate each other...
}

// Computes the extinction due to shadowing at a given position
//	_WorldPositionKm, the world position where to sample the shadow map (this position is in kilometers and is in Earth coordinates, meaning that if you're standing on the ground then your position is (0,_PlanetRadiusKm,0))
//	_SphereRadiusKm, the radius of the sphere onto which to project the position to (including the Earth radius)
float	GetShadowAtPosition( float3 _WorldPositionKm, float _SphereRadiusKm )
{
	// Compute altitude (relative to sea level)
	float	AltitudeKm = length( _WorldPositionKm - _PlanetCenterKm ) - _PlanetRadiusKm;
// 	if ( AltitudeKm >= _ShadowAltitudesMaxKm.w )
// 		return 1.0;	// Above highest cloud layer : no shadow anyway!

	return GetShadowAtAltitude( WorldPosition2Shadow( _WorldPositionKm ), AltitudeKm );
}

#endif
