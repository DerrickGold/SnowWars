// Common header to tone mapping shaders
//
#ifndef TONE_MAPPING_SUPPORT_INCLUDED
#define TONE_MAPPING_SUPPORT_INCLUDED

uniform sampler2D	_MainTex;
uniform sampler2D	_TexScattering;
uniform float3		_ToneMappingLuminance;
uniform float		_ToneMappingBoostFactor;

// Gamma correction
uniform float		_Gamma;

// Glow support
uniform float		_GlowSupport;
uniform float		_GlowUseMax;
uniform float2		_GlowIntensityThreshold;

// uniform sampler2D	_DEBUGTexLuminance0;
// uniform sampler2D	_DEBUGTexLuminance1;
// uniform sampler2D	_DEBUGTexLuminance2;
// uniform sampler2D	_DEBUGTexLuminance3;
// uniform sampler2D	_DEBUGTexLuminance4;
// uniform sampler2D	_DEBUGTexLuminance5;
// uniform sampler2D	_DEBUGTexLuminance6;
// uniform sampler2D	_DEBUGTexLuminance7;
// uniform sampler2D	_DEBUGTexLuminance8;
// uniform sampler2D	_DEBUGTexLuminance9;
// uniform sampler2D	_DEBUGTexPrecisionTest128x128;
// uniform sampler2D	_DEBUGTexPrecisionTest256;
// 
// uniform sampler2D	_DEBUGSkyEnvMapMip0;
// uniform sampler2D	_DEBUGSkyEnvMapMip1;
// uniform sampler2D	_DEBUGSkyEnvMapMip2;
// uniform sampler2D	_DEBUGSkyEnvMapMip3;
// uniform sampler2D	_DEBUGSkyEnvMapMip4;
// uniform sampler2D	_DEBUGLayerSkyEnvMapDownsampled0;
// uniform sampler2D	_DEBUGLayerSkyEnvMapDownsampled1;
// uniform sampler2D	_DEBUGLayerSkyEnvMapDownsampled2;
// uniform sampler2D	_DEBUGLayerSkyEnvMapDownsampled3;
// uniform sampler2D	_DEBUGTexDensity;
// 
// uniform sampler2D	_DEBUGLayerCloud0;
// uniform sampler2D	_DEBUGLayerCloud1;
// uniform sampler2D	_DEBUGLayerCloud2;
// uniform sampler2D	_DEBUGLayerCloud3;
// 
// uniform sampler2D	_DEBUGLayerSkyEnvMap0;
// uniform sampler2D	_DEBUGLayerSkyEnvMap1;
// uniform sampler2D	_DEBUGLayerSkyEnvMap2;
// uniform sampler2D	_DEBUGLayerSkyEnvMap3;
// uniform sampler2D	_DEBUGLayerEnvSun0;
// uniform sampler2D	_DEBUGLayerEnvSun1;
// uniform sampler2D	_DEBUGLayerEnvSun2;
// uniform sampler2D	_DEBUGLayerEnvSun3;
// 
// uniform sampler2D	_DEBUGTexShadowMap;
// uniform sampler2D	_DEBUGTexLightCookie;
// uniform sampler2D	_DEBUGTexCloudVolume;
// uniform sampler2D	_DEBUGTexCloudLayer;
// uniform sampler2D	_DEBUGTexFogLayer;
// uniform sampler2D	_DEBUGTexSky;
// uniform sampler2D	_DEBUGTexBackground;
// uniform sampler2D	_DEBUGTexBackgroundEnvironment;
// uniform sampler2D	_DEBUGTexDeepShadowMap0;
// uniform sampler2D	_DEBUGTexDeepShadowMap1;
// uniform sampler2D	_DEBUGTexDeepShadowMap2;
// uniform sampler2D	_DEBUGTexDeepShadowMapEnvMap;


///////////////////////////////////////////////////////////////////////////////////////////////
// Default vertex shader

uniform float4 _MainTex_TexelSize;

struct PS_IN_TONEMAP
{
	float4	Position	: POSITION;
	float4	UV			: TEXCOORD0;
	float4	MainTexUV	: TEXCOORD1;	// UVs for the main tex are NOT reversed
}; 

