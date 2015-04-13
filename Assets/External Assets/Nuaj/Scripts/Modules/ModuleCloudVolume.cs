using System;
using System.Collections.Generic;
using UnityEngine;

namespace Nuaj
{
	/// <summary>
	/// This module is responsible for the display of volumetric clouds
	/// </summary>
	[Serializable]
	public class ModuleCloudVolume : ModuleCloudLayerBase
	{
		#region NESTED TYPES

		/// <summary>
		/// A single layer of 3D volumetric clouds
		/// </summary>
		[Serializable]
		public class	CloudLayer : CloudLayerBase
		{
			#region CONSTANTS

			protected const int		ENVIRONMENT_CLOUD_STEPS_COUNT = 8;	// Use less tracing steps for environment...

			// DEFAULT VALUES
			public const float		DEFAULT_ALTITUDE = 2.0f;
			public const float		DEFAULT_THICKNESS = 2.0f;
			protected const float	DEFAULT_COVERAGE_OFFSET = -0.2f;
			protected const float	DEFAULT_COVERAGE_CONTRAST = 2.0f;
			protected const float	DEFAULT_BEVEL_SOFTNESS = 1.0f;
			protected static readonly Color	DEFAULT_COLOR = Color.white;
			protected const float	DEFAULT_TRACE_LIMITER = 60.0f;
			protected const float	DEFAULT_HORIZON_BLEND_START = 0.0f;
			protected const float	DEFAULT_HORIZON_BLEND_END = 125.0f;

			protected const float	DEFAULT_NOISE_TILING = 0.016f;
			protected const float	DEFAULT_FREQ_FACTOR = 3.0f;
			protected const float	DEFAULT_AMPL_FACTOR = 0.5f;
			protected const float	DEFAULT_WIND_FORCE = 0.0f;
			protected static readonly Vector2	DEFAULT_WIND_DIRECTION = Vector2.right;
			protected const float	DEFAULT_EVOLUTION_SPEED = 8.0f;

			protected const float	DEFAULT_DENSITY = 3.0f;
			protected const float	DEFAULT_ALBEDO_DIRECTIONAL = 0.85f;
			protected const float	DEFAULT_FACTOR_DIRECTIONAL = 0.1f;
			protected const float	DEFAULT_ALBEDO_ISOTROPIC = 0.5f;	// Previously, 0.2
			protected const float	DEFAULT_FACTOR_ISOTROPIC = 0.4f;

			protected const float	DEFAULT_CONTRIBUTION_ISOTROPIC_SKY = 40.0f;
			protected const float	DEFAULT_CONTRIBUTION_ISOTROPIC_SUN = 20.0f;
			protected const float	DEFAULT_CONTRIBUTION_ISOTROPIC_TERRAIN = 0.44f;

			protected const float	DEFAULT_PHASE_ANISOTROPY_SF = 0.95f;
			protected const float	DEFAULT_PHASE_WEIGHT_SF = 0.15f;
			protected const float	DEFAULT_PHASE_ANISOTROPY_F = 0.5f;
			protected const float	DEFAULT_PHASE_WEIGHT_F = 0.3f;
			protected const float	DEFAULT_PHASE_ANISOTROPY_B = -0.2f;
			protected const float	DEFAULT_PHASE_WEIGHT_B = 0.2f;
			protected const int		DEFAULT_STEPS_COUNT = 64;

			protected const int		DEFAULT_SHADOW_MAP_SIZE = 512;
			protected const int		DEFAULT_SHADOW_STEPS_COUNT = 16;
			protected const float	DEFAULT_SHADOW_OPACITY = 0.6f;
			protected const SHADOW_QUALITY	DEFAULT_SHADOW_MAP_QUALITY = SHADOW_QUALITY.DEEP_SHADOW_MAP_ONE_LAYER;
			protected const bool	DEFAULT_SMOOTH_SHADOW_MAP = true;
			protected const float	DEFAULT_SHADOW_SMOOTH_SIZE = 2.35f;

			#endregion

			#region NESTED TYPES

			/// <summary>
			/// Describes the quality of shadowing to use for the volume cloud.
			/// Volume clouds use an internal shadowing scheme that allow to perform volumetric shadowing through the use of several layers of shadow maps called "deep shadow maps".
			/// You can select either one, two or three layers, each layer coding the shadowing of 4 slices. The more the layers, the more accurate the shadowing of course, but also eats up more memory and time.
			/// </summary>
			public enum		SHADOW_QUALITY
			{
				/// <summary>
				/// A deep shadow map with 1 layer of 4 values (total of 4)
				/// </summary>
				DEEP_SHADOW_MAP_ONE_LAYER,
				/// <summary>
				/// A deep shadow map with 2 layers of 4 values (total of 8)
				/// </summary>
				DEEP_SHADOW_MAP_TWO_LAYERS,
				/// <summary>
				/// A deep shadow map with 3 layers of 4 values (total of 12)
				/// </summary>
				DEEP_SHADOW_MAP_THREE_LAYERS,
			}

			#endregion

			#region FIELDS

			protected ModuleCloudVolume					m_Owner = null;

			// Appearance
			[SerializeField] protected float			m_CoverageOffset = DEFAULT_COVERAGE_OFFSET;
			[SerializeField] protected float			m_CoverageContrast = DEFAULT_COVERAGE_CONTRAST;
			[SerializeField] protected float			m_BevelSoftness = DEFAULT_BEVEL_SOFTNESS;
			[SerializeField] protected Color			m_CloudColor = DEFAULT_COLOR;
			[SerializeField] protected float			m_TraceLimiter = DEFAULT_TRACE_LIMITER;
			[SerializeField] protected float			m_HorizonBlendStart = DEFAULT_HORIZON_BLEND_START;
			[SerializeField] protected float			m_HorizonBlendEnd = DEFAULT_HORIZON_BLEND_END;

			// Noise parameters
			[SerializeField] protected float			m_NoiseTiling = DEFAULT_NOISE_TILING;
			[SerializeField] protected float			m_FrequencyFactor = DEFAULT_FREQ_FACTOR;
			[SerializeField] protected float			m_AmplitudeFactor = DEFAULT_AMPL_FACTOR;

			// Animation
			[SerializeField] protected float			m_WindForce = DEFAULT_WIND_FORCE;
			[SerializeField] protected Vector2			m_WindDirection = DEFAULT_WIND_DIRECTION;
			[SerializeField] protected float			m_EvolutionSpeed = DEFAULT_EVOLUTION_SPEED;

