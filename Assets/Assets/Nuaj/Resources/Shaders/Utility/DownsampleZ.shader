// This shader is simply used to downsample the Z-Buffer for modules that render in downsampled resolution
//
Shader "Hidden/DownsampleZ"
{
	Properties
	{
		_MainTex( "Base (RGB)", 2D ) = "black" {}
	}

	SubShader
	{
		ZTest Off
		Cull Off
		ZWrite Off
		Fog { Mode off }

		// Pass #0 downsamples the original ZBuffer
		//
		Pass
		{
			CGPROGRAM
			#pragma target 3.0
			#pragma vertex VS
			#pragma fragment PS
			#pragma glsl
			#pragma only_renderers d3d9 d3d11 opengl

			#include "../Header.cginc"

			uniform float4	_dUV;

			half4	PS( PS_IN _In ) : COLOR
			{
				_In.UV -= 0.5 * _dUV;	// Go sample at the middle of the source texel

				float4	Z;
						Z.x = ReadDepth( _In.UV );	_In.UV.xy += _dUV.xz;
						Z.y = ReadDepth( _In.UV );	_In.UV.xy += _dUV.zy;
						Z.z = ReadDepth( _In.UV );	_In.UV.xy -= _dUV.xz;
						Z.w = ReadDepth( _In.UV );
				float2	ZMax2 = max( Z.xy, Z.zw );
				float	ZMax = max( ZMax2.x, ZMax2.y );
				float2	ZMin2 = min( Z.xy, Z.zw );
				float	ZMin = min( ZMin2.x, ZMin2.y );

				return float4( ZMax, ZMin, dot( 0.25.xxxx, Z ), Z.x );
			}
			ENDCG
		}

		// Pass #1 downsamples an existing downsampled target
		//
		Pass
		{
			CGPROGRAM
			#pragma target 3.0
			#pragma vertex VS
			#pragma fragment PS
			#pragma glsl
			#pragma only_renderers d3d9 d3d11 opengl

			#include "../Header.cginc"

			uniform float4		_dUV;
			uniform sampler2D	_MainTex;

			half4	PS( PS_IN _In ) : COLOR
			{
				_In.UV -= 0.5 * _dUV;	// Go sample at the middle of the source texel

				float4	Z0 = _tex2Dlod( _MainTex, _In.UV );	_In.UV.xy += _dUV.xz;
				float4	Z1 = _tex2Dlod( _MainTex, _In.UV );	_In.UV.xy += _dUV.zy;
				float4	Z2 = _tex2Dlod( _MainTex, _In.UV );	_In.UV.xy -= _dUV.xz;
				float4	Z3 = _tex2Dlod( _MainTex, _In.UV );

				float	ZMax = max( Z0.x, max( Z1.x, max( Z2.x, Z3.x ) ) );
				float	ZMin = min( Z0.y, min( Z1.y, min( Z2.y, Z3.y ) ) );
				float	ZAvg = 0.25 * (Z0.z + Z1.z + Z2.z + Z3.z);

				return float4( ZMax, ZMin, ZAvg, Z0.w );
			}
			ENDCG
		}
	}
	Fallback off
}
