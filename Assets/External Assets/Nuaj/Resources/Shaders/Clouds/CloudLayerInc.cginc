// Main computation routines for cloud layers
//
#ifndef CLOUD_SUPPORT_INCLUDED
#define CLOUD_SUPPORT_INCLUDED

#include "../PlanetDataInc.cginc"
#include "../LightSupportInc.cginc"
#include "../ShadowMapInc.cginc"
#include "../LocalVariationsInc.cginc"
#include "../Sky/AerialPerspectiveComplexInc.cginc"

uniform float2		_RenderTargetInvSize;

// Cloud parameters
uniform float4		_CloudAltitudeKm;			// X=Low Altitude Y=Top Altitude Z=Thickness W=1/Thickness
uniform float		_CloudLayerIndex;

// Noise parameters
uniform float		_Coverage;
uniform float		_NoiseTiling;
uniform float		_NoiseOctavesCount;
uniform float4		_CloudPosition;				// XY=Main cloud position  ZW=Octaves position
uniform float2		_FrequencyFactor;
uniform float4		_AmplitudeFactor;
uniform float		_Smoothness;
uniform float		_NormalAmplitude;
uniform sampler2D	_TexNoise0;
uniform sampler2D	_TexNoise1;
uniform sampler2D	_TexNoise2;
uniform sampler2D	_TexNoise3;

// Lighting parameters
uniform sampler2D	_TexPhaseMie;
uniform float		_ScatteringCoeff;
uniform float3		_CloudColor;

uniform float4		_ScatteringFactors;
uniform float		_ScatteringSkyFactor;
uniform float		_ScatteringTerrainFactor;

// ===================================================================================
// Special vertex shader that computes the ambient Sky and Sun color arriving at cloud

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
// Cloud Noise Computation

// Computes the mip level at which we sample the cloud texture given the cloud and camera position
float	GetMipLevel( float3 _WorldPositionKm, float3 _CameraPosKm, float3 _SurfaceNormal )
{
	float3	ToPosition = _WorldPositionKm - _CameraPosKm;
	float	Distance2Camera = length( ToPosition );
			ToPosition /= Distance2Camera;

	float	PixelSize = (2.0 * Distance2Camera * _CameraData.y * _RenderTargetInvSize.y) / abs( dot( ToPosition, _SurfaceNormal ) );
	float	TexelSize = 512.0 * _NoiseTiling;	// Assuming a 512 pixels wide noise texture

	return _Smoothness + log2( PixelSize / TexelSize );
}

// Computes the mip level for environment rendering at which we sample the cloud texture given the cloud and camera position
float	GetEnvironmentMipLevel( float3 _WorldPositionKm, float3 _CameraPosKm, float3 _SurfaceNormal )
{
	float3	ToPosition = _WorldPositionKm - _CameraPosKm;
	float	Distance2Camera = length( ToPosition );
			ToPosition /= Distance2Camera;

	float	PixelSize = (Distance2Camera * _EnvironmentMapPixelSize) / abs( dot( ToPosition, _SurfaceNormal ) );
	float	TexelSize = 512.0 * _NoiseTiling;	// Assuming a 512 pixels wide noise texture

	return _Smoothness + log2( PixelSize / TexelSize );
}

float	Asin_DL( float x )
{
	if ( x < 0.5f )
	{
		float	x2 = x*x;
		float	x3 = x*x2;
		float	x5 = x3*x2;
		return x + 0.16666666666666666666666666666667 * x3 + 0.075 * x5;
	}
	else
	{
		x = sqrt( 1.0f - x*x );
		float	x2 = x*x;
		float	x3 = x*x2;
		float	x5 = x3*x2;
		return HALF_PI - (x + 0.16666666666666666666666666666667 * x3 + 0.075 * x5);
	}
}

float	Acos_DL( float x )
{
	return HALF_PI - Asin_DL( x );
}

// Converts a WORLD position into a 2D cloud surface position
float2	World2Surface( float3 _WorldPositionKm )
{
	float3	ToPositionKm = _WorldPositionKm - _PlanetCenterKm;
	float2	SurfacePositionKm = float2( dot( ToPositionKm, _PlanetTangent ), dot( ToPositionKm, _PlanetBiTangent ) );

// Project to tangent plane
// 	float	CloudRadiusKm = _PlanetRadiusKm + _CloudAltitudeKm.x;
// 	float3	ToPositionKm = (_WorldPositionKm - _PlanetCenterKm) / CloudRadiusKm;
// 	float	CosAngle = dot( ToPositionKm, _PlanetNormal );
// 	float	DistanceFactor = CloudRadiusKm * Acos_DL( CosAngle );
// 	float2	SurfacePositionKm = DistanceFactor * float2( dot( ToPositionKm, _PlanetTangent ), dot( ToPositionKm, _PlanetBiTangent ) );

// Project to sphere with acos
// 	float	CloudRadiusKm = _PlanetRadiusKm + _CloudAltitudeKm.x;
// 	float3	ToPositionKm = _WorldPositionKm - _PlanetCenterKm;
// 	float	CosAngle = dot( ToPositionKm / CloudRadiusKm, _PlanetNormal );
// 	float	DistanceFactor = 1.0 / CosAngle;
// 	float2	SurfacePositionKm = DistanceFactor * float2( dot( ToPositionKm, _PlanetTangent ), dot( ToPositionKm, _PlanetBiTangent ) );

	SurfacePositionKm *= _NoiseTiling;

	return SurfacePositionKm;
}

