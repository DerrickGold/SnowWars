// Common header for cloud shaders that need local variations
// Requires PlanetDataInc.cginc
//
#ifndef LOCAL_VARIATIONS_SUPPORT_INCLUDED
#define LOCAL_VARIATIONS_SUPPORT_INCLUDED

uniform float4		_NuajLocalCoverageOffset;		// Offset for local cloud coverage
uniform float4		_NuajLocalCoverageFactor;		// Factor for local cloud coverage
uniform sampler2D	_NuajLocalCoverageTexture;		// Texture of local cloud coverage
uniform float4x4	_NuajLocalCoverageTransform;	// Transforms a WORLD space position into local coverage texture space (XZ)

uniform float4		_NuajTerrainEmissiveOffset;		// Offset for emissive terrain color
uniform float4		_NuajTerrainEmissiveFactor;		// Factor for emissive terrain color
uniform sampler2D	_NuajTerrainEmissiveTexture;	// Texture of emissive terrain color
uniform float4x4	_NuajTerrainEmissiveTransform;	// Transforms a WORLD space position into emissive terrain texture space (XZ)

//uniform float3		_NuajTerrainAlbedo;				// Terrain albedo for global light reflection and cloud lighting from below

// Gets the local coverage for each cloud layer
float4	GetLocalCoverage( float3 _WorldPositionKm )
{
	float4	UV = float4( 0.5 * (1.0 + mul( _NuajLocalCoverageTransform, float4( _Kilometer2WorldUnit * _WorldPositionKm, 1.0 ) ).xz), 0.0, 0.0 );
	return _NuajLocalCoverageOffset + _NuajLocalCoverageFactor * _tex2Dlod( _NuajLocalCoverageTexture, UV );
}

// Gets the local coverage for each cloud layer
float	GetLocalCoverage( float3 _WorldPositionKm, int _CloudLayerIndex )
{
	float4	Coverage = GetLocalCoverage( _WorldPositionKm );
	if ( _CloudLayerIndex == 0 )
		return Coverage.x;
	else if ( _CloudLayerIndex == 1 )
		return Coverage.y;
	else if ( _CloudLayerIndex == 2 )
		return Coverage.z;
	else //if ( _CloudLayerIndex == 3 )
		return Coverage.w;
}

// Gets the terrain emissive color + the terrain albedo factor in alpha
float4	GetTerrainEmissive( float3 _WorldPositionKm )
{
	float4	UV = float4( 0.5 * (1.0 + mul( _NuajTerrainEmissiveTransform, float4( _Kilometer2WorldUnit * _WorldPositionKm, 1.0 ) ).xz), 0.0, 0.0 );
	return _NuajTerrainEmissiveOffset + _NuajTerrainEmissiveFactor * _tex2Dlod( _NuajTerrainEmissiveTexture, UV );
}

#endif

