// Sky composition routine
//
#ifndef SKY_COMPOSITION_INCLUDED
#define SKY_COMPOSITION_INCLUDED

uniform sampler2D	_MainTex;
uniform float4		_ZBufferDiscrepancyThreshold;
uniform float4		_dUV;		// 1/SourceSize
uniform float4		_InvdUV;	// SouceSize

////////////////////////////////////////////////////////////////////////////////////
// The routine that should be called by the PS to compose the sky with clouds
// It supports from 0 to 4 active cloud layers, you have to declare the proper DEFINES for each case
half4	ComposeSkyAndClouds( PS_IN _In )
{
	// Retrieve camera infos
	float3	CameraPositionKm, View;
	float	Depth2Distance;
	ComputeCameraPositionViewKm( _In.UV.xy, CameraPositionKm, View, Depth2Distance );

	float	SceneZ = ReadDepth( _In.UV );

	//////////////////////////////////////////////////////////////////////////
	// Read the cloud layers
	float4	SliceHitDistancesEnterKm = float4(
		ComputeSphereEnterIntersection( CameraPositionKm, View, _PlanetCenterKm, _PlanetRadiusKm + _ShadowAltitudesMaxKm.x ),
		ComputeSphereEnterIntersection( CameraPositionKm, View, _PlanetCenterKm, _PlanetRadiusKm + _ShadowAltitudesMaxKm.y ),
		ComputeSphereEnterIntersection( CameraPositionKm, View, _PlanetCenterKm, _PlanetRadiusKm + _ShadowAltitudesMaxKm.z ),
		ComputeSphereEnterIntersection( CameraPositionKm, View, _PlanetCenterKm, _PlanetRadiusKm + _ShadowAltitudesMaxKm.w ) );

	float4	SliceHitDistancesExitKm = float4(
		ComputeSphereExitIntersection( CameraPositionKm, View, _PlanetCenterKm, _PlanetRadiusKm + _ShadowAltitudesMinKm.x ),
		ComputeSphereExitIntersection( CameraPositionKm, View, _PlanetCenterKm, _PlanetRadiusKm + _ShadowAltitudesMinKm.y ),
		ComputeSphereExitIntersection( CameraPositionKm, View, _PlanetCenterKm, _PlanetRadiusKm + _ShadowAltitudesMinKm.z ),
		ComputeSphereExitIntersection( CameraPositionKm, View, _PlanetCenterKm, _PlanetRadiusKm + _ShadowAltitudesMinKm.w ) );

	float4	CloudColorR = 0.0;
	float4	CloudColorG = 0.0;
	float4	CloudColorB = 0.0;
	float4	CloudColorA = 1.0;
#if CLOUD_LAYERS > 0
//	if ( SliceHitDistancesEnterKm.x < HALF_INFINITY )
	{
		float4	LayerColor = _tex2Dlod( _TexCloudLayer0, _In.UV );
		CloudColorR.x = LayerColor.x;
		CloudColorG.x = LayerColor.y;
		CloudColorB.x = LayerColor.z;
		CloudColorA.x = LayerColor.w;
	}
#endif
#if CLOUD_LAYERS > 1
//	if ( SliceHitDistancesEnterKm.y < HALF_INFINITY )
	{
		float4	LayerColor = _tex2Dlod( _TexCloudLayer1, _In.UV );
		CloudColorR.y = LayerColor.x;
		CloudColorG.y = LayerColor.y;
		CloudColorB.y = LayerColor.z;
		CloudColorA.y = LayerColor.w;
	}
#endif
#if CLOUD_LAYERS > 2
//	if ( SliceHitDistancesEnterKm.z < HALF_INFINITY )
	{
		float4	LayerColor = _tex2Dlod( _TexCloudLayer2, _In.UV );
		CloudColorR.z = LayerColor.x;
		CloudColorG.z = LayerColor.y;
		CloudColorB.z = LayerColor.z;
		CloudColorA.z = LayerColor.w;
	}
#endif
#if CLOUD_LAYERS > 3
//	if ( SliceHitDistancesEnterKm.w < HALF_INFINITY )
	{
		float4	LayerColor = _tex2Dlod( _TexCloudLayer3, _In.UV );
		CloudColorR.w = LayerColor.x;
		CloudColorG.w = LayerColor.y;
		CloudColorB.w = LayerColor.z;
		CloudColorA.w = LayerColor.w;
	}
#endif

	float	CaseChoice = step( dot( SliceHitDistancesExitKm, _CaseSwizzle ), 0.0 );	// 1 if viewing "up", 0 if viewing "down"

	float4	Swizzle0 = lerp( _SwizzleEnterDown0, _SwizzleExitUp0, CaseChoice );
	float4	Swizzle1 = lerp( _SwizzleEnterDown1, _SwizzleExitUp1, CaseChoice );
	float4	Swizzle2 = lerp( _SwizzleEnterDown2, _SwizzleExitUp2, CaseChoice );
	float4	Swizzle3 = lerp( _SwizzleEnterDown3, _SwizzleExitUp3, CaseChoice );

	// Compute cloud extinctions
	float4	CloudExtinctions = float4(
			dot( CloudColorA, Swizzle0 ),
			dot( CloudColorA, Swizzle1 ),
			dot( CloudColorA, Swizzle2 ),
			dot( CloudColorA, Swizzle3 ) );

	// Patch invalid extinctions
	// This will place 1 if an extinction swizzle is invalid (i.e. swizzle = 0)
	float4	InvalidExtinctions = float4( dot( Swizzle0, 1.0 ), dot( Swizzle1, 1.0 ), dot( Swizzle2, 1.0 ), dot( Swizzle3, 1.0 ) );
	CloudExtinctions = lerp( 1.0.xxxx, CloudExtinctions, InvalidExtinctions );

	// Re-order cloud colors
	float3	CloudColor0 = float3( dot( CloudColorR, Swizzle0 ), dot( CloudColorG, Swizzle0 ), dot( CloudColorB, Swizzle0 ) );
	float3	CloudColor1 = float3( dot( CloudColorR, Swizzle1 ), dot( CloudColorG, Swizzle1 ), dot( CloudColorB, Swizzle1 ) );
	float3	CloudColor2 = float3( dot( CloudColorR, Swizzle2 ), dot( CloudColorG, Swizzle2 ), dot( CloudColorB, Swizzle2 ) );
	float3	CloudColor3 = float3( dot( CloudColorR, Swizzle3 ), dot( CloudColorG, Swizzle3 ), dot( CloudColorB, Swizzle3 ) );

	float4	CloudColor;
	CloudColor.xyz = CloudColor0 + CloudExtinctions.x * (CloudColor1 + CloudExtinctions.y * (CloudColor2 + CloudExtinctions.z * CloudColor3));
	CloudColor.w = CloudExtinctions.x * CloudExtinctions.y * CloudExtinctions.z * CloudExtinctions.w;


	//////////////////////////////////////////////////////////////////////////
	// Either read back the computed sky values or compute more accurate ones based on ZBuffers' discrepancies
	float3	SkyScattering, SkyExtinction;

#ifdef ACCURATE_REFINE
	// Accurate refine reads back the downsampled Z buffer and refines pixels that have too large a discrepancy
	float4	TempUV = _In.UV - 0.5 * _dUV;
	float2	uv = frac( TempUV.xy * _InvdUV.xy );
 
	float	SkyZ0 = ReadDownsampledDepthMax( _TexDownsampledZBuffer, TempUV );	TempUV.xy += _dUV.xz;
	float	SkyZ1 = ReadDownsampledDepthMax( _TexDownsampledZBuffer, TempUV );	TempUV.xy += _dUV.zy;
	float	SkyZ3 = ReadDownsampledDepthMax( _TexDownsampledZBuffer, TempUV );	TempUV.xy -= _dUV.xz;
	float	SkyZ2 = ReadDownsampledDepthMax( _TexDownsampledZBuffer, TempUV );	TempUV.xy -= _dUV.zy;
	float	SkyZ = lerp( lerp( SkyZ0, SkyZ1, uv.x ), lerp( SkyZ2, SkyZ3, uv.x ), uv.y );


	if ( ZErrorMetric( SceneZ, SkyZ ) > 0.01 * _ZBufferDiscrepancyThreshold.x )		// Latest version with new relative error metric
//	if ( (SkyZ - SceneZ > _ZBufferDiscrepancyThreshold.x || SkyZ > 0.25 * _CameraData.w) && !IsZInfinity( SceneZ ) )	// Working
//	if ( SceneZ - SkyZ > _ZBufferDiscrepancyThreshold.x )
//	if ( true )
	{	// Recompute accurate sky
		UnPack2Colors( RenderSky( _In, SceneZ ), SkyScattering, SkyExtinction );
		SkyScattering = lerp( SkyScattering, float3( 1, 0, 0 ), _ZBufferDiscrepancyThreshold.y );
		SkyExtinction = lerp( SkyExtinction, 0.0, _ZBufferDiscrepancyThreshold.y );
	}
	else
	{	// Simulate bilinear
		float3	S[4], E[4];
		UnPack2Colors( _tex2Dlod( _MainTex, TempUV ), S[0], E[0] );		TempUV.xy += _dUV.xz;
		UnPack2Colors( _tex2Dlod( _MainTex, TempUV ), S[1], E[1] );		TempUV.xy += _dUV.zy;
		UnPack2Colors( _tex2Dlod( _MainTex, TempUV ), S[3], E[3] );		TempUV.xy -= _dUV.xz;
		UnPack2Colors( _tex2Dlod( _MainTex, TempUV ), S[2], E[2] );		TempUV.xy -= _dUV.zy;

		SkyScattering = lerp( lerp( S[0], S[1], uv.x ), lerp( S[2], S[3], uv.x ), uv.y );
		SkyExtinction = lerp( lerp( E[0], E[1], uv.x ), lerp( E[2], E[3], uv.x ), uv.y );
	}

#elif defined(SMART_REFINE)
	// "Smart" refine attempts a bilinear interpolation with a bias toward the most relevant sample

	float4	TempUV = _In.UV - 0.5 * _dUV;

	// Default UV interpolants for a normal bilinear interpolation
	float2	uv = frac( TempUV.xy * _InvdUV.xy );

	float4	SkyZ;
	float3	S[4], E[4];
			SkyZ.x = ReadDownsampledDepthMax( _TexDownsampledZBuffer, TempUV );	UnPack2Colors( _tex2Dlod( _MainTex, TempUV ), S[0], E[0] ); TempUV.xy += _dUV.xz;
			SkyZ.y = ReadDownsampledDepthMax( _TexDownsampledZBuffer, TempUV );	UnPack2Colors( _tex2Dlod( _MainTex, TempUV ), S[1], E[1] ); TempUV.xy += _dUV.zy;
			SkyZ.z = ReadDownsampledDepthMax( _TexDownsampledZBuffer, TempUV );	UnPack2Colors( _tex2Dlod( _MainTex, TempUV ), S[3], E[3] ); TempUV.xy -= _dUV.xz;
			SkyZ.w = ReadDownsampledDepthMax( _TexDownsampledZBuffer, TempUV );	UnPack2Colors( _tex2Dlod( _MainTex, TempUV ), S[2], E[2] ); TempUV.xy -= _dUV.zy;

	// Compute bias weights toward each sample based on Z discrepancies
//	float	ZFactor = _ZBufferDiscrepancyThreshold.z;
//	float4	DeltaZ = ZFactor * ZErrorMetric( SceneZ.xxxx, SkyZ );
//	float4	Weights = saturate( _ZBufferDiscrepancyThreshold.x / (1.0 + DeltaZ) );
	float4	Weights = 1.0 - saturate( _ZBufferDiscrepancyThreshold.x * ZErrorMetric( SceneZ.xxxx, SkyZ ) );		// Latest version with new relative error metric

	// This vector gives the bias toward one of the UV corners. It lies in [-1,+1]
	// For equal weights, the bias sums to 0 so the UVs won't be influenced and normal bilinear filtering is applied
	// Otherwise, the UVs will tend more or less strongly toward one of the corners of the big pixel where values were sampled
	//
	// Explicit code would be :
	// float2	uv_bias  = Weights.x * float2( -1.0, -1.0 )		// Bias toward top-left
	// 					 + Weights.y * float2( +1.0, -1.0 )		// Bias toward top-right
	// 					 + Weights.z * float2( +1.0, +1.0 )		// Bias toward bottom-right
	// 					 + Weights.w * float2( -1.0, +1.0 );	// Bias toward bottom-left
	float2	uv_bias  = float2( Weights.y + Weights.z - Weights.x - Weights.w, Weights.z + Weights.w - Weights.x - Weights.y );

	// Now, we need to apply the actual UV bias.
	//
	// Explicit code would be :
	// 	uv.x = uv_bias.x < 0.0 ? lerp( uv.x, 0.0, -uv_bias.x ) : lerp( uv.x, 1.0, uv_bias.x );
	// 	uv.y = uv_bias.y < 0.0 ? lerp( uv.y, 0.0, -uv_bias.y ) : lerp( uv.y, 1.0, uv_bias.y );
	//
	// Unfortunately, using branching 1) is bad and 2) yields some infinite values for some obscure reason !
	// So we need to remove the branching.
	// The idea here is to perform biasing toward top-left & bottom-right independently then choose which bias direction
	//	is actually needed, based on the sign of the uv_bias vector
	//
	float2	uv_topleft = lerp( uv, 0.0, saturate(-uv_bias) );		// Bias toward top-left corner (works if uv_bias is negative)
	float2	uv_bottomright = lerp( uv, 1.0, saturate(uv_bias) );	// Bias toward bottom-right corner (works if uv_bias is positive)
	float2	ChooseDirection = saturate( 10000.0 * uv_bias );		// Isolate the sign of the uv_bias vector so negative gives 0 and positive gives 1
	uv = lerp( uv_topleft, uv_bottomright, ChooseDirection );		// Final bias will choose the appropriate direction based on the sign of the bias

	// Perform normal bilinear filtering with biased UV interpolants
	SkyScattering = lerp( lerp( S[0], S[1], uv.x ), lerp( S[2], S[3], uv.x ), uv.y );
	SkyExtinction = lerp( lerp( E[0], E[1], uv.x ), lerp( E[2], E[3], uv.x ), uv.y );

	// Final biasing based on average deltaZ
	if ( _ZBufferDiscrepancyThreshold.z * ZErrorMetric( SceneZ, 0.25 * (SkyZ.x + SkyZ.y + SkyZ.z + SkyZ.w) ) > 1.0 )
	{
		SkyScattering = 0.0;
		SkyExtinction = 1.0;
		float	DistanceKm = 0.0;
		float	StepDistanceKm = _WorldUnit2Kilometer * Depth2Distance * SceneZ;

#ifdef AERIAL_PERSPECTIVE_SIMPLE_SUPPORT_INCLUDED
		float3	ScaledSigma_Rayleigh = SCALE_RAYLEIGH * _Sigma_Rayleigh;
		float	ScaledSigma_Mie = SCALE_MIE * _Sigma_Mie;
		float3	PreviousSunColor = ComputeSunExtinction( length( CameraPositionKm - _PlanetCenterKm ) );
		float3	CurrentSunColor = ComputeSunExtinction( length( CameraPositionKm + StepDistanceKm * View - _PlanetCenterKm ) );
		ComputeSkyColor( CameraPositionKm, View, float2( DistanceKm, StepDistanceKm ), ComputePlanetShadow( CameraPositionKm, View, _SunDirection ), ComputeSkyPhases( View, _SunDirection ), ScaledSigma_Rayleigh, ScaledSigma_Mie, PreviousSunColor, CurrentSunColor, SkyScattering, SkyExtinction );
#else
		ComputeSingleStep( CameraPositionKm, View, DistanceKm, StepDistanceKm, ComputePlanetShadow( CameraPositionKm, View, _SunDirection ), ComputeSkyPhases( View, _SunDirection ), true, SkyScattering, SkyExtinction );
#endif

		SkyScattering = lerp( SkyScattering, float3( 1, 0, 0 ), _ZBufferDiscrepancyThreshold.y );
		SkyExtinction = lerp( SkyExtinction, float3( 0, 0, 0 ), _ZBufferDiscrepancyThreshold.y );
	}

#elif defined(CUTOUT_REFINE)
	// "Cutout" refine simply applies sky only if ZBuffer is not at infinity
	float4	TempUV = _In.UV - 0.5 * _dUV;

	float3	S[4], E[4];
	UnPack2Colors( _tex2Dlod( _MainTex, TempUV ), S[0], E[0] ); TempUV.xy += _dUV.xz;
	UnPack2Colors( _tex2Dlod( _MainTex, TempUV ), S[1], E[1] ); TempUV.xy += _dUV.zy;
	UnPack2Colors( _tex2Dlod( _MainTex, TempUV ), S[3], E[3] ); TempUV.xy -= _dUV.xz;
	UnPack2Colors( _tex2Dlod( _MainTex, TempUV ), S[2], E[2] ); TempUV.xy -= _dUV.zy;

	float2	uv = frac( TempUV.xy * _InvdUV.xy );
	SkyScattering = lerp( lerp( S[0], S[1], uv.x ), lerp( S[2], S[3], uv.x ), uv.y );
	SkyExtinction = lerp( lerp( E[0], E[1], uv.x ), lerp( E[2], E[3], uv.x ), uv.y );

	float	IsInfinity = SaturateInfinity( SceneZ );
	SkyScattering *= IsInfinity;
	SkyExtinction = lerp( 1.0.xxx, SkyExtinction, IsInfinity );

#else // #if !defined(ACCURATE_REFINE) && !defined(SMART_REFINE) && !defined(CUTOUT_REFINE)
	// Default bilinear simply performs a bilinear interpolation
	float4	TempUV = _In.UV - 0.5 * _dUV;

	float3	S[4], E[4];
	UnPack2Colors( _tex2Dlod( _MainTex, TempUV ), S[0], E[0] );	TempUV.xy += _dUV.xz;
	UnPack2Colors( _tex2Dlod( _MainTex, TempUV ), S[1], E[1] );	TempUV.xy += _dUV.zy;
	UnPack2Colors( _tex2Dlod( _MainTex, TempUV ), S[3], E[3] );	TempUV.xy -= _dUV.xz;
	UnPack2Colors( _tex2Dlod( _MainTex, TempUV ), S[2], E[2] );	TempUV.xy -= _dUV.zy;

	float2	uv = frac( TempUV.xy * _InvdUV.xy );
	SkyScattering = lerp( lerp( S[0], S[1], uv.x ), lerp( S[2], S[3], uv.x ), uv.y );
	SkyExtinction = lerp( lerp( E[0], E[1], uv.x ), lerp( E[2], E[3], uv.x ), uv.y );

#endif


	//////////////////////////////////////////////////////////////////////////
	// Compute background color
//	float3	BackgroundColor = IsZInfinity( SceneZ ) ? _tex2Dlod( _TexBackground, _In.UV ).xyz : 0.0.xxx;	// MARCHE PAS SUR MAC ! => faire un _tex2Dlod inconditionnel
	float3	BackgroundColor = lerp( 0.0.xxx, _tex2Dlod( _TexBackground, _In.UV ).xyz, SaturateInfinity( SceneZ ) );


	//////////////////////////////////////////////////////////////////////////
	// Compose
	SkyExtinction *= CloudColor.w;
	float3	Scattering = BackgroundColor * SkyExtinction + CloudColor.xyz + SkyScattering;

	return Pack2Colors( Scattering, SkyExtinction );
}

#endif