// Dynamic 2D version (4 octaves)
float	GetNoise2D( float3 _WorldPositionKm, float _MipLevel, out float3 _Normal )
{
	float4	UV = float4( World2Surface( _WorldPositionKm ), 0.0, _MipLevel );
	float	Amplitude = 1.0;

	UV.xy += _CloudPosition.xy;

	float4	Value = _tex2Dlod( _TexNoise0, UV );
	float	Noise = Value.w;
	_Normal = 2.0 * Value.xyz - 1.0;

	if ( _NoiseOctavesCount < 2 )
		return Noise;						// 1 octave

	Amplitude *= _AmplitudeFactor.x;
	UV.xy *= _FrequencyFactor;
	UV.xy += _CloudPosition.zw;
	Value = _tex2Dlod( _TexNoise1, UV );
	Noise += Amplitude * Value.w;
	_Normal += Amplitude * (2.0 * Value.xyz - 1.0);

 	if ( _NoiseOctavesCount < 3 )
 		return _AmplitudeFactor.y * Noise;	// 2 octaves

	Amplitude *= _AmplitudeFactor.x;
	UV.xy *= _FrequencyFactor;
	UV.xy += _CloudPosition.zw;
	Value = _tex2Dlod( _TexNoise2, UV );
	Noise += Amplitude * Value.w;
	_Normal += Amplitude * (2.0 * Value.xyz - 1.0);

 	if ( _NoiseOctavesCount < 4 )
 		return _AmplitudeFactor.z * Noise;	// 3 octaves

	Amplitude *= _AmplitudeFactor.x;
	UV.xy *= _FrequencyFactor;
	UV.xy += _CloudPosition.zw;
	Value = _tex2Dlod( _TexNoise3, UV );
	Noise += Amplitude * Value.w;
	_Normal += Amplitude * (2.0 * Value.xyz - 1.0);

	return _AmplitudeFactor.w * Noise;		// 4 octaves
}

float	ComputeCloudDensity( float3 _WorldPositionKm, float _LocalCoverage, float _MipLevel, out float3 _Normal )
{
	float	N = saturate( _LocalCoverage * (GetNoise2D( _WorldPositionKm, _MipLevel, _Normal ) + _Coverage - 0.5) );
	return N*N;
}

// Computes the thickness and normal of the cloud layer at given position
//
float	ComputeCloudThicknessKm( float3 _WorldPositionKm, float _LocalCoverage, float _MipLevel, out float3 _CloudNormalWorld )
{
	float3	CloudNormalTS;
	float	ThicknessKm = _CloudAltitudeKm.z * ComputeCloudDensity( _WorldPositionKm, _LocalCoverage, _MipLevel, CloudNormalTS );

	// Normalize normal and transform into WORLD space
	CloudNormalTS = normalize( float3( _NormalAmplitude.xx, 1.0 ) * CloudNormalTS );

	float3	CloudSphereNormal = (_WorldPositionKm - _PlanetCenterKm) / (_PlanetRadiusKm + _CloudAltitudeKm.x);
	_CloudNormalWorld = -CloudNormalTS.x * _PlanetTangent + CloudNormalTS.z * CloudSphereNormal + CloudNormalTS.y * _PlanetBiTangent;

	return ThicknessKm;
}

// Gets the phase and the convolved phase
float2	GetPhase( float _DotVL )
{
	float	CosTheta = 0.5 * (1.0 - _DotVL);
	float4	Phase = _tex2Dlod( _TexPhaseMie, float4( CosTheta, 0.5, 0.0, 0.0 ) );	// XY=Phase*65536 ZW=PhaseConvolved*65536
	return float2( Phase.x + Phase.y * INV256, Phase.z + Phase.w * INV256 );
}

