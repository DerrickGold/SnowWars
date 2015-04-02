// Main computation routines for volume cloud
//
#ifndef VOLUME_CLOUD_SUPPORT_INCLUDED
#define VOLUME_CLOUD_SUPPORT_INCLUDED

#include "../PlanetDataInc.cginc"
#include "../LightSupportInc.cginc"
#include "../ShadowMapInc.cginc"
#include "../LocalVariationsInc.cginc"
#include "../Sky/AerialPerspectiveComplexInc.cginc"
#include "Noise3DSupportInc.cginc"

uniform float2		_RenderTargetInvSize;
uniform float		_StepsCount;

// Cloud parameters
uniform float4		_CloudAltitudeKm;			// X=Low Altitude Y=Top Altitude Z=Thickness W=1/Thickness
uniform float		_CloudLayerIndex;

// Noise parameters
uniform float		_NoiseTiling;
uniform float3		_Coverage;					// X=Offset Y=Contrast Z=Bevel
uniform float		_CloudTraceLimiter;
uniform float2		_HorizonBlend;				// X=BlendStart Y=BlendEnd Z=BlendValue
uniform float4		_CloudPosition;				// XY=Main cloud position  ZW=Octaves position
uniform float		_FrequencyFactor;
uniform float2		_AmplitudeFactor;

// Lighting parameters
uniform float3		_CloudColor;
uniform float		_CloudSigma_t;
uniform float		_CloudSigma_s;
uniform float		_CloudSigma_s_Isotropy;
uniform float		_DirectionalFactor;
uniform float		_IsotropicFactor;

uniform float3		_IsotropicScatteringFactors;	// X=isotropic factor Y=directional factor Z=terrain reflection factor

// Phase parameters
uniform float		_PhaseAnisotropyStrongForward;
uniform float		_PhaseWeightStrongForward;
uniform float		_PhaseAnisotropyForward;
uniform float		_PhaseWeightForward;
uniform float		_PhaseAnisotropyBackward;
uniform float		_PhaseWeightBackward;

// Deep Shadow Map parameters
uniform float		_ShadowLayersCount;
uniform sampler2D	_TexDeepShadowMap0;
uniform sampler2D	_TexDeepShadowMap1;
uniform sampler2D	_TexDeepShadowMap2;

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

#define	SHADOW_BORDER_SIZE_PIXELS	3.0

// Returns 0 when UVs reach the border of the texture, 1 when UVs are within the boundary threshold, <0 if outside
// Used by the shadow map (in clamp mode) to avoid nasty patterns repeating forever...
float	BorderFade( float4 _UV )
{
	float2	UV2Border = 1.0 - abs( 2.0 * (_UV.xy - 0.5) );	// 0 at the border and 1 at the center
	float	Distance2BorderUV = min( UV2Border.x, UV2Border.y );
	float	Distance2BorderNormalized = Distance2BorderUV / (SHADOW_BORDER_SIZE_PIXELS * _RenderTargetInvSize.x);	// 1 at SHADOW_BORDER_SIZE_PIXELS from the border, 0 at the border
	return Distance2BorderNormalized;
}

// ===================================================================================
// Cloud Noise & Density Computation

// Computes the mip level at which we sample the cloud texture given the cloud and camera position
float	GetMipLevel( float3 _WorldPositionKm, float3 _CameraPosKm, float3 _SurfaceNormal )
{
	float3	ToPosition = _WorldPositionKm - _CameraPosKm;
	float	Distance2Camera = length( ToPosition );
			ToPosition /= Distance2Camera;

	float	PixelSize = (2.0 * Distance2Camera * _CameraData.y * _RenderTargetInvSize.y) / abs( dot( ToPosition, _SurfaceNormal ) );
	float	TexelSize = 16.0 * _NoiseTiling;	// Assuming a 16 pixels wide noise texture

	return max( 0.0, log2( PixelSize / TexelSize ) );
}