			// Lighting parameters
			[SerializeField] protected float			m_Density = DEFAULT_DENSITY;
			[SerializeField] protected float			m_AlbedoDirectional = DEFAULT_ALBEDO_DIRECTIONAL;
			[SerializeField] protected float			m_DirectionalFactor = DEFAULT_FACTOR_DIRECTIONAL;
			[SerializeField] protected float			m_AlbedoIsotropic = DEFAULT_ALBEDO_ISOTROPIC;
			[SerializeField] protected float			m_IsotropicFactor = DEFAULT_FACTOR_ISOTROPIC;

			[SerializeField] protected float			m_IsotropicContributionSky = DEFAULT_CONTRIBUTION_ISOTROPIC_SKY;
			[SerializeField] protected float			m_IsotropicContributionSun = DEFAULT_CONTRIBUTION_ISOTROPIC_SUN;
			[SerializeField] protected float			m_IsotropicContributionTerrain = DEFAULT_CONTRIBUTION_ISOTROPIC_TERRAIN;

				// Phase functions
			[SerializeField] protected float			m_PhaseWeightStrongForward = DEFAULT_PHASE_WEIGHT_SF;
			[SerializeField] protected float			m_PhaseWeightForward = DEFAULT_PHASE_WEIGHT_F;
			[SerializeField] protected float			m_PhaseWeightBackward = DEFAULT_PHASE_WEIGHT_B;

			[SerializeField] protected float			m_PhaseAnisotropyStrongForward = DEFAULT_PHASE_ANISOTROPY_SF;
			[SerializeField] protected float			m_PhaseAnisotropyForward = DEFAULT_PHASE_ANISOTROPY_F;
			[SerializeField] protected float			m_PhaseAnisotropyBackward = DEFAULT_PHASE_ANISOTROPY_B;

			// Rendering quality parameters
			[SerializeField] protected int				m_StepsCount = DEFAULT_STEPS_COUNT;
			[SerializeField] protected int				m_ShadowMapSize = DEFAULT_SHADOW_MAP_SIZE;
			[SerializeField] protected int				m_ShadowStepsCount = DEFAULT_SHADOW_STEPS_COUNT;
			[SerializeField] protected float			m_ShadowOpacity = DEFAULT_SHADOW_OPACITY;
			[SerializeField] protected SHADOW_QUALITY	m_ShadowQuality = DEFAULT_SHADOW_MAP_QUALITY;
			[SerializeField] protected bool				m_bSmoothShadowMap = DEFAULT_SMOOTH_SHADOW_MAP;
			[SerializeField] protected float			m_ShadowSmoothSize = DEFAULT_SHADOW_SMOOTH_SIZE;


			/////////////////////////////////////////////////////////
			// Textures & Targets
			protected RenderTexture				m_RTScatteringDownsampled = null;
			protected RenderTexture[]			m_RTShadowMaps = null;	// Several layers of deep shadow maps, depending on shadow quality
			protected RenderTexture				m_RTShadowMapEnvSky = null;

			// Internal data
			protected Vector4					m_CloudPosition = Vector4.zero;	// Our very own position accumulators

			protected float						m_SigmaExtinction = 0.0f;
			protected float						m_SigmaScattering = 0.0f;
			protected float						m_SigmaScatteringIsotropy = 0.0f;

			#endregion

			#region PROPERTIES

			internal ModuleCloudVolume		Owner
			{
				get { return m_Owner; }
				set
				{
					if ( value == m_Owner )
						return;

					m_Owner = value;
					UpdateCachedValues();
				}
			}

			/// <summary>
			/// Bypass rendering if density or thickness are 0
			/// </summary>
			public override bool	Bypass { get { return m_Density <= 0.0f || m_ThicknessKm <= 0.0f; } }

			/// <summary>
			/// Tells this cloud layer is a volumetric layer
			/// </summary>
			public override bool	IsVolumetric		{ get { return true; } }

			/// <summary>
			/// We sometimes have a downsampled version of the buffer
			/// </summary>
			public override RenderTexture	DownsampledRenderTarget
			{
				get { return m_RTScatteringDownsampled != null ? m_RTScatteringDownsampled : m_RTScattering; }
			}

			#region Rendering

			/// <summary>
			/// Gets or sets the amount of steps of ray-marching for rendering the cloud
			/// The higher the better of course, but also the slower...
			/// </summary>
			public int				StepsCount				{ get { return m_StepsCount; } set { m_StepsCount = Math.Max( 1, value ); } }

			/// <summary>
			/// Gets or sets the shadow map quality
			/// </summary>
			public SHADOW_QUALITY	ShadowQuality
			{
				get { return m_ShadowQuality; }
				set
				{
					if ( value == m_ShadowQuality )
						return;

					m_ShadowQuality = value;

					InitializeShadowMap();

					// Notify
					if ( ShadowQualityChanged != null )
						ShadowQualityChanged( this, EventArgs.Empty );
				}
			}

			/// <summary>
			/// Gets or sets the amount of steps of ray-marching for rendering the cloud's shadow map
			/// The higher the better of course, but also the slower...
			/// </summary>
			public int				ShadowStepsCount		{ get { return m_ShadowStepsCount; } set { m_ShadowStepsCount = Math.Max( 4, value ); } }

			/// <summary>
			/// Gets or sets the shadow opacity
			/// </summary>
			public float			ShadowOpacity			{ get { return m_ShadowOpacity; } set { m_ShadowOpacity = value; } }

			/// <summary>
			/// Gets or sets the size of the internal deep shadow map
			/// </summary>
			public int				ShadowMapSize
			{
				get { return m_ShadowMapSize; }
				set
				{
					value = Math.Max( 64, value );
					if ( value == m_ShadowMapSize )
						return;

					m_ShadowMapSize = value;

					InitializeShadowMap();
				}
			}

			/// <summary>
			/// Tells if we should smooth out the shadow map
			/// </summary>
			public bool						SmoothShadowMap
			{
				get { return m_bSmoothShadowMap; }
				set { m_bSmoothShadowMap = value; }
			}

			/// <summary>
			/// Gets or sets the size of the smoothing kernel
			/// </summary>
			public float					ShadowSmoothSize
			{
				get { return m_ShadowSmoothSize; }
				set { m_ShadowSmoothSize = value; }
			}

			/// <summary>
			/// Occurs whenever the ShadowQuality parameter changes
			/// </summary>
			public event EventHandler		ShadowQualityChanged;

			#endregion

			#region Appearance

			/// <summary>
			/// Gets or sets the cloud's coverage offset
			/// </summary>
			public float					CoverageOffset
			{
				get { return m_CoverageOffset; }
				set { m_CoverageOffset = value; }
			}

