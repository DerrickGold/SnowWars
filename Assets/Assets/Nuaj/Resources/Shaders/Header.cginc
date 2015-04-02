// Common header to all shaders
//
#ifndef HEADER_INCLUDED
#define HEADER_INCLUDED

#include "UnityCG.cginc"	// C:\Program Files (x86)\Unity\Editor\Data\CGIncludes

#if defined(TARGET_GLSL) || defined(SHADER_TARGET_GLSL)
#undef TARGET_GLSL
#define TARGET_GLSL 1
#endif

static const float	PI = 3.1415926535897932384626433832795;
static const float	HALF_PI = 1.5707963267948966192313216916398;
static const float	INV_2PI	= 0.15915494309189533576888376337251;
static const float	INV_4PI	= 0.07957747154594766788444188168626;

static const float	INV1024 = 0.0009765625;
static const float	INV256 = 0.00390625;

static const float3	LUMINANCE = float3( 0.2126, 0.7152, 0.0722 );	// RGB => Y from a sRGB D65 illuminant (taken from http://wiki.nuaj.net/index.php?title=Color_Transforms#RGB_.E2.86.92_XYZ)

///////////////////////////////////////////////////////////////////////////////////////////////
// Default vertex shaders
struct PS_IN
{
	float4	Position	: POSITION;
	float4	UV			: TEXCOORD0;
}; 

PS_IN VS( appdata_img _In )
{
	PS_IN	Out;
			Out.Position = mul( UNITY_MATRIX_MVP, _In.vertex );
			Out.UV = float4( MultiplyUV( UNITY_MATRIX_TEXTURE0, _In.texcoord ).xy, 0.0, 0.0 );

	return Out;
}

// VS used when blitting with a viewport clipping
PS_IN VS_VIEWPORT( appdata_img _In )
{
	PS_IN	Out;
			Out.Position = float4( _In.vertex.xyz, 1.0 );
			Out.UV = float4( _In.texcoord, 0.0, 0.0 );

	return Out;
}


///////////////////////////////////////////////////////////////////////////////////////////////
// FUCKING TEX2DLOD PATCH !
#if TARGET_GLSL
#define	_tex2Dlod( s, uv ) tex2D( s, uv.xy )	// SIMPLE AS THAT???? Ôõ
#else
#define	_tex2Dlod( s, uv ) tex2Dlod( s, uv )
#endif

///////////////////////////////////////////////////////////////////////////////////////////////
// Camera helpers
//
uniform float4		_CameraData;		// X=AspectRatio*tan(FOV/2) Y=tan(FOV/2) Z=NearClip W=FarClip
uniform float4x4	_Camera2WorldKm;	// Same but with position in kilometers
uniform float4x4	_World2CameraKm;
uniform sampler2D	_CameraDepthTexture;

// Tells if Z is at "infinity" (i.e. ZFar)
bool	IsZInfinity( float _Z )
{
	return _Z > 0.995 * _CameraData.w;
}

// Returns 1 if Z is at "infinity" (i.e. ZFar)
float	StepInfinity( float _Z )
{
	return step( 0.995 * _CameraData.w, _Z );
}

// Returns 1 if Z is at "infinity" (i.e. ZFar)
float	SaturateInfinity( float _Z )
{
	return saturate( 1e4 * (_Z - 0.995 * _CameraData.w) );
}

// Unprojects depth from Z buffer
float	ReadDepth( float4 _UV )
{
	float	Zproj = _tex2Dlod( _CameraDepthTexture, _UV ).x;
	float	Q = _CameraData.w / (_CameraData.w - _CameraData.z);	// Zf / (Zf-Zn)
//	return (Q * _CameraData.z) / (Q - Zproj);

	float	Z = (Q * _CameraData.z) / (Q - Zproj);
	return lerp( Z, 10000.0, StepInfinity( Z ) );	// For far Z to always project to 10000.0, our ref value...
}

float	ReadDownsampledDepthMax( sampler2D _TexDownsampledDepth, float4 _UV )
{
	float	Z = _tex2Dlod( _TexDownsampledDepth, _UV ).x;
//			Z = lerp( Z, _CameraData.w, StepInfinity( Z ) );	// Make sure it's infinity!
	return Z;
}