// Computes the mip level for environment rendering at which we sample the cloud texture given the cloud and camera position
float	GetEnvironmentMipLevel( float3 _WorldPositionKm, float3 _CameraPosKm, float3 _SurfaceNormal )
{
	float3	ToPosition = _WorldPositionKm - _CameraPosKm;
	float	Distance2Camera = length( ToPosition );
			ToPosition /= Distance2Camera;

	float	PixelSize = (Distance2Camera * _EnvironmentMapPixelSize) / abs( dot( ToPosition, _SurfaceNormal ) );
	float	TexelSize = 16.0 * _NoiseTiling;	// Assuming a 16 pixels wide noise texture

	return max( 0.0, log2( PixelSize / TexelSize ) );
}

// Converts a WORLD position into a 3D cloud volume position
//	_WorldPositionKm, the world position to convert to noise UVW
//	_HeightInCloudKm, the height in kilometers from the bottom of the cloud layer (in [0,CloudThicknessKm])
float3	World2NoiseUVW( float3 _WorldPositionKm, out float _HeightInCloudKm )
{
	float	CloudRadiusKm = _PlanetRadiusKm + _CloudAltitudeKm.x;
	float3	ToPositionKm = _WorldPositionKm - _PlanetCenterKm;
	_HeightInCloudKm = length( ToPositionKm ) - CloudRadiusKm;	// Vertical position in [0,CloudThicknessKm]

	return _WorldPositionKm.xzy * _NoiseTiling;
}

#if 0//###

//uniform float4	_DEBUGMipGruge;

// Composes 4 dynamic noise octaves and returns the noise value + top & bottom isotropic noise values
//	_HeightInCloudKm, the height in kilometers from the bottom of the cloud layer
float	GetNoise( float3 _UVW, float _MipLevel, float _HeightInCloudKm )
{
	_UVW.xy += _CloudPosition.xy;

float4	_DEBUGMipGruge = float4( 1, 0.5, 0.06125, 0 );

//float	AmplitudeFactor = _AmplitudeFactor.x;
float	AmplitudeFactor = _AmplitudeFactor.x * lerp( _DEBUGMipGruge.x, _DEBUGMipGruge.y, _DEBUGMipGruge.z * _MipLevel );//###

	// Sample octaves
	float	Value = SampleNoiseTexture( _UVW, _MipLevel );
	float	Noise = Value.x;
	float	Amplitude = AmplitudeFactor;
	_UVW *= _FrequencyFactor;
	_UVW.xy += _CloudPosition.zw;

	Value = SampleNoiseTexture( _UVW, _MipLevel );
	Noise += Amplitude * Value.x;
	Amplitude *= AmplitudeFactor;
	_UVW *= _FrequencyFactor;
	_UVW.xy += _CloudPosition.zw;

	Value = SampleNoiseTexture( _UVW, _MipLevel );
	Noise += Amplitude * Value.x;
	Amplitude *= AmplitudeFactor;
	_UVW *= _FrequencyFactor;
	_UVW.xy += _CloudPosition.zw;

	Value = SampleNoiseTexture( _UVW, _MipLevel );
	Noise += Amplitude * Value.x;

	return _AmplitudeFactor.y * Noise;	// Normalize octaves
}

#else

// Composes 4 dynamic noise octaves and returns the noise value + top & bottom isotropic noise values
//	_HeightInCloudKm, the height in kilometers from the bottom of the cloud layer
float	GetNoise( float3 _UVW, float _MipLevel, float _HeightInCloudKm )
{
	// Sample octaves
	_UVW.xy += _CloudPosition.xy;

	float	Value = SampleNoiseTexture( _UVW, _MipLevel );
	float	Noise = Value.x;
	float	Amplitude = _AmplitudeFactor.x;
	_UVW *= _FrequencyFactor;
	_UVW.xy += _CloudPosition.zw;

	Value = SampleNoiseTexture( _UVW, _MipLevel );
	Noise += Amplitude * Value.x;
	Amplitude *= _AmplitudeFactor.x;
	_UVW *= _FrequencyFactor;
	_UVW.xy += _CloudPosition.zw;

	Value = SampleNoiseTexture( _UVW, _MipLevel );
	Noise += Amplitude * Value.x;
	Amplitude *= _AmplitudeFactor.x;
	_UVW *= _FrequencyFactor;
	_UVW.xy += _CloudPosition.zw;

	Value = SampleNoiseTexture( _UVW, _MipLevel );
	Noise += Amplitude * Value.x;

	return _AmplitudeFactor.y * Noise;	// Normalize octaves
}
#endif


