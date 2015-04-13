using System;
using System.Collections;
using UnityEngine;

namespace Nuaj
{
	/// <summary>
	/// This module is responsible for aerial perspective of the entire viewport
	/// It's inspired from "Display of Earth Taking into Account Atmospheric Scattering" (1993) by Nishita et Al. (http://nis-lab.is.s.u-tokyo.ac.jp/~nis/cdrom/sig93_nis.pdf)
	/// It also mixes the 4 possible cloud layers together
	/// </summary>
	[Serializable]
	public class ModulePerspective : ModuleCloudLayerBase
	{
		#region CONSTANTS

		/// <summary>
		/// Defines the default density of air molecules at sea level used for Rayleigh scattering
		/// </summary>
		public const float					DEFAULT_RAYLEIGH_DENSITY = 1e-5f * 14.0f;

		/// <summary>
		/// Defines the default density of aerosols at sea level used for Mie scattering
		/// </summary>
		public const float					DEFAULT_MIE_DENSITY = 1e-4f * 50.0f;

		protected const float				DEFAULT_MIE_ANISOTROPY = 0.5f;

		protected const int					DENSITY_TEXTURE_SIZE = 128;

		protected const float				H0_AIR = 7.994f;					// Altitude scale factor for air molecules
		protected const float				H0_AEROSOLS = 1.200f;				// Altitude scale factor for aerosols
		protected const int					DENSITY_TEXTURE_STEPS_COUNT = 256;	// Ray marching steps count for the density texture

		// This is the place where you can change the color of the sky to create extra-terrestrial skies at will
		// Note that you will need to disable/enable the manager for the changes to take effect...
		protected static readonly Vector3	WAVELENGTHS = new Vector3( 0.650f, 0.570f, 0.475f );								// RGB wavelengths λ in µm 
		protected static readonly Vector3	WAVELENGTHS_POW4 = new Vector3( 0.17850625f, 0.10556001f, 0.050906640625f );		// λ^4 
		protected static readonly Vector3	INV_WAVELENGTHS_POW4 = new Vector3( 5.6020447463324113301354994573019f, 9.4732844379230354373782268493533f, 19.643802610477206282947491194819f );	// 1/λ^4 

		// Environment rendering
		protected const float				ENVIRONMENT_THETA_START = 0.02f * Mathf.PI;
		protected const float				ENVIRONMENT_THETA_END = 0.5f * Mathf.PI;//0.49f * Mathf.PI;
		protected const float				ENVIRONMENT_PHI_START = 0.0f * Mathf.PI;
		protected const float				ENVIRONMENT_PHI_END = 2.0f * Mathf.PI;

		#endregion
		
		#region NESTED TYPES

		/// <summary>
		/// Defines the various available sky models
		/// </summary>
		public enum SKY_MODEL
		{
			/// <summary>
			/// The complex volumetric sky model allows godrays and flight to outer space as it accounts for decreasing particles density towards high altitudes
			/// </summary>
			COMPLEX,

			/// <summary>
			/// The simple volumetric uses a constant particles density and doesn't account for volumetric effects so there is no godrays nor flight to outer space
			/// This model is obviously faster than the complex sky model but also less accurate
			/// </summary>
			SIMPLE,

			/// <summary>
			/// This model simply composes the clouds and background together without computing any sky model
			/// It can be usedful to create a standalone cloud in space, like a nebula or a galaxy for example...
			/// </summary>
			NONE
		}

		/// <summary>
		/// Defines a layer for low-altitude fog
		/// </summary>
		[Serializable]
		public class	FogLayer : CloudLayerBase
		{
			#region CONSTANTS

			protected const int		ENVIRONMENT_CLOUD_STEPS_COUNT = 8;

			// DEFAULT VALUES
			protected const float	DEFAULT_ALTITUDE = 0.0f;	// Default fog altitude on construction
			protected const float	DEFAULT_THICKNESS = 2.0f;	// Default fog thickness on construction
			protected static readonly Color	DEFAULT_COLOR = Color.white;
			protected const int		DEFAULT_STEPS_COUNT = 8;
			protected const float	DEFAULT_STEP_SIZE = 0.1f;
			protected const float	DEFAULT_DENSITY_FACTOR = 1.0f;
			protected const float	DEFAULT_DENSITY_RATIO_BOTTOM = 1.0f;
			protected const float	DEFAULT_FOG_MAX_DISTANCE = 8.0f;
			protected const float	DEFAULT_ISOTROPIC_SKY_FACTOR = 1.0f;
			protected static readonly Vector2	DEFAULT_NOISE_TILING = Vector2.one;
			protected const float	DEFAULT_NOISE_AMPLITUDE = 1.0f;
			protected const float	DEFAULT_NOISE_OFFSET = 0.0f;
			protected const float	DEFAULT_WIND_FORCE = 0.0f;
			protected static readonly Vector2	DEFAULT_WIND_DIRECTION = Vector2.right;
			protected const float	DEFAULT_DOWNPOUR_STRENGTH = 0.0f;

			#endregion

			#region FIELDS

			protected ModulePerspective					m_Owner = null;

			/////////////////////////////////////////////////////////
			// General serializable parameters

			// Appearance
			[SerializeField] protected GameObject		m_FogLocator = null;
			[SerializeField] protected Color			m_Color = DEFAULT_COLOR;
			[SerializeField] protected int				m_StepsCount = DEFAULT_STEPS_COUNT;
			[SerializeField] protected float			m_StepSize = DEFAULT_STEP_SIZE;
			[SerializeField] protected float			m_MieDensityFactor = DEFAULT_DENSITY_FACTOR;
			[SerializeField] protected float			m_DensityRatioBottom = DEFAULT_DENSITY_RATIO_BOTTOM;
			[SerializeField] protected float			m_FogMaxDistance = DEFAULT_FOG_MAX_DISTANCE;
			[SerializeField] protected float			m_IsotropicSkyFactor = DEFAULT_ISOTROPIC_SKY_FACTOR;

			// Noise
			[SerializeField] protected Vector2			m_NoiseTiling = DEFAULT_NOISE_TILING;
			[SerializeField] protected float			m_NoiseAmplitude = DEFAULT_NOISE_AMPLITUDE;
			[SerializeField] protected float			m_NoiseOffset = DEFAULT_NOISE_OFFSET;

			// Animation
			[SerializeField] protected float			m_WindForce = DEFAULT_WIND_FORCE;
			[SerializeField] protected Vector2			m_WindDirection = DEFAULT_WIND_DIRECTION;
			[SerializeField] protected float			m_DownpourStrength = DEFAULT_DOWNPOUR_STRENGTH;


			/////////////////////////////////////////////////////////
			// Materials
			protected NuajMaterial			m_MaterialRender = null;

			/////////////////////////////////////////////////////////
			// Internal data
			protected RenderTexture			m_RTScatteringDownsampled = null;
			protected Vector3				m_FogNoisePosition = Vector3.zero;

			// Cached density values
			protected NuajTexture2D			m_DensityTexture = new NuajTexture2D();
			protected Matrix4x4				m_Density2World, m_World2Density;
			protected Vector4				m_DensityOffset = Vector4.zero;
			protected Vector4				m_DensityFactor = Vector4.one;

			#endregion

			#region PROPERTIES

			internal ModulePerspective		Owner
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
			/// Tells this cloud layer is a volumetric layer
			/// </summary>
			public override bool IsVolumetric		{ get { return true; } }

			/// <summary>
			/// Bypass rendering in case the density or thickness is 0
			/// </summary>
			public override bool Bypass				{ get { return m_MieDensityFactor < 1e-3f || m_Owner.m_SigmaMie < 1e-3f || m_ThicknessKm < 1e-3f; } }

			/// <summary>
			/// We sometimes have a downsampled version of the buffer
			/// </summary>
			public override RenderTexture	DownsampledRenderTarget
			{
				get { return m_RTScatteringDownsampled != null ? m_RTScatteringDownsampled : m_RTScattering; }
			}

			#region Appearance

			/// <summary>
			/// Gets or sets the locator that allows you to specify the location, size and density of the fog layer.
			/// </summary>
			public GameObject				FogLocator
			{
				get { return m_FogLocator; }
				set
				{
					if ( value == m_FogLocator )
						return;
					if ( value != null && !value.GetComponent<NuajMapLocator>() )
					{	// Not a camera !
						Nuaj.Help.LogError( "The GameObject assigned as FogLocator must have a NuajMapLocator component !" ); 
						return;
					}

					m_FogLocator = value;
					UpdateCachedValues();
				}
			}

			/// <summary>
			/// Gets or sets the fog color
			/// </summary>
			public Color					Color
			{
				get { return m_Color; }
				set { m_Color = value; }
			}

			/// <summary>
			/// Gets or sets the amount of marching steps for rendering
			/// This has a strong impact on quality as well as speed (increasing steps count increases quality but also decreases speed of course, in case you were wondering ^^)
			/// </summary>
			public int						StepsCount
			{
				get { return m_StepsCount; }
				set { m_StepsCount = value; }
			}

			/// <summary>
			/// Gets or sets the size of each step in the fog (in kilometers)
			/// Setting large steps covers more ground but makes the fog less precise. Large steps are good when dealing with low density fog, or a fog that starts far away from the camera.
			/// Small steps makes the fog more precise, which is useful in a high density/close fog.
			/// </summary>
			public float					StepSize
			{
				get { return m_StepSize; }
				set { m_StepSize = value; }
			}

			/// <summary>
			/// Gets or sets the factor applied the sky's Mie density
			/// This factors adds up on top of the factor that can be found in the Fog Locator but this parameter here is easier to use.
			/// </summary>
			public float					MieDensityFactor
			{
				get { return m_MieDensityFactor; }
				set
				{
					if ( Mathf.Approximately( value, m_MieDensityFactor ) )
						return;

					m_MieDensityFactor = value;
					UpdateCachedValues();
				}
			}

			/// <summary>
			/// Gets or sets the density ratio at the bottom of the fog layer.
			/// This is used to increase density depending on the height within the fog layer. You can thus create very dense fog (ratio > 1) at its base or almost inexisting fog (ratio = 0).
			/// </summary>
			public float					DensityRatioBottom
			{
				get { return m_DensityRatioBottom; }
				set { m_DensityRatioBottom = value; }
			}

			/// <summary>
			/// Gets or sets the maximum distance at which the fog is in effect
			/// </summary>
			public float					MaxDistance
			{
				get { return m_FogMaxDistance; }
				set { m_FogMaxDistance = value; }
			}