// Computes the actual scattering and extinction of the cloud
//
float4	ComputeCloudLighting( float3 _WorldPositionKm, float3 _CameraPosKm, float3 _View, float3 _SkyAmbientTop, float3 _SkyAmbientBottom, float3 _SunColor, float _MipLevel )
{
	// Compute local coverage and terrain emissive
	float4	TerrainEmissive = GetTerrainEmissive( _WorldPositionKm );
	float	LocalCoverage = GetLocalCoverage( _WorldPositionKm, _CloudLayerIndex );

	// Retrieve cloud thickness and normal
	float3	CloudSphereNormal = (_WorldPositionKm - _PlanetCenterKm) / (_PlanetRadiusKm + _CloudAltitudeKm.x);
	float3	Normal;
	float	H = ComputeCloudThicknessKm( _WorldPositionKm, LocalCoverage, _MipLevel, Normal );

	float	DotEarthSun = dot( CloudSphereNormal, _SunDirection );
	float	DotV = abs( dot( _View, Normal ) );
	float	DotL = dot( _SunDirection, Normal );
	float	DotVL = dot( _SunDirection, _View );
	float	Hv = H / max( 0.01, DotV );
	float	Hl = H / max( 0.01, abs( DotL ) );

	float2	TempPhase = INV_4PI * GetPhase( DotVL );
	float	Phase = TempPhase.x;
	float	Phase2 = TempPhase.y;

	float	Kappa_sc = _ScatteringCoeff;
	
	// Compute extinction
	float3	Extinction = exp( -Kappa_sc * H / max( 0.01, DotV ) );

	// Compute 0-scattering (narrow forward peak)
	float	KappaS_sc = _ScatteringCoeff;
	float	Hl0 = H / max( 0.01, DotL );
	float3	I0 = _ScatteringFactors.x * Hl0 * KappaS_sc * exp( -KappaS_sc * Hl0 ) * pow( 0.5 * Phase, KappaS_sc * Hv );	// Narrow forward scattering

	// Compute first-order scattering (analytical)
	float3	ExpHv = exp( -Kappa_sc * Hv );
	float3	ExpHl = exp( -Kappa_sc * Hl );
	float3	ExpHVmL = (ExpHv - ExpHl) * DotL / (DotV - DotL);
	float3	ExpHVpL = (1.0 - ExpHv * ExpHl) * -DotL / max( 0.01, -DotL + DotV );
	float3	Common = _ScatteringFactors.y * Kappa_sc * Phase;
	float3	I1t = max( 0.0.xxx, Common * ExpHVmL );
 	float3	I1r = max( 0.0.xxx, Common * ExpHVpL );

	// Compute second-order scattering (analytical)
			Common = _ScatteringFactors.z * Kappa_sc * Kappa_sc * Phase2;
	float3	I2t = max( 0.0.xxx, Common * ExpHVmL );
 	float3	I2r = max( 0.0.xxx, Common * ExpHVpL );

	// Compute multiple scattering (diffuse approximation)
	float3	Tau_c = exp( -Kappa_sc * H );
			Common = H * Kappa_sc;
	float3	Tms = Common * Tau_c * saturate( DotL );
	float3	Rms = Common * (1.0 - Tau_c) * saturate( -DotL );
	float3	I3t = max( 0.0.xxx, _ScatteringFactors.w * Tms * 0.07957747154594766788444188168626 * DotL / max( 0.01, DotV ) );
 	float3	I3r = max( 0.0.xxx, _ScatteringFactors.w * Rms * 0.07957747154594766788444188168626 * -DotL / max( 0.01, DotV ) );

	// Compute reflection by terrain
	float3	TerrainColor = TerrainEmissive.w * _TerrainReflectedLight * saturate( DotEarthSun )	// Diffuse reflection of Sun & Sky on terrain
						 + TerrainEmissive.xyz;	// Emissive terrain color

	// Compute lighting by lightning
	float3	LightningColor = Hv * Kappa_sc * ComputeLightningColor( _WorldPositionKm, _View, _MiePhaseAnisotropy ) * ExpHv;

	// Compute shadow at position
	float	Shadow = GetShadowAtPosition( _WorldPositionKm, _PlanetRadiusKm + _CloudAltitudeKm.y );

	// Build final colors
	float3	TransmissionColor = Shadow * _SunColor * (I0+I1t+I2t+I3t) + _ScatteringSkyFactor * Tms * _SkyAmbientTop + LightningColor + _ScatteringTerrainFactor * Rms * TerrainColor;
	float3	ReflectionColor = Shadow * _SunColor * (I1r+I2r+I3r) + _ScatteringSkyFactor * Rms * _SkyAmbientBottom + LightningColor;

	return float4( _CloudColor * (TransmissionColor + ReflectionColor), dot(Extinction,LUMINANCE) );
}

float4	ComputeCloudShadow( PS_IN _In )
{
 	// Compute position on cloud layer in WORLD space
	float3	CloudPositionKm = Shadow2CloudPosition( _In.UV.xy, _PlanetRadiusKm + _CloudAltitudeKm.x );

	// Get local coverage
	float	LocalCoverage = GetLocalCoverage( CloudPositionKm, _CloudLayerIndex );

	// Compute layer thickness at position
	float3	Normal;
	float	H = ComputeCloudThicknessKm( CloudPositionKm, LocalCoverage, _Smoothness, Normal );
 	float	DotL = dot( _SunDirection, Normal );
 	float	Hl = H / max( 0.01, DotL );

	// Return extinction through layer
	return exp( -_ScatteringCoeff * Hl );
}

#endif