// Bevels the noise values so the clouds completely disappear at top and bottom
//	_HeightInCloudKm, the height in kilometers from the bottom of the cloud layer
float	BevelCloud( float _HeightInCloudKm )
{
	return 1.0 - saturate( _Coverage.z * abs( 2.0 * _HeightInCloudKm * _CloudAltitudeKm.w - 1.0 ) );
}

// Blends the cloud with the horizon
// Returns 1 (unaffected) if before start blending threshold and 0 if after end blending threhsold
float	HorizonBlend( float _Distance2CameraKm )
{
	return smoothstep( _HorizonBlend.y, _HorizonBlend.x, _Distance2CameraKm );
}

// Computes the density and traversed optical depth at current position within the cloud
// Returns _HeightInCloudKm, the height in kilometers from the bottom of the cloud layer
//
float	ComputeCloudDensity( float4 _WorldPositionKm, float _LocalCoverage, float _MipLevel, out float _HeightInCloudKm )
{
	float3	UVW = World2NoiseUVW( _WorldPositionKm.xyz, _HeightInCloudKm );
	float	Noise = GetNoise( UVW, _MipLevel, _HeightInCloudKm ) + _Coverage.x;

	float	CloudDensity = saturate( _Coverage.y * Noise );
			CloudDensity *= BevelCloud( _HeightInCloudKm );
			CloudDensity *= _LocalCoverage;
		 	CloudDensity *= HorizonBlend( _WorldPositionKm.w );

	return CloudDensity;	
}

// ===================================================================================
// Computes the extinction at current position within the cloud
//	_HeightInCloudKm, the height in kilometers from the bottom of the cloud layer
//
#ifndef ENVIRONMENT_RENDERING
float	ComputeCloudSelfShadowing( float3 _WorldPositionKm, float _HeightInCloudKm )
{
	float4	ShadowMapUV = float4( WorldPosition2Shadow( _WorldPositionKm ), 0.0, 0.0 );

	// Sample the appropriate slice
	float	NormalizedAltitude = 1.0 - saturate( _HeightInCloudKm * _CloudAltitudeKm.w );
	float	SliceIndex = _ShadowLayersCount * NormalizedAltitude;

	float4	OpticalDepthValues = 1.0;
	if ( SliceIndex > 8.0 )
	{	// Sample 3rd slice
		SliceIndex -= 8.0;
		OpticalDepthValues = _tex2Dlod( _TexDeepShadowMap2, ShadowMapUV );
	}
	else if ( SliceIndex > 4.0 )
	{	// Sample 2nd slice
		SliceIndex -= 4.0;
		OpticalDepthValues = _tex2Dlod( _TexDeepShadowMap1, ShadowMapUV );
	}
	else
	{	// Sample 1st slice
		OpticalDepthValues = _tex2Dlod( _TexDeepShadowMap0, ShadowMapUV );
	}

	// We now have SliceIndex in [0,4[
	// We need to interpolate the correct values
	float3	Sup = step( float3( 1.0, 2.0, 3.0 ), SliceIndex.xxx );
	float3	Inf = 1.0 - Sup;
	float4	IsSlice = float4( Inf.x, Sup.x * Inf.y, Sup.y * Inf.z, Sup.z );

	float	Top = dot( IsSlice, OpticalDepthValues.xyzw );
	float	Bottom = dot( IsSlice, OpticalDepthValues.yzww );
	return exp( -lerp( Top, Bottom, frac(SliceIndex) ) );
}
#else
float	ComputeCloudSelfShadowing( float4 _UV, float _Distance2CameraKm, float _HeightInCloudKm )
{
	// Sample the appropriate slice
	float	NormalizedAltitude = 1.0 - saturate( _HeightInCloudKm * _CloudAltitudeKm.w );
	float	SliceIndex = 4.0 * NormalizedAltitude;

	float4	OpticalDepthValues = _tex2Dlod( _TexDeepShadowMap0, _UV );

	// We now have SliceIndex in [0,4[
	// We need to interpolate the correct values
	float3	Sup = step( float3( 1.0, 2.0, 3.0 ), SliceIndex.xxx );
	float3	Inf = 1.0 - Sup;
	float4	IsSlice = float4( Inf.x, Sup.x * Inf.y, Sup.y * Inf.z, Sup.z );

	float	Top = dot( IsSlice, OpticalDepthValues.xyzw );
	float	Bottom = dot( IsSlice, OpticalDepthValues.yzww );
	return exp( -lerp( Top, Bottom, frac(SliceIndex) ) );
}
#endif