			/// <summary>
			/// Gets or sets the factor of isotropic sky diffusion within the fog
			/// </summary>
			public float					IsotropicSkyFactor
			{
				get { return m_IsotropicSkyFactor; }
				set { m_IsotropicSkyFactor = value; }
			}

			#endregion

			#region Noise

			/// <summary>
			/// Gets or sets the horizontal noise tiling factor
			/// </summary>
			public float					NoiseTilingHorizontal
			{
				get { return m_NoiseTiling.x; }
				set { m_NoiseTiling.x = value; }
			}

			/// <summary>
			/// Gets or sets the vertical noise tiling factor
			/// </summary>
			public float					NoiseTilingVertical
			{
				get { return m_NoiseTiling.y; }
				set { m_NoiseTiling.y = value; }
			}

			/// <summary>
			/// Gets or sets the noise amplitude factor
			/// </summary>
			public float					NoiseAmplitude
			{
				get { return m_NoiseAmplitude; }
				set { m_NoiseAmplitude = value; }
			}

			/// <summary>
			/// Gets or sets the noise offset
			/// </summary>
			public float					NoiseOffset
			{
				get { return m_NoiseOffset; }
				set { m_NoiseOffset = value; }
			}

			#endregion

			#region Animation

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
			/// Gets or sets the strength of the rain downpour
			/// </summary>
			public float					DownpourStrength
			{
				get { return m_DownpourStrength; }
				set { m_DownpourStrength = value; }
			}

			#endregion

			#endregion

			#region METHODS

			public	FogLayer() : base()
			{
				m_bEnabled = false;
				m_AltitudeKm = DEFAULT_ALTITUDE;
				m_ThicknessKm = DEFAULT_THICKNESS;
			}

			#region IMonoBehaviour Members

			public override void OnEnable()
			{
				m_MaterialRender = Help.CreateMaterial( "Clouds/FogVolume" );

				// Update internal data
				UpdateCachedValues();
			}

			public override void OnDisable()
			{
				Help.SafeDestroyNuaj( ref m_MaterialRender );
			}

			public override void Update()
			{
				// Accumulate position
				Vector3		Wind = m_WindForce * m_NoiseTiling.x * new Vector3( m_WindDirection.x, m_WindDirection.y, 0.0f );
							Wind.z = m_NoiseTiling.y * m_DownpourStrength;

				m_FogNoisePosition += Wind * NuajTime.DeltaTime;
			}

			#endregion

			#region ICloudLayer Members

			protected RenderTexture	m_RTTempDensity = null;

			public override void	RenderShadow( int _LayerIndex, RenderTexture _ShadowMap, Rect _ShadowViewport, RenderTexture _ShadowEnvMapSkyTop, bool _bRenderEnvironment )
			{
				if ( m_Owner.IsInErrorState || m_Owner.m_Owner == null )
					return;

				//////////////////////////////////////////////////////////////////////////
				// Setup parameters
				NuajMaterial	M = m_MaterialRender;

				UploadFogUniforms( M, _LayerIndex, _ShadowMap, _ShadowEnvMapSkyTop, null );

				//////////////////////////////////////////////////////////////////////////
				// Render temporary density
				if ( m_DensityTexture.Texture != null )
					m_RTTempDensity = Help.CreateTempRT( m_DensityTexture.Texture.width, m_DensityTexture.Texture.height, RenderTextureFormat.ARGB32, FilterMode.Bilinear, TextureWrapMode.Clamp );
				else
					m_RTTempDensity = Help.CreateTempRT( 32, 32, RenderTextureFormat.ARGB32, FilterMode.Bilinear, TextureWrapMode.Clamp );

				M.SetVector( "_DensityOffset", m_DensityOffset );
				M.SetVector( "_DensityFactor", m_DensityFactor );

				M.Blit( m_DensityTexture.Texture, m_RTTempDensity, 7 );

				// Upload
				M.SetTexture( "_TexLayeredDensity", m_RTTempDensity );

				//////////////////////////////////////////////////////////////////////////
				// Render the fog's shadow into the global shadow map
				if ( m_bCastShadow )
				{
					M.SetVector( "_RenderTargetInvSize", new Vector2( 1.0f / _ShadowMap.width, 1.0f / _ShadowMap.height ) );
					M.SetTexture( "_TexShadowMap", null as RenderTexture );			// Don't use the shadow map as a texture since we're rendering into it !
					M.BlitViewport( _ShadowMap, _LayerIndex, _ShadowViewport );		// The index of the layer guides the shader choice here.
				}

				//////////////////////////////////////////////////////////////////////////
				// Render the env map
				if ( _bRenderEnvironment )
				{
					M.SetFloat( "_StepsCount", ENVIRONMENT_CLOUD_STEPS_COUNT );
					if ( _ShadowEnvMapSkyTop )
						M.SetTexture( "_TexShadowEnvMapSkyTop", _ShadowEnvMapSkyTop );
					else
						M.SetTexture( "_TexShadowEnvMapSkyTop", m_Owner.m_Owner.m_TextureEmptyCloud, true );
 					M.SetTexture( "_TexShadowEnvMapSkyBottom", m_Owner.m_Owner.m_TextureEmptyCloud, true );
					M.Blit( null, m_RTEnvMapSky, 5 );

					// Downsample into a 1x1 version of the environment sky map for ambient shadowing
					m_Owner.DownsampleSkyEnvMap( m_RTEnvMapSky, m_RTEnvMapSkyDownsampled, _ShadowEnvMapSkyTop );
				}
				else
					m_Owner.m_Owner.ClearTarget( m_RTEnvMapSkyDownsampled, new Vector4( 0, 0, 0, 1 ) );
			}

			public override void Render( int _LayerIndex, RenderTexture _ShadowMap, Rect _ShadowViewport, RenderTexture _ShadowEnvMapSkyTop )
			{
				if ( m_Owner.IsInErrorState || m_Owner.m_Owner == null )
					return;

				// Downsample the ZBuffer
				RenderTexture	DownsampledZBuffer = Owner.Owner.DownsampleZBuffer( Owner.m_DownsampleFactor );

				//////////////////////////////////////////////////////////////////////////
				// Setup parameters
				NuajMaterial	M = m_MaterialRender;

				UploadFogUniforms( M, _LayerIndex, _ShadowMap, _ShadowEnvMapSkyTop, DownsampledZBuffer );

				m_Owner.SetupScatteringCoefficients( M, true );


				//////////////////////////////////////////////////////////////////////////
				// Main rendering
				NuajManager.UPSAMPLING_TECHNIQUE	UpsamplingTechnique = m_Owner.m_Owner.UpsamplingTechnique;
				if ( UpsamplingTechnique != NuajManager.UPSAMPLING_TECHNIQUE.BILINEAR )
				{
					RenderTexture	RTTempScattering = m_RTScatteringDownsampled;

					// Render to the downsampled buffer
					M.SetFloat( "_UseSceneZ", UpsamplingTechnique == NuajManager.UPSAMPLING_TECHNIQUE.CUTOUT ? 0.0f : 1.0f );
					M.Blit( null, RTTempScattering, 4 );

 					// UpScale to the fullscale buffer
 					M.SetVector( "_dUV", new Vector4( 1.0f / RTTempScattering.width, 1.0f / RTTempScattering.height, 0.0f, 0.0f ) );
					M.SetVector( "_InvdUV", new Vector4( RTTempScattering.width, RTTempScattering.height, 0.0f, 0.0f ) );

					int	ShaderIndex = -1;
					switch ( UpsamplingTechnique )
					{
						case NuajManager.UPSAMPLING_TECHNIQUE.ACCURATE:
							ShaderIndex = 8;
							M.SetVector( "_ZBufferDiscrepancyThreshold", new Vector3( 0.1f * m_Owner.m_Owner.ZBufferDiscrepancyThreshold, m_Owner.m_Owner.ShowZBufferDiscrepancies ? 1.0f : 0.0f, 0.0f ) );	// Need to decrease the discrepancy threshold for the fog as it's generally very near to the camera and needs more precision
							break;
						case NuajManager.UPSAMPLING_TECHNIQUE.SMART:
							ShaderIndex = 9;
							M.SetVector( "_ZBufferDiscrepancyThreshold", new Vector3( 10.0f * m_Owner.m_Owner.SmartUpsamplingWeightFactor, m_Owner.m_Owner.ShowZBufferDiscrepancies ? 1.0f : 0.0f, 0.1f * m_Owner.m_Owner.SmartUpsamplingCutoutFactor ) );	// Need to increase weight factor for the fog as it's generally very near to the camera and needs more precision
							break;
						case NuajManager.UPSAMPLING_TECHNIQUE.CUTOUT:
							ShaderIndex = 10;
							break;
					}
					M.Blit( RTTempScattering, m_RTScattering, ShaderIndex );
				}
				else
				{	// Direct render to downsampled buffer
					M.SetFloat( "_UseSceneZ", 1.0f );
					M.Blit( null, m_RTScattering, 4 );
				}

				// Release temp target
				if ( m_RTTempDensity != null )
				{
					RenderTexture.active = null;
					Help.ReleaseTemporary( m_RTTempDensity );
				}
			}

			#endregion

			/// <summary>
			/// Uploads the uniforms for fog rendering
			/// </summary>
			/// <param name="_LayerIndex"></param>
			/// <param name="M"></param>
			/// <param name="_UploadLightingConstants"></param>
			protected void	UploadFogUniforms( NuajMaterial M, int _LayerIndex, RenderTexture _ShadowMap, RenderTexture _ShadowEnvMapSkyTop, RenderTexture _DownsampledZBuffer )
			{
				M.SetVector( "_FogAltitudeKm", new Vector4( m_AltitudeKm, m_AltitudeKm + m_ThicknessKm, m_ThicknessKm, 1.0f / m_ThicknessKm ) );
				M.SetFloat( "_FogLayerIndex", _LayerIndex );
				M.SetTexture( "_TexShadowMap", _ShadowMap );
				M.SetTexture( "_TexShadowEnvMapSkyTop", _ShadowEnvMapSkyTop );
				M.SetTexture( "_TexShadowEnvMapSkyBottom", m_RTEnvMapSkyDownsampled );
				if ( _DownsampledZBuffer != null )
					M.SetTexture( "_TexDownsampledZBuffer", _DownsampledZBuffer );

				M.SetMatrix( "_Density2World", m_Density2World );
				M.SetMatrix( "_World2Density", m_World2Density );
				M.SetColor( "_FogColor", m_Color );
				M.SetFloat( "_MieDensityFactor", m_MieDensityFactor );
				M.SetFloat( "_DensityRatioBottom", m_DensityRatioBottom );
				M.SetFloat( "_FogMaxDistance", m_FogMaxDistance );
				M.SetFloat( "_IsotropicSkyFactor", m_IsotropicSkyFactor );
				M.SetFloat( "_StepsCount", m_StepsCount );
				M.SetFloat( "_MaxStepSizeKm", m_StepSize );
				M.SetFloat( "_NoiseAmplitude", m_NoiseAmplitude );
				M.SetFloat( "_NoiseOffset", m_NoiseOffset );
				M.SetVector( "_NoiseTiling", m_NoiseTiling );
				M.SetVector( "_NoisePosition", m_FogNoisePosition );
			}