			/// <summary>
			/// Gets or sets the cloud's coverage contrast
			/// </summary>
			public float					CoverageContrast
			{
				get { return m_CoverageContrast; }
				set { m_CoverageContrast = value; }
			}

			/// <summary>
			/// Gets or sets the cloud's bevel softness
			/// </summary>
			public float					BevelSoftness
			{
				get { return m_BevelSoftness; }
				set { m_BevelSoftness = Mathf.Clamp01( value ); }
			}

			/// <summary>
			/// Gets or sets the cloud density that influences the capacity of the cloud to absorb and scatter light
			/// </summary>
			public float					Density
			{
				get { return m_Density; }
				set
				{
					if ( Mathf.Approximately( value, m_Density ) )
						return;

					m_Density = value;
					UpdateCachedValues();
				}
			}

			/// <summary>
			/// Gets or sets the cloud density via what is called the "mean free path"
			/// The mean free path is the approximate distance light can travel through the cloud without hitting a particle.
			/// If the mean free path is short (a few meters) then the cloud will likely be very dark as it contains a lot of scattering particles.
			/// If the mean free path is long (up to a few hundred meters) then the cloud will be very bright as almost no light gets scattered.
			/// </summary>
			public float					MeanFreePath
			{
				get { return 1.0f / Math.Max( 1e-3f, 4.0f * Mathf.PI * m_Density ); }
				set
				{
					value = Math.Max( 0.1f, value );
					if ( Mathf.Approximately( value, MeanFreePath ) )
						return;

					Density = 1.0f / (4.0f * Mathf.PI * value);
				}
			}

			/// <summary>
			/// Gets or sets the internal color of the clouds (for funky clouds only)
			/// </summary>
			public Color					CloudColor
			{
				get { return m_CloudColor; }
				set { m_CloudColor = value; }
			}

			/// <summary>
			/// Gets or sets the trace limiter factor that allows to clamp the trace distance and avoid tracing too large steps
			/// </summary>
			public float					TraceLimiter
			{
				get { return m_TraceLimiter; }
				set { m_TraceLimiter = value; }
			}

			/// <summary>
			/// Gets or sets the distance (in kilometers) at which we start blending with the horizon
			/// </summary>
			public float					HorizonBlendStart
			{
				get { return m_HorizonBlendStart; }
				set { m_HorizonBlendStart = value; }
			}

			/// <summary>
			/// Gets or sets the distance (in kilometers) at which we fully blend with the horizon
			/// </summary>
			public float					HorizonBlendEnd
			{
				get { return m_HorizonBlendEnd; }
				set { m_HorizonBlendEnd = value; }
			}

			#endregion

			#region Wind Animation

			/// <summary>
			/// Gets or sets the force of the wind in cloud units per seconds
			/// </summary>
			public float					WindForce
			{
				get { return m_WindForce; }
				set { m_WindForce = value; }
			}

			/// <summary>
			/// Gets or sets the 2D wind direction
			/// </summary>
			public Vector2					WindDirection
			{
				get { return m_WindDirection; }
				set { m_WindDirection = value.normalized; }
			}

			/// <summary>
			/// Gets or sets the angle of the wind
			/// </summary>
			public float					WindDirectionAngle
			{
				get { return Mathf.Atan2( m_WindDirection.y, m_WindDirection.x ); }
				set { WindDirection = new Vector2( Mathf.Cos( value ), Mathf.Sin( value ) ); }
			}

			/// <summary>
			/// Gets or sets the speed at which clouds evolve
			/// </summary>
			public float					EvolutionSpeed
			{
				get { return m_EvolutionSpeed; }
				set { m_EvolutionSpeed = value; }
			}

			#endregion

			#region Noise

			/// <summary>
			/// Gets or sets the tiling factor of the noise texture
			/// </summary>
			public float					NoiseTiling
			{
				get { return m_NoiseTiling; }
				set { m_NoiseTiling = value; }
			}

			/// <summary>
			/// Gets or sets the frequency factor applied for each additional noise octave
			/// </summary>
			public float					FrequencyFactor
			{
				get { return m_FrequencyFactor; }
				set { m_FrequencyFactor = value; }
			}

			/// <summary>
			/// Gets or sets the amplitude factor applied for each additional noise octave
			/// </summary>
			public float					AmplitudeFactor
			{
				get { return m_AmplitudeFactor; }
				set { m_AmplitudeFactor = value; }
			}

			#endregion

			#region Advanced Lighting

			/// <summary>
			/// Gets or sets the cloud albedo for directional lighting.
			/// Cloud albedo (i.e. the ability of the cloud to scatter and reflect light) is defined as a ratio of scattering over extinction.
			/// A value of 0 will yield extremely dark clouds while a value of 1 will reflect all light and absorb nothing (in nature, it is usually considered to be almost 1, because clouds are mostly composed of small water droplets that mainly reflect light : almost no absorption occurs, hence the whiteness of clouds)
			/// </summary>
			public float					AlbedoDirectional
			{
				get { return m_AlbedoDirectional; }
				set
				{
					if ( Mathf.Approximately( value, m_AlbedoDirectional ) )
						return;

					m_AlbedoDirectional = Mathf.Clamp01( value );
					UpdateCachedValues();
				}
			}

			/// <summary>
			/// Gets or sets the factor applied to directional lighting
			/// </summary>
			public float					DirectionalFactor
			{
				get { return m_DirectionalFactor; }
				set { m_DirectionalFactor = value; }
			}

			/// <summary>
			/// Gets or sets the magic isotropic albedo for isotropic lighting.
			/// </summary>
			public float					AlbedoIsotropic
			{
				get { return m_AlbedoIsotropic; }
				set
				{
					if ( Mathf.Approximately( value, m_AlbedoDirectional ) )
						return;

					m_AlbedoIsotropic = Mathf.Clamp01( value );
					UpdateCachedValues();
				}
			}

			/// <summary>
			/// Gets or sets the factor applied to isotropic (i.e. ambient) lighting
			/// </summary>
			public float					IsotropicFactor
			{
				get { return m_IsotropicFactor; }
				set { m_IsotropicFactor = value; }
			}

			/// <summary>
			/// Gets or sets the contribution of sky light to isotropic lighting
			/// </summary>
			public float					IsotropicContributionSky
			{
				get { return m_IsotropicContributionSky; }
				set { m_IsotropicContributionSky = value; }
			}

			/// <summary>
			/// Gets or sets the contribution of Sun light to isotropic lighting
			/// </summary>
			public float					IsotropicContributionSun
			{
				get { return m_IsotropicContributionSun; }
				set { m_IsotropicContributionSun = value; }
			}