// ===================================================================================
// Exponential Integral (http://en.wikipedia.org/wiki/Exponential_integral)
float	Ei( float z )
{
 	return 0.5772156649015328606065 + log( 1e-6 + abs(z) ) + z * (1.0 + z * (0.25 + z * ( (1.0/18.0) + z * ( (1.0/96.0) + z * (1.0/600.0) ) ) ) );		// For x!=0
}

// ===================================================================================
// Computes scattering from a single step in the cloud
// The computation is paramount to good looking rendering of clouds
// The idea that I finally adopted here is to assume light from top and bottom scatters through a uniform homogeneous infinite slab of cloud material.
// The integral to solve for a slab of height H is:
// 
//		I(x) = 2PI * Integral[0,PI/2]( L(x,theta) * exp( -Sigma_s * H / cos(theta) ) * sin(theta) * dtheta )
//
// Which fortunately has a solution:
//	
//		I(x) = 2PI * [-Sigma_s * H * Ei( -Sigma_s * H / cos(theta) ) - cos(theta) * exp( -Sigma_s * H / cos(theta) )][solve for 0,PI/2]
//		I(x) = 2PI * [Sigma_s * H * Ei( -Sigma_s * H ) + exp( -Sigma_s * H )]
//
// Ei(x) being the exponential integral (http://en.wikipedia.org/wiki/Exponential_integral)
//
//
//	_DirectionalLight, the Sun's color attenuated through cloud
//	_SkyAmbient, the ambient sky color, not attenuated
//	_Density, the cloud density for the current step
//	_CloudExtinction, the extinction of light travelling in the Sun's direction
//	_PhaseDirect, the phase function for direct light
//	_PhaseIsotropic, the phase function for isotropic light
//
float3	ComputeSingleStepScattering( float3 _WorldPositionKm, float3 _View, float _StepSizeKm, float3 _DirectionalLight, float3 _SkyAmbientTop, float3 _SkyAmbientBottom, float _Density, float _HeightKm, float _PhaseDirect, float _DotEarthSun, float4 _TerrainEmissive )
{
	float	IsotropicSphereRadiusTopKm = _CloudAltitudeKm.z - _HeightKm;
	float	IsotropicSphereRadiusBottomKm = _HeightKm;

	float3	TerrainColor = _TerrainEmissive.w * _TerrainReflectedLight * saturate( _DotEarthSun )	// Diffuse reflection of Sun & Sky on terrain
						 + _TerrainEmissive.xyz;					// Emissive terrain color

	// =============================================
	// Compute top/bottom light sources
	float3  IsotropicLightTop  = _IsotropicScatteringFactors.x * _SkyAmbientTop;
			IsotropicLightTop += _IsotropicScatteringFactors.y * _DirectionalLight;

	float3	IsotropicLightBottom  = _IsotropicScatteringFactors.x * _SkyAmbientBottom;
			IsotropicLightBottom += _IsotropicScatteringFactors.z * TerrainColor;


	// =============================================
	// Compute an approximate isotropic diffusion through an infinite slab
	float	a = -_CloudSigma_s_Isotropy * IsotropicSphereRadiusTopKm;
	float3  IsotropicScatteringTop = IsotropicLightTop * max( 0.0, exp( a ) - a * Ei( a ));

			a = -_CloudSigma_s_Isotropy * IsotropicSphereRadiusBottomKm;
	float3  IsotropicScatteringBottom = IsotropicLightBottom * max( 0.0, exp( a ) - a * Ei( a ));
	float3  IsotropicScattering = _Density * (IsotropicScatteringTop + IsotropicScatteringBottom);


	// =============================================
	// Compute the direct lighting component
	float3	DirectSource = _DirectionalLight * _PhaseDirect;
	float3	LightningSource = ComputeLightningColor( _WorldPositionKm.xyz, _View, _MiePhaseAnisotropy );
	float3  DirectionalScattering = _Density * _CloudSigma_s * (DirectSource + LightningSource);


	// =============================================
	// Compute final result
	return _DirectionalFactor * DirectionalScattering + _IsotropicFactor * IsotropicScattering;
}

