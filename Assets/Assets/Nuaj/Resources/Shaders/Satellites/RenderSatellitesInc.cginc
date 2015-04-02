// This file contains useful common helpers for satellites
//
static const float	INV_PI = 0.31830988618379067153776752674503;

#include "UnityCG.cginc"	// C:\Program Files (x86)\Unity\Editor\Data\CGIncludes

uniform float4x4	_Camera2World;
uniform float4x4	_World2Camera;

uniform float3		_Direction;			// Tangent space for the satellite
uniform float3		_Tangent;
uniform float3		_BiTangent;

uniform float		_DistanceMKm;
uniform float		_Luminance;			// Texture luminance
uniform float2		_Size;				// Screen size
uniform float4		_UV;				// UV offset

// Data for planetary body rendering
uniform float4		_Albedo;
uniform float2		_OrenNayarCoefficients;
uniform float		_bSimulateLighting;
uniform sampler2D	_TexDiffuse;
uniform sampler2D	_TexNormal;

// Data for nearby star rendering
uniform sampler2D	_TexEmissive;

// Data for stellar background rendering
uniform float		_Brightness;
uniform float		_Contrast;
uniform float		_Gamma;
uniform samplerCUBE	_TexCubeEmissive;
uniform float		_FlipCubeMap;

#include "../Header.cginc"
#include "../PlanetDataInc.cginc"
#include "../LightSupportInc.cginc"

struct PS_IN_SAT
{
	float4	Position	: POSITION;
	float2	UV			: TEXCOORD0;
};

// Vertex shader used for environment map rendering
PS_IN_SAT VS_ENVIRONMENT( appdata_img _In )
{
	PS_IN_SAT	Out;
				Out.Position = _In.vertex;
				Out.UV = _In.texcoord.xy;

	return Out;
}

// Performs Oren-Nayar lighting on a disc
float4	OrenNayarLighting( float2 _InUV )
{
	float2	UV = _UV.xy + _UV.zw * 0.5 * (1.0 + _InUV);

	// Check we're inside the disc
	float	SqDistance = dot( _InUV, _InUV );
	clip( 1.0 - SqDistance );	// Ouste!
	float	Z = sqrt( 1.0 - SqDistance );

	// Recompute tangent space on the surface of the sphere
	float3	NormalWorld = _InUV.x * _Tangent + _InUV.y * _BiTangent - Z * _Direction;
	float3	TangentWorld = cross( NormalWorld, _BiTangent );
	float3	BiTangentWorld = cross( TangentWorld, NormalWorld );

	// Transform light into TANGENT space
	float3	SunDirectionTS = float3(	dot( _SunDirection, TangentWorld ),
										dot( _SunDirection, BiTangentWorld ),
										dot( _SunDirection, NormalWorld ) );

	// Transform view into TANGENT space
	float3	View = normalize( mul( _Camera2World, float4( _CameraData.xy * _InUV, +1.0, 0.0 ) ).xyz );
	float3	ViewDirectionTS = float3(	dot( View, TangentWorld ),
										dot( View, BiTangentWorld ),
										dot( View, NormalWorld ) );

	// Retrieve normal in TANGENT space
	float3	NormalMap = UnpackNormal( tex2D( _TexNormal, UV ) );

	float	CosTheta_i = dot( SunDirectionTS, NormalMap );
	float	CosTheta_v = max( 0.0, dot( ViewDirectionTS, NormalMap ) );

	// Compute Oren-Nayar lighting (http://en.wikipedia.org/wiki/Oren%E2%80%93Nayar_reflectance_model)
	float	SinTheta_i = sqrt( 1.0 - CosTheta_i * CosTheta_i );
	float	SinTheta_v = sqrt( 1.0 - CosTheta_v * CosTheta_v );

	float	TanTheta_i = SinTheta_i / CosTheta_i;
	float	TanTheta_v = SinTheta_v / CosTheta_v;

	float	TanBeta = min( TanTheta_i, TanTheta_v );
	float	SinAlpha = max( SinTheta_i, SinTheta_v );

	float	NormalizerPhi_i = 1.0 / sqrt( 1.0 - SunDirectionTS.z*SunDirectionTS.z );
	float	CosPhi_i = SunDirectionTS.x * NormalizerPhi_i;
	float	SinPhi_i = SunDirectionTS.y * NormalizerPhi_i;

	float	NormalizerPhi_v = 1.0 / sqrt( 1.0 - ViewDirectionTS.z*ViewDirectionTS.z );
	float	CosPhi_v = ViewDirectionTS.x * NormalizerPhi_v;
	float	SinPhi_v = ViewDirectionTS.y * NormalizerPhi_v;

	float	CosDeltaPhi = max( 0.0, CosPhi_i * CosPhi_v + SinPhi_i * SinPhi_v );	// = cos( Phi_i - Phi_v )

	float	Reflectance = _Luminance * INV_PI * CosTheta_i * saturate(_OrenNayarCoefficients.x + (_OrenNayarCoefficients.y * CosDeltaPhi * SinAlpha * TanBeta));

	float4	Color = _Albedo * tex2D( _TexDiffuse, UV );
	return lerp( float4( 0.0, 0.0, 0.0, _Albedo.w ), float4( Reflectance * Color.xyz, _Albedo.w * Color.w ), step( 0.0, CosTheta_i ) );
}

// Computes the UVs for satellite texture sampling when rendering the environment
float2	ComputeEnvironmentUV( float2 _InUV )
{
	float3	CameraPositionKm, View;
	ComputeEnvironmentPositionViewSky( _InUV, CameraPositionKm, View );

 	// Compute intersection of the view ray with the satellite's plane
 	float3	N = _Direction;
 	float	t = 1.0 / dot( View, N );
  	clip( t );	// We hit behind...
  
	float3	CameraPosition = _Camera2World._m03_m13_m23;
	float3	P = CameraPosition + t * View;

	// Clip to satellite's size
	float3	C = CameraPosition + N;	// Satellite's center
	float3	D = P - C;
	float2	UV = 0.5 * (1.0 + float2( dot( D, _Tangent ), dot( D, _BiTangent ) ) / _Size);
	clip( UV.x * (1.0-UV.x) );
	clip( UV.y * (1.0-UV.y) );

	return UV;
}
