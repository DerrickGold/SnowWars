// Support for 3D noise
//
#ifndef NOISE3D_SUPPORT_INCLUDED
#define NOISE3D_SUPPORT_INCLUDED

uniform sampler2D	_NuajTexNoise3D0;				// 16x16x16 3D noise texture arranged as a (17*16) x 16 2D texture
uniform sampler2D	_NuajTexNoise3D1;				// 8x8x8 3D noise texture arranged as a (9*8) x 8 2D texture
uniform sampler2D	_NuajTexNoise3D2;				// 4x4x4 3D noise texture arranged as a (5*4) x 4 2D texture
uniform sampler2D	_NuajTexNoise3D3;				// 2x2x2 3D noise texture arranged as a (3*2) x 2 2D texture

// 3D Noise sampling
#if NOISE_MIP_LEVEL == 1
float	SampleNoiseTexture( float3 _UVW, float _MipLevel )
{
	float2	WrappedUW = fmod( 8.0 * (1000.0 + _UVW.xz), 8.0 );	// UW wrapped in [0,8[

	float	IntW = floor( WrappedUW.y );				// Integer slice number
	float	dw = WrappedUW.y - IntW;					// Remainder for intepolating between slices

	_UVW.x = (9.0 * IntW + WrappedUW.x + 0.25) * 0.01388888888888888888888888888889;	// divided by 9*8 = 272

	float4	Value = _tex2Dlod( _NuajTexNoise3D1, float4( _UVW.xy, 0.0, 0.0 ) );

	// Here, contrary to default mip level, we increase noise contrast
	return 0.5 + 3.0 * (lerp( Value.x, Value.y, dw ) - 0.5);
}
#elif NOISE_MIP_LEVEL == 2
float	SampleNoiseTexture( float3 _UVW, float _MipLevel )
{
	float2	WrappedUW = fmod( 4.0 * (1000.0 + _UVW.xz), 4.0 );	// UW wrapped in [0,4[

	float	IntW = floor( WrappedUW.y );				// Integer slice number
	float	dw = WrappedUW.y - IntW;					// Remainder for intepolating between slices

	_UVW.x = (5.0 * IntW + WrappedUW.x + 0.25) * 0.05;	// divided by 5*4 = 20

	float4	Value = _tex2Dlod( _NuajTexNoise3D1, float4( _UVW.xy, 0.0, 0.0 ) );

	return lerp( Value.x, Value.y, dw );
}
#else
float	SampleNoiseTexture( float3 _UVW, float _MipLevel )
{
	float2	WrappedUW = fmod( 16.0 * (1000.0 + _UVW.xz), 16.0 );	// UW wrapped in [0,16[

	float	IntW = floor( WrappedUW.y );				// Integer slice number
	float	dw = WrappedUW.y - IntW;					// Remainder for intepolating between slices

	_UVW.x = (17.0 * IntW + WrappedUW.x + 0.25) * 0.00367647058823529411764705882353;	// divided by 17*16 = 272

	float4	Value = _tex2Dlod( _NuajTexNoise3D0, float4( _UVW.xy, 0.0, 0.0 ) );

	return lerp( Value.x, Value.y, dw );
}
#endif

#endif