			/// <summary>
			/// Gets or sets the contribution of terrain reflected light to isotropic lighting
			/// </summary>
			public float					IsotropicContributionTerrain
			{
				get { return m_IsotropicContributionTerrain; }
				set { m_IsotropicContributionTerrain = value; }
			}

			#region Phases Parameters

			/// <summary>
			/// Gets or sets the anisotropy factor for the "strong-forward" phase
			/// </summary>
			public float					PhaseAnisotropyStrongForward
			{
				get { return m_PhaseAnisotropyStrongForward; }
				set { m_PhaseAnisotropyStrongForward = Mathf.Clamp( value, -1.0f, +1.0f ); }
			}

			/// <summary>
			/// Gets or sets the weight of the "strong-forward" phase
			/// </summary>
			public float					PhaseWeightStrongForward
			{
				get { return m_PhaseWeightStrongForward; }
				set { m_PhaseWeightStrongForward = Mathf.Clamp01( value ); }
			}

			/// <summary>
			/// Gets or sets the anisotropy factor for the "forward" phase
			/// </summary>
			public float					PhaseAnisotropyForward
			{
				get { return m_PhaseAnisotropyForward; }
				set { m_PhaseAnisotropyForward = Mathf.Clamp( value, -1.0f, +1.0f ); }
			}

			/// <summary>
			/// Gets or sets the weight of the "forward" phase
			/// </summary>
			public float					PhaseWeightForward
			{
				get { return m_PhaseWeightForward; }
				set { m_PhaseWeightForward = Mathf.Clamp01( value ); }
			}

			/// <summary>
			/// Gets or sets the anisotropy factor for the "backward" phase
			/// </summary>
			public float					PhaseAnisotropyBackward
			{
				get { return m_PhaseAnisotropyBackward; }
				set { m_PhaseAnisotropyBackward = Mathf.Clamp( value, -1.0f, +1.0f ); }
			}

			/// <summary>
			/// Gets or sets the weight of the "backward" phase
			/// </summary>
			public float					PhaseWeightBackward
			{
				get { return m_PhaseWeightBackward; }
				set { m_PhaseWeightBackward = Mathf.Clamp01( value ); }
			}

			#endregion

			#endregion

			#endregion

			#region METHODS

			public	CloudLayer()
			{
				m_AltitudeKm = DEFAULT_ALTITUDE;
				m_ThicknessKm = DEFAULT_THICKNESS;
			}

			#region IMonoBehaviour Members

			public override void OnDestroy()
			{
				base.OnDestroy();

				DestroyShadowMaps();
			}

			public override void Awake()
			{
				base.Awake();

				InitializeShadowMap();
			}

			public override void OnEnable()
			{
				base.OnEnable();

				// Initialize shadow maps if they're missing
				if ( m_RTShadowMaps == null )
					InitializeShadowMap();

				// Update internal data
				UpdateCachedValues();
			}

			public override void Update()
			{
				// Accumulate position
				Vector2		Wind = m_WindForce * m_WindDirection;
				Vector2		CloudPositionMain = new Vector2( m_CloudPosition.x, m_CloudPosition.y );
				Vector2		CloudPositionOctave = new Vector2( m_CloudPosition.z, m_CloudPosition.w );
							CloudPositionMain += m_NoiseTiling * Wind * NuajTime.DeltaTime;
							CloudPositionOctave += m_EvolutionSpeed * m_NoiseTiling * Wind * NuajTime.DeltaTime;
				m_CloudPosition = new Vector4( CloudPositionMain.x, CloudPositionMain.y, CloudPositionOctave.x, CloudPositionOctave.y );
			}

			#endregion

			#region ICloudLayer Members