float	ReadDownsampledDepthMin( sampler2D _TexDownsampledDepth, float4 _UV )
{
	float	Z = _tex2Dlod( _TexDownsampledDepth, _UV ).y;
//			Z = lerp( Z, _CameraData.w, StepInfinity( Z ) );	// Make sure it's infinity!
	return Z;
}

float	ReadDownsampledDepthAvg( sampler2D _TexDownsampledDepth, float4 _UV )
{
	float	Z = _tex2Dlod( _TexDownsampledDepth, _UV ).z;
//			Z = lerp( Z, _CameraData.w, StepInfinity( Z ) );	// Make sure it's infinity!
	return Z;
}

float	ReadDownsampledDepthTopLeft( sampler2D _TexDownsampledDepth, float4 _UV )
{
	float	Z = _tex2Dlod( _TexDownsampledDepth, _UV ).w;
//			Z = lerp( Z, _CameraData.w, StepInfinity( Z ) );	// Make sure it's infinity!
	return Z;
}

// This is the metric I'm now using to compute the discrepancies in Z
// It's a relative error metric that reduces the error for large Zs
//
// For example:
//	_Zscene = Zfar = 10000 (as I'm currently using in my test scene)
//	_Zdownsampled = 9900 (because I'm storing downsampled Z in linear space on half precision floats, it's never quite equal to Zfar)
//  error = abs(10000-9900)/9900=0.0101
//
// Now, with the same difference of 100 but for closer Zs:
//	_Zscene = 110
//	_Zdownsampled = 10
//  error = abs(110-10)/10=10
//
// So the error for close Zs is much more important than far Zs, which makes sense (to me at least)
//
float	ZErrorMetric( float _Zscene, float _Zdownsampled )
{
	return abs( _Zscene - _Zdownsampled ) / min( _Zscene, _Zdownsampled );
}
float4	ZErrorMetric( float4 _Zscene, float4 _Zdownsampled )
{
	return abs( _Zscene - _Zdownsampled ) / min( _Zscene, _Zdownsampled );
}

// Computes WORLD position in kilometers and view given screen space UV
void	ComputeCameraPositionViewKm( float2 _UV, out float3 _PositionKm, out float3 _View, out float _Depth2Distance )
{
	_View = float3( _CameraData.xy * (2.0 * _UV.xy - 1.0), -1.0 );
	_Depth2Distance = length( _View );
	_View /= _Depth2Distance;
	_View = mul( _Camera2WorldKm, float4( _View, 0.0 ) ).xyz;
#if TARGET_GLSL
	_PositionKm = _Camera2WorldKm._m30_m31_m32;
#else
	_PositionKm = _Camera2WorldKm._m03_m13_m23;
#endif
}

///////////////////////////////////////////////////////////////////////////////////////////////
// Color packing/unpacking
//

// The official sRGB to XYZ conversion matrix is (following ITU-R BT.709)
// 0.4125 0.3576 0.1805
// 0.2126 0.7152 0.0722 
// 0.0193 0.1192 0.9505 
static const float3x3 RGB2XYZ = {
		0.5141364, 0.3238786, 0.16036376,
		0.265068, 0.67023428, 0.06409157,
		0.0241188, 0.1228178, 0.84442666 };

// The official XYZ to sRGB conversion matrix is (following ITU-R BT.709) 
// 3.2410 -1.5374 -0.4986
// -0.9692 1.8760 0.0416 
// 0.0556 -0.2040 1.0570 
static const float3x3 XYZ2RGB = {
		2.5651, -1.1665, -0.3986,
		-1.0217, 1.9777, 0.0439,
		0.0753, -0.2543, 1.1892 };

// RGB -> xyY conversion 
// http://wiki.nuaj.net/index.php?title=Color_Transforms#RGB_.E2.86.92_XYZ
// http://wiki.nuaj.net/index.php?title=Color_Transforms#XYZ_.E2.86.92_xyY
//
float3 RGB2xyY( float3 _RGB )
{
	float3 XYZ = mul( _RGB, RGB2XYZ ); 

	// XYZ -> Yxy conversion
	float3	xyY;
			xyY.z = XYZ.y;
 
	// x = X / (X + Y + Z) 
	// y = X / (X + Y + Z) 
	xyY.xy = XYZ.xy / (XYZ.x + XYZ.y + XYZ.z);

	return xyY;
}