			/// <summary>
			/// Resets the layer to its default values
			/// </summary>
			public override void		Reset()
			{
				base.Reset();

				Altitude = DEFAULT_ALTITUDE;
				Thickness = DEFAULT_THICKNESS;
				Color = DEFAULT_COLOR;
				StepsCount = DEFAULT_STEPS_COUNT;
				StepSize = DEFAULT_STEP_SIZE;
				MieDensityFactor = DEFAULT_DENSITY_FACTOR;
				DensityRatioBottom = DEFAULT_DENSITY_RATIO_BOTTOM;
				MaxDistance = DEFAULT_FOG_MAX_DISTANCE;
				IsotropicSkyFactor = DEFAULT_ISOTROPIC_SKY_FACTOR;
				NoiseTilingHorizontal = DEFAULT_NOISE_TILING.x;
				NoiseTilingVertical = DEFAULT_NOISE_TILING.y;
				NoiseAmplitude = DEFAULT_NOISE_AMPLITUDE;
				NoiseOffset = DEFAULT_NOISE_OFFSET;
				WindForce = DEFAULT_WIND_FORCE;
				WindDirection = DEFAULT_WIND_DIRECTION;
				DownpourStrength = DEFAULT_DOWNPOUR_STRENGTH;
			}

			internal override void CreateRenderTargets( int _Width, int _Height )
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

				m_RTScattering = Help.CreateRT( "FogCloudTarget", Width, Height, RenderTextureFormat.ARGBHalf, FilterMode.Bilinear, TextureWrapMode.Clamp );
				CreateEnvMaps( "FogCloudEnvMap" );
			}

			internal override void DestroyRenderTargets()
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

			protected override void UpdateCachedValues()
			{
				base.UpdateCachedValues();

				NuajMapLocator	Locator = null;
				if ( m_FogLocator != null && m_FogLocator.gameObject.activeSelf && (Locator = m_FogLocator.GetComponent<NuajMapLocator>()) != null )
				{
					m_DensityTexture.Texture = Locator.Texture;
					if ( m_DensityTexture.Texture != null )
					{
						m_DensityOffset = Locator.Offset;
						m_DensityFactor = Locator.Factor;
					}
					else
					{	// So we have fog even when no texture is set
						m_DensityOffset = Vector4.one;
						m_DensityFactor = Vector4.one;
					}
					m_World2Density = Locator.transform.worldToLocalMatrix;
					m_Density2World = Locator.transform.localToWorldMatrix;
				}
				else
				{	// No locator...
					m_DensityOffset = Vector4.one;
					m_DensityFactor = Vector4.one;
					m_DensityTexture.Texture = null;
					m_World2Density = m_Density2World = Matrix4x4.identity;
				}
			}

			#endregion
		}

		#endregion

		#region FIELDS

		/////////////////////////////////////////////////////////
		// General serializable parameters
		[SerializeField] protected float		m_DownsampleFactor = 0.25f;
		[SerializeField] protected SKY_MODEL	m_SkyModel = SKY_MODEL.COMPLEX;
		[SerializeField] protected int			m_SkyStepsCount = 16;
		[SerializeField] protected int			m_UnderCloudsMinStepsCount = 32;
		[SerializeField] protected bool			m_bComputePlanetShadow = true;
		[SerializeField] protected bool			m_bGodRays = true;
		[SerializeField] protected bool			m_bUseCustomAmbientSkyColor = false;
		[SerializeField] protected Color		m_CustomAmbientSkyColor = new Color( 1.0f, 1.0f, 1.0f );
		[SerializeField] protected float		m_ScatteringBoost = 1.0f;
		[SerializeField] protected float		m_ExtinctionBoost = 1.0f;

		// Scattering parameters
		[SerializeField] protected float		m_DensityRayleigh = DEFAULT_RAYLEIGH_DENSITY;
		[SerializeField] protected float		m_DensityMie = DEFAULT_MIE_DENSITY;
		[SerializeField] protected float		m_ScatteringAnisotropy = DEFAULT_MIE_ANISOTROPY;

		// Fog parameters
		[SerializeField] protected FogLayer		m_FogLayer = new FogLayer();


		/////////////////////////////////////////////////////////
		// Materials
		protected NuajMaterial			m_MaterialRenderSkyComplex = null;
		protected NuajMaterial			m_MaterialRenderEnvironmentComplex = null;
		protected NuajMaterial			m_MaterialRenderSkySimple = null;
		protected NuajMaterial			m_MaterialRenderEnvironmentSimple = null;
		protected NuajMaterial			m_MaterialRenderSkyNone = null;
		protected NuajMaterial			m_MaterialRenderEnvironmentNone = null;

		/////////////////////////////////////////////////////////
		// Textures & Targets
		protected RenderTexture			m_RTScattering = null;
		protected RenderTexture			m_DensityTexture = null;

		// Sun & Sky Environment Map
		protected RenderTexture[]		m_RTSkyMaps = new RenderTexture[1+NuajManager.ENVIRONMENT_TEXTURE_SIZE_POT];
		protected RenderTexture			m_RTSkyEnvMap = null;


		/////////////////////////////////////////////////////////
		// Internal data
		protected Vector4[,]			m_DensityTextureCPU = new Vector4[DENSITY_TEXTURE_SIZE,DENSITY_TEXTURE_SIZE];

		// Cached Mie coefficients
		protected float					m_SigmaMie = 0.0f;
		protected Vector3				m_SigmaRayleigh = Vector3.zero;

		// Cached environment values
		protected Vector3				m_EnvSkyColor = Vector3.zero;
		protected Vector3				m_EnvSunColor = Vector3.zero;

		#endregion

		#region PROPERTIES

		/// <summary>
		/// Gets the owner NuajManager instance
		/// </summary>
		public override NuajManager	Owner
		{
			get { return m_Owner; }
			internal set
			{
				if ( value == m_Owner )
					return;

				// Un-Subscribe
				if ( m_Owner != null )
					m_Owner.PlanetDimensionsChanged -= new EventHandler( NuajManager_PlanetDimensionsChanged );

				m_Owner = value;

				// Subscribe
				if ( m_Owner != null )
					m_Owner.PlanetDimensionsChanged += new EventHandler( NuajManager_PlanetDimensionsChanged );
			}
		}

		/// <summary>
		/// Gets or sets the downsample factor the module will render with
		/// This factor has a strong impact on both speed and quality
		/// </summary>
		public float		DownsampleFactor
		{
			get { return m_DownsampleFactor; }
			set
			{
				value = Math.Max( 0.05f, Math.Min( 1.0f, value ) );
				if ( Mathf.Approximately( value, m_DownsampleFactor ) )
					return;

				m_DownsampleFactor = value;
				
				// Update render targets
				UpdateRenderTargets();
			}
		}

		/// <summary>
		/// Specifies which sky model to use.
		/// </summary>
		public SKY_MODEL	SkyModel					{ get { return m_SkyModel; } set { m_SkyModel = value; } }

		/// <summary>
		/// Gets or sets the amount of ray-marching steps used for tracing the sky (COMPLEX sky model only).
		/// </summary>
		public int			SkyStepsCount				{ get { return m_SkyStepsCount; } set { m_SkyStepsCount = value; } }

		/// <summary>
		/// Gets or sets the minimum amount of ray-marching steps used for tracing the sky UNDER the clouds (COMPLEX sky model only).
		/// This is where godrays need the most resolution so it should be a high number but this also has a strong impact on speed.
		/// </summary>
		public int			UnderCloudsMinStepsCount	{ get { return m_UnderCloudsMinStepsCount; } set { m_UnderCloudsMinStepsCount = value; } }

		/// <summary>
		/// Gets or sets the density of air molecules that influence Rayleigh scattering
		/// </summary>
		public float		DensityRayleigh
		{
			get { return m_DensityRayleigh; }
			set
			{
				if ( Mathf.Approximately( value, m_DensityRayleigh ) )
					return;

				m_DensityRayleigh = value;
				UpdateCachedValues();
			}
		}

		/// <summary>
		/// Gets or sets the density of aerosols particles that influence Mie scattering
		/// </summary>
		public float		DensityMie
		{
			get { return m_DensityMie; }
			set
			{
				if ( Mathf.Approximately( value, m_DensityMie ) )
					return;

				m_DensityMie = value;
				UpdateCachedValues();
			}
		}

		/// <summary>
		/// Gets or sets the prefered scattering direction (-1 is backward, +1 is forward, 0 is isotropic)
		/// </summary>
		public float		ScatteringAnisotropy
		{
			get { return m_ScatteringAnisotropy; }
			set
			{
				if ( Mathf.Approximately( value, m_ScatteringAnisotropy ) )
					return;

				m_ScatteringAnisotropy = value;
				UpdateCachedValues();
			}
		}

		/// <summary>
		/// Gets or sets the scattering boost factor
		/// </summary>
		public float		ScatteringBoost
		{
			get { return m_ScatteringBoost; }
			set
			{
				if ( Mathf.Approximately( value, m_ScatteringBoost ) )
					return;

				m_ScatteringBoost = value;
			}
		}

		/// <summary>
		/// Gets or sets the extinction boost factor
		/// </summary>
		public float		ExtinctionBoost
		{
			get { return m_ExtinctionBoost; }
			set
			{
				if ( Mathf.Approximately( value, m_ExtinctionBoost ) )
					return;

				m_ExtinctionBoost = value;
			}
		}

		/// <summary>
		/// Tells if we should compute Earth's shadow (i.e. night sky)
		/// </summary>
		public bool			ComputeEarthShadow		{ get { return m_bComputePlanetShadow; } set { m_bComputePlanetShadow = value; } }

		/// <summary>
		/// Tells if we should enable God rays
		/// </summary>
		public bool			EnableGodRays			{ get { return m_bGodRays; } set { m_bGodRays = value; } }