			public override void	RenderShadow( int _LayerIndex, RenderTexture _ShadowMap, Rect _ShadowViewport, RenderTexture _ShadowEnvMapSkyTop, bool _bRenderEnvironment )
			{
				if ( m_Owner.m_Owner == null )
					return;	// When using a prefab, the module's owner is invalid

				//////////////////////////////////////////////////////////////////////////
				// Setup material parameters
				NuajMaterial	M = Owner.m_MaterialRenderCloudShadow;
				UploadCloudUniforms( M, _LayerIndex, null );

				//////////////////////////////////////////////////////////////////////////
				// Render the deep shadow map layers
				if ( m_bCastShadow && m_ShadowOpacity > 0.0f )
				{
					int TotalShadowStepsCount = m_ShadowStepsCount * m_RTShadowMaps.Length;

					RenderTexture TempShadowMap = null;
					if ( m_bSmoothShadowMap )
						TempShadowMap = Help.CreateTempRT( m_ShadowMapSize, m_ShadowMapSize, RenderTextureFormat.ARGBHalf, FilterMode.Bilinear, TextureWrapMode.Clamp );

					M.SetVector( "_RenderTargetInvSize", new Vector2( 1.0f / m_ShadowMapSize, 1.0f / m_ShadowMapSize ) );
					M.SetFloat( "_ShadowOpacity", m_ShadowOpacity );
					M.SetVector( "_ShadowStepsCount", new Vector3( m_ShadowStepsCount, TotalShadowStepsCount, 0.25f * m_ShadowStepsCount ) );
					M.SetTexture( "_TexShadowMap", _ShadowMap );

					// Scale viewport based on our shadow map size as compared to main shadow map
					Rect		Viewport = _ShadowViewport;
					if ( m_ShadowMapSize != m_Owner.m_Owner.ShadowMapSize )
					{	// Scale viewport based on our shadow map size as compared to main shadow map
						Matrix4x4	World2ShadowMap, ShadowMap2World;
						Vector4		UVBounds;
						m_Owner.m_Owner.ComputeShadowMapRenderingData( m_ShadowMapSize, out World2ShadowMap, out ShadowMap2World, out Viewport, out UVBounds );

						// Override UV bounds
						M.SetVector( "_ShadowMapUVBounds", UVBounds );
						M.SetMatrix( "_NuajShadow2World", ShadowMap2World );
						M.SetMatrix( "_NuajWorld2Shadow", World2ShadowMap );
					}

					for ( int DeepShadowMapLayerIndex = 0; DeepShadowMapLayerIndex < m_RTShadowMaps.Length; DeepShadowMapLayerIndex++ )
					{
						// Clear shadow map (necessary on Mac otherwise it uses strange uninitialized values that fuck everything up)
						m_Owner.m_Owner.ClearTarget( m_RTShadowMaps[DeepShadowMapLayerIndex], Vector4.zero );

						if ( DeepShadowMapLayerIndex == 0 )
						{	// First layer only samples the global shadow map for initial shadowing
							M.BlitViewport( m_RTShadowMaps[DeepShadowMapLayerIndex], 4, Viewport );
						}
						else
						{	// Subsequent layers read previous layer and start with an offset
							M.SetFloat( "_ShadowLayerIndex", DeepShadowMapLayerIndex );
							M.SetTexture( "_TexDeepShadowMapPreviousLayer", m_RTShadowMaps[DeepShadowMapLayerIndex - 1] );
							M.BlitViewport( m_RTShadowMaps[DeepShadowMapLayerIndex], 5, Viewport );
						}

						if ( m_bSmoothShadowMap )
						{	// Smooth out the shadow map
							M.SetVector( "_dUV", m_ShadowSmoothSize * new Vector4( 1.0f / m_ShadowMapSize, 0.0f, 0.0f, 0.0f ) );
							M.Blit( m_RTShadowMaps[DeepShadowMapLayerIndex], TempShadowMap, 6 );	// First is horizontal pass

							M.SetVector( "_dUV", m_ShadowSmoothSize * new Vector4( 0.0f, 1.0f / m_ShadowMapSize, 0.0f, 0.0f ) );
							M.Blit( TempShadowMap, m_RTShadowMaps[DeepShadowMapLayerIndex], 6 );	// Second is vertical pass
						}
					}

					if ( TempShadowMap != null )
						Help.ReleaseTemporary( TempShadowMap );

					//////////////////////////////////////////////////////////////////////////
					// Render the cloud's shadow into the global shadow map
					M.SetVector( "_RenderTargetInvSize", new Vector2( 1.0f / _ShadowMap.width, 1.0f / _ShadowMap.height ) );
					M.SetTexture( "_TexShadowMap", null as RenderTexture );		// Don't use the shadow map as a texture since we're rendering into it !
					for ( int DeepShadowMapLayerIndex=0; DeepShadowMapLayerIndex < m_RTShadowMaps.Length; DeepShadowMapLayerIndex++ )
						M.SetTexture( "_TexDeepShadowMap" + DeepShadowMapLayerIndex, m_RTShadowMaps[DeepShadowMapLayerIndex] );

					M.BlitViewport( _ShadowMap, _LayerIndex, _ShadowViewport );					// The index of the layer guides the shader choice here.
				}
				else
				{	// Clear to white (i.e. no shadowing)
					for ( int DeepShadowMapLayerIndex=0; DeepShadowMapLayerIndex < m_RTShadowMaps.Length; DeepShadowMapLayerIndex++ )
						m_Owner.Owner.ClearTarget( m_RTShadowMaps[DeepShadowMapLayerIndex], Vector4.one );
				}


				//////////////////////////////////////////////////////////////////////////
				// Render the env map
				if ( _bRenderEnvironment )
				{
					if ( m_bCastShadow && m_ShadowOpacity > 0.0f )
					{	// Render the tiny environment shadow map
						M.Blit( null, m_RTShadowMapEnvSky, 7 );
						M.SetTexture( "_TexDeepShadowMap0", m_RTShadowMapEnvSky );
					}
					else
 						M.SetTexture( "_TexDeepShadowMap0", m_Owner.m_Owner.m_TextureBlack, true );

					M.SetFloat( "_StepsCount", ENVIRONMENT_CLOUD_STEPS_COUNT );
					if ( _ShadowEnvMapSkyTop )
						M.SetTexture( "_TexShadowEnvMapSkyTop", _ShadowEnvMapSkyTop );
					else
						M.SetTexture( "_TexShadowEnvMapSkyTop", m_Owner.m_Owner.m_TextureEmptyCloud, true );
 					M.SetTexture( "_TexShadowEnvMapSkyBottom", m_Owner.m_Owner.m_TextureEmptyCloud, true );
					M.Blit( null, m_RTEnvMapSky, 8 );

					// Downsample into a 1x1 version of the environment sky map for ambient shadowing
					m_Owner.m_Owner.ModuleSky.DownsampleSkyEnvMap( m_RTEnvMapSky, m_RTEnvMapSkyDownsampled, _ShadowEnvMapSkyTop );
				}
				else
					m_Owner.m_Owner.ClearTarget( m_RTEnvMapSkyDownsampled, new Vector4( 0, 0, 0, 1 ) );
			}

