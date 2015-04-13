// This shader renders the clouds shadow map into a light cookie useable by Unity
//
Shader "Hidden/Nuaj/RenderLightCookie"
{
	Properties
	{
		_TexShadowMap( "Base (RGB)", 2D ) = "white" {}
	}

	SubShader
	{
		ZTest Off
		Cull Off
		ZWrite Off
		Fog { Mode off }

		Pass
		{
			CGPROGRAM
			#pragma target 3.0
			#pragma vertex VS2
			#pragma fragment PS
			#pragma glsl
			#pragma only_renderers d3d9 d3d11 opengl

			#include "Header.cginc"

			#include "PlanetDataInc.cginc"
			#include "LightSupportInc.cginc"
			#include "ShadowMapInc.cginc"

			uniform float		_CookieSize;
			uniform float		_SampleAltitudeKm;	// Altitude at which we sample the shadow map
			uniform float4x4	_Light2World;

			PS_IN VS2( appdata_img _In )
			{
				PS_IN	Out;
						Out.Position = mul( UNITY_MATRIX_MVP, _In.vertex );
						Out.UV = float4( MultiplyUV( UNITY_MATRIX_TEXTURE0, _In.texcoord ).xy, 0, 0 );

				return Out;
			}

			float4	PS( PS_IN _In ) : COLOR
			{
				float3	LightPosition = _Light2World._m03_m13_m23;
				float3	LightX = _Light2World._m00_m10_m20;
				float3	LightY = _Light2World._m01_m11_m21;
				float3	LightZ = _Light2World._m02_m12_m22;
				float3	Origin = LightPosition + _CookieSize * (LightX * (_In.UV.x-0.5) + LightY * (_In.UV.y-0.5));
				float2	UV = WorldPosition2Shadow( _WorldUnit2Kilometer * Origin );
				return GetShadowAtAltitude( UV, _SampleAltitudeKm );
			}
			ENDCG
		}
	}
	Fallback off
}
