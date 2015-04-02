// This renders different types of satellites
//	. Planetary Bodies, like the Moon
//	. Nearby Stars, like the Sun
//	. Cosmic Background, like the milky way and all the stars in the galaxy
//
Shader "Hidden/Nuaj/RenderSatellites"
{
	Properties
	{
		_MainTex( "Base (RGB)", 2D ) = "white" {}
		_TexDiffuse( "Base (RGB)", 2D ) = "black" {}
		_TexNormal( "Base (RGB)", 2D ) = "bump" {}
		_TexEmissive( "Base (RGB)", 2D ) = "black" {}
		_TexCubeEmissive( "Base (RGB)", CUBE ) = "black" {}
	}

	SubShader
	{
		Tags { "Queue" = "Overlay-1" }
		ZTest Off
		Cull Off
		ZWrite Off
		Fog { Mode off }
		AlphaTest Off
		Blend SrcAlpha OneMinusSrcAlpha	// Alpha blending

		//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		// Pass #0 renders a planetary body without lighting
		Pass
		{
			CGPROGRAM
			#pragma vertex VS_SAT
			#pragma fragment PS
			#pragma target 3.0
			#pragma glsl
			#pragma only_renderers d3d9 d3d11 opengl

			#include "RenderSatellitesInc.cginc"

			PS_IN_SAT VS_SAT( appdata_img _In )
			{
				// Build vertex position from UVs
				float3	CameraPosition = _Camera2World._m03_m13_m23;
				float3	VertexWorld = CameraPosition + _CameraData.y * (_Size.x * _In.texcoord.x * _Tangent + _Size.y * _In.texcoord.y * _BiTangent) + 1.0 * _Direction;
				float4	VertexCamera = mul( _World2Camera, float4( VertexWorld, 1.0 ) );
				float4	VertexProj = mul( UNITY_MATRIX_P, VertexCamera );

				PS_IN_SAT	Out;
							Out.Position = VertexProj;
							Out.UV = _UV.xy + _UV.zw * 0.5 * (1.0 + _In.texcoord.xy);

				return Out;
			}

			half4	PS( PS_IN_SAT _In ) : COLOR
			{
				float4	Color = _Albedo * tex2D( _TexDiffuse, _In.UV );
				return float4( _Luminance * Color.xyz, Color.w );
			}
			ENDCG
		}

		//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		// Pass #1 renders a planetary body with lighting
		Pass
		{
			CGPROGRAM
			#pragma vertex VS_SAT
			#pragma fragment PS
			#pragma target 3.0
			#pragma glsl
			#pragma only_renderers d3d9 d3d11 opengl

			#include "RenderSatellitesInc.cginc"

			PS_IN_SAT VS_SAT( appdata_img _In )
			{
				// Build vertex position from UVs
				float3	CameraPosition = _Camera2World._m03_m13_m23;
				float3	VertexWorld = CameraPosition + _CameraData.y * (_Size.x * _In.texcoord.x * _Tangent + _Size.y * _In.texcoord.y * _BiTangent) + 1.0 * _Direction;
				float4	VertexCamera = mul( _World2Camera, float4( VertexWorld, 1.0 ) );
				float4	VertexProj = mul( UNITY_MATRIX_P, VertexCamera );

				PS_IN_SAT	Out;
							Out.Position = VertexProj;
							Out.UV = _In.texcoord.xy;

				return Out;
			}

			half4	PS( PS_IN_SAT _In ) : COLOR
			{
				return OrenNayarLighting( _In.UV );
			}
			ENDCG
		}

		//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		// Pass #2 renders an emissive nearby star
		Pass
		{
			CGPROGRAM
			#pragma vertex VS_SAT
			#pragma fragment PS
			#pragma target 3.0
			#pragma glsl
			#pragma only_renderers d3d9 d3d11 opengl

			#include "RenderSatellitesInc.cginc"

			PS_IN_SAT VS_SAT( appdata_img _In )
			{
				// Build vertex position from UVs
				float3	CameraPosition = _Camera2World._m03_m13_m23;
				float3	VertexWorld = CameraPosition + _CameraData.y * (_Size.x * _In.texcoord.x * _Tangent + _Size.y * _In.texcoord.y * _BiTangent) + 1.0 * _Direction;
				float4	VertexCamera = mul( _World2Camera, float4( VertexWorld, 1.0 ) );
				float4	VertexProj = mul( UNITY_MATRIX_P, VertexCamera );

				PS_IN_SAT	Out;
							Out.Position = VertexProj;
							Out.UV = _UV.xy + _UV.zw * 0.5 * (1.0 + _In.texcoord.xy);

				return Out;
			}

			half4	PS( PS_IN_SAT _In ) : COLOR
			{
				float4	Color = tex2D( _TexEmissive, _In.UV );
				return float4( _Luminance * Color.xyz, Color.w );
			}
			ENDCG
		}

		//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		// Pass #3 renders an emissive cosmic background
		Pass
		{
			CGPROGRAM
			#pragma vertex VS_SAT
			#pragma fragment PS
			#pragma target 3.0
			#pragma glsl
			#pragma only_renderers d3d9 d3d11 opengl

			#include "RenderSatellitesInc.cginc"
 
			PS_IN_SAT VS_SAT( appdata_img _In )
			{
				PS_IN_SAT	Out;
							Out.Position = float4( _In.texcoord.xy, 1.0, 1.0 );
							Out.UV = _In.texcoord.xy;

				return Out;
			}

			half4	PS( PS_IN_SAT _In ) : COLOR
			{
				// Build view in tangent space
#if TARGET_GLSL
				float3	View = normalize( mul( _Camera2World, float4( _CameraData.xy * float2( 1.0, -_FlipCubeMap ) * _In.UV, -1.0, 0.0 ) ).xyz );
#else
				float3	View = normalize( mul( _Camera2World, float4( _CameraData.xy * float2( 1.0, _FlipCubeMap ) * _In.UV, -1.0, 0.0 ) ).xyz );
#endif
				float3	ViewTS = float3(	dot( View, _Tangent ),
											dot( View, _BiTangent ),
											dot( View, _Direction ) );

				float4	Color = texCUBE( _TexCubeEmissive, ViewTS );

				// Apply contrast/brightness/gamma
				Color.xyz = _Luminance * pow( saturate( 0.5 + _Contrast * (_Brightness + Color.xyz - 0.5) ), _Gamma );

				return float4( Color.xyz, Color.w );
			}
			ENDCG
		}

		//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		//
		// ENVIRONMENT RENDERING
		//
		//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

		//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		// Pass #4 renders a planetary body (with and without lighting)
		Pass
		{
			CGPROGRAM
			#pragma vertex VS_ENVIRONMENT
			#pragma fragment PS
			#pragma target 3.0
			#pragma glsl
			#pragma only_renderers d3d9 d3d11 opengl

			#include "RenderSatellitesInc.cginc"

			half4	PS( PS_IN_SAT _In ) : COLOR
			{
				float2	UV = ComputeEnvironmentUV( _In.UV );

				float2	CroppedUV = _UV.xy + _UV.zw * UV;
				float4	Color = _Albedo * tex2D( _TexDiffuse, CroppedUV );
				float4	ResultUnlit = float4( _Luminance * Color.xyz, Color.w );

				float4	ResultLit = OrenNayarLighting( 2.0 * _In.UV - 1.0 );

				return lerp( ResultUnlit, ResultLit, _bSimulateLighting );
			}
			ENDCG
		}

		//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		// Pass #5 renders an emissive nearby star
		Pass
		{
			CGPROGRAM
			#pragma vertex VS_ENVIRONMENT
			#pragma fragment PS
			#pragma target 3.0
			#pragma glsl
			#pragma only_renderers d3d9 d3d11 opengl

			#include "RenderSatellitesInc.cginc"

			half4	PS( PS_IN_SAT _In ) : COLOR
			{
				float2	UV = ComputeEnvironmentUV( _In.UV );

				float2	CroppedUV = _UV.xy + _UV.zw * UV;
				float4	Color = tex2D( _TexEmissive, CroppedUV );
				return float4( _Luminance * Color.xyz, Color.w );
			}
			ENDCG
		}

		//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		// Pass #6 renders an emissive cosmic background
		Pass
		{
			CGPROGRAM
			#pragma vertex VS_ENVIRONMENT
			#pragma fragment PS
			#pragma target 3.0
			#pragma glsl
			#pragma only_renderers d3d9 d3d11 opengl

			#include "RenderSatellitesInc.cginc"

			half4	PS( PS_IN_SAT _In ) : COLOR
			{
 				float3	CameraPositionKm, View;
 				ComputeEnvironmentPositionViewSky( _In.UV, CameraPositionKm, View );

				// Build view in tangent space
				float3	ViewTS = float3(	dot( View, _Tangent ),
											dot( View, _BiTangent ),
											dot( View, _Direction ) );

				float4	Color = texCUBE( _TexCubeEmissive, ViewTS );

				// Apply contrast/brightness/gamma
				Color.xyz = _Luminance * pow( saturate( 0.5 + _Contrast * (_Brightness + Color.xyz - 0.5) ), _Gamma );

				return float4( Color.xyz, Color.w );
			}
			ENDCG
		}
	}
	Fallback off
}