			public override void	Render( int _LayerIndex, RenderTexture _ShadowMap, Rect _ShadowViewport, RenderTexture _ShadowEnvMapSkyTop )
			{
				if ( m_Owner.m_Owner == null )
					return;	// When using a prefab, the module's owner is invalid

				// Downsample the ZBuffer
				RenderTexture	DownsampledZBuffer = Owner.Owner.DownsampleZBuffer( Owner.m_DownsampleFactor );

				//////////////////////////////////////////////////////////////////////////
				// Setup material parameters
 				NuajMaterial	M = Owner.m_MaterialRenderCloud;
				UploadCloudUniforms( M, _LayerIndex, DownsampledZBuffer );

				M.SetTexture( "_TexShadowEnvMapSkyTop", _ShadowEnvMapSkyTop );
				M.SetTexture( "_TexShadowEnvMapSkyBottom", m_RTEnvMapSkyDownsampled );

				M.SetFloat( "_StepsCount", m_StepsCount );

				// Upload deep shadow maps
				for ( int DeepShadowMapLayerIndex=0; DeepShadowMapLayerIndex < m_RTShadowMaps.Length; DeepShadowMapLayerIndex++ )
					M.SetTexture( "_TexDeepShadowMap" + DeepShadowMapLayerIndex, m_RTShadowMaps[DeepShadowMapLayerIndex] );

				// Scale viewport based on our shadow map size as compared to main shadow map
				if ( m_ShadowMapSize != m_Owner.m_Owner.ShadowMapSize )
				{	// Scale viewport based on our shadow map size as compared to main shadow map
					Matrix4x4	World2ShadowMap, ShadowMap2World;
					Vector4		UVBounds;
					Rect		Viewport;
					m_Owner.m_Owner.ComputeShadowMapRenderingData( m_ShadowMapSize, out World2ShadowMap, out ShadowMap2World, out Viewport, out UVBounds );

					// Override UV bounds
					M.SetVector( "_ShadowMapUVBounds", UVBounds );
					M.SetMatrix( "_NuajShadow2World", ShadowMap2World );
					M.SetMatrix( "_NuajWorld2Shadow", World2ShadowMap );
				}

				//////////////////////////////////////////////////////////////////////////
				// Main rendering
				NuajManager.UPSAMPLING_TECHNIQUE	UpsamplingTechnique = m_Owner.m_Owner.UpsamplingTechnique;
				if ( UpsamplingTechnique != NuajManager.UPSAMPLING_TECHNIQUE.BILINEAR )
				{
					RenderTexture	RTTempScattering = m_RTScatteringDownsampled;
					// ===== Render to the downsampled buffer =====
					M.SetVector( "_RenderTargetInvSize", new Vector2( 1.0f / RTTempScattering.width, 1.0f / RTTempScattering.height ) );
					M.SetFloat( "_UseSceneZ", UpsamplingTechnique == NuajManager.UPSAMPLING_TECHNIQUE.CUTOUT ? 0.0f : 1.0f );
					M.Blit( null, RTTempScattering, 0 );

 					// ===== UpSample to the full size buffer =====
 					M.SetVector( "_dUV", new Vector4( 1.0f / RTTempScattering.width, 1.0f / RTTempScattering.height, 0.0f, 0.0f ) );
					M.SetVector( "_InvdUV", new Vector4( RTTempScattering.width, RTTempScattering.height, 0.0f, 0.0f ) );
					M.SetVector( "_RenderTargetInvSize", new Vector2( 1.0f / m_RTScattering.width, 1.0f / m_RTScattering.height ) );

					int		ShaderIndex = -1;
					if ( UpsamplingTechnique == NuajManager.UPSAMPLING_TECHNIQUE.ACCURATE )
					{
						ShaderIndex = 1;
						M.SetVector( "_ZBufferDiscrepancyThreshold", new Vector3( m_Owner.m_Owner.ZBufferDiscrepancyThreshold, m_Owner.m_Owner.ShowZBufferDiscrepancies ? 1.0f : 0.0f, 0.0f ) );
					}
					else if ( UpsamplingTechnique == NuajManager.UPSAMPLING_TECHNIQUE.SMART )
					{
						ShaderIndex = 2;
						M.SetVector( "_ZBufferDiscrepancyThreshold", new Vector3( 1.0f / Mathf.Max( 1e-3f, m_Owner.m_Owner.SmartUpsamplingWeightFactor ), m_Owner.m_Owner.ShowZBufferDiscrepancies ? 1.0f : 0.0f, 0.1f * m_Owner.m_Owner.SmartUpsamplingCutoutFactor ) );
					}
					else if ( UpsamplingTechnique == NuajManager.UPSAMPLING_TECHNIQUE.CUTOUT )
					{
						ShaderIndex = 3;
					}
					M.Blit( RTTempScattering, m_RTScattering, ShaderIndex );
				}
				else
				{	// Direct render to downsampled buffer
					M.SetVector( "_RenderTargetInvSize", new Vector2( 1.0f / m_RTScattering.width, 1.0f / m_RTScattering.height ) );
					M.SetFloat( "_UseSceneZ", 1.0f );
					M.Blit( null, m_RTScattering, 0 );
				}
			}

			#endregion

			/// <summary>
			/// Resets the layer to its default values
			/// </summary>
			public override void		Reset()
			{
				base.Reset();

				Altitude = DEFAULT_ALTITUDE;
				Thickness = DEFAULT_THICKNESS;
				CoverageOffset = DEFAULT_COVERAGE_OFFSET;
				CoverageContrast = DEFAULT_COVERAGE_CONTRAST;
				BevelSoftness = DEFAULT_BEVEL_SOFTNESS;
				Density = DEFAULT_DENSITY;
				CloudColor = DEFAULT_COLOR;
				TraceLimiter = DEFAULT_TRACE_LIMITER;
				HorizonBlendStart = DEFAULT_HORIZON_BLEND_START;
				HorizonBlendEnd = DEFAULT_HORIZON_BLEND_END;
				NoiseTiling = DEFAULT_NOISE_TILING;
				FrequencyFactor = DEFAULT_FREQ_FACTOR;
				AmplitudeFactor = DEFAULT_AMPL_FACTOR;
				WindForce = DEFAULT_WIND_FORCE;
				WindDirection = DEFAULT_WIND_DIRECTION;
				EvolutionSpeed = DEFAULT_EVOLUTION_SPEED;
				AlbedoDirectional = DEFAULT_ALBEDO_DIRECTIONAL;
				AlbedoIsotropic = DEFAULT_ALBEDO_ISOTROPIC;
				DirectionalFactor = DEFAULT_FACTOR_DIRECTIONAL;
				IsotropicFactor = DEFAULT_FACTOR_ISOTROPIC;
				IsotropicContributionSky = DEFAULT_CONTRIBUTION_ISOTROPIC_SKY;
				IsotropicContributionSun = DEFAULT_CONTRIBUTION_ISOTROPIC_SUN;
				IsotropicContributionTerrain = DEFAULT_CONTRIBUTION_ISOTROPIC_TERRAIN;
				PhaseWeightStrongForward = DEFAULT_PHASE_WEIGHT_SF;
				PhaseWeightForward = DEFAULT_PHASE_WEIGHT_F;
				PhaseWeightBackward = DEFAULT_PHASE_WEIGHT_B;
				PhaseAnisotropyStrongForward = DEFAULT_PHASE_ANISOTROPY_SF;
				PhaseAnisotropyForward = DEFAULT_PHASE_ANISOTROPY_F;
				PhaseAnisotropyBackward = DEFAULT_PHASE_ANISOTROPY_B;
				StepsCount = DEFAULT_STEPS_COUNT;
				ShadowMapSize = DEFAULT_SHADOW_MAP_SIZE;
				ShadowStepsCount = DEFAULT_SHADOW_STEPS_COUNT;
				ShadowOpacity = DEFAULT_SHADOW_OPACITY;
				ShadowQuality = DEFAULT_SHADOW_MAP_QUALITY;
				SmoothShadowMap = DEFAULT_SMOOTH_SHADOW_MAP;
				ShadowSmoothSize = DEFAULT_SHADOW_SMOOTH_SIZE;
			}