		/// <summary>
		/// Tells if we should use the custom ambient sky color instead of the ones that are automatically computed
		/// </summary>
		public bool			UseCustomAmbientSkyColor	{ get { return m_bUseCustomAmbientSkyColor; } set { m_bUseCustomAmbientSkyColor = value; } }

		/// <summary>
		/// Gets or sets the custom ambient sky color
		/// </summary>
		public Color		CustomAmbientSkyColor	{ get { return m_CustomAmbientSkyColor; } set { m_CustomAmbientSkyColor = value; } }

		/// <summary>
		/// Occurs whenever a sky parameter is modified
		/// </summary>
		public event EventHandler	SkyParametersChanged;

		/// <summary>
		/// Gets the fog layer
		/// </summary>
		public FogLayer		Fog						{ get { return m_FogLayer; } }

		public override ICloudLayer[]				CloudLayers		{ get { return new ICloudLayer[] { m_FogLayer }; } }

		/// <summary>
		/// This is the actual Sun color seen from the ground with which we should light the scene (i.e. direction light color)
		/// WARNING: This is a HDR color, so you need to tone map that color using the rendered ToneMappingLuminance to get a LDR color that Unity can actually use
		/// </summary>
		public Vector3		EnvironmentSunColor
		{
			get { return m_EnvSunColor; }
		}

		/// <summary>
		/// This is the actual Sky color seen from the ground with which we should light the scene (i.e. ambient light color)
		/// WARNING: This is a HDR color, so you need to tone map that color using the rendered ToneMappingLuminance to get a LDR color that Unity can actually use
		/// </summary>
		public Vector3		EnvironmentSkyColor
		{
			get { return m_EnvSkyColor; }
		}

		#endregion

		#region METHODS

		internal	ModulePerspective( string _Name ) : base( _Name )
		{
		}

		#region MonoBehaviour

		public override void OnDestroy()
		{
			m_FogLayer.OnDestroy();
		}

		public override void Awake()
		{
			m_FogLayer.Owner = this;
			m_FogLayer.Awake();
		}

		public override void Start()
		{
			m_FogLayer.Start();
		}

		public override void OnEnable()
		{
			try
			{
				m_MaterialRenderSkyComplex = Help.CreateMaterial( "Sky/AerialPerspectiveComplex" );
				m_MaterialRenderEnvironmentComplex = Help.CreateMaterial( "Sky/RenderEnvironmentComplex" );

				m_MaterialRenderSkySimple = Help.CreateMaterial( "Sky/AerialPerspectiveSimple" );
				m_MaterialRenderEnvironmentSimple = Help.CreateMaterial( "Sky/RenderEnvironmentSimple" );

				m_MaterialRenderSkyNone = Help.CreateMaterial( "Sky/AerialPerspectiveNone" );
				m_MaterialRenderEnvironmentNone = Help.CreateMaterial( "Sky/RenderEnvironmentNone" );

				// Enable fog layer
				m_FogLayer.Owner = this;
				m_FogLayer.OnEnable();

				ExitErrorState();
			}
			catch ( Exception _e )
			{
				EnterErrorState( "An error occurred while creating the materials for the module.\r\n" + _e.Message );
			}

			// Update internal data
			UpdateCachedValues();
		}

		public override void OnDisable()
		{
			// Disable fog layer
			m_FogLayer.OnDisable();

			// Destroy constant textures
			Help.SafeDestroy( ref m_DensityTexture );

			// Destroy materials
			Help.SafeDestroyNuaj( ref m_MaterialRenderSkyComplex );
			Help.SafeDestroyNuaj( ref m_MaterialRenderEnvironmentComplex );
			Help.SafeDestroyNuaj( ref m_MaterialRenderSkySimple );
			Help.SafeDestroyNuaj( ref m_MaterialRenderEnvironmentSimple );
			Help.SafeDestroyNuaj( ref m_MaterialRenderSkyNone );
			Help.SafeDestroyNuaj( ref m_MaterialRenderEnvironmentNone );
		}

		public override void Update()
		{
			m_FogLayer.Update();
		}

		#endregion

		/// <summary>
		/// Renders the aerial perspective
		/// </summary>
		/// <param name="_Scattering">The final scattering texture to render to</param>
		/// <param name="_Layers">Up to 4 cloud layers that will be composed with the sky</param>
		/// <param name="_ShadowMap">The shadow map cast by the clouds</param>
		/// <param name="_Background">The background map where satellites are rendered</param>
		internal void Render( RenderTexture _Scattering, ICloudLayer[] _Layers, Texture _ShadowMap, Texture _Background )
		{
			NuajMaterial.SetGlobalFloat( "_bComputePlanetShadow", m_bComputePlanetShadow ? 1 : 0 );

			RenderTexture	DownsampledZBuffer = null;

			switch ( m_SkyModel )
			{
				//////////////////////////////////////////////////////////////////////////
				// Complex Sky Model
				case SKY_MODEL.COMPLEX:
					{
						SetupSkyParametersComplex( m_MaterialRenderSkyComplex, _Layers, _ShadowMap );
						m_Owner.SetupLayerOrderingData( m_MaterialRenderSkyComplex );

						// Downsample the ZBuffer
						DownsampledZBuffer = m_Owner.DownsampleZBuffer( m_DownsampleFactor );

						// Upload downsampled cloud targets
						SetupCloudTextures( m_MaterialRenderSkyComplex, _Layers, false, true );

						// Render sky in downsampled target
						m_MaterialRenderSkyComplex.SetTexture( "_TexDownsampledZBuffer", DownsampledZBuffer );
						m_MaterialRenderSkyComplex.Blit( null, m_RTScattering, _Layers.Length );					// The amount of layers guides the index of the shader here...

						//////////////////////////////////////////////////////////////////////////
 						// Mix sky with clouds

						// Upload full-sized cloud targets
						SetupCloudTextures( m_MaterialRenderSkyComplex, _Layers, false, false );

						m_MaterialRenderSkyComplex.SetTexture( "_TexDownsampledZBuffer", DownsampledZBuffer );
						m_MaterialRenderSkyComplex.SetTextureRAW( "_TexBackground", _Background );

 						m_MaterialRenderSkyComplex.SetVector( "_dUV", new Vector4( 1.0f / DownsampledZBuffer.width, 1.0f / DownsampledZBuffer.height, 0.0f, 0.0f ) );
						m_MaterialRenderSkyComplex.SetVector( "_InvdUV", new Vector4( DownsampledZBuffer.width, DownsampledZBuffer.height, 0.0f, 0.0f ) );

						int		ShaderIndex = _Layers.Length;	// The amount of layers guides the index of the shader here...
						if ( m_Owner.UpsamplingTechnique == NuajManager.UPSAMPLING_TECHNIQUE.ACCURATE )
						{	// Use "accurate" refinement
							ShaderIndex += 5;
							m_MaterialRenderSkyComplex.SetVector( "_ZBufferDiscrepancyThreshold", new Vector3( m_Owner.ZBufferDiscrepancyThreshold, m_Owner.ShowZBufferDiscrepancies ? 1.0f : 0.0f, 0.0f ) );
						}
						else if ( m_Owner.UpsamplingTechnique == NuajManager.UPSAMPLING_TECHNIQUE.SMART )
						{	// Use "smart" refinement
							ShaderIndex += 10;
							m_MaterialRenderSkyComplex.SetVector( "_ZBufferDiscrepancyThreshold", new Vector3( m_Owner.SmartUpsamplingWeightFactor, m_Owner.ShowZBufferDiscrepancies ? 1.0f : 0.0f, m_Owner.SmartUpsamplingCutoutFactor ) );
						}
						else if ( m_Owner.UpsamplingTechnique == NuajManager.UPSAMPLING_TECHNIQUE.CUTOUT )
						{	// Use "cutout" refinement
							ShaderIndex += 15;
						}
						else
							ShaderIndex += 20;	// Use a simple bilinear

						m_MaterialRenderSkyComplex.Blit( m_RTScattering, _Scattering, ShaderIndex );
						break;
					}

				//////////////////////////////////////////////////////////////////////////
				// Simple Sky Model
				case SKY_MODEL.SIMPLE:
					{
						SetupSkyParametersSimple( m_MaterialRenderSkySimple, _Layers );
						m_Owner.SetupLayerOrderingData( m_MaterialRenderSkySimple );

						// Downsample the ZBuffer
						DownsampledZBuffer = m_Owner.DownsampleZBuffer( m_DownsampleFactor );

						// Upload downsampled cloud targets
						SetupCloudTextures( m_MaterialRenderSkySimple, _Layers, false, true );

						// Render sky in downsampled target
						m_MaterialRenderSkySimple.SetTexture( "_TexDownsampledZBuffer", DownsampledZBuffer );
						m_MaterialRenderSkySimple.Blit( null, m_RTScattering, _Layers.Length );				// The amount of layers guides the index of the shader here...

 						//////////////////////////////////////////////////////////////////////////
 						// Mix sky with clouds

						// Upload full-sized cloud targets
						SetupCloudTextures( m_MaterialRenderSkySimple, _Layers, false, false );

						m_MaterialRenderSkySimple.SetTexture( "_TexDownsampledZBuffer", DownsampledZBuffer );
						m_MaterialRenderSkySimple.SetTextureRAW( "_TexBackground", _Background );

						m_MaterialRenderSkySimple.SetVector( "_dUV", new Vector4( 1.0f / DownsampledZBuffer.width, 1.0f / DownsampledZBuffer.height, 0.0f, 0.0f ) );
						m_MaterialRenderSkySimple.SetVector( "_InvdUV", new Vector4( DownsampledZBuffer.width, DownsampledZBuffer.height, 0.0f, 0.0f ) );

						int		ShaderIndex = _Layers.Length;	// The amount of layers guides the index of the shader here...
						if ( m_Owner.UpsamplingTechnique == NuajManager.UPSAMPLING_TECHNIQUE.ACCURATE )
						{	// Use "accurate" refinement
							ShaderIndex += 5;
							m_MaterialRenderSkySimple.SetVector( "_ZBufferDiscrepancyThreshold", new Vector3( m_Owner.ZBufferDiscrepancyThreshold, m_Owner.ShowZBufferDiscrepancies ? 1.0f : 0.0f, 0.0f ) );
						}
						else if ( m_Owner.UpsamplingTechnique == NuajManager.UPSAMPLING_TECHNIQUE.SMART )
						{	// Use "smart" refinement
							ShaderIndex += 10;
							m_MaterialRenderSkySimple.SetVector( "_ZBufferDiscrepancyThreshold", new Vector3( m_Owner.SmartUpsamplingWeightFactor, m_Owner.ShowZBufferDiscrepancies ? 1.0f : 0.0f, m_Owner.SmartUpsamplingCutoutFactor ) );
						}
						else if ( m_Owner.UpsamplingTechnique == NuajManager.UPSAMPLING_TECHNIQUE.CUTOUT )
						{	// Use "cutout" refinement
							ShaderIndex += 15;
						}
						else
							ShaderIndex += 20;	// Use a simple bilinear

 						m_MaterialRenderSkySimple.Blit( m_RTScattering, _Scattering, ShaderIndex );
						break;
					}

				//////////////////////////////////////////////////////////////////////////
				// Empty Sky Model
				case SKY_MODEL.NONE:

					m_Owner.SetupLayerOrderingData( m_MaterialRenderSkyNone );

					// Upload full-sized cloud targets
					SetupCloudTextures( m_MaterialRenderSkyNone, _Layers, false, false );

					m_MaterialRenderSkyNone.SetTextureRAW( "_TexBackground", _Background );

 					m_MaterialRenderSkyNone.Blit( null, _Scattering, _Layers.Length );	// The amount of layers guides the index of the shader here...
					break;
			}
		}