// ===================================================================================
// Actual cloud lighting computation
float4	ComputeCloudLighting( float3 _CameraPosKm, float3 _View, float2 _HitDistancesKm, float2 _EarthShadowDistancesKm, float3 _SkyAmbientTop, float3 _SkyAmbientBottom, float3 _SunColor, float _MipLevel, float4 _UV, float _StepsCount )
{
	// STOOPID ATI FIX!
	if ( _StepsCount < 1.0 )
		_StepsCount = 1.0;
	// STOOPID ATI FIX!

	float	InvStepsCount = 1.0 / (_StepsCount+1.0);	// Count one more step since we start from half a step in, and end at 1-half a step out

	float	DotEarthSun = dot( _PlanetNormal, _SunDirection );

	// Compute light phases
  	float	CosTheta = dot( _View, _SunDirection );
	float	PhaseStrongForward = ComputeMiePhase( CosTheta, _PhaseAnisotropyStrongForward );						// Strong forward phase
	float	PhaseForward = ComputeMiePhase( CosTheta, _PhaseAnisotropyForward );									// Forward phase
	float	PhaseBackward = ComputeMiePhase( CosTheta, _PhaseAnisotropyBackward );									// Backward phase
	float   PhaseDirect = _PhaseWeightStrongForward * PhaseStrongForward + _PhaseWeightForward * PhaseForward + _PhaseWeightBackward * PhaseBackward;	// Direct lighting phase is the weighted sum of all these


	// Compute local coverage and terrain emissive
	float3	ProbePositionKm = _CameraPosKm + 0.5 * (_HitDistancesKm.x + _HitDistancesKm.y) * _View;
	float4	TerrainEmissive = GetTerrainEmissive( ProbePositionKm );
	float	LocalCoverage = GetLocalCoverage( ProbePositionKm, _CloudLayerIndex );

	// Compute dummy density increase based on angle with cloud layer
	float	DensityInterpolant = smoothstep( 0.1, 0.0, abs( dot( _View, _PlanetNormal ) ) );						// Density is at its full when viewing horizontally
			DensityInterpolant = saturate( DensityInterpolant * 0.0125 * _HitDistancesKm.x );						// ...and when viewing a far pixel

	// Compute step size
	float	StepSizeKm = (_HitDistancesKm.y - _HitDistancesKm.x) * InvStepsCount;
	float	InvStepSizeKm = 1.0 / StepSizeKm;
	float4	StepKm = StepSizeKm * float4( _View, 1.0 );
	float4	WorldPositionKm = float4( _CameraPosKm + _HitDistancesKm.x * _View, _HitDistancesKm.x );				// Start from Entry Distance
			WorldPositionKm += 0.5 * StepKm;	// and add half a step

	// Start tracing
	float3	Scattering = 0.0;
	float3	Extinction = 1.0;

	for ( float StepIndex=0.0; StepIndex < _StepsCount; StepIndex++ )
	{
		// =============================================
		// Sample cloud density at current altitude, and optical depth in Sun direction from the deep shadow map
		float	HeightKm;
		float	Rho_cloud = ComputeCloudDensity( WorldPositionKm, LocalCoverage, _MipLevel, HeightKm );
#ifndef ENVIRONMENT_RENDERING
		float	Extinction_cloud = ComputeCloudSelfShadowing( WorldPositionKm.xyz, HeightKm );
#else
		float	Extinction_cloud = ComputeCloudSelfShadowing( _UV, WorldPositionKm.w, HeightKm );
#endif

		// =============================================
		// Retrieve sun light attenuated when passing through the atmosphere & cloud
		float	EarthShadow = IsInShadow( WorldPositionKm.w, WorldPositionKm.w + StepKm.w, InvStepSizeKm, _EarthShadowDistancesKm );
		float3	DirectionalLight = Extinction_cloud * EarthShadow * _SunColor;

		// =============================================
		// Invent a scattered light based on traversed cloud depth
 		// The more light goes through cloud matter, the more it's scattered within the cloud but too much matter and it goes back to zero (log normal behavior)
		float3	StepScattering = ComputeSingleStepScattering( WorldPositionKm.xyz, _View, StepSizeKm, DirectionalLight, _SkyAmbientTop, _SkyAmbientBottom, Rho_cloud, HeightKm, PhaseDirect, DotEarthSun, TerrainEmissive );

		// =============================================
		// Accumulate in-scattered light with extinction along the ray
		Scattering += StepScattering * StepSizeKm * Extinction;

		// =============================================
		// Accumulate extinction along the ray
		float3	CurrentExtinctionCoefficient = _CloudSigma_t * Rho_cloud;
		Extinction *= exp( -CurrentExtinctionCoefficient * StepSizeKm );

		// =============================================
		// March one step
		WorldPositionKm += StepKm;
	}

	return float4( _CloudColor * Scattering, dot(Extinction,LUMINANCE) );
}