			/// <summary>
			/// Uploads the uniforms for clouds rendering
			/// </summary>
			/// <param name="_LayerIndex"></param>
			/// <param name="M"></param>
			/// <param name="_UploadLightingConstants"></param>
			protected void	UploadCloudUniforms( NuajMaterial M, int _LayerIndex, RenderTexture _DownsampledZBuffer )
			{
				Vector2		AmplitudeFactor = new Vector2( m_AmplitudeFactor, 1.0f / (1.0f + m_AmplitudeFactor * (1.0f + m_AmplitudeFactor * (1.0f + m_AmplitudeFactor))) );

				float		CoverageOffset = Mathf.Lerp( -1.0f, 0.25f, 0.5f * (1.0f + m_CoverageOffset) );	// Rescale the coverage to match 2D layer behaviour
				Vector2		HorizonBlend = new Vector2( m_HorizonBlendStart, m_HorizonBlendEnd );

				M.SetVector( "_CloudAltitudeKm", new Vector4( m_AltitudeKm, m_AltitudeKm+m_ThicknessKm, m_ThicknessKm, 1.0f / m_ThicknessKm ) );
				M.SetFloat( "_CloudLayerIndex", _LayerIndex );
				if ( _DownsampledZBuffer != null )
					M.SetTexture( "_TexDownsampledZBuffer", _DownsampledZBuffer );

				// Noise parameters
				M.SetVector( "_Coverage", new Vector3( CoverageOffset, m_CoverageContrast, m_BevelSoftness ) );
				M.SetFloat( "_CloudTraceLimiter", m_TraceLimiter );
				M.SetVector( "_HorizonBlend", HorizonBlend );
				M.SetFloat( "_NoiseTiling", m_NoiseTiling );
				M.SetFloat( "_FrequencyFactor", m_FrequencyFactor );
				M.SetVector( "_AmplitudeFactor", AmplitudeFactor );
				M.SetVector( "_CloudPosition", m_CloudPosition );

				// Lighting parameters
				M.SetFloat( "_CloudSigma_s", m_SigmaScattering );
				M.SetFloat( "_CloudSigma_t", m_SigmaExtinction );
				M.SetFloat( "_CloudSigma_s_Isotropy", m_SigmaScatteringIsotropy );
				M.SetColor( "_CloudColor", m_CloudColor );
				M.SetFloat( "_PhaseAnisotropyStrongForward", m_PhaseAnisotropyStrongForward );
				M.SetFloat( "_PhaseAnisotropyForward", m_PhaseAnisotropyForward );
				M.SetFloat( "_PhaseAnisotropyBackward", m_PhaseAnisotropyBackward );
				M.SetFloat( "_PhaseWeightStrongForward", m_PhaseWeightStrongForward );
				M.SetFloat( "_PhaseWeightForward", m_PhaseWeightForward );
				M.SetFloat( "_PhaseWeightBackward", m_PhaseWeightBackward );
				M.SetFloat( "_DirectionalFactor", m_DirectionalFactor );
				M.SetFloat( "_IsotropicFactor", m_IsotropicFactor );
				M.SetVector( "_IsotropicScatteringFactors", new Vector3( m_IsotropicContributionSky, m_IsotropicContributionSun, m_IsotropicContributionTerrain ) );

				// Rendering parameters
				M.SetFloat( "_ShadowLayersCount", 4 * m_RTShadowMaps.Length );

				// Since we need sky support for Sun attenuation computation
				m_Owner.Owner.ModuleSky.SetupScatteringCoefficients( M, true );
			}

			protected void	InitializeShadowMap()
			{
				DestroyShadowMaps();

				int	ShadowLayersCount = 0;
				switch ( m_ShadowQuality )
				{
					case SHADOW_QUALITY.DEEP_SHADOW_MAP_ONE_LAYER:
						ShadowLayersCount = 1;
						break;
					case SHADOW_QUALITY.DEEP_SHADOW_MAP_TWO_LAYERS:
						ShadowLayersCount = 2;
						break;
					case SHADOW_QUALITY.DEEP_SHADOW_MAP_THREE_LAYERS:
						ShadowLayersCount = 3;
						break;
				}

				if ( ShadowLayersCount == 0 )
					return;	// No shadow map...

				// Create the new shadow map layers
				m_RTShadowMaps = new RenderTexture[ShadowLayersCount];
				for ( int LayerIndex=0; LayerIndex < ShadowLayersCount; LayerIndex++ )
					m_RTShadowMaps[LayerIndex] = Help.CreateRT( "VolumeDeepShadowMap Layer #" + LayerIndex, m_ShadowMapSize, m_ShadowMapSize, RenderTextureFormat.ARGBHalf, FilterMode.Bilinear, TextureWrapMode.Clamp );
				m_RTShadowMapEnvSky = Help.CreateRT( "VolumeDeepShadowMap Env Sky", 2 << NuajManager.ENVIRONMENT_TEXTURE_SIZE_POT, 1 << NuajManager.ENVIRONMENT_TEXTURE_SIZE_POT, RenderTextureFormat.ARGBHalf, FilterMode.Bilinear, TextureWrapMode.Clamp );
			}

			protected void	DestroyShadowMaps()
			{
				if ( m_RTShadowMaps == null )
					return;	// Already cleared...

				// Destroy existing shadow maps
				Help.SafeDestroy( ref m_RTShadowMapEnvSky );
				for ( int LayerIndex=0; LayerIndex < m_RTShadowMaps.Length; LayerIndex++ )
					Help.SafeDestroy( ref m_RTShadowMaps[LayerIndex] );
				m_RTShadowMaps = null;
			}

			internal override void	CreateRenderTargets( int _Width, int _Height )
			{
				if ( m_Owner.m_Owner == null )
					return;	// When using a prefab, the module's owner is invalid

				int		Width = _Width;
				int		Height = _Height;
				if ( m_Owner.m_Owner.UpsamplingTechnique != NuajManager.UPSAMPLING_TECHNIQUE.BILINEAR )
				{	// Use fullscale size !
					Width = m_Owner.m_ScreenWidth;
					Height = m_Owner.m_ScreenHeight;

					// But we also render in a downsampled buffer before upsampling to full size...
					m_RTScatteringDownsampled = Help.CreateRT( "VolumeCloudTargetDownsampled", _Width, _Height, RenderTextureFormat.ARGBHalf, m_Owner.m_Owner.UpsamplingTechnique == NuajManager.UPSAMPLING_TECHNIQUE.CUTOUT ? FilterMode.Bilinear : FilterMode.Point, TextureWrapMode.Clamp );
				}

				m_RTScattering = Help.CreateRT( "VolumeCloudTarget", Width, Height, RenderTextureFormat.ARGBHalf, FilterMode.Bilinear, TextureWrapMode.Clamp );

				CreateEnvMaps( "VolumeCloudEnvMap" );
			}

			internal override void	DestroyRenderTargets()
			{
				Help.SafeDestroy( ref m_RTScattering );
				Help.SafeDestroy( ref m_RTScatteringDownsampled );
			}

			internal override void UpsamplingTechniqueChanged( NuajManager.UPSAMPLING_TECHNIQUE _Technique )
			{
				base.UpsamplingTechniqueChanged( _Technique );

				// Re-allocate render targets
				DestroyRenderTargets();
				CreateRenderTargets( m_Owner.m_Width, m_Owner.m_Height );
			}