		#region Environment Maps Rendering

		/// <summary>
		/// Renders the environment map with the CPU for faster but less accurate scene lighting
		/// The software environment only renders the sky without the contribution of clouds, making it less realistic
		/// </summary>
		public void RenderEnvironmentSoftware()
		{
			if ( IsInErrorState )
				return;

			RenderEnvironmentCustom(
				ComputeSunColor( Vector3.zero, m_Owner.SunDirection ),
				ComputeAmbientSkyColor()	// Doesn't take clouds into account here !
				);
		}

		/// <summary>
		/// Renders the environment using custom Sun & Sky colors
		/// </summary>
		/// <param name="_SunColor">The custom Sun environment color to use</param>
		/// <param name="_SkyColor">The custom Sky environment color to use</param>
		public void RenderEnvironmentCustom( Vector3 _SunColor, Vector3 _SkyColor )
		{
			m_EnvSunColor = _SunColor;
			m_EnvSkyColor = _SkyColor;

 			NuajMaterial.SetGlobalTexture( "_TexAmbientSky", m_Owner.m_TextureEmptyCloud, true );	// Set black hardware ambient
			if ( m_bUseCustomAmbientSkyColor )
 				NuajMaterial.SetGlobalVector( "_SoftAmbientSky", new Vector4( m_CustomAmbientSkyColor.r, m_CustomAmbientSkyColor.g, m_CustomAmbientSkyColor.b, 1.0f ) );
			else
 				NuajMaterial.SetGlobalVector( "_SoftAmbientSky", new Vector4( m_EnvSkyColor.x, m_EnvSkyColor.y, m_EnvSkyColor.z, 1.0f ) );

			Vector3	ReflectedLightColor = Vector3.Scale( Help.ColorToVec3( m_Owner.TerrainAlbedo ), m_EnvSkyColor + m_EnvSunColor );
			NuajMaterial.SetGlobalVector( "_TerrainReflectedLight", ReflectedLightColor );
		}

		/// <summary>
		/// Renders the environment map with the GPU for accurate scene lighting
		/// </summary>
		/// <param name="_Layers">Up to 4 cloud layers that will be composed with the sky</param>
		/// <param name="_ShadowMap">The shadow map cast by the clouds</param>
		/// <param name="_Background">The background environment map where satellites are rendered</param>
		public void RenderEnvironmentHardware( ICloudLayer[] _Layers, RenderTexture _ShadowMap, RenderTexture _Background )
		{
			if ( IsInErrorState )
				return;

			// Compute the luminance we are using for scaling
			// BUG: This introduces a nasty feedback loop that makes the tone mapping flicker
//			float	LuminanceScale = Math.Max( 0.1f, 2.0f * Vector3.Dot( NuajManager.LUMINANCE, m_EnvSunColor ) );	// We actually scale up to twice the previous Sun's luminance

			// Instead, we use a wrong "below the horizon" test
			float	LuminanceScale = Math.Max( NuajManager.MIN_LUMINANCE_AT_NIGHT, m_Owner.SunIntensity * Mathf.Clamp01( 10.0f * Vector3.Dot( m_Owner.SunDirection, m_Owner.PlanetNormal ) ) );

			switch ( m_SkyModel )
			{
				//////////////////////////////////////////////////////////////////////////
				// Complex Sky Model
				case SKY_MODEL.COMPLEX:
					{
						SetupSkyParametersComplex( m_MaterialRenderEnvironmentComplex, _Layers, _ShadowMap );
						SetupCloudTextures( m_MaterialRenderEnvironmentComplex, _Layers, true, false );

						m_MaterialRenderEnvironmentComplex.SetTexture( "_TexBackground", _Background );

						// Render sky environment map WITHOUT clouds (used for clouds lighting, but only on next frame as the clouds have already been rendered)
 						m_MaterialRenderEnvironmentComplex.Blit( null, m_RTSkyMaps[0], 0 );
 						DownsampleSkyEnvMap( m_RTSkyMaps[0], m_RTSkyEnvMap, null );

						// Render sky environment map WITH clouds (used by scene as ambient light)
						m_MaterialRenderEnvironmentComplex.Blit( null, m_RTSkyMaps[0], 1 );
						m_EnvSkyColor = DownsampleSkyEnvMapForCPU( m_RTSkyMaps[0], 1, LuminanceScale );

 						// Render Sun map (used by scene as directional light's color)
						m_EnvSunColor = CPUReadBack( null, m_MaterialRenderEnvironmentComplex, 2, 2, LuminanceScale );
 						break;
					}

				//////////////////////////////////////////////////////////////////////////
				// Simple Sky Model
				case SKY_MODEL.SIMPLE:
					{
						SetupSkyParametersSimple( m_MaterialRenderEnvironmentSimple, _Layers );
						SetupCloudTextures( m_MaterialRenderEnvironmentSimple, _Layers, true, false );

						m_MaterialRenderEnvironmentSimple.SetTexture( "_TexBackground", _Background );

						// Render sky environment map WITHOUT clouds (used for clouds lighting, but only on next frame as the clouds have already been rendered)
 						m_MaterialRenderEnvironmentSimple.Blit( null, m_RTSkyMaps[0], 0 );
 						DownsampleSkyEnvMap( m_RTSkyMaps[0], m_RTSkyEnvMap, null );

						// Render sky environment map WITH clouds (used by scene as ambient light)
						m_MaterialRenderEnvironmentSimple.Blit( null, m_RTSkyMaps[0], 1 );
						m_EnvSkyColor = DownsampleSkyEnvMapForCPU( m_RTSkyMaps[0], 1, LuminanceScale );
 
 						// Render Sun map (used by scene as directional light's color)
						m_EnvSunColor = CPUReadBack( null, m_MaterialRenderEnvironmentSimple, 2, 2, LuminanceScale );
						break;
					}

				//////////////////////////////////////////////////////////////////////////
				// Empty Sky Model
				case SKY_MODEL.NONE:
					{
						SetupCloudTextures( m_MaterialRenderEnvironmentNone, _Layers, true, false );

						m_MaterialRenderEnvironmentNone.SetTexture( "_TexBackground", _Background );

						// Render sky environment map WITHOUT clouds (used for clouds lighting, but only on next frame as the clouds have already been rendered)
 						m_MaterialRenderEnvironmentNone.Blit( null, m_RTSkyMaps[0], 0 );
 						DownsampleSkyEnvMap( m_RTSkyMaps[0], m_RTSkyEnvMap, null );

						// Render sky environment map WITH clouds (used by scene as ambient light)
						m_MaterialRenderEnvironmentNone.Blit( null, m_RTSkyMaps[0], 1 );
						m_EnvSkyColor = DownsampleSkyEnvMapForCPU( m_RTSkyMaps[0], 1, LuminanceScale );

						// Render Sun map (used by scene as directional light's color)
						m_EnvSunColor = CPUReadBack( null, m_MaterialRenderEnvironmentNone, 2, 2, LuminanceScale );
						break;
					}
			}

			// Update global constants
			NuajMaterial.SetGlobalTexture( "_TexAmbientSky", m_RTSkyEnvMap );
			if ( m_bUseCustomAmbientSkyColor )
 				NuajMaterial.SetGlobalVector( "_SoftAmbientSky", new Vector4( m_CustomAmbientSkyColor.r, m_CustomAmbientSkyColor.g, m_CustomAmbientSkyColor.b, 1.0f ) );
			else
				NuajMaterial.SetGlobalVector( "_SoftAmbientSky", Vector4.zero );

			Vector3	ReflectedLightColor = Vector3.Scale( Help.ColorToVec3( m_Owner.TerrainAlbedo ), m_EnvSkyColor + m_EnvSunColor );
			NuajMaterial.SetGlobalVector( "_TerrainReflectedLight", ReflectedLightColor );
		}

		/// <summary>
		/// Downsamples the env maps down to a 1x1 size and possibly combine with an existing env map
		/// </summary>
		/// <param name="_Source">The source texture to downsample</param>
		/// <param name="_Target">The 1x1 target to render to</param>
		/// <param name="_CombineMipMap">The existing 1x1 mip-map we may want to combine with</param>
		internal void	DownsampleSkyEnvMap( RenderTexture _Source, RenderTexture _Target, RenderTexture _CombineMipMap )
		{
			for ( int PassIndex=1; PassIndex < m_RTSkyMaps.Length; PassIndex++ )
			{
				m_MaterialRenderEnvironmentComplex.SetVector( "_dUV", new Vector3( 1.0f / _Source.width, 1.0f / _Source.height, 0.0f ) );
				m_MaterialRenderEnvironmentComplex.Blit( _Source, m_RTSkyMaps[PassIndex], 3 );
				_Source = m_RTSkyMaps[PassIndex];
			}

			// Render last mip map
			m_MaterialRenderEnvironmentComplex.SetVector( "_dUV", new Vector3( 1.0f / _Source.width, 1.0f / _Source.height, 0.0f ) );
			if ( _CombineMipMap )
			{
				m_MaterialRenderEnvironmentComplex.SetTexture( "_TexCombineEnvMap", _CombineMipMap );
				m_MaterialRenderEnvironmentComplex.Blit( _Source, _Target, 4 );
			}
			else
				m_MaterialRenderEnvironmentComplex.Blit( _Source, _Target, 3 );
		}