PS_IN_TONEMAP VS_TONEMAP( appdata_img _In )
{
	PS_IN_TONEMAP	Out;
			Out.Position = mul( UNITY_MATRIX_MVP, _In.vertex );
			Out.UV = float4( MultiplyUV( UNITY_MATRIX_TEXTURE0, _In.texcoord ).xy, 0, 0 );
			Out.MainTexUV = Out.UV;

#ifndef TARGET_GLSL
	// On D3D when AA is used, the main texture & scene depth texture
	// will come out in different vertical orientations.
	// So flip sampling of the texture when that is the case (main texture texel size will have negative Y).
	if ( _MainTex_TexelSize.y < 0.0 )
		Out.UV.y = 1.0 - Out.UV.y;
#endif

	return Out;
}


// From Adaptive Logarithmic Mapping For Displaying High Contrast Scenes (Drago et al.)
// The gamma is linear before a given threshold then goes back to a standard gamma curve
//
float	ContrastedGamma( float _LDRLuminance )
{
	return pow( _LDRLuminance, _Gamma );
}

///////////////////////////////////////////////////////////////////////////////
// Glow support
float	ComputeGlowAlpha( float _Luminance )
{
	return smoothstep( _GlowIntensityThreshold.x, _GlowIntensityThreshold.y, _Luminance );
}

float	CombineGlowAlpha( float _SourceAlpha, float _GlowAlpha )
{
	return lerp( _SourceAlpha, lerp( _GlowAlpha, max( _GlowAlpha, _SourceAlpha ), _GlowUseMax ), _GlowSupport );
}

float3	ComputeImageTint( float _ImageLuminance )
{
//	return _ToneMappingLuminance / _ImageLuminance;
	return _ToneMappingLuminance / max( 0.01, max( max( _ToneMappingLuminance.x, _ToneMappingLuminance.y ), _ToneMappingLuminance.z ) );
}

///////////////////////////////////////////////////////////////////////////////
// Reinhard algorithm
//
uniform float	_ReinhardMiddleGrey;		// Nominal = 0.18  (down to 1/4 (0.045) and up to 4x (0.72))
uniform float	_ReinhardWhiteLuminance;	// Nominal = 1.0

float3	ToneMapReinhard( float3 _RGB, out float _GlowAlpha )
{
	float	ImageLuminance = dot( _ToneMappingLuminance, LUMINANCE );
	float3	ImageTint = ComputeImageTint( ImageLuminance );

	// Switch to xyY
	float3	xyY = RGB2xyY( _RGB );

	// Apply tone mapping
	float	Lwhite = _ReinhardWhiteLuminance;
	float	L = _ReinhardMiddleGrey * xyY.z / (1e-3 + ImageLuminance);
	xyY.z = _ToneMappingBoostFactor * L * (1.0 + L / (Lwhite * Lwhite)) / (1.0 + L);

	// Apply gamma and back to RGB
	xyY.z = ContrastedGamma( xyY.z );
	_RGB = xyY2RGB( xyY );

	// Apply image tint
	_RGB *= ImageTint;

	// Apply glow
	_GlowAlpha = ComputeGlowAlpha( xyY.z );

	return _RGB;
}

///////////////////////////////////////////////////////////////////////////////
// Drago et al. algorithm
//
uniform float	_DragoMaxDisplayLuminance;	// Nominal = 50.0
uniform float	_DragoBias;					// Nominal = 0.85

// Strangely, the GLSL compiler generates a faulty code when it comes to the log10() function so I simply rewrote it myself...
float	MyLog10( float x )
{
	return 0.30102999566398119521373889472449 * log2( x );
}

float3	ToneMapDrago( float3 _RGB, out float _GlowAlpha )
{
	float	ImageLuminance = dot( _ToneMappingLuminance, LUMINANCE );
	float3	ImageTint = ComputeImageTint( ImageLuminance );

	// Switch to xyY
	float3	xyY = RGB2xyY( _RGB );

	// Apply tone mapping
	float	Ldmax = _DragoMaxDisplayLuminance;
	float	Lw = xyY.z;
	float	Lwmax = ImageLuminance;
	float	bias = _DragoBias;

	xyY.z  = Ldmax * 0.01 * log( Lw + 1.0 );
	xyY.z /= MyLog10( Lwmax + 1.0 ) * log( 2.0 + 0.8 * pow( Lw / Lwmax, -1.4426950408889634073599246810019 * log( bias ) ) );
	xyY.z *= _ToneMappingBoostFactor;

	// Apply gamma and back to RGB
	xyY.z = ContrastedGamma( xyY.z );
	_RGB = xyY2RGB( xyY );

	// Apply image tint
	_RGB *= ImageTint;

	// Apply glow
	_GlowAlpha = ComputeGlowAlpha( xyY.z );

	return _RGB;
}

