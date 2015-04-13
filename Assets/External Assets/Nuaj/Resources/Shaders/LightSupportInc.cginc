// Common header for shaders that need light support (i.e. Sun & Sky data)
// (Requires PlanetDataInc.cginc)
//
#ifndef LIGHT_SUPPORT_INCLUDED
#define LIGHT_SUPPORT_INCLUDED

uniform float3		_SunColor;					// The color of the Sun in space (not tainted by atmosphere)
uniform float		_SunLuminance;				// The luminance of the Sun
uniform float3		_SunDirection;				// The direction pointing toward the Sun
uniform sampler2D	_TexAmbientSky;				// The ambient Sky color into a 1x1 texture
uniform float4		_SoftAmbientSky;			// The software ambient Sky color W=lerp between full software or hardware ambient

uniform float3		_AmbientNightSky;			// An ambient night sky term

uniform float3		_TerrainReflectedLight;		// The intensity of the light (Sun + Sky) as reflected by the ground (tainted by atmosphere and clouds)

uniform float3		_EnvProbePositionKm;		// The position of the probe used for environment rendering
uniform float		_EnvironmentMapPixelSize;	// The size of an environment map pixel
uniform float4		_EnvironmentAngles;			// Contains the minimum & maximum phi/theta angles used by the environment rendering

uniform sampler2D	_TexShadowEnvMapSkyTop;		// Environment shadowing by clouds above
uniform sampler2D	_TexShadowEnvMapSkyBottom;	// Environment shadowing by clouds above AND current cloud

// Both lightning segments
uniform float3		_NuajLightningPosition00;
uniform float3		_NuajLightningPosition01;
uniform float3		_NuajLightningColor0;

uniform float3		_NuajLightningPosition10;
uniform float3		_NuajLightningPosition11;
uniform float3		_NuajLightningColor1;


////////////////////////////////////////////////////////////////////////////////////////
// Environment Map Computation Helpers

// Computes the environment view vector given the UV coordinates we're rendering with
float3	GetEnvironmentView( float2 _UV )
{
	float2	Angles = _EnvironmentAngles.xy + _UV * _EnvironmentAngles.zw;
	float2	SinCosTheta, SinCosPhi;
	sincos( Angles.y, SinCosTheta.x, SinCosTheta.y );
	sincos( Angles.x, SinCosPhi.x, SinCosPhi.y );
	float3	ViewTS = float3( SinCosTheta.x * SinCosPhi.x, SinCosTheta.y, SinCosTheta.x * SinCosPhi.y );
	return ViewTS.x * _PlanetTangent + ViewTS.y * _PlanetNormal + ViewTS.z * _PlanetBiTangent;
}

// Computes the camera position & view direction for environment mapping
void	ComputeEnvironmentPositionViewSky( float2 _UV, out float3 _ProbePositionKm, out float3 _View )
{
	_ProbePositionKm = _EnvProbePositionKm;
	_View = GetEnvironmentView( _UV );
}

// Computes the camera position & view direction for environment mapping
void	ComputeEnvironmentPositionViewSun( out float3 _ProbePositionKm, out float3 _View )
{
	_ProbePositionKm = _EnvProbePositionKm;
	_View = _SunDirection;
}


////////////////////////////////////////////////////////////////////////////////////////
// Ambient Term Shadowing Helpers

// Computes the ambient sky color that reaches the cloud, taking into account shadowing from cloud layers above and below
void	ComputeShadowedAmbientTerm( out float3 _AmbientSkyColorTop, out float3 _AmbientSkyColorBottom )
{
	float4	UV = float4( 0.5, 0.5, 0.0, 0.0 );

	// The shadow term is the product of all cloud layers' downsampled 1x1 environment maps' extinctions
	// Environment maps of invalid layers or not-computed yet layers are set to 1
	// This is of course invalid in the case of a software ambient estimate since environment maps are cleared to white...
	float	AmbientShadowTop = _tex2Dlod( _TexShadowEnvMapSkyTop, UV ).w;
	float	AmbientShadowBottom = _tex2Dlod( _TexShadowEnvMapSkyBottom, UV ).w;

	// The ambient sky term
	float3	AmbientSky = lerp( _tex2Dlod( _TexAmbientSky, UV ).xyz, _SoftAmbientSky.xyz, _SoftAmbientSky.w );

	// And the final shadow results
	_AmbientSkyColorTop = AmbientShadowTop * AmbientSky;
	_AmbientSkyColorBottom = AmbientShadowBottom * AmbientSky;

	// Also add night sky contribution
	_AmbientSkyColorTop += _AmbientNightSky;
//	_AmbientSkyColorBottom += _AmbientNightSky;
}


////////////////////////////////////////////////////////////////////////////////////////
// Mie phase function
float	ComputeMiePhase( float _CosTheta, float _MiePhaseAnisotropy )
{
	// Classic Henyey-Greenstein
// 	float   OneMinusG2 = 1.0 - _MiePhaseAnisotropy*_MiePhaseAnisotropy;
// 	return OneMinusG2 * pow( abs(1.0 + _MiePhaseAnisotropy*_MiePhaseAnisotropy - 2.0 * _MiePhaseAnisotropy * _CosTheta), -1.5 );

	// Cornette-Shanks
	// (from http://arxiv.org/pdf/astro-ph/0304060.pdf)
	float	Num = 1.5 * (1.0 + _CosTheta*_CosTheta) * (1.0 - _MiePhaseAnisotropy*_MiePhaseAnisotropy);
	float	Den = (2.0 + _MiePhaseAnisotropy*_MiePhaseAnisotropy) * pow( abs(1.0 + _MiePhaseAnisotropy*_MiePhaseAnisotropy - 2.0 * _MiePhaseAnisotropy * _CosTheta), 1.5 );
	return Num / Den;
}


////////////////////////////////////////////////////////////////////////////////////////
// Lightning Lighting Helpers
//
// This is the simplest and most convincing method : a stoopid point light. It doesn't simulate the entire lightning segment but is much better looking though !
float	ComputeSingleLightningIntensity( float3 _WorldPositionKm, float3 _View, float3 _L0, float3 _L1, float _Anisotropy )
{
	float3	Dp = _L0 - _WorldPositionKm;
	float	DistanceMeters = length( Dp );
			Dp /= DistanceMeters;

	float	Den = 1.0 / (1.0 - _Anisotropy * dot( Dp, _View ));
	float	Phase = (1.0 - _Anisotropy*_Anisotropy) * Den * Den;

	return INV_4PI * Phase / max( 1e-3, DistanceMeters*DistanceMeters );
}

float3	ComputeLightningColor( float3 _WorldPositionKm, float3 _View, float _Anisotropy )
{
	float	I0 = ComputeSingleLightningIntensity( _WorldPositionKm, _View, _NuajLightningPosition00, _NuajLightningPosition01, _Anisotropy );
	float	I1 = ComputeSingleLightningIntensity( _WorldPositionKm, _View, _NuajLightningPosition10, _NuajLightningPosition11, _Anisotropy );
	return _NuajLightningColor0 * I0 + _NuajLightningColor1 * I1;
}

#endif