		/// <summary>
		/// Downsamples the env maps down to a 1x1 size
		/// </summary>
		/// <param name="_Source">The source texture to downsample</param>
		/// <param name="_ValueIndex">The index of the CPU value to write in [0,3]</param>
		/// <param name="_LuminanceScale">The luminance scale that was used to pack the HDR color</param>
		/// <returns>The downsampled value</returns>
		internal Vector3	DownsampleSkyEnvMapForCPU( RenderTexture _Source, int _ValueIndex, float _LuminanceScale )
		{
			for ( int PassIndex=1; PassIndex < m_RTSkyMaps.Length; PassIndex++ )
			{
				m_MaterialRenderEnvironmentComplex.SetVector( "_dUV", new Vector3( 1.0f / _Source.width, 1.0f / _Source.height, 0.0f ) );
				m_MaterialRenderEnvironmentComplex.Blit( _Source, m_RTSkyMaps[PassIndex], 3 );
				_Source = m_RTSkyMaps[PassIndex];
			}

			// Render last mip map
			m_MaterialRenderEnvironmentComplex.SetFloat( "_LuminanceScale", 1.0f / _LuminanceScale );
			m_MaterialRenderEnvironmentComplex.SetVector( "_dUV", new Vector3( 1.0f / _Source.width, 1.0f / _Source.height, 0.0f ) );
			return CPUReadBack( _Source, m_MaterialRenderEnvironmentComplex, 5, _ValueIndex, _LuminanceScale );
		}

		/// <summary>
		/// Combines the Sun env map with the existing one
		/// </summary>
		/// <param name="_Source">The source texture to combine</param>
		/// <param name="_LastMipMap">The 1x1 target to combine with</param>
		internal void	CombineSunEnvMap( RenderTexture _Source, RenderTexture _LastMipMap )
		{
			m_MaterialRenderEnvironmentComplex.Blit( _Source, _LastMipMap, 6 );
		}

		/// <summary>
		/// Performs CPU readback of a 1x1 texture
		/// </summary>
		/// <param name="_Source"></param>
		/// <param name="_PassIndex"></param>
		/// <param name="_ValueIndex"></param>
		/// <param name="_LuminanceScale"></param>
		/// <returns></returns>
		internal Vector3	CPUReadBack( RenderTexture _Source, NuajMaterial _Material, int _PassIndex, int _ValueIndex, float _LuminanceScale )
		{
			m_Owner.RenderToCPU( _Source, _ValueIndex, _Material, _PassIndex );

			// Read back
			Color	PackedResult = m_Owner.CPUReadBack( _ValueIndex );
			return Help.ColorToVec3( PackedResult ) * _LuminanceScale * PackedResult.a;
		}

		#endregion

		#region Render Targets Size Update

		protected override void	InternalCreateRenderTargets()
		{
			// Compute downsampled with & height
			m_Width = (int) Math.Floor( m_DownsampleFactor * m_ScreenWidth );
			m_Width = Math.Max( 32, m_Width );

			m_Height = (int) Math.Floor( m_DownsampleFactor * m_ScreenHeight );
			m_Height = Math.Max( 32, m_Height );

			// Build targets
			m_RTScattering = Help.CreateRT( "PerspectiveDownsampledScattering", m_Width, m_Height, RenderTextureFormat.ARGBHalf, FilterMode.Point, TextureWrapMode.Clamp );

			// Forward to fog layer
			m_FogLayer.CreateRenderTargets( m_Width, m_Height );

			// Build environment maps
 			int	Width = 2 << NuajManager.ENVIRONMENT_TEXTURE_SIZE_POT;
 			int	Height = 1 << NuajManager.ENVIRONMENT_TEXTURE_SIZE_POT;
			for ( int EnvMapIndex=0; EnvMapIndex < m_RTSkyMaps.Length; EnvMapIndex++ )
			{
				m_RTSkyMaps[EnvMapIndex] = Help.CreateRT( "SkyEnvMap#" + EnvMapIndex, Width, Height, RenderTextureFormat.ARGBHalf, FilterMode.Point, TextureWrapMode.Clamp );

				Width >>= 1;
				Height = Math.Max( 1, Height >> 1 );
			}
			m_RTSkyEnvMap = Help.CreateRT( "SkyEnvMap - LastLevel", 1, 1, RenderTextureFormat.ARGBHalf, FilterMode.Point, TextureWrapMode.Clamp );
		}

		protected override void	InternalDestroyRenderTargets()
		{
			Help.SafeDestroy( ref m_RTScattering );
 			for ( int EnvMapIndex=0; EnvMapIndex < m_RTSkyMaps.Length; EnvMapIndex++ )
 				Help.SafeDestroy( ref m_RTSkyMaps[EnvMapIndex] );
			Help.SafeDestroy( ref m_RTSkyEnvMap );

			// Forward to fog layer
			m_FogLayer.DestroyRenderTargets();
		}

		#endregion

		#region Density Texture

		/// <summary>
		/// Computes the texture storing atmosphere density for particles responsible for Rayleigh and Mie scattering (i.e. air molecules and aerosols respectively)
		/// The U direction varies along with view angle where U=0 is UP and U=1 is DOWN
		/// The V direction varies along with altitude where V=0 is 0m (i.e. sea level) and V=1 is 100km (i.e. top of the atmosphere)
		/// 
		/// The XY components of the texture store the Rayleigh/Mie density at current altitude
		/// The ZW components of the texture store the Rayleigh/Mie densities accumulated from the start altitude to the top of the atmosphere by following the view vector
		/// </summary>
		protected void	ComputeDensityTexture()
		{
			if ( m_DensityTexture != null )
				return;	// Already computed !

			//////////////////////////////////////////////////////////////////////////
			// Build the GPU density texture
			NuajMaterial	BuildDensity = Help.CreateMaterial( "Sky/BuildDensityTexture" );
			m_DensityTexture = Help.CreateRT( "AtmosphereDensity", DENSITY_TEXTURE_SIZE, DENSITY_TEXTURE_SIZE, RenderTextureFormat.ARGBHalf, FilterMode.Bilinear, TextureWrapMode.Clamp );

			BuildDensity.Blit( null, m_DensityTexture, 0 );
			Help.SafeDestroyNuaj( ref BuildDensity );

			//////////////////////////////////////////////////////////////////////////
			// Build the CPU texture
			Vector2	Pos = Vector2.zero;
			Vector2	View = Vector2.zero;
			Vector4	Color = Vector4.zero;

			for ( int Y=0; Y < DENSITY_TEXTURE_SIZE; Y++ )
				for ( int X=0; X < DENSITY_TEXTURE_SIZE; X++ )
				{
					double	Altitude = m_Owner.PlanetAtmosphereAltitudeKm * Y / (DENSITY_TEXTURE_SIZE-1);
					View.y = 1.0f - 2.0f * X / (DENSITY_TEXTURE_SIZE-1);
					View.x = (float) Math.Sqrt( 1.0f - View.y*View.y );

					// Compute intersection of ray with upper atmosphere
					double	D = m_Owner.PlanetRadiusKm + Altitude;
					double	b = D * View.y;
					double	c = D*D-m_Owner.PlanetAtmosphereRadiusKm*m_Owner.PlanetAtmosphereRadiusKm;
					double	Delta = Math.Sqrt( b*b-c );
					double	HitDistance = Delta - b;	// Distance at which we hit the upper atmosphere (in kilometers)

					// Compute air molecules and aerosols density at current altitude
					Color.x = (float) Math.Exp( -Altitude / H0_AIR );
					Color.y = (float) Math.Exp( -Altitude / H0_AEROSOLS );

					// Accumulate densities along the ray
					double	SumDensityRayleigh = 0.0;
					double	SumDensityMie = 0.0;

					float	StepLength = (float) HitDistance / DENSITY_TEXTURE_STEPS_COUNT;
					Pos.x = 0.5f * StepLength * View.x;
					Pos.y = (float) D + 0.5f * StepLength * View.y;

					for ( int StepIndex=0; StepIndex < DENSITY_TEXTURE_STEPS_COUNT; StepIndex++ )
					{
						Altitude = Pos.magnitude - m_Owner.PlanetRadiusKm;	// Relative height from sea level
						Altitude = Math.Max( 0.0, Altitude );		// Don't go below the ground...

						// Compute and accumulate densities at current altitude
						double	Rho_air = Math.Exp( -Altitude / H0_AIR );
						double	Rho_aerosols = Math.Exp( -Altitude / H0_AEROSOLS );
						SumDensityRayleigh += Rho_air;
						SumDensityMie += Rho_aerosols;

						// March
						Pos.x += StepLength * View.x;
						Pos.y += StepLength * View.y;
					}

					SumDensityRayleigh *= HitDistance / DENSITY_TEXTURE_STEPS_COUNT;
					SumDensityMie *= HitDistance / DENSITY_TEXTURE_STEPS_COUNT;

					// Write accumulated densities (clamp because of Float16)
					Color.z = (float) Math.Min( 1e4, SumDensityRayleigh );
					Color.w = (float) Math.Min( 1e4, SumDensityMie );

					m_DensityTextureCPU[X,Y] = Color;
				}
		}

		#endregion

		#region Software Sky Computation

		/// <summary>
		/// Computes the color of the Sun passing through the atmosphere given the provided direction and using the current density parameters
		/// </summary>
		/// <param name="_ViewPosition">The viewing position (in WORLD space)</param>
		/// <param name="_SunDirection">The NORMALIZED Sun direction (in WORLD space, and pointing TOWARD the Sun)</param>
		/// <returns>The color of the Sun after passing through the atmosphere</returns>
		public Vector3	ComputeSunColor( Vector3 _ViewPosition, Vector3 _SunDirection )
		{
			Vector3	Extinction;
			float	Terminator;
			ComputeSkyColor( _ViewPosition, _SunDirection, out Extinction , out Terminator, 8 );

			return Help.Vec3Product( m_Owner.SunColor, Extinction );
		}

		/// <summary>
		/// Computes the ambient sky color
		/// It's quite an ugly and not very accurate piece of code but it does the job...
		/// </summary>
		/// <returns></returns>
		public Vector3	ComputeAmbientSkyColor()
		{
			Vector3	SumColor = Vector3.zero;
			int		SumCount = 0;
			Vector3	View, Extinction;
			float	Terminator;

			int	THETA_COUNT = 3;
			int	PHI_COUNT = 4;

			for ( int Y=0; Y < THETA_COUNT; Y++ )
			{
				float	Theta = 0.5f * (0.5f + Y) * Mathf.PI / THETA_COUNT;
				View.y = Mathf.Cos( Theta );
				float	fSinTheta = Mathf.Sin( Theta );
				for ( int X=0; X < PHI_COUNT; X++ )
				{
					float	Phi = 2.0f * Mathf.PI * X / PHI_COUNT;
					View.x = Mathf.Cos( Phi ) * fSinTheta;
					View.z = Mathf.Sin( Phi ) * fSinTheta;
					SumColor += ComputeSkyColor( Vector3.zero, View, out Extinction, out Terminator, 4 );
					SumCount++;
				}
			}

			return SumColor / SumCount;
		}