			protected override void	UpdateCachedValues()
			{
				base.UpdateCachedValues();

				m_SigmaExtinction = 4.0f * Mathf.PI * m_Density;
				m_SigmaScattering = m_AlbedoDirectional * m_SigmaExtinction;
				m_SigmaScatteringIsotropy = m_AlbedoIsotropic;
			}

			#endregion
		}

		#endregion

		#region FIELDS

		/////////////////////////////////////////////////////////
		// General serializable parameters
		[SerializeField] protected float				m_DownsampleFactor = 0.25f;
		[SerializeField] protected List<CloudLayer>		m_CloudLayers = new List<CloudLayer>();
		[SerializeField] protected int					m_SelectedLayerIndex = -1;


		/////////////////////////////////////////////////////////
		// Materials
		protected NuajMaterial			m_MaterialRenderCloud = null;
		protected NuajMaterial			m_MaterialRenderCloudShadow = null;

		#endregion

		#region PROPERTIES

		/// <summary>
		/// Gets the owner NuajManager instance
		/// </summary>
		public override NuajManager Owner
		{
			get { return base.Owner; }
			internal set
			{
				base.Owner = value;

				// Also reconnect the layers' owner
				foreach ( CloudLayer L in m_CloudLayers )
					L.Owner = this;
			}
		}

		/// <summary>
		/// Gets or sets the downsample factor the module will render with
		/// </summary>
		public float		DownsampleFactor
		{
			get { return m_DownsampleFactor; }
			set
			{
				value = Math.Max( 0.05f, Math.Min( 1.0f, value ) );
				if ( value == m_DownsampleFactor )
					return;

				m_DownsampleFactor = value;
				
				// Update render targets
				UpdateRenderTargets();
			}
		}

		/// <summary>
		/// Gets the list of existing clouds layers
		/// </summary>
		public override ICloudLayer[]	CloudLayers		{ get { return m_CloudLayers.ToArray(); } }

		/// <summary>
		/// Gets or sets the cloud layer currently selected by the user (a GUI thingy really)
		/// </summary>
		public CloudLayer	SelectedLayer
		{
			get { return m_SelectedLayerIndex >= 0 && m_SelectedLayerIndex < m_CloudLayers.Count ? m_CloudLayers[m_SelectedLayerIndex] : null; }
			set
			{
				if ( value == null )
					m_SelectedLayerIndex = -1;
				else
					m_SelectedLayerIndex = m_CloudLayers.IndexOf( value );
			}
		}

		/// <summary>
		/// Gets the amount of existing cloud layers
		/// </summary>
		public int			CloudLayersCount			{ get { return m_CloudLayers.Count; } }

		#endregion

		#region METHODS

		internal	ModuleCloudVolume( string _Name ) : base( _Name )
		{
		}

		#region IMonoBehaviour Members

		public override void OnDestroy()
		{
			// Forward to layers
			foreach ( CloudLayer L in m_CloudLayers )
				L.OnDestroy();
		}

		public override void Awake()
		{
			// Forward to layers
			foreach ( CloudLayer L in m_CloudLayers )
			{
				L.Owner = this;
				L.Awake();
			}
		}

		public override void Start()
		{
			// Forward to layers
			foreach ( CloudLayer L in m_CloudLayers )
				L.Start();
		}

		public override void OnEnable()
		{
			try
			{
				m_MaterialRenderCloud = Help.CreateMaterial( "Clouds/CloudVolume" );
				m_MaterialRenderCloudShadow = Help.CreateMaterial( "Clouds/CloudVolumeShadow" );

				ExitErrorState();
			}
			catch ( Exception _e )
			{
				EnterErrorState( "An error occurred while creating the materials for the module.\r\n" + _e.Message );
			}

			// Forward to layers
			foreach ( CloudLayer L in m_CloudLayers )
				L.OnEnable();
		}

		public override void OnDisable()
		{
			// Forward to layers
			foreach ( CloudLayer L in m_CloudLayers )
				L.OnDisable();

			Help.SafeDestroyNuaj( ref m_MaterialRenderCloud );
			Help.SafeDestroyNuaj( ref m_MaterialRenderCloudShadow );
		}

		public override void Update()
		{
			// Forward to layers
			foreach ( CloudLayer L in m_CloudLayers )
				L.Update();
		}

		#endregion

		/// <summary>
		/// Adds a new cloud layer at specified altitude and of specified thickness
		/// </summary>
		/// <param name="_Altitude">The altitude (in kilometers) of the cloud layer</param>
		/// <param name="_Thickness">The thickness (in kilometers) of the cloud layer</param>
		/// <returns></returns>
		public CloudLayer	AddLayer( float _Altitude, float _Thickness )
		{
			CloudLayer	Result = new CloudLayer();
			Result.Owner = this;
			Result.CreateRenderTargets( m_Width, m_Height );
			Result.Altitude = _Altitude;
			Result.Thickness = _Thickness;

			// Simulate Unity steps
			Result.Awake();
			Result.Start();
			Result.OnEnable();

			m_CloudLayers.Add( Result );

			// Update selection
			if ( SelectedLayer == null )
				SelectedLayer = Result;

			NotifyLayersChanged();

			return Result;
		}

		/// <summary>
		/// Removes an existing layer
		/// </summary>
		/// <param name="_Layer"></param>
		public void			RemoveLayer( CloudLayer _Layer )
		{
			if ( !m_CloudLayers.Contains( _Layer ) )
				return;

			// Backup selection
			CloudLayer	PreviousSelection = SelectedLayer;

			// Simulate Unity steps
			_Layer.OnDisable();
			_Layer.OnDestroy();

			m_CloudLayers.Remove( _Layer );

			// Restore selection
			SelectedLayer = PreviousSelection;
			if ( SelectedLayer == null && m_CloudLayers.Count > 0 )
				SelectedLayer = m_CloudLayers[0];	// Select first layer otherwise...

			NotifyLayersChanged();
		}

		#region Render Targets Size Update

		protected override void	InternalCreateRenderTargets()
		{
			// Compute downsampled with & height
			m_Width = (int) Math.Floor( m_DownsampleFactor * m_ScreenWidth );
			m_Width = Math.Max( 32, m_Width );

			m_Height = (int) Math.Floor( m_DownsampleFactor * m_ScreenHeight );
			m_Height = Math.Max( 32, m_Height );

			// Build targets
			foreach ( CloudLayer L in m_CloudLayers )
				L.CreateRenderTargets( m_Width, m_Height );
		}

		protected override void	InternalDestroyRenderTargets()
		{
			foreach ( CloudLayer L in m_CloudLayers )
				L.DestroyRenderTargets();
		}

		#endregion

		#endregion
	}
}