// We need to build the density texture via a shader since we must store floating point values and Unity doesn't allow it 
//
Shader "Hidden/Nuaj/AerialPerspective_BuildDensity"
{
	Properties
	{
		_MainTex( "Base (RGB)", 2D ) = "white" {}
		_TexDensity( "Base (RGB)", 2D ) = "black" {}
		_TexSourceScattering( "Base (RGB)", 2D ) = "black" {}
		_ZBuffer( "Base (RGB)", 2D ) = "black" {}
	}

	SubShader
	{
		Tags { "Queue" = "Overlay-1" }
		ZTest Off
		Cull Off
		ZWrite Off
		Fog { Mode off }
		AlphaTest Off
		Blend Off


		//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		// Pass #0 computes Scattering (RGB) and Extinction (A) in a single blow
		// The result is an extinction lacking a color component
		Pass
		{
			CGPROGRAM
			#pragma vertex VS
			#pragma fragment PS
			#pragma target 3.0
			#pragma glsl
			#pragma only_renderers d3d9 d3d11 opengl

			#include "../Header.cginc"
			#include "AerialPerspectiveComplexInc.cginc"

			static const int	DENSITY_TEXTURE_STEPS_COUNT = 32;

			float4	PS( PS_IN _In ) : COLOR
			{
				float	Altitude = (_PlanetAtmosphereRadiusKm - _PlanetRadiusKm) * _In.UV.y;
				float3	View;
						View.y = 1.0 - 2.0 * _In.UV.x;
						View.x = sqrt( 1.0 - View.y*View.y );
						View.z = 0.0;

				// Compute intersection of ray with upper atmosphere
				float	D = _PlanetRadiusKm + Altitude;
				float	b = D * View.y;
				float	c = D*D-_PlanetAtmosphereRadiusKm*_PlanetAtmosphereRadiusKm;
				float	Delta = sqrt( b*b-c );
				float	HitDistance = Delta - b;	// Distance at which we hit the upper atmosphere (in kilometers)

				// Compute air molecules and aerosols density at current altitude
				float4	Result;
				Result.x = exp( -Altitude / H0_AIR );
				Result.y = exp( -Altitude / H0_AEROSOLS );

				// Accumulate densities along the ray
				float	SumDensityRayleigh = 0.0;
				float	SumDensityMie = 0.0;

				float	StepLength = HitDistance / DENSITY_TEXTURE_STEPS_COUNT;
				float3	Pos;
						Pos.x = 0.5 * StepLength * View.x;
						Pos.y = D + 0.5 * StepLength * View.y;
						Pos.z = 0.0;

				for ( int StepIndex=0; StepIndex < DENSITY_TEXTURE_STEPS_COUNT; StepIndex++ )
				{
					Altitude = length(Pos) - _PlanetRadiusKm;	// Relative height from sea level
					Altitude = max( 0.0, Altitude );		// Don't go below the ground...

					// Compute and accumulate densities at current altitude
					float	Rho_air = exp( -Altitude / H0_AIR );
					float	Rho_aerosols = exp( -Altitude / H0_AEROSOLS );
					SumDensityRayleigh += Rho_air;
					SumDensityMie += Rho_aerosols;

					// March
					Pos.x += StepLength * View.x;
					Pos.y += StepLength * View.y;
				}

				SumDensityRayleigh *= HitDistance / DENSITY_TEXTURE_STEPS_COUNT;
				SumDensityMie *= HitDistance / DENSITY_TEXTURE_STEPS_COUNT;

				// Write accumulated densities (clamp because of Float16)
				Result.z = min( 1e4, SumDensityRayleigh );
				Result.w = min( 1e4, SumDensityMie );

				return Result;
			}
			ENDCG
		}
	}
	Fallback off
}