// Directly called by the PS for shadow computation
float	ComputeCloudShadow( PS_IN _In )
{
	float	OpticalDepth = 0.0;
	if ( _ShadowLayersCount <= 4.0 )
		OpticalDepth = _tex2Dlod( _TexDeepShadowMap0, _In.UV ).w;
	else if ( _ShadowLayersCount <= 8.0 )
		OpticalDepth = _tex2Dlod( _TexDeepShadowMap1, _In.UV ).w;
	else //if ( _ShadowLayersCount <= 12.0 )
		OpticalDepth = _tex2Dlod( _TexDeepShadowMap2, _In.UV ).w;

	return exp( -OpticalDepth );
}

// Directly called by the PS for cloud computation
float4	ComputeCloudColor( PS_IN_AMBIENT_SUN _In, float Z )
{
	// Sample Sun & Sky colors
	float3	SkyAmbientTop, SkyAmbientBottom;
	ComputeShadowedAmbientTerm( SkyAmbientTop, SkyAmbientBottom );
	float3	SunColor = ComputeSunExtinction( _PlanetRadiusKm + _CloudAltitudeKm.y );	// Get sun color at the top of the cloud

	// Build position/view
	float3	CameraPositionKm, View;
	float	Depth2Distance;
	ComputeCameraPositionViewKm( _In.UV.xy, CameraPositionKm, View, Depth2Distance );

	// Compute scene distance
	float	PlanetHitDistanceKm = ComputeSphereEnterIntersection( CameraPositionKm, View, _PlanetCenterKm, _PlanetRadiusKm + _PlanetRadiusOffsetKm );
			PlanetHitDistanceKm = lerp( PlanetHitDistanceKm, INFINITY, saturate( -10000.0 * PlanetHitDistanceKm ) );	// If looking up, discard hit...
	float	ZBufferDistanceKm = Z * Depth2Distance * _WorldUnit2Kilometer;	// Scene distance from the Z buffer
	float	SceneDistanceKm = lerp( ZBufferDistanceKm, PlanetHitDistanceKm, StepInfinity( Z ) );	// Either planet hit or scene hit

	// Compute cloud distance
	float	CloudRadiusBottomKm = _PlanetRadiusKm + _CloudAltitudeKm.x;
	float2	CloudHitDistanceBottomKm = ComputeBothSphereIntersections( CameraPositionKm, View, _PlanetCenterKm, CloudRadiusBottomKm );
	float	CloudRadiusTopKm = _PlanetRadiusKm + _CloudAltitudeKm.y;
	float2	CloudHitDistanceTopKm = ComputeBothSphereIntersections( CameraPositionKm, View, _PlanetCenterKm, CloudRadiusTopKm );

	// Order min/max
	float3	Center2Camera = CameraPositionKm - _PlanetCenterKm;
	float	CameraRadiusKm = length( Center2Camera );
			Center2Camera /= CameraRadiusKm;
	float2	CloudHitDistancesKm;
	if ( CameraRadiusKm < CloudRadiusBottomKm )
	{	// Below
		CloudHitDistancesKm = float2( CloudHitDistanceBottomKm.y, CloudHitDistanceTopKm.y );	// View up
	}
	else if ( CameraRadiusKm > CloudRadiusTopKm )
	{	// Above
		if ( CloudHitDistanceBottomKm.x < HALF_INFINITY )
			CloudHitDistancesKm = float2( CloudHitDistanceTopKm.x, CloudHitDistanceBottomKm.x );
		else
			CloudHitDistancesKm = float2( 0.0, -1.0 );	// No hit
	}
	else
	{	// Inside
		if ( CloudHitDistanceBottomKm.x < 0.0 )
			CloudHitDistancesKm = float2( 0.0, CloudHitDistanceTopKm.y );		// We hit top cloud first
		else
			CloudHitDistancesKm = float2( 0.0, CloudHitDistanceBottomKm.x );	// We hit bottom cloud first
	}

	CloudHitDistancesKm.x = max( 0.0, CloudHitDistancesKm.x );					// Don't start before camera position
	CloudHitDistancesKm.y = min( SceneDistanceKm, CloudHitDistancesKm.y );		// Don't end after scene position
	if ( CloudHitDistancesKm.x > CloudHitDistancesKm.y )//|| CloudHitDistancesKm.x > _CloudFadeDistancesKm.y )
		return float4( 0.0, 0.0, 0.0, 1.0 );				// Above that layer or not looking at it?

	// Limit trace distance for inside the clouds
	// Given coverage, density and steps count, we decide on an approximate "max distance" we can see
	// We use 1/Sigma_t to determine a mean free path and also use the coverage to increase the mean free path in case the cloud coverage is low
	float	MeanFreePathKm = _CloudTraceLimiter * (1.0 + CloudHitDistancesKm.x) / (_CloudSigma_t * lerp( 1.0, 0.025, smoothstep( -0.2, -0.6, _Coverage.x )));
	CloudHitDistancesKm.y = min( CloudHitDistancesKm.y, CloudHitDistancesKm.x + MeanFreePathKm );


	// Compute potential intersection with earth's shadow
	float2	EarthShadowDistancesKm = ComputePlanetShadow( CameraPositionKm, View, _SunDirection );

	// Compute mip level at hit position
	float3	HitPositionCloudKm = CameraPositionKm + CloudHitDistancesKm.x * View;
	float	MipLevel = GetMipLevel( HitPositionCloudKm, CameraPositionKm, _PlanetNormal );

	// Render the cloud
	float4	CloudColor = ComputeCloudLighting( CameraPositionKm, View, CloudHitDistancesKm, EarthShadowDistancesKm, SkyAmbientTop, SkyAmbientBottom, SunColor, MipLevel, _In.UV, _StepsCount );

	// Modulate color by sky extinction
	CloudColor.xyz *= ComputeSkyExtinctionSimple( float2( CameraRadiusKm, length( HitPositionCloudKm - _PlanetCenterKm ) ), CloudHitDistancesKm.x );

	return CloudColor;
}

#endif