///////////////////////////////////////////////////////////////////////////////
// Filmic Curve algorithm (Hable)
//
uniform float _Filmic_A = 0.15;			// A = Shoulder Strength
uniform float _Filmic_B = 0.50;			// B = Linear Strength
uniform float _Filmic_C = 0.10;			// C = Linear Angle
uniform float _Filmic_D = 0.20;			// D = Toe Strength
uniform float _Filmic_E = 0.02;			// E = Toe Numerator
uniform float _Filmic_F = 0.30;			// F = Toe Denominator
										// (Note: E/F = Toe Angle)
uniform float _Filmic_W = 11.2;			// LinearWhite = Linear White Point Value

uniform float _FilmicMiddleGrey;

float	FilmicToneMapOperator( float _In )
{
   return (_In*(_Filmic_A*_In+_Filmic_C*_Filmic_B) + _Filmic_D*_Filmic_E) / max( 0.001, _In*(_Filmic_A*_In+_Filmic_B) + _Filmic_D*_Filmic_F )
		   - _Filmic_E/_Filmic_F;
}

float3	ToneMapFilmic( float3 _RGB, out float _GlowAlpha )
{
	float	ImageLuminance = dot( _ToneMappingLuminance, LUMINANCE );
	float3	ImageTint = ComputeImageTint( ImageLuminance );

	_RGB = max( 0.00001.xxx, _RGB );

	// Switch to xyY
	float3	xyY = RGB2xyY( _RGB );

	// Apply tone mapping
	xyY.z *= _ToneMappingBoostFactor * _FilmicMiddleGrey / ImageLuminance;
	xyY.z = FilmicToneMapOperator( xyY.z ) / FilmicToneMapOperator( _Filmic_W );

	// Apply gamma and back to RGB
	xyY.z = ContrastedGamma( xyY.z );
	_RGB = xyY2RGB( xyY );

	// Apply image tint
	_RGB *= ImageTint;

	// Apply glow
	_GlowAlpha = ComputeGlowAlpha( xyY.z );

	return _RGB;
}

///////////////////////////////////////////////////////////////////////////////
// Exponential algorithm
//
uniform float	_ExponentialExposure;
uniform float	_ExponentialGain;

float3	ToneMapExponential( float3 _RGB, out float _GlowAlpha )
{
	float	ImageLuminance = dot( _ToneMappingLuminance, LUMINANCE );
	float3	ImageTint = ComputeImageTint( ImageLuminance );

	// Switch to xyY
	float3	xyY = RGB2xyY( _RGB );

	// Apply tone mapping
	xyY.z = _ExponentialGain * _ToneMappingBoostFactor * (1.0 - exp( -_ExponentialExposure * xyY.z ));

	// Apply gamma and back to RGB
	xyY.z = ContrastedGamma( xyY.z );
	_RGB = xyY2RGB( xyY );

	// Apply image tint
	_RGB *= ImageTint;

	// Apply glow
	_GlowAlpha = ComputeGlowAlpha( xyY.z );

	return _RGB;
}

///////////////////////////////////////////////////////////////////////////////
// Linear algorithm
//
uniform float	_LinearMiddleGrey;
uniform float	_LinearFactor;

float3	ToneMapLinear( float3 _RGB, out float _GlowAlpha )
{
	float	ImageLuminance = dot( _ToneMappingLuminance, LUMINANCE );
	float3	ImageTint = ComputeImageTint( ImageLuminance );

	// Switch to xyY
	float3	xyY = RGB2xyY( _RGB );

	// Apply tone mapping
	xyY.z *= _LinearFactor * _ToneMappingBoostFactor * _LinearMiddleGrey / ImageLuminance;	// Exposure correction

	// Apply gamma and back to RGB
	xyY.z = ContrastedGamma( xyY.z );
	_RGB = xyY2RGB( xyY );

	// Apply image tint
	_RGB *= ImageTint;

	// Apply glow
	_GlowAlpha = ComputeGlowAlpha( xyY.z );

	return _RGB;
}

#endif