		/// <summary>
		/// Computes the color of the sky given the provided view position and direction and using the current density parameters
		/// </summary>
		/// <param name="_ViewPosition">The viewing position (in WORLD space)</param>
		/// <param name="_ViewDirection">The viewing direction (in WORLD space)</param>
		/// <param name="_Extinction">The background color that will be attenuated by the atmosphere
		/// (use 0 for empty space and 1 for occluded space, then use as a multiplier of the  existing background)</param>
		/// <param name="_Terminator">the terminator value (1 is fully lit, 0 is in Earth's shadow)</param>
		/// <param name="_StepsCount"></param>
		/// <returns>The color of the sky</returns>
		public Vector3	ComputeSkyColor( Vector3 _ViewPosition, Vector3 _ViewDirection, out Vector3 _Extinction, out float _Terminator, int _StepsCount )
		{
			// Compute view ray intersection with the upper atmosphere
			double	CameraHeight = m_Owner.WorldUnit2Kilometer * _ViewPosition.y;	// Relative height from sea level
			double	D = CameraHeight + m_Owner.PlanetRadiusKm;
			double	b = D * _ViewDirection.y;
			double	c = D*D-m_Owner.PlanetAtmosphereRadiusKm*m_Owner.PlanetAtmosphereRadiusKm;
			double	Delta = Math.Sqrt( b*b-c );
			double	HitDistance = Delta - b;		// Distance at which we hit the upper atmosphere (in kilometers)
			HitDistance /= m_Owner.WorldUnit2Kilometer;		// Back in WORLD units

			// Return color of the sky at that position
			return ComputeSkyColor( _ViewPosition, _ViewDirection, (float) HitDistance, out _Extinction, out _Terminator, _StepsCount );
		}

		/// <summary>
		/// Computes the color of the sky given the provided view position and direction and using the current density parameters
		/// </summary>
		/// <param name="_ViewPosition">The viewing position (in WORLD space)</param>
		/// <param name="_ViewDirection">The viewing direction (in WORLD space)</param>
		/// <param name="_ViewDistance">The distance to the point we're viewing (in WORLD space)</param>
		/// <param name="_Extinction">The background color that will be attenuated by the atmosphere
		/// (use 0 for empty space and 1 for occluded space, then use as a multiplier of the  existing background)</param>
		/// <param name="_Terminator">the terminator value (1 is fully lit, 0 is in Earth's shadow)</param>
		/// <param name="_StepsCount"></param>
		/// <returns>The color of the sky</returns>
		public Vector3	ComputeSkyColor( Vector3 _ViewPosition, Vector3 _ViewDirection, float _ViewDistance, out Vector3 _Extinction, out float _Terminator, int _StepsCount )
		{
			// Compute density & extinction parameters
			Vector3	Sigma_Rayleigh = 4.0f * Mathf.PI * m_DensityRayleigh * INV_WAVELENGTHS_POW4;
			float	Sigma_Mie = 4.0f * Mathf.PI * m_DensityMie;

			// Compute camera height & hit distance in kilometers
			double	Height = m_Owner.PlanetRadiusKm + m_Owner.WorldUnit2Kilometer * _ViewPosition.y;
			double	HitDistance = m_Owner.WorldUnit2Kilometer * _ViewDistance;

			// Compute phases
			float	CosTheta = Vector3.Dot( _ViewDirection, m_Owner.SunDirection );
			float	PhaseRayleigh = 0.75f * (1.0f + CosTheta*CosTheta);
			float	PhaseMie = 1.0f / (1.0f + m_ScatteringAnisotropy * CosTheta);
					PhaseMie = (1.0f - m_ScatteringAnisotropy*m_ScatteringAnisotropy) * PhaseMie * PhaseMie;

			// Compute potential intersection with earth's shadow
			Vector3	CurrentPosition = new Vector3( 0.0f, (float) Height, 0.0f );

			_Terminator = 1.0f;
			if ( Vector3.Dot( CurrentPosition, m_Owner.SunDirection ) < 0.0 )
			{	// Project current position in the 2D plane normal to the light to test the intersection with the shadow cylinder cast by the Earth
				Vector3	X = Vector3.Cross( m_Owner.SunDirection, _ViewDirection ).normalized;
				Vector3	Y = Vector3.Cross( X, m_Owner.SunDirection );
				Vector2	P = new Vector2( Vector3.Dot( CurrentPosition, X ), Vector3.Dot( CurrentPosition, Y ) );
				Vector2	V = new Vector2( Vector3.Dot( _ViewDirection, X ), Vector3.Dot( _ViewDirection, Y ) );
				double	a = Vector2.Dot( V, V );
				double	b = Vector2.Dot( P, V );
				double	c = Vector2.Dot( P, P ) - m_Owner.PlanetRadiusKm*m_Owner.PlanetRadiusKm;
				double	Delta = b*b - a*c;
				if ( Delta >= 0.0f )
					_Terminator = 1.0f - (float) Math.Max( 0.0, Math.Min( 1.0, (-b+Math.Sqrt(Delta)) / (a * HitDistance) ) );
			}

			// Ray-march the view ray
			Vector3	AccumulatedLightRayleigh = Vector3.zero;
			Vector3	AccumulatedLightMie = Vector3.zero;
			_Extinction = Vector3.one;

			float	StepSize = (float) HitDistance / _StepsCount;
			Vector3	Step = StepSize * _ViewDirection;
			CurrentPosition += 0.5f * Step;	// Start at half a step

			Vector3	SunExtinction = Vector3.zero;
			for ( int StepIndex=0; StepIndex < _StepsCount; StepIndex++ )
			{
				// =============================================
				// Sample extinction at current altitude and view direction
				Vector4	OpticalDepth = ComputeOpticalDepth( CurrentPosition, m_Owner.SunDirection );

				// Retrieve densities
				float	Rho_air = OpticalDepth.x;
				float	Rho_aerosols = OpticalDepth.y;

				// =============================================
				// Retrieve sun light attenuated when passing through the atmosphere
				SunExtinction.x = Mathf.Exp( -Sigma_Rayleigh.x * OpticalDepth.z - Sigma_Mie * OpticalDepth.w );
				SunExtinction.y = Mathf.Exp( -Sigma_Rayleigh.y * OpticalDepth.z - Sigma_Mie * OpticalDepth.w );
				SunExtinction.z = Mathf.Exp( -Sigma_Rayleigh.z * OpticalDepth.z - Sigma_Mie * OpticalDepth.w );
				Vector3	Light = Help.Vec3Product( m_Owner.SunColor, SunExtinction );

				// =============================================
				// Compute in-scattered light
				Vector3	InScatteringRayleigh = Light * Rho_air * m_DensityRayleigh * PhaseRayleigh * StepSize;
						InScatteringRayleigh.x *= INV_WAVELENGTHS_POW4.x * _Extinction.x;
						InScatteringRayleigh.y *= INV_WAVELENGTHS_POW4.y * _Extinction.y;
						InScatteringRayleigh.z *= INV_WAVELENGTHS_POW4.z * _Extinction.z;
				Vector3	InScatteringMie = Light * Rho_aerosols * m_DensityMie * PhaseMie * StepSize;
						InScatteringMie.x *= _Extinction.x;
						InScatteringMie.y *= _Extinction.y;
						InScatteringMie.z *= _Extinction.z;

				// =============================================
				// Accumulate in-scattered light
				AccumulatedLightRayleigh += InScatteringRayleigh;
				AccumulatedLightMie += InScatteringMie;

				// =============================================
				// Perform extinction of previous step's energy
				_Extinction.x *= Mathf.Exp( -(Sigma_Rayleigh.x * Rho_air + Sigma_Mie * Rho_aerosols) * StepSize );
				_Extinction.y *= Mathf.Exp( -(Sigma_Rayleigh.y * Rho_air + Sigma_Mie * Rho_aerosols) * StepSize );
				_Extinction.z *= Mathf.Exp( -(Sigma_Rayleigh.z * Rho_air + Sigma_Mie * Rho_aerosols) * StepSize );

				// March
				CurrentPosition += Step;
			}

			return AccumulatedLightRayleigh + AccumulatedLightMie;
		}

		/// <summary>
		/// Gets the rayleigh and mie densities from the density texture
		/// ρ(s,s') = Integral[s,s']( ρ(h(l)) dl )
		/// </summary>
		/// <param name="_ViewPosition"></param>
		/// <param name="_ViewDirection"></param>
		/// <returns></returns>
		protected Vector4	ComputeOpticalDepth( Vector3 _ViewPosition, Vector3 _ViewDirection )
		{
			Vector3	EarthNormal = _ViewPosition;
			float	Altitude = EarthNormal.magnitude;
			EarthNormal /= Altitude;

			// Normalize altitude
			Altitude = Math.Max( 0.0f, (float) ((Altitude - m_Owner.PlanetRadiusKm) / Math.Max( 0.01f, m_Owner.PlanetAtmosphereRadiusKm - m_Owner.PlanetRadiusKm)) );

			// Actual view direction
			float	CosTheta = Vector3.Dot( _ViewDirection, EarthNormal );

			Vector2	UV = new Vector2( 0.5f * (1.0f - CosTheta), Altitude );
			return SampleDensityTexture( UV );
		}

		protected Vector4	SampleDensityTexture( Vector2 _UV )
		{
			float	U = Mathf.Clamp( _UV.x * DENSITY_TEXTURE_SIZE, 0.0f, DENSITY_TEXTURE_SIZE-1 );
			int		X0 = (int) Math.Floor( U );
			float	s = U - X0;
					X0 = Math.Min( DENSITY_TEXTURE_SIZE-1, X0 );
			int		X1 = Math.Min( DENSITY_TEXTURE_SIZE-1, X0+1 );

			float	V = Mathf.Clamp( _UV.y * DENSITY_TEXTURE_SIZE, 0.0f, DENSITY_TEXTURE_SIZE-1 );
			int		Y0 = (int) Math.Floor( V );
			float	t = V - Y0;
					Y0 = Math.Min( DENSITY_TEXTURE_SIZE-1, Y0 );
			int		Y1 = Math.Min( DENSITY_TEXTURE_SIZE-1, Y0+1 );

			Vector4	C00 = m_DensityTextureCPU[X0,Y0];
			Vector4	C01 = m_DensityTextureCPU[X1,Y0];
			Vector4	C10 = m_DensityTextureCPU[X0,Y1];
			Vector4	C11 = m_DensityTextureCPU[X1,Y1];

			Vector4	C0 = Vector4.Lerp( C00, C01, s );
			Vector4	C1 = Vector4.Lerp( C10, C11, s );
			return Vector4.Lerp( C0, C1, t );
		}