// xyY -> RGB conversion 
//
float3	xyY2RGB( float3 _xyY )
{
	// xyY -> XYZ conversion
	float3	XYZ;
			XYZ.y = _xyY.z;
			XYZ.x = _xyY.x * _xyY.z / _xyY.y;					// X = x * Y / y
			XYZ.z = (1.0 - _xyY.x - _xyY.y) * _xyY.z / _xyY.y;	// Z = (1-x-y) * Y / y

	// RGB conversion
	return max( 0.0.xxx, mul( XYZ, XYZ2RGB ) );
}

// Packs a float2 with values in [0,1] into a single half
// This is the core secret of Nuaj' because otherwise we would have to render using 2 passes, dramatically killing framerate
// All of this because Unity doesn't support multiple render targets...
half	PackFloat2IntoHalf( float2 _Value )
{
	float	x = min( 210.0, floor( 210.0 * _Value.x ) );	// Use less precision here to avoid strange cases at sunset where orange becomes green
	float	y = min( 255.0, floor( 400.0 * _Value.y ) );

	half	Sign = step( 128.0, x );
	x -= Sign * 128.0;						// Remove bit 7 (sign)
	Sign = 1.0 - 2.0 * Sign;
	half	Exponent = floor( 0.25 * x );	// Remove 2 LS bits (we're left with a 5 bits exponent)
	x -= 4.0 * Exponent;					// Remove bits 2-6 (we're left with the 2 LS bits of x)
	half	Mantissa = 1.0 + (256.0 * x + y) * INV1024;

	return Sign * exp2( Exponent - 15.0 ) * Mantissa;
}

// UnPacks a single half into a float2 with values in [0,1]
// float	HalfExp2[32] = {
// 	32768.0, 16384.0, 8192.0, 4096.0, 2048.0, 1024.0, 512.0, 256.0, 128.0, 64.0, 32.0, 16.0, 8.0, 4.0, 2.0, 1.0,	// From +15 to 0
// 	0.5, 0.25, 0.125, 0.0625, 0.03125, 0.015625, 0.0078125, 0.00390625, 0.001953125, 0.0009765625, 0.00048828125, 0.000244140625, 0.0001220703125, 0.00006103515625, 0.000030517578125, 0.0000152587890625 };	// From -1 to -16
float2	UnPackHalfIntoFloat2( half _Value )
{
	half	Sign = step( _Value, 0.0 );
	_Value = abs( _Value );			// Remove sign
	half	Exponent = floor( log2( _Value ) );
	_Value *= exp2( -Exponent );	// We should have a value in [1,2[
//	_Value *= HalfExp2[16+int(Exponent)];// We should have a value in [1,2[
	float	Mantissa = 1024.0 * (_Value - 1.0);

	float	x = (128.0 * Sign + (Exponent + 15.0) * 4.0 + floor( Mantissa * INV256 )) / 210.0;//* 0.005;	// 1/200
	float	y = frac( Mantissa * INV256 ) * 256.0 / 400.0;

	return float2( x, y );
}

// Packs xyY into a half2
half2	PackxyY( float3 _xyY )
{
	return half2( _xyY.z, PackFloat2IntoHalf( _xyY.xy ) );
}

// Unpacks a half2 into xyY
float3	UnPackxyY( half2 _xyY )
{
	return float3( UnPackHalfIntoFloat2( _xyY.y ), _xyY.x );
}

// Packs 2 RGB colors into a half4
half4	Pack2Colors( float3 _RGB0, float3 _RGB1 )
{
	return half4( PackxyY( RGB2xyY( _RGB0 ) ), PackxyY( RGB2xyY( _RGB1 ) ) );
}

// Unpacks a half4 into 2 RGB colors
void	UnPack2Colors( half4 _Packed, out float3 _RGB0, out float3 _RGB1 )
{
	_RGB0 = xyY2RGB( UnPackxyY( _Packed.xy ) );
	_RGB1 = xyY2RGB( UnPackxyY( _Packed.zw ) );
}

#endif