		#endregion

		/// <summary>
		/// Assigns basic scattering coefficients to a material that needs to compute the optical depth of the atmosphere
		/// </summary>
		/// <param name="_Material"></param>
		/// <param name="_bSetupDensityTexture"></param>
		internal void	SetupScatteringCoefficients( NuajMaterial _Material, bool _bSetupDensityTexture )
		{
			// Build the GPU & CPU density textures if they do not already exist
			_Material.SetFloat( "_DensitySeaLevel_Rayleigh", m_DensityRayleigh );
			_Material.SetVector( "_Sigma_Rayleigh", m_SigmaRayleigh );
			_Material.SetFloat( "_DensitySeaLevel_Mie", m_DensityMie );
			_Material.SetFloat( "_Sigma_Mie", m_SigmaMie );
			_Material.SetFloat( "_MiePhaseAnisotropy", Mathf.Clamp( m_ScatteringAnisotropy, -0.99f, +0.99f ) );

			ComputeDensityTexture();
			if ( _bSetupDensityTexture )
 				_Material.SetTexture( "_TexDensity", m_DensityTexture );
		}

		/// <summary>
		/// Setups the sky parameters for the sky material
		/// </summary>
		/// <param name="_Material">The material to setup</param>
		/// <param name="_Layers">The array of cloud layers (from 0 to 4 elements)</param>
		/// <param name="_ShadowMap">The shadow map</param>
		protected void	SetupSkyParametersComplex( NuajMaterial _Material, ICloudLayer[] _Layers, Texture _ShadowMap )
		{
			// Build the GPU & CPU density textures if they do not already exist
			ComputeDensityTexture();
			_Material.SetTexture( "_TexDensity", m_DensityTexture );

			_Material.SetTextureRAW( "_TexShadowMap", _ShadowMap );

			_Material.SetFloat( "_DensitySeaLevel_Rayleigh", m_DensityRayleigh );
			_Material.SetVector( "_Sigma_Rayleigh", m_SigmaRayleigh );
			_Material.SetFloat( "_DensitySeaLevel_Mie", m_DensityMie );
			_Material.SetFloat( "_Sigma_Mie", m_SigmaMie );
			_Material.SetFloat( "_MiePhaseAnisotropy", Mathf.Clamp( m_ScatteringAnisotropy, -0.99f, +0.99f ) );
			_Material.SetVector( "_ScatteringBoost", new Vector2( 20.0f * m_ScatteringBoost, 1.0f / (2.0f * m_ExtinctionBoost) ) );

			_Material.SetFloat( "_SkyStepsCount", m_SkyStepsCount );//+ (_Layers.Length == 0 ? m_UnderCloudsMinStepsCount : 0) );	// Use higher resolution if no cloud layers
			_Material.SetFloat( "_UnderCloudsMinStepsCount", m_bGodRays ? m_UnderCloudsMinStepsCount : 0 );
			_Material.SetFloat( "_bGodRays", m_bGodRays ? 1 : 0 );
		}

		protected void	SetupSkyParametersSimple( NuajMaterial _Material, ICloudLayer[] _Layers )
		{
			// Build the GPU & CPU density textures if they do not already exist
			ComputeDensityTexture();
			_Material.SetTexture( "_TexDensity", m_DensityTexture );

			_Material.SetVector( "_Sigma_Rayleigh", m_SigmaRayleigh );
			_Material.SetFloat( "_Sigma_Mie", m_SigmaMie );
			_Material.SetFloat( "_MiePhaseAnisotropy", Mathf.Clamp( m_ScatteringAnisotropy, -0.99f, +0.99f ) );
		}

		/// <summary>
		/// Setups the cloud textures to compose the sky with
		/// </summary>
		/// <param name="_Material">The material to setup</param>
		/// <param name="_Layers">The array of cloud layers (from 0 to 4 elements)</param>
		/// <param name="_bIsEnvironmentRendering">True if the material is rendering the tiny environment map</param>
		/// <param name="_bUseDownsampledTarget">True if the material is rendering a downsampled version (in which case it will need the downsampled cloud target)</param>
		protected void	SetupCloudTextures( NuajMaterial _Material, ICloudLayer[] _Layers, bool _bIsEnvironmentRendering, bool _bUseDownsampledTarget )
		{
			// Prepare cloud layers' textures
			switch ( _Layers.Length )
			{
				case 0:
					_Material.SetTexture( "_TexCloudLayer0", m_Owner.m_TextureEmptyCloud, true );
					_Material.SetTexture( "_TexCloudLayer1", m_Owner.m_TextureEmptyCloud, true );
					_Material.SetTexture( "_TexCloudLayer2", m_Owner.m_TextureEmptyCloud, true );
					_Material.SetTexture( "_TexCloudLayer3", m_Owner.m_TextureEmptyCloud, true );
					break;
				case 1:
					_Material.SetTexture( "_TexCloudLayer0", _bIsEnvironmentRendering ? _Layers[0].EnvironmentRenderTargetSky : (_bUseDownsampledTarget ? _Layers[0].DownsampledRenderTarget : _Layers[0].RenderTarget) );
					_Material.SetTexture( "_TexCloudLayer1", m_Owner.m_TextureEmptyCloud, true );
					_Material.SetTexture( "_TexCloudLayer2", m_Owner.m_TextureEmptyCloud, true );
					_Material.SetTexture( "_TexCloudLayer3", m_Owner.m_TextureEmptyCloud, true );
					break;
				case 2:
					_Material.SetTexture( "_TexCloudLayer0", _bIsEnvironmentRendering ? _Layers[0].EnvironmentRenderTargetSky : (_bUseDownsampledTarget ? _Layers[0].DownsampledRenderTarget : _Layers[0].RenderTarget) );
					_Material.SetTexture( "_TexCloudLayer1", _bIsEnvironmentRendering ? _Layers[1].EnvironmentRenderTargetSky : (_bUseDownsampledTarget ? _Layers[1].DownsampledRenderTarget : _Layers[1].RenderTarget) );
					_Material.SetTexture( "_TexCloudLayer2", m_Owner.m_TextureEmptyCloud, true );
					_Material.SetTexture( "_TexCloudLayer3", m_Owner.m_TextureEmptyCloud, true );
					break;
				case 3:
					_Material.SetTexture( "_TexCloudLayer0", _bIsEnvironmentRendering ? _Layers[0].EnvironmentRenderTargetSky : (_bUseDownsampledTarget ? _Layers[0].DownsampledRenderTarget : _Layers[0].RenderTarget) );
					_Material.SetTexture( "_TexCloudLayer1", _bIsEnvironmentRendering ? _Layers[1].EnvironmentRenderTargetSky : (_bUseDownsampledTarget ? _Layers[1].DownsampledRenderTarget : _Layers[1].RenderTarget) );
					_Material.SetTexture( "_TexCloudLayer2", _bIsEnvironmentRendering ? _Layers[2].EnvironmentRenderTargetSky : (_bUseDownsampledTarget ? _Layers[2].DownsampledRenderTarget : _Layers[2].RenderTarget) );
					_Material.SetTexture( "_TexCloudLayer3", m_Owner.m_TextureEmptyCloud, true );
					break;
				case 4:
					_Material.SetTexture( "_TexCloudLayer0", _bIsEnvironmentRendering ? _Layers[0].EnvironmentRenderTargetSky : (_bUseDownsampledTarget ? _Layers[0].DownsampledRenderTarget : _Layers[0].RenderTarget) );
					_Material.SetTexture( "_TexCloudLayer1", _bIsEnvironmentRendering ? _Layers[1].EnvironmentRenderTargetSky : (_bUseDownsampledTarget ? _Layers[1].DownsampledRenderTarget : _Layers[1].RenderTarget) );
					_Material.SetTexture( "_TexCloudLayer2", _bIsEnvironmentRendering ? _Layers[2].EnvironmentRenderTargetSky : (_bUseDownsampledTarget ? _Layers[2].DownsampledRenderTarget : _Layers[2].RenderTarget) );
					_Material.SetTexture( "_TexCloudLayer3", _bIsEnvironmentRendering ? _Layers[3].EnvironmentRenderTargetSky : (_bUseDownsampledTarget ? _Layers[3].DownsampledRenderTarget : _Layers[3].RenderTarget) );
					break;
			}
		}

		protected void	UpdateCachedValues()
		{
			if ( m_Owner == null )
				return;
			
			m_SigmaMie = 4.0f * Mathf.PI * m_DensityMie;
			m_SigmaRayleigh = 4.0f * Mathf.PI * m_DensityRayleigh * INV_WAVELENGTHS_POW4;

			// Setup the global environment parameters
			NuajMaterial.SetGlobalVector( "_EnvironmentAngles", new Vector4( ENVIRONMENT_PHI_START, ENVIRONMENT_THETA_START, ENVIRONMENT_PHI_END-ENVIRONMENT_PHI_START, ENVIRONMENT_THETA_END-ENVIRONMENT_THETA_START ) );
			NuajMaterial.SetGlobalFloat( "_EnvironmentMapPixelSize", 2.0f * Mathf.Tan( 0.5f * ENVIRONMENT_THETA_END ) / NuajManager.ENVIRONMENT_TEXTURE_SIZE_POT );

			Vector3	ProbePositionKm = m_Owner.Camera2WorldKm.GetColumn( 3 );	// Use camera position
					ProbePositionKm.y = 0.0f;									// Force it to the ground, this is where we will probe the environment
			NuajMaterial.SetGlobalVector( "_EnvProbePositionKm", ProbePositionKm );

			// Notify
			if ( SkyParametersChanged != null )
				SkyParametersChanged( this, EventArgs.Empty );
		}

		#endregion

		#region EVENT HANDLERS

		protected void NuajManager_PlanetDimensionsChanged( object sender, EventArgs e )
		{
			Help.SafeDestroy( ref m_DensityTexture );	// This will trigger a rebuild on next frame
		}

		#endregion
	}
}