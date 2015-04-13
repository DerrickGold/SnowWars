#define USE_CPU_READBACK_TRIPLE_BUFFER	// Uses a triple buffer with a 2 frames delay before accessing a texture by CPU... But it doesn't seem to work anyway... Better safe than sorry though

using System;
using System.Collections.Generic;
using UnityEngine;

using Nuaj;

/// <summary>
/// Nuaj' Manager is the main component of the Nuaj' atmospheric system.
/// It represents the API of the system through which you can access all specific modules at runtime
/// </summary>
[ExecuteInEditMode]
public class NuajManager : MonoBehaviour, IComparer<ICloudLayer>
{
	#region CONSTANTS

	// World constants
	protected const float				WORLD_UNIT_TO_KILOMETER = 0.01f;	// 1 World Unit equals XXX kilometers
	protected const float				EARTH_RADIUS = 6400.0f;				// Earth radius (in kilometers)
	protected const float				ATMOSPHERE_ALTITUDE = 60.0f;		// Altitude of the top atmosphere (in kilometers)

	// Default parameters
	protected const int					DEFAULT_SHADOW_MAP_SIZE = 512;
	protected const int					DEFAULT_LIGHT_COOKIE_SIZE = 128;
	protected const int					NOISE3D_TEXTURE_POT = 4;
	protected const int					NOISE3D_TEXTURE_SIZE = 1 << NOISE3D_TEXTURE_POT;
	protected const int					NOISE2D_TEXTURE_POT = 8;
	internal const int					NOISE2D_TEXTURE_SIZE = 1 << NOISE2D_TEXTURE_POT;

	// Luminance adaptation
	internal const float				MIN_LUMINANCE_AT_DAY = 0.1f;		// Minimum luminance we can adapt during day time
	internal const float				MAX_LUMINANCE_AT_DAY = 6.0f;		// Maximum luminance we can adapt during day time
	internal const float				MIN_LUMINANCE_AT_NIGHT = 0.02f;		// Minimum luminance we can adapt during night time
	internal const float				MAX_LUMINANCE_AT_NIGHT = 1.0f;		// Maximum luminance we can adapt during night time
	internal const float				LUMINANCE_ADAPTATION_SPEED_AT_DAY = 0.7f;	// Adaptation speed during day time
	internal const float				LUMINANCE_ADAPTATION_SPEED_AT_NIGHT = 0.5f * LUMINANCE_ADAPTATION_SPEED_AT_DAY;	// Adaptation speed during night time

	internal static readonly Vector3	LUMINANCE = new Vector3( 0.2126f, 0.7152f, 0.0722f );	// RGB => Y (taken from http://wiki.gamedev.net/index.php/D3DBook:High-Dynamic_Range_Rendering#Light_Adaptation)
	internal const int					ENVIRONMENT_TEXTURE_SIZE_POT = 4;	// Use a 32x16 rendering for sky environment

	protected const int					MAX_ALLOWED_LAYERS	= 4;			// We can't render more than 4 cloud layers at a time (no need to change that for higher values, this will only make the manager crash !)

	protected const int					CPU_READBACK_COUNT = 3;				// We need to readback at most 3 values : luminance, sun color & sky color

	#endregion

	#region NESTED TYPES

	/// <summary>
	/// The various supported tone mapping schemes
	/// </summary>
	public enum		TONE_MAPPING_TYPE
	{
		/// <summary>
		/// Filmic tone mapping applies a S-curve to the image luminance to attenuate highlights and increase shadows' contrast
		/// </summary>
		FILMIC,

		/// <summary>
		/// Drago tone mapping applies a logarithmic curve to the image luminance
		/// </summary>
		DRAGO,

		/// <summary>
		/// Reinhard tone mapping applies an inverse curve to the image luminance
		/// </summary>
		REINHARD,

		/// <summary>
		/// Linear applies a linear curve to the image luminance
		/// </summary>
		LINEAR,

		/// <summary>
		/// Exponential applies an exponential curve to the image luminance
		/// </summary>
		EXPONENTIAL,

		/// <summary>
		/// No tone mapping is applied : the output color equals the input color
		/// </summary>
		DISABLED,
	}

	/// <summary>
	/// The various luminance computation schemes
	/// </summary>
	public enum		LUMINANCE_COMPUTATION_TYPE
	{
		/// <summary>
		/// Downsamples the scene's luminance into a single pixel used to tone-map the image
		/// This is the most accurate and automated process but also the slowest
		/// </summary>
		DOWNSAMPLE,

		/// <summary>
		/// LOG-Downsamples the scene's luminance into a single pixel used to tone-map the image
		/// This is the most accurate and automated process but also the slowest
		/// The "log" part here is simply that we take the log of the luminance instead of the linear luminance.
		/// This is important when large luminance ranges (like 10000 for daylight and 0.001 during nighttime) are used.
		/// </summary>
		DOWNSAMPLE_LOG,

		/// <summary>
		/// Uses a constant luminance of 1
		/// Fast and painless but not accurate
		/// </summary>
		ONE,

		/// <summary>
		/// Uses a custom value set by the user
		/// </summary>
		CUSTOM,
	}

	/// <summary>
	/// This describes the various upscale techniques that can be used to refine downsampled rendering
	/// </summary>
	public enum		UPSAMPLING_TECHNIQUE
	{
		/// <summary>
		/// Refines areas with strong discrepancies at the cost of recomputing additional pixels
		/// This is the best method but also the most time consuming if there are many jagged edges, like with vegetation or watching the clouds through grating
		/// </summary>
		ACCURATE,

		/// <summary>
		/// This method attempts to retrieve the most appropriate color without recomputing new values
		/// </summary>
		SMART,

		/// <summary>
		/// This method displays the layers using a sharp cutout with the scene
		/// </summary>
		CUTOUT,

		/// <summary>
		/// Simple bilinear interpolation, this is the cheapest method but it will show unwanted square artefacts at edges
		/// </summary>
		BILINEAR,
	}

	/// <summary>
	/// Use this delegate to perform your own custom environment Sky & Sun rendering
	/// </summary>
	/// <param name="_Sender"></param>
	/// <param name="_SunColor">The environment Sun color (HDR!) that will be fed to Unity's directional Sun light</param>
	/// <param name="_SkyColor">The environment Sky color (HDR!) taht will be fed to Unity's ambient color</param>
	/// <example>You can find an example of an existing environment renderer in ModulePerspective.RenderEnvironmentSoftware()</example>
	public delegate void	CustomEnvironmentRenderingEventHandler( NuajManager _Sender, out Vector3 _SunColor, out Vector3 _SkyColor );

	/// <summary>
	/// Use this delegate to perform custom luminance mapping
	/// </summary>
	/// <param name="_Sender"></param>
	/// <param name="_LastFrameLuminance">The scene's luminance at last frame</param>
	/// <param name="_CurrentFrameLuminance">The scene's target luminance at current frame</param>
	/// <returns>The RGB "luminance" to use to tone map the scene</returns>
	public delegate Vector3	CustomLuminanceAdaptationEventHandler( NuajManager _Sender, Vector3 _LastFrameLuminance, float _CurrentFrameLuminance );

	/// <summary>
	/// Use this delegate to perform custom sky composition
	/// </summary>
	/// <param name="_Layers">The cloud layers from lowest to highest (up to 4 layers)</param>
	/// <param name="_ShadowMap">The shadow map used for godrays. Each channel of the RGBA shadow map indicates the amount of shadowing for each of the 4 layers (R is lowest layer and A is highest)</param>
	/// <param name="_Background">The background image consisting of satellites</param>
	public delegate void	CustomSkyCompositionEventHandler( ICloudLayer[] _Layers, Texture _ShadowMap, Texture _Background );

	/// <summary>
	/// Use this delegate to perform custom background clear (if not used, the background is cleared to black by default)
	/// </summary>
	/// <param name="_BackgroundToClear">The background image where satellites will be rendered</param>
	public delegate void	CustomBackgroundClearEventHandler( RenderTexture _BackgroundToClear );

	/// <summary>
	/// Use this delegate to perform custom background rendering
	/// </summary>
	/// <param name="_CurrentBackground">The current background image where satellites have already been rendered.</param>
	/// <returns>A new texture to use as background</returns>
	public delegate Texture	CustomBackgroundRenderEventHandler( RenderTexture _CurrentBackground );

	/// <summary>
	/// This describes the parameters used by the Filmic tone mapping algorithm (http://filmicgames.com/archives/75)
	/// </summary>
	[Serializable]
	public class	ToneMappingParameters_Filmic
	{
		public float	A = 0.15f;	// A = Shoulder Strength
		public float	B = 0.50f;	// B = Linear Strength
		public float	C = 0.10f;	// C = Linear Angle
		public float	D = 0.20f;	// D = Toe Strength
		public float	E = 0.02f;	// E = Toe Numerator
		public float	F = 0.30f;	// F = Toe Denominator
									// (Note: E/F = Toe Angle)
		public float	W = 0.14f;	// LinearWhite = Linear White Point Value

		[NonSerialized]
		public float	MiddleGrey;	// Internally computed by Nuaj
	}

	/// <summary>
	/// This describes the parameters used by the Drago (log) tone mapping algorithm (http://citeseer.ist.psu.edu/viewdoc/summary?doi=10.1.1.10.7814)
	/// </summary>
	[Serializable]
	public class	ToneMappingParameters_Drago
	{
		public float	MaxDisplayLuminance = 80.0f;
		public float	Bias = 0.85f;
	}

	/// <summary>
	/// This describes the parameters used by the Reinhard tone mapping algorithm (http://www.cs.ucf.edu/~reinhard/cdrom/)
	/// </summary>
	[Serializable]
	public class	ToneMappingParameters_Reinhard
	{
		public float	WhiteLuminance = 0.1f;
		[NonSerialized]
		public float	MiddleGrey;	// Internally computed by Nuaj
	}

	/// <summary>
	/// This describes the parameters used by the Linear tone mapping algorithm
	/// </summary>
	[Serializable]
	public class	ToneMappingParameters_Linear
	{
		public float	Factor = 10.0f;
		[NonSerialized]
		public float	MiddleGrey;	// Internally computed by Nuaj
	}

	/// <summary>
	/// This describes the parameters used by the Exponential tone mapping algorithm (http://megapov.inetart.net/manual-1.2/global_settings.html)
	/// </summary>
	[Serializable]
	public class	ToneMappingParameters_Exponential
	{
		public float	Exposure = 0.25f;
		public float	Gain = 3.5f;
	}

	#endregion

	#region FIELDS

	/////////////////////////////////////////////////////////
	// General serializable parameters
	[SerializeField] protected GameObject				m_Camera = null;

	// World
	[SerializeField] protected float					m_WorldUnit2Kilometer = WORLD_UNIT_TO_KILOMETER;
	[SerializeField] protected Vector3					m_PlanetCenterKm = -EARTH_RADIUS * Vector3.up;	// By default, we're on the surface so the center is 6400 Kms below us...
	[SerializeField] protected Vector3					m_PlanetNormal = Vector3.up;					// This is the normal to the planet where the camera is standing
	[SerializeField] protected float					m_PlanetRadiusKm = EARTH_RADIUS;
	[SerializeField] protected float					m_PlanetRadiusOffsetKm = -1.0f;
	[SerializeField] protected float					m_PlanetAtmosphereAltitudeKm = ATMOSPHERE_ALTITUDE;
	[SerializeField] protected UPSAMPLING_TECHNIQUE		m_UpsamplingTechnique = UPSAMPLING_TECHNIQUE.ACCURATE;
	[SerializeField] protected float					m_ZBufferDiscrepancyThreshold = 200.0f;
	[SerializeField] protected float					m_SmartUpsamplingWeightFactor = 0.5f;
	[SerializeField] protected float					m_SmartUpsamplingCutoutFactor = 0.05f;
	[SerializeField] protected bool						m_bShowZBufferDiscrepancies = false;

	// Sun
	[SerializeField] protected GameObject				m_Sun = null;
	[SerializeField] protected Vector3					m_SunDirection = Vector3.up;
	[SerializeField] protected float					m_SunPhi = 0.0f;
	[SerializeField] protected float					m_SunTheta = 0.0f;
	[SerializeField] protected bool						m_bSunDrivenDirection = true;
	[SerializeField] protected bool						m_bSunDrivenDirectionalColor = true;
	[SerializeField] protected bool						m_bSunDrivenAmbientColor = true;
	[SerializeField] protected Color					m_SunHue = Color.white;
	[SerializeField] protected float					m_SunIntensity = 10.0f;
	[SerializeField] protected bool						m_bRenderSoftwareEnvironment = false;
	[SerializeField] protected float					m_SunsetAngleStart = 85.0f;						// Sun starts setting at 85°
	[SerializeField] protected float					m_SunsetAngleEnd = 88.0f;						// Sun actually goes below the horizon without noticeable effect on the visible atmosphere after 110° (assuming we're standing on the ground at sea level) but we choose to make it set very early to avoid shadow flickering

	// Shadows
	[SerializeField] protected int						m_ShadowMapSize = DEFAULT_SHADOW_MAP_SIZE;
	[SerializeField] protected float					m_ShadowFarClip = 5000.0f;
	[SerializeField] protected bool						m_bCastShadowUsingLightCookie = true;
	[SerializeField] protected int						m_LightCookieTextureSize = DEFAULT_LIGHT_COOKIE_SIZE;
	[SerializeField] protected float					m_LightCookieSize = 500.0f;
	[SerializeField] protected bool						m_bLightCookieSampleAtCameraAltitude = true;
	[SerializeField] protected float					m_LightCookieSampleAltitudeKm = 0.0f;

	// Lightning
	// We allow only 2 lighting bolts at the same time. That's how it is.
	[SerializeField] protected GameObject				m_LightningBolt0 = null;
	[SerializeField] protected GameObject				m_LightningBolt1 = null;

	// Local variations
	[SerializeField] protected GameObject				m_LocalCoverage = null;
	[SerializeField] protected GameObject				m_TerrainEmissive = null;
	[SerializeField] protected Color					m_TerrainAlbedo = new Color( 74.0f, 48.0f, 32.0f, 127.0f ) / 255.0f;

	// Luminance adaptation
	[SerializeField] protected float					m_ToneMappingMinLuminanceAtDay = MIN_LUMINANCE_AT_DAY;
	[SerializeField] protected float					m_ToneMappingMaxLuminanceAtDay = MAX_LUMINANCE_AT_DAY;
	[SerializeField] protected float					m_ToneMappingAdaptationSpeedAtDay = LUMINANCE_ADAPTATION_SPEED_AT_DAY;
	[SerializeField] protected float					m_ToneMappingMinLuminanceAtNight = MIN_LUMINANCE_AT_NIGHT;
	[SerializeField] protected float					m_ToneMappingMaxLuminanceAtNight = MAX_LUMINANCE_AT_NIGHT;
	[SerializeField] protected float					m_ToneMappingAdaptationSpeedAtNight = LUMINANCE_ADAPTATION_SPEED_AT_NIGHT;

	[SerializeField] protected ToneMappingParameters_Reinhard		m_ToneMappingParamsReinhard = new ToneMappingParameters_Reinhard();
	[SerializeField] protected ToneMappingParameters_Drago			m_ToneMappingParamsDrago = new ToneMappingParameters_Drago();
	[SerializeField] protected ToneMappingParameters_Filmic			m_ToneMappingParamsFilmic = new ToneMappingParameters_Filmic();
	[SerializeField] protected ToneMappingParameters_Exponential	m_ToneMappingParamsExponential = new ToneMappingParameters_Exponential();
	[SerializeField] protected ToneMappingParameters_Linear			m_ToneMappingParamsLinear = new ToneMappingParameters_Linear();

	[SerializeField] protected float					m_UnitySunColorFactor = 0.15f;
	[SerializeField] protected float					m_UnityAmbientColorFactor = 0.5f;

	// Tone mapping
	[SerializeField] protected TONE_MAPPING_TYPE			m_ToneMappingType = TONE_MAPPING_TYPE.FILMIC;
	[SerializeField] protected LUMINANCE_COMPUTATION_TYPE	m_LuminanceComputationType = LUMINANCE_COMPUTATION_TYPE.DOWNSAMPLE;
	[SerializeField] protected float					m_LuminanceAverageOrMax = 1.0f;
	[SerializeField] protected bool						m_bSceneIsHDR = false;
	[SerializeField] protected float					m_SceneLuminanceCorrection = 0.5f;
	[SerializeField] protected float					m_ToneMappingGamma = 2.2f;
	[SerializeField] protected float					m_ToneMappingBoostFactor = 1.0f;

	// Glow Support
	[SerializeField] protected bool						m_bEnableGlowSupport = false;
	[SerializeField] protected bool						m_bCombineAlphas = false;
	[SerializeField] protected Vector2					m_GlowIntensityThreshold = new Vector2( 0.75f, 1.4f );


	/////////////////////////////////////////////////////////
	// The available modules
	[SerializeField] protected ModulePerspective	m_ModulePerspective = new ModulePerspective( "Aerial Perspective" );
	[SerializeField] protected ModuleCloudLayer		m_ModuleCloudLayer = new ModuleCloudLayer( "Cloud Layer" );
	[SerializeField] protected ModuleCloudVolume	m_ModuleCloudVolume = new ModuleCloudVolume( "Volume Clouds" );
	[SerializeField] protected ModuleSatellites		m_ModuleSatellites = new ModuleSatellites( "Satellites" );
	protected ModuleBase[]				m_Modules = null;


	/////////////////////////////////////////////////////////
	// Materials
	protected NuajMaterial				m_MaterialCompose = null;
	protected NuajMaterial				m_MaterialClearTexture = null;
	protected NuajMaterial				m_MaterialRenderLightCookie = null;
	protected NuajMaterial				m_MaterialDownsampleZBuffer = null;
	protected ImageScaler				m_ImageScaler = new ImageScaler();

	/////////////////////////////////////////////////////////
	// Textures & Targets
	protected RenderTexture				m_RTScattering = null;
	protected RenderTexture				m_RTShadowMap = null;
	protected RenderTexture				m_RTBackground = null;
	protected RenderTexture				m_RTBackgroundEnvironment = null;
	protected RenderTexture				m_RTLightCookie = null;

	// Default internal textures
	internal NuajTexture2D				m_TextureEmptyCloud = null;
	internal NuajTexture2D				m_TextureWhite = null;
	internal NuajTexture2D				m_TextureBlack = null;
	internal NuajTexture2D[]			m_TextureNoise3D = null;
	internal NuajTexture2D				m_TextureNoise2D = null;
	protected RenderTexture[]			m_GPU2CPURenderTextures = new RenderTexture[3];
	protected NuajTexture2D				m_CPUReadableTexture = null;
	protected Color[]					m_CPUReadBack = null;

	/////////////////////////////////////////////////////////
	// Camera Effect
	protected EffectComposeAtmosphere	m_CameraEffectComposeAtmosphere = null;

	/////////////////////////////////////////////////////////
	// Internal parameters
	protected bool						m_bInternalDataAreValid = false;

	protected int						m_ScreenWidth = 0;
	protected int						m_ScreenHeight = 0;

	// Cached Sun & Moon & Stars data
	protected Matrix4x4					m_Sun2World = Matrix4x4.identity;
	protected Matrix4x4					m_World2Sun = Matrix4x4.identity;
	protected Vector3					m_SunColor = Vector3.one;	// Cached color = Intensity * Hue
	protected Vector3					m_AmbientNightSky = Vector3.zero;
	protected bool						m_bUseMoonAtNight = false;
	protected Vector3					m_MoonDirection = Vector3.zero;
	protected Vector3					m_MoonColor = Vector3.zero;
	protected float						m_MoonIntensity = 0.0f;
	protected float						m_SmoothDayNight = 0.0f;					// A value in [0,1] where 0 is day, 1 is night

	protected Vector3					m_LightSourceDirection = Vector3.zero;		// The actual light source we need to use. Can be the Sun or the Moon depending on time of day...

	// Cached luminance data for tone mapping
	protected float						m_ImageLuminance = 0.0f;
	protected Vector3					m_PreviousFrameLuminance = Vector3.zero;
	protected Vector3					m_CurrentAdaptationLuminance = Vector3.one;

	// Cached camera data
	protected Vector4					m_CameraData;
	protected Matrix4x4					m_Camera2World;
	protected Matrix4x4					m_World2Camera;
	protected Matrix4x4					m_Camera2WorldKm;	// Same but with positions in kilometers
	protected Matrix4x4					m_World2CameraKm;

	// Cached planet data
	protected Vector3					m_PlanetTangent = Vector3.zero;
	protected Vector3					m_PlanetBiTangent = Vector3.zero;
	protected float						m_Kilometer2WorldUnit = 0.0f;

	// Cached local variations data
	protected NuajTexture2D				m_LocalCoverageTexture = new NuajTexture2D();
	protected NuajTexture2D				m_TerrainEmissiveTexture = new NuajTexture2D();

	// Cached shadow map data
	protected Vector4					m_ShadowMapAltitudesMinKm = Vector4.zero;	// The minimum altitudes for the 4 cloud layers
	protected Vector4					m_ShadowMapAltitudesMaxKm = Vector4.zero;	// The maximum altitudes for the 4 cloud layers
	protected float						m_ShadowMapPlaneAltitudesKm = 0.0f;			// The altitude where the shadow map plane is computed. It's the altitude of the top of the highest non empty cloud layer.
	protected Matrix4x4					m_ShadowPlane2World;						// Transforms between world and shadow plane (kilometers)
	protected Matrix4x4					m_World2ShadowPlane;
	protected Matrix4x4					m_ShadowMap2World;							// Transforms between world (kilometers) and shadow UV (normalized texture coordinates)
	protected Matrix4x4					m_World2ShadowMap;

	protected Vector2					m_ShadowMapQuadMin;
	protected Vector2					m_ShadowMapQuadMax;
	internal Vector4					m_ShadowMapUVBounds;
	protected Rect						m_ShadowMapViewport;

	// Cached CPU-readable data
	protected int						m_WrittenCPUDataCount = 0;				// The amount of written data to be read back by the CPU. Updated each frame. If 0, no read-back is performed which saves a lot of time !

	// Error & Warning states
	protected bool						m_bInErrorState = false;
	protected string					m_Error = "";
	protected bool						m_bInWarningState = false;
	protected string					m_Warning = "";

	#endregion

	#region PROPERTIES

	/// <summary>
	/// Gets or sets the camera that will receive the atmospheric effects
	/// </summary>
	public GameObject				Camera
	{
		get { return m_Camera; }
		set
		{
			if ( value == m_Camera )
				return;
			if ( value != null && !value.GetComponent<Camera>() )
			{	// Not a camera !
				Nuaj.Help.LogError( "The GameObject assigned as Camera has no Camera component !" ); 
				value = null;
			}

			// Destroy image effect
			DestroyCameraEffect();

			m_Camera = value;

			// Initialize image effect
			CreateOrAttachCameraEffect();

			// Notify
			if ( CameraChanged != null )
				CameraChanged( this, EventArgs.Empty );
		}
	}

	/// <summary>
	/// Gets the camera's altitude in kilometers
	/// </summary>
	public float					CameraAltitudeKm
	{
		get
		{
			if ( m_Camera == null )
				return 0.0f;

			Vector3	CameraPositionKm = (Vector3) m_Camera2WorldKm.GetColumn( 3 );
			return Vector3.Magnitude( CameraPositionKm - m_PlanetCenterKm ) - m_PlanetRadiusKm;
		}
	}

	#region Sun & Moon & Stars Parameters

	/// <summary>
	/// Gets or sets the Sun object whose transform's Z axis will dictate the Sun's direction.
	/// (NOTE: this is a vector pointing TOWARD the Sun)
	/// </summary>
	public GameObject				Sun
	{
		get { return m_Sun; }
		set
		{
			if ( value == m_Sun )
				return;

			if ( m_Sun != null )
			{	// Un-subscribe from previous Sun
				SunDirection = Vector3.up;

				if ( m_Sun.light != null )
					m_Sun.light.cookie = null;
			}

			m_Sun = value;

			if ( m_Sun != null )
			{	// Subscribe to new Sun
				SunDirection = m_Sun.transform.up;

 				if ( m_Sun.light != null )
 					m_Sun.light.cookie = m_RTLightCookie;
			}

			// Notify
			if ( SunChanged != null )
				SunChanged( this, EventArgs.Empty );
		}
	}

	/// <summary>
	/// Gets or sets the Sun's direction in WORLD space.
	/// (NOTE: this is a vector pointing TOWARD the Sun)
	/// </summary>
	public Vector3					SunDirection
	{
		get { return m_SunDirection; }
		set
		{
			if ( value.sqrMagnitude < 1e-6f )
				value = Vector3.up;
			else
				value = value.normalized;

			m_SunDirection = value;

			// Compute SUN => WORLD transform
			m_Sun2World = Matrix4x4.identity;

			Vector3	Up = Vector3.up;
			Vector3	Right = Vector3.Cross( Up, m_SunDirection ).normalized;
			Up = Vector3.Cross( m_SunDirection, Right );

			m_Sun2World.SetColumn( 0, Help.Vec3ToVec4( Right, 0.0f ) );
			m_Sun2World.SetColumn( 1, Help.Vec3ToVec4( Up, 0.0f ) );
			m_Sun2World.SetColumn( 2, Help.Vec3ToVec4( m_SunDirection, 0.0f ) );
			m_Sun2World.SetColumn( 3, Help.Vec3ToVec4( m_PlanetCenterKm, 1.0f ) );		// Center on the planet
			m_World2Sun = m_Sun2World.inverse;

			// Update the Sun's angles
			m_SunTheta = (float) Math.Acos( m_SunDirection.y );
			m_SunPhi = (float) Math.Atan2( m_SunDirection.x, m_SunDirection.z );

			// Also update game object's transform
			if ( m_bSunDrivenDirection && m_Sun != null )
				m_Sun.transform.LookAt( m_Sun.transform.position - m_SunDirection, m_Sun2World.GetRow( 1 ) );

			// Update cached values
			UpdateLightingCachedValues();

			// Notify
			if ( SunDirectionChanged != null )
				SunDirectionChanged( this, EventArgs.Empty );
		}
	}

	/// <summary>
	/// Gets or sets the Sun's azimuth in radians
	/// </summary>
	public float					SunAzimuth
	{
		get { return m_SunPhi; }
		set
		{
			value = Mathf.Clamp( value, -Mathf.PI, +Mathf.PI );
			if ( Mathf.Approximately( value, m_SunPhi ) )
				return;

			m_SunPhi = value;
			SunDirection = new Vector3( Mathf.Sin( m_SunPhi ) * Mathf.Sin( m_SunTheta ), Mathf.Cos( m_SunTheta ), Mathf.Cos( m_SunPhi ) * Mathf.Sin( m_SunTheta ) );
		}
	}

	/// <summary>
	/// Gets or sets the Sun's elevation in radians
	/// </summary>
	public float					SunElevation
	{
		get { return m_SunTheta; }
		set
		{
			value = Mathf.Clamp( value, 1e-4f, Mathf.PI );
			if ( Mathf.Approximately( value, m_SunTheta ) )
				return;

			m_SunTheta = value;
			SunDirection = new Vector3( Mathf.Sin( m_SunPhi ) * Mathf.Sin( m_SunTheta ), Mathf.Cos( m_SunTheta ), Mathf.Cos( m_SunPhi ) * Mathf.Sin( m_SunTheta ) );
		}
	}

	/// <summary>
	/// Tells if Nuaj' drives the Sun game object (usually, a directional light).
	/// If true, the light's direction is set by Nuaj'.
	/// If false, the light's direction is used by Nuaj'.
	/// </summary>
	public bool						NuajDrivesSunDirection
	{
		get { return m_bSunDrivenDirection; }
		set { m_bSunDrivenDirection = value; }
	}

	/// <summary>
	/// Tells if Nuaj' drives the Sun game object (usually, a directional light).
	/// If true, the light's direction is set by Nuaj'
	/// </summary>
	public bool						NuajDrivesSunDirectionalColor
	{
		get { return m_bSunDrivenDirectionalColor; }
		set { m_bSunDrivenDirectionalColor = value; }
	}

	/// <summary>
	/// Tells if Nuaj' drives the Scene's ambient lighting.
	/// If true, the ambient color is set by Nuaj'
	/// </summary>
	public bool						NuajDrivesSunAmbientColor
	{
		get { return m_bSunDrivenAmbientColor; }
		set { m_bSunDrivenAmbientColor = value; }
	}

	/// <summary>
	/// Gets or sets the Sun's hue (i.e. the Sun's hue in space, without alteration by the atmosphere)
	/// </summary>
	public Color					SunHue
	{
		get { return m_SunHue; }
		set
		{
			if ( Color.Equals( value, m_SunHue ) )
				return;

			m_SunHue = value;
			UpdateLightingCachedValues();
		}
	}

	/// <summary>
	/// Gets or sets the Sun's intensity (i.e. the Sun's intensity in space, without alteration by the atmosphere)
	/// </summary>
	public float					SunIntensity
	{
		get { return m_SunIntensity; }
		set
		{
			if ( Mathf.Approximately( value, m_SunIntensity ) )
				return;
			m_SunIntensity = value;
			UpdateLightingCachedValues();
		}
	}

	/// <summary>
	/// Tells if Nuaj' should render the environment in software (i.e. CPU computed) or hardware.
	/// Hardware environment is much more accurate but uses an additional GPU overhead to render the environment map.
	/// Software environment lacks the contribution of clouds and shadow but is a bit faster to evaluate.
	/// </summary>
	public bool						RenderSoftwareEnvironment
	{
		get { return m_bRenderSoftwareEnvironment; }
		set { m_bRenderSoftwareEnvironment = value; }
	}

	/// <summary>
	/// Gets or sets the angle where the Sun starts setting
	/// </summary>
	public float					SunsetAngleStart
	{
		get { return m_SunsetAngleStart; }
		set
		{
			if ( Mathf.Approximately( value, m_SunsetAngleStart ) )
				return;
			m_SunsetAngleStart = value;
			UpdateLightingCachedValues();
		}
	}

	/// <summary>
	/// Gets or sets the angle after which we consider the Sun is set
	/// </summary>
	public float					SunsetAngleEnd
	{
		get { return m_SunsetAngleEnd; }
		set
		{
			if ( Mathf.Approximately( value, m_SunsetAngleEnd ) )
				return;
			m_SunsetAngleEnd = value;
			UpdateLightingCachedValues();
		}
	}

	/// <summary>
	/// Gets the Sun's color (i.e. the Sun's color in space, without alteration by the atmosphere).
	/// If you need the Sun's color as seen from the camera (with alteration by the atmosphere) use ModulePerspective.RenderedSunColor
	/// </summary>
	/// <remarks>This value is equivalent to SunIntensity * SunHue</remarks>
	public Vector3					SunColor
	{
		get { return m_SunColor; }
	}

	/// <summary>
	/// Gets or sets the ambient night sky color to add a little light at night
	/// NOTE: This parameter is set by the background satellites
	/// </summary>
	internal Vector3				AmbientNightSky
	{
		get { return m_AmbientNightSky; }
		set
		{
			if ( Help.Approximately( value, m_AmbientNightSky ) )
				return;

			m_AmbientNightSky = value;
			UpdateLightingCachedValues();
		}
	}

	/// <summary>
	/// Sets the flag to use the moon light at night
	/// NOTE: This parameter is set by the planetary body satellites
	/// </summary>
	internal bool					UseMoonAtNight
	{
		get { return m_bUseMoonAtNight; }
		set
		{
			if ( value == m_bUseMoonAtNight )
				return;

			m_bUseMoonAtNight = value;
			UpdateLightingCachedValues();
		}
	}

	/// <summary>
	/// Sets the direction of the Moon satellite used for night lighting
	/// NOTE: This parameter is set by the planetary body satellites
	/// </summary>
	internal Vector3				MoonDirection
	{
		get { return m_MoonDirection; }
		set
		{
			if ( Help.Approximately( value, m_MoonDirection ) )
				return;

			m_MoonDirection = value;
			UpdateLightingCachedValues();
		}
	}

	/// <summary>
	/// Sets the color of the Moon satellite used for night lighting
	/// NOTE: This parameter is set by the planetary body satellites
	/// </summary>
	internal Vector3				MoonColor
	{
		get { return m_MoonColor; }
		set
		{
			if ( Help.Approximately( value, m_MoonColor ) )
				return;

			m_MoonColor = value;
			UpdateLightingCachedValues();
		}
	}

	/// <summary>
	/// Sets the luminance of the Moon satellite used for night lighting
	/// NOTE: This parameter is set by the planetary body satellites
	/// </summary>
	internal float					MoonIntensity
	{
		get { return m_MoonIntensity; }
		set
		{
			if ( Help.Approximately( value, m_MoonIntensity ) )
				return;

			m_MoonIntensity = value;
			UpdateLightingCachedValues();
		}
	}

	#endregion

	#region World Parameters

	/// <summary>
	/// Gets or sets the World's scale factor that maps a unit to a kilometer
	/// </summary>
	public float					WorldUnit2Kilometer	{ get { return m_WorldUnit2Kilometer; } set { m_WorldUnit2Kilometer = value; UpdatePlanetCachedValues(); } }

	/// <summary>
	/// Gets or sets the ZBuffer discrepancy threshold that helps to determine which pixels should be recomputed at full resolution.
	/// </summary>
	public float					ZBufferDiscrepancyThreshold		{ get { return m_ZBufferDiscrepancyThreshold; } set { m_ZBufferDiscrepancyThreshold = Mathf.Max( 1.0f, value ); } }

	/// <summary>
	/// Gets or sets the strength of the smart upsampling effect
	/// </summary>
	public float					SmartUpsamplingWeightFactor		{ get { return m_SmartUpsamplingWeightFactor; } set { m_SmartUpsamplingWeightFactor = value; } }

	/// <summary>
	/// Gets or sets the weight to apply to Z discrepancies when upsampling the buffers with the SMART technique
	/// </summary>
	public float					SmartUpsamplingCutoutFactor		{ get { return m_SmartUpsamplingCutoutFactor; } set { m_SmartUpsamplingCutoutFactor = value; } }

	/// <summary>
	/// Gets or sets the technique used to upsample and refine the downsampled rendering
	/// </summary>
	public UPSAMPLING_TECHNIQUE		UpsamplingTechnique
	{
		get { return m_UpsamplingTechnique; }
		set
		{
			if ( value == m_UpsamplingTechnique )
				return;

			m_UpsamplingTechnique = value;

			// Notify modules
			foreach ( ModuleBase M in m_Modules )
				M.UpsamplingTechniqueChanged( m_UpsamplingTechnique );
		}
	}

	/// <summary>
	/// Shows the ZBuffer discrepancies and highlights in red the pixels that need to be recomputed at full resolution.
	/// This is a helper for you to tweak the threshold nicely depending on the precision of your scene.
	/// </summary>
	public bool						ShowZBufferDiscrepancies		{ get { return m_bShowZBufferDiscrepancies; } set { m_bShowZBufferDiscrepancies = value; } }

	/// <summary>
	/// Gets or sets the position of the planet's center (in kilometers)
	/// </summary>
	public Vector3					PlanetCenter		{ get { return m_PlanetCenterKm; } set { m_PlanetCenterKm = value; UpdatePlanetCachedValues(); } }

	/// <summary>
	/// Gets or sets the normal to planet's surface where the camera is currently standing
	/// </summary>
	public Vector3					PlanetNormal		{ get { return m_PlanetNormal; } set { m_PlanetNormal = value.normalized; UpdatePlanetCachedValues(); } }

	/// <summary>
	/// Gets or sets the radius of the planet (in kilometers)
	/// </summary>
	public float					PlanetRadiusKm
	{
		get { return m_PlanetRadiusKm; }
		set
		{
			if ( Mathf.Approximately( value, m_PlanetRadiusKm ) )
				return;

			m_PlanetRadiusKm = value;
			UpdatePlanetCachedValues();

			// Notify
			if ( PlanetDimensionsChanged != null )
				PlanetDimensionsChanged( this, EventArgs.Empty );
		}
	}

	/// <summary>
	/// Gets or sets the planet radius offset (in kilometers) to trace the sky and clouds a bit below the horizon
	/// </summary>
	public float					PlanetRadiusOffsetKm
	{
		get { return m_PlanetRadiusOffsetKm; }
		set
		{
			if ( Mathf.Approximately( value, m_PlanetRadiusOffsetKm ) )
				return;

			m_PlanetRadiusOffsetKm = value;
			UpdatePlanetCachedValues();
		}
	}

	/// <summary>
	/// Gets or sets the altitude of the top of the planet's atmosphere (in kilometers)
	/// </summary>
	public float					PlanetAtmosphereAltitudeKm
	{
		get { return m_PlanetAtmosphereAltitudeKm; }
		set
		{
			if ( Mathf.Approximately( value, m_PlanetAtmosphereAltitudeKm ) )
				return;

			m_PlanetAtmosphereAltitudeKm = value;
			UpdatePlanetCachedValues();

			// Notify
			if ( PlanetDimensionsChanged != null )
				PlanetDimensionsChanged( this, EventArgs.Empty );
		}
	}

	/// <summary>
	/// Gets the radius of the planet, including its atmosphere (in kilometers)
	/// </summary>
	public float					PlanetAtmosphereRadiusKm	{ get { return m_PlanetRadiusKm + m_PlanetAtmosphereAltitudeKm; } }

	#endregion

	#region Shadow Map Parameters

	/// <summary>
	/// Gets or sets the size of the global shadow map for sky and world shadowing
	/// </summary>
	public int						ShadowMapSize
	{
		get { return m_ShadowMapSize; }
		set
		{
			value = Math.Max( 64, value );
			if ( value == m_ShadowMapSize )
				return;

			m_ShadowMapSize = value;

			InitializeShadowMap();

			// Notify
			if ( ShadowMapSizeChanged != null )
				ShadowMapSizeChanged( this, EventArgs.Empty );
		}
	}

	/// <summary>
	/// Gets or sets the far clip distance for shadows
	/// </summary>
	public float					ShadowFarClip
	{
		get { return m_ShadowFarClip; }
		set { m_ShadowFarClip = value; }
	}

	/// <summary>
	/// Gets or sets the light cookie enabled state.
	/// If enabled, the shadow map will be used as a light cookie and will also shadow the scene.
	/// Notice that it requires a Sun object to be plugged-in, and the Sun object must have a Light component
	/// </summary>
	public bool						CastShadowUsingLightCookie
	{
		get { return m_bCastShadowUsingLightCookie; }
		set
		{
			if ( value == m_bCastShadowUsingLightCookie )
				return;

			m_bCastShadowUsingLightCookie = value;

			InitializeLightCookie();
		}
	}

	/// <summary>
	/// Gets or sets the size of the light cookie texture
	/// </summary>
	public int						LightCookieTextureSize
	{
		get { return m_LightCookieTextureSize; }
		set
		{
			value = Math.Max( 32, value );
			if ( value == m_LightCookieTextureSize )
				return;

			m_LightCookieTextureSize = value;

			InitializeLightCookie();
		}
	}

	/// <summary>
	/// Gets or sets the size of the light cookie in WORLD units.
	/// NOTE: This is the SAME property as the "light cookie size" on directional lights but Unity doesn't provide any way of changing that property at the moment.
	///  so I have to duplicate it here. It's a bit annoying since you need to synchronize the 2 values both in here and in your directional light so they match.
	/// </summary>
	public float					LightCookieSize
	{
		get { return m_LightCookieSize; }
		set { m_LightCookieSize = value; }
	}

	/// <summary>
	/// Gets or sets the light cookie camera altitude sampling state.
	/// If true, the light cookie will sample the shadow map at camera's altitude, overriding the manual LightCookieSampleAltitude property.
	/// </summary>
	public bool						LightCookieSampleAtCameraAltitude
	{
		get { return m_bLightCookieSampleAtCameraAltitude; }
		set { m_bLightCookieSampleAtCameraAltitude = value; }
	}

	/// <summary>
	/// Gets or sets the altitude (in kilometers) where shadow map is sampled
	/// </summary>
	public float					LightCookieSampleAltitudeKm
	{
		get { return m_LightCookieSampleAltitudeKm; }
		set { m_LightCookieSampleAltitudeKm = value; }
	}

	#endregion

	#region Local Variations

	/// <summary>
	/// Gets or sets the local coverage map locator.
	/// This allows you (yes, you!) to setup the local cloud coverage.
	/// Each of the four cloud layers is added coverage as specified by this map's RGBA values.
	/// </summary>
	public GameObject				LocalCoverage
	{
		get { return m_LocalCoverage; }
		set
		{
			if ( value == m_LocalCoverage )
				return;
			if ( value != null && !value.GetComponent<NuajMapLocator>() )
			{	// Not a camera !
				Nuaj.Help.LogError( "The GameObject assigned as LocalCoverage must have a NuajMapLocator component !" ); 
				return;
			}

			m_LocalCoverage = value;
		}
	}

	/// <summary>
	/// Gets or sets the terrain emissive map locator.
	/// This allows you to setup the local terrain color that gets reflected by the clouds.
	/// This is very useful to simulate a city by night for example.
	/// </summary>
	public GameObject				TerrainEmissive
	{
		get { return m_TerrainEmissive; }
		set
		{
			if ( value == m_TerrainEmissive )
				return;
			if ( value != null && !value.GetComponent<NuajMapLocator>() )
			{	// Not a locator !
				Nuaj.Help.LogError( "The GameObject assigned as TerrainEmissive must have a NuajMapLocator component !" ); 
				return;
			}

			m_TerrainEmissive = value;
		}
	}

	/// <summary>
	/// Gets or sets the terrain albedo used to reflect the Sun and ambient sky on the clouds so they appear to be lit by underneath
	/// </summary>
	public Color					TerrainAlbedo
	{
		get { return m_TerrainAlbedo; }
		set { m_TerrainAlbedo = value; }
	}

	#endregion

	#region Lightning

	/// <summary>
	/// Gets the first parametrable lightning bolt
	/// </summary>
	public GameObject			LightningBolt0
	{
		get { return m_LightningBolt0; }
		set
		{
			if ( value == m_LightningBolt0 )
				return;
			if ( value != null && !value.GetComponent<NuajLightningBolt>() )
			{	// Not a lightning bolt !
				Nuaj.Help.LogError( "The GameObject assigned as LightningBolt0 must have a NuajLightningBolt component !" ); 
				return;
			}

			m_LightningBolt0 = value;
		}
	}

	/// <summary>
	/// Gets the second parametrable lightning bolt
	/// </summary>
	public GameObject			LightningBolt1
	{
		get { return m_LightningBolt1; }
		set
		{
			if ( value == m_LightningBolt1 )
				return;
			if ( value != null && !value.GetComponent<NuajLightningBolt>() )
			{	// Not a lightning bolt !
				Nuaj.Help.LogError( "The GameObject assigned as LightningBolt1 must have a NuajLightningBolt component !" ); 
				return;
			}

			m_LightningBolt1 = value;
		}
	}

	#endregion

	#region Luminance Adaptation

	/// <summary>
	/// Gets or sets the minimum adaptable luminance at day
	/// </summary>
	public float					ToneMappingMinLuminanceAtDay
	{
		get { return m_ToneMappingMinLuminanceAtDay; }
		set { m_ToneMappingMinLuminanceAtDay = value; }
	}

	/// <summary>
	/// Gets or sets the maximum adaptable luminance at day
	/// </summary>
	public float					ToneMappingMaxLuminanceAtDay
	{
		get { return m_ToneMappingMaxLuminanceAtDay; }
		set { m_ToneMappingMaxLuminanceAtDay = value; }
	}

	/// <summary>
	/// Gets or sets the tone mapping adaptation speed at which we adapt the scene's luminance at day (0 is very slow, 1 is instantaneous)
	/// </summary>
	public float					ToneMappingAdaptationSpeedAtDay
	{
		get { return m_ToneMappingAdaptationSpeedAtDay; }
		set { m_ToneMappingAdaptationSpeedAtDay = value; }
	}

	/// <summary>
	/// Gets or sets the minimum adaptable luminance at night
	/// </summary>
	public float					ToneMappingMinLuminanceAtNight
	{
		get { return m_ToneMappingMinLuminanceAtNight; }
		set { m_ToneMappingMinLuminanceAtNight = value; }
	}

	/// <summary>
	/// Gets or sets the maximum adaptable luminance at night
	/// </summary>
	public float					ToneMappingMaxLuminanceAtNight
	{
		get { return m_ToneMappingMaxLuminanceAtNight; }
		set { m_ToneMappingMaxLuminanceAtNight = value; }
	}

	/// <summary>
	/// Gets or sets the tone mapping adaptation speed at which we adapt the scene's luminance at day (0 is very slow, 1 is instantaneous)
	/// </summary>
	public float					ToneMappingAdaptationSpeedAtNight
	{
		get { return m_ToneMappingAdaptationSpeedAtNight; }
		set { m_ToneMappingAdaptationSpeedAtNight = value; }
	}

	/// <summary>
	/// Gets or sets the factor to apply to the tone mapped Sun color to make it a Unity LDR color
	/// </summary>
	public float					UnitySunColorFactor
	{
		get { return m_UnitySunColorFactor; }
		set { m_UnitySunColorFactor = value; }
	}

	/// <summary>
	/// Gets or sets the factor to apply to the tone mapped Sky color to make it a Unity LDR ambient color
	/// </summary>
	public float					UnityAmbientColorFactor
	{
		get { return m_UnityAmbientColorFactor; }
		set { m_UnityAmbientColorFactor = value; }
	}

	#endregion

	#region Tone Mapping

	/// <summary>
	/// Gets or sets the type of luminance computation to apply to the image to compute its luminance
	/// </summary>
	public LUMINANCE_COMPUTATION_TYPE	LuminanceComputationType
	{
		get { return m_LuminanceComputationType; }
		set
		{
			if ( value == m_LuminanceComputationType )
				return;

			m_LuminanceComputationType = value;

			// Notify
			if ( LuminanceComputationTypeChanged != null )
				LuminanceComputationTypeChanged( this, EventArgs.Empty );
		}
	}

	/// <summary>
	/// Gets or sets the tone mapping interpolant to choose between average (0) or maximum (1) image luminance
	/// </summary>
	public float					LuminanceAverageOrMax
	{
		get { return m_LuminanceAverageOrMax; }
		set { m_LuminanceAverageOrMax = m_ImageScaler.AverageOrMax = value; }
	}

	/// <summary>
	/// Tells if the main input scene was rendered in LDR or HDR.
	/// If the scene is LDR then a strange feedback loop needs to be used to approximately convert the scene into HDR.
	/// Otherwise, the scene is simply used "as is" without correction.
	/// </summary>
	public bool						SceneIsHDR
	{
		get { return m_bSceneIsHDR; }
		set { m_bSceneIsHDR = value; }
	}

	/// <summary>
	/// Gets or sets the luminance correction factor to apply to scene lighting
	/// </summary>
	public float					SceneLuminanceCorrection
	{
		get { return m_SceneLuminanceCorrection; }
		set { m_SceneLuminanceCorrection = value; }
	}

	/// <summary>
	/// Gets or sets the immediate image luminance with which we will tone map the image.
	/// NOTE: Setting the image luminance is useless if the LuminanceComputationType is not set to "CUSTOM".
	/// NOTE: This luminance is slowly adapted with time and is not used immediately by the tone mapper.
	/// </summary>
	public float					ImmediateImageLuminance
	{
		get { return m_ImageLuminance; }
		set { m_ImageLuminance = value; }
	}

	/// <summary>
	/// Gets the current tone mapping image luminance.
	/// This is the value with which we perform the tone mapping to adapt the HDR rendering down to LDR
	/// </summary>
	public Vector3					ToneMappingLuminance
	{
		get { return m_CurrentAdaptationLuminance; }
	}

	/// <summary>
	/// Gets or sets the type of tone mapping to apply to the image
	/// </summary>
	public TONE_MAPPING_TYPE		ToneMappingType
	{
		get { return m_ToneMappingType; }
		set
		{
			if ( value == m_ToneMappingType )
				return;

			m_ToneMappingType = value;

			// Notify
			if ( ToneMappingTypeChanged != null )
				ToneMappingTypeChanged( this, EventArgs.Empty );
		}
	}

	#region Parameters for the different algorithms

	/// <summary>
	/// Gets the tone mapping parameters for the Reinhard algorithm
	/// </summary>
	public ToneMappingParameters_Reinhard		ToneMappingParamsReinhard		{ get { return m_ToneMappingParamsReinhard; } }
	/// <summary>
	/// Gets the tone mapping parameters for the Drago algorithm (i.e. log)
	/// </summary>
	public ToneMappingParameters_Drago			ToneMappingParamsDrago			{ get { return m_ToneMappingParamsDrago; } }
	/// <summary>
	/// Gets the tone mapping parameters for the Filmic algorithm
	/// </summary>
	public ToneMappingParameters_Filmic			ToneMappingParamsFilmic			{ get { return m_ToneMappingParamsFilmic; } }
	/// <summary>
	/// Gets the tone mapping parameters for the Exponential algorithm
	/// </summary>
	public ToneMappingParameters_Exponential	ToneMappingParamsExponential	{ get { return m_ToneMappingParamsExponential; } }
	/// <summary>
	/// Gets the tone mapping parameters for the Linear algorithm
	/// </summary>
	public ToneMappingParameters_Linear			ToneMappingParamsLinear			{ get { return m_ToneMappingParamsLinear; } }

	#endregion

	/// <summary>
	/// Gets or sets the tone mapping gamma correction
	/// </summary>
	public float					ToneMappingGamma
	{
		get { return m_ToneMappingGamma; }
		set { m_ToneMappingGamma = value; }
	}

	/// <summary>
	/// Gets or sets the tone mapping intensity boost factor
	/// </summary>
	public float					ToneMappingIntensityBoostFactor
	{
		get { return m_ToneMappingBoostFactor; }
		set { m_ToneMappingBoostFactor = value; }
	}

	#endregion

	#region Glow Support

	/// <summary>
	/// Tells if Nuaj' should support the Glow effect.
	/// If true, the alpha written by Nuaj will trigger the glow effect.
	/// If false, the alpha is your scene's alpha passed through
	/// </summary>
	public bool						EnableGlowSupport
	{
		get { return m_bEnableGlowSupport; }
		set { m_bEnableGlowSupport = value; }
	}

	/// <summary>
	/// Tells if written alpha should be Nuaj' computed alpha only (false) or the maximum of your scene's alpha and Nuaj's alpha (true)
	/// </summary>
	/// <remarks>Only works if glow support is enabled</remarks>
	public bool						GlowCombineAlphas
	{
		get { return m_bCombineAlphas; }
		set { m_bCombineAlphas = value; }
	}

	/// <summary>
	/// Gets or sets the threshold at which intensity makes no glow
	/// </summary>
	public float					GlowIntensityThresholdMin
	{
		get { return m_GlowIntensityThreshold.x; }
		set { m_GlowIntensityThreshold.x = value; }
	}

	/// <summary>
	/// Gets or sets the threshold at which intensity has a maximum glow
	/// </summary>
	public float					GlowIntensityThresholdMax
	{
		get { return m_GlowIntensityThreshold.y; }
		set { m_GlowIntensityThreshold.y = value; }
	}

	#endregion

	#region Modules Access

	/// <summary>
	/// Gets the list of available modules
	/// </summary>
	public ModuleBase[]				Modules				{ get { return m_Modules; } }

	/// <summary>
	/// Gets the module that manages the sky and aerial perspective
	/// </summary>
	public ModulePerspective		ModuleSky			{ get { return m_ModulePerspective; } }

	/// <summary>
	/// Gets the module that manages the cloud layers
	/// </summary>
	public ModuleCloudLayer			ModuleCloudLayer	{ get { return m_ModuleCloudLayer; } }

	/// <summary>
	/// Gets the module that manages the volumes cloud
	/// </summary>
	public ModuleCloudVolume		ModuleCloudVolume	{ get { return m_ModuleCloudVolume; } }

	/// <summary>
	/// Gets the module that manages the satellites
	/// </summary>
	public ModuleSatellites			ModuleSatellites	{ get { return m_ModuleSatellites; } }

	#endregion

	#region Error & Warning State

	/// <summary>
	/// Tells if the module is in an error state
	/// </summary>
	public bool						IsInErrorState		{ get { return m_bInErrorState; } }

	/// <summary>
	/// Gives informations about the error state
	/// </summary>
	public string					Error				{ get { return m_Error; } }

	/// <summary>
	/// Tells if the module is in an warning state
	/// </summary>
	public bool						IsInWarningState	{ get { return m_bInWarningState; } }

	/// <summary>
	/// Gives informations about the warning state
	/// </summary>
	public string					Warning				{ get { return m_Warning; } }

	#endregion


	/// <summary>
	/// Gets the scattering texture last rendered by the manager
	/// </summary>
	public RenderTexture			TextureScattering	{ get { return m_RTScattering; } }

	/// <summary>
	/// Gets the background texture where satellites are rendered
	/// </summary>
	public RenderTexture			TextureBackground	{ get { return m_RTBackground; } }

	/// <summary>
	/// Gets the background environment texture where satellites are rendered
	/// </summary>
	public RenderTexture			TextureBackgroundEnvironment	{ get { return m_RTBackgroundEnvironment; } }

	// Internal data
	internal Vector4				CameraData			{ get { return m_CameraData; } }
	internal Matrix4x4				Camera2World		{ get { return m_Camera2World; } }
	internal Matrix4x4				World2Camera		{ get { return m_World2Camera; } }
	internal Matrix4x4				Camera2WorldKm		{ get { return m_Camera2WorldKm; } }
	internal Matrix4x4				World2CameraKm		{ get { return m_World2CameraKm; } }

	/// <summary>
	/// Occurs when the Camera object changed
	/// </summary>
	public event EventHandler		CameraChanged;

	/// <summary>
	/// Occurs when the Sun object changed
	/// </summary>
	public event EventHandler		SunChanged;

	/// <summary>
	/// Occurs when the Sun direction was updated
	/// </summary>
	public event EventHandler		SunDirectionChanged;

	/// <summary>
	/// Occurs when the planet's center, dimensions or orientation changed
	/// </summary>
	public event EventHandler		PlanetDimensionsChanged;

	/// <summary>
	/// Occurs when the shadow map size changed
	/// </summary>
	public event EventHandler		ShadowMapSizeChanged;

	/// <summary>
	/// Occurs when the tone mapping algorithm changed
	/// </summary>
	public event EventHandler		ToneMappingTypeChanged;

	/// <summary>
	/// Occurs when the luminance adaptation algorithm changed
	/// </summary>
	public event EventHandler		LuminanceComputationTypeChanged;

	/// <summary>
	/// Occurs when Nuaj' entered or exited the error state
	/// </summary>
	public event EventHandler		ErrorStateChanged;

	/// <summary>
	/// Occurs when Nuaj' entered or exited the warning state
	/// </summary>
	public event EventHandler		WarningStateChanged;

	/// <summary>
	/// Occurs every frame and replaces the software or hardware environment rendering
	/// </summary>
	public event CustomEnvironmentRenderingEventHandler	CustomEnvironmentRender;

	/// <summary>
	/// Occurs every frame right BEFORE the satellites are rendered into the background buffer.
	/// You can then perform custom background clear
	/// </summary>
	public event CustomBackgroundClearEventHandler		CustomBackgroundClear;

	/// <summary>
	/// Occurs every frame right AFTER the satellites have been rendered into the background buffer.
	/// You can then perform custom background rendering for your own satellites
	/// </summary>
	public event CustomBackgroundRenderEventHandler		CustomBackgroundRender;

	/// <summary>
	/// Occurs every frame when the Sky module is disabled.
	/// It is then up to you to compose the clouds and background together
	/// </summary>
	public event CustomSkyCompositionEventHandler		CustomSkyComposition;

	/// <summary>
	/// Occurs every frame right before tone mapping so you have a chance to perform your own custom luminance adaptation.
	/// For example, you can perform temporal adaptation to slowly adapt from very dark zones to bright ones, like the
	///  blooming effect that occurs when you exit a tunnel.
	/// Or, you can limit adaption and return a special blue-ish tint at night.
	/// Or even a greenish tint with special adaptation if you look through light amplification goggles.
	/// </summary>
	public event CustomLuminanceAdaptationEventHandler	CustomLuminanceAdaptation;

	#endregion

	#region METHODS

	public		NuajManager()
	{
		// =========== Build list ===========
		m_Modules = new ModuleBase[4];
		m_Modules[0] = m_ModulePerspective;
		m_Modules[1] = m_ModuleCloudLayer;
		m_Modules[2] = m_ModuleCloudVolume;
		m_Modules[3] = m_ModuleSatellites;

		// =========== Subscribe to events ===========
		m_ModulePerspective.SkyParametersChanged += new EventHandler( ModulePerspective_SkyParametersChanged );
	}

	#region MonoBehaviour Members

	void		OnDestroy()
	{
		// Clear drive camera
		Camera = null;

		// Destroy render targets
		DestroyRenderTargets();
		DestroyShadowMap();
		DestroyLightCookie();

		// Destroy modules
		foreach ( ModuleBase Module in m_Modules )
			Module.OnDestroy();
	}

	void		Awake()
	{
		// Awake modules
		foreach ( ModuleBase Module in m_Modules )
		{
			Module.Owner = this;	// Reconnect the owner...
			Module.Awake();
		}

		InitializeShadowMap();
		InitializeLightCookie();
	}

	void		Start()
	{
		if ( !enabled )
			return;

		// Start modules
		foreach ( ModuleBase Module in m_Modules )
			Module.Start();
	}

	void		OnEnable()
	{
		try
		{
			if ( !SystemInfo.supportsImageEffects || !SystemInfo.supportsRenderTextures )
				throw new Exception( "Your system configuration does not support image effects or RenderTextures !\r\nNuaj' Atmosphere Manager cannot work and is therefore disabled..." );

			// Create the materials
			m_MaterialCompose = Nuaj.Help.CreateMaterial( "ComposeAtmosphere" );
			m_MaterialClearTexture = Nuaj.Help.CreateMaterial( "Utility/ClearTexture" );
			m_MaterialRenderLightCookie = Nuaj.Help.CreateMaterial( "RenderLightCookie" );
			m_MaterialDownsampleZBuffer = Nuaj.Help.CreateMaterial( "Utility/DownsampleZ" );

			// Create the tone mapper
			m_ImageScaler.OnEnable();

			// Initialize Sun direction
			Vector3	OldDirection = m_SunDirection;
			m_SunDirection = Vector3.zero;
			SunDirection = OldDirection;

			// Initialize image effect if it's missing (shouldn't be the case but when debugging you never know what can fuck up)
			CreateOrAttachCameraEffect();

			// Initialize shadow map & light cookie if they're missing
			if ( m_RTShadowMap == null )
				InitializeShadowMap();
			if ( m_RTLightCookie == null )
				InitializeLightCookie();

			// Enable modules
			// This is where the materials should be created
			foreach ( ModuleBase Module in m_Modules )
			{
				Module.Owner = this;	// Reconnect the owner... (when the assembly is recompiled, owners have disappeared but Awake() is not called and only OnEnable() is called)
				Module.OnEnable();
			}

			ExitErrorState();
		}
		catch ( Exception _e )
		{	// Fatal error !
			EnterErrorState( _e.Message );
			Nuaj.Help.LogError( "An error occurred while enabling Nuaj' Manager :\r\n" + _e.Message );
			enabled = false;
			return;
		}

		// Restore internal values
		UpdateCachedValues();
	}

	void		OnDisable()
	{
		try
		{
			// Disable modules
			foreach ( ModuleBase Module in m_Modules )
				Module.OnDisable();

			// Destroy the tone mapper
			m_ImageScaler.OnDisable();

			// Destroy materials
			SafeDestroyNuaj( ref m_MaterialCompose );
			SafeDestroyNuaj( ref m_MaterialClearTexture );
			SafeDestroyNuaj( ref m_MaterialRenderLightCookie );
			SafeDestroyNuaj( ref m_MaterialDownsampleZBuffer );

			GC.Collect();
		}
		catch ( Exception _e )
		{
			Nuaj.Help.LogError( "An error occurred while disabling Nuaj' Manager :\r\n" + _e.Message );
			enabled = false;
			return;
		}
	}

	void		Update()
	{
		// Update Nuaj' time
		NuajTime.UpdateTime();

		// Update modules
		foreach ( ModuleBase Module in m_Modules )
			Module.Update();
	}

	#endregion

	#region Rendering

	protected bool	m_bLastFullscreenState = false;
	protected void	BeginFrame()
	{
		if ( Screen.fullScreen != m_bLastFullscreenState )
		{	// We need to disable then enable again on resolution change because we are not notified... (there are too many things that happen without notification if you don't mind my saying)
			enabled = false;
			enabled = true;
		}
		m_bLastFullscreenState = Screen.fullScreen;

		// Clear the amount of CPU data written for that frame
		m_WrittenCPUDataCount = 0;
	}

	protected List<ICloudLayer>	m_RenderCloudLayers = new List<ICloudLayer>();
	protected ICloudLayer[]		m_CloudLayersArray = null;
	protected int				m_CloudLayersCastingShadowCount = 0;

	/// <summary>
	/// Performs the main rendering job :
	///	 * Updates transforms for camera and shadow map
	///  * Renders the clouds
	///  * Renders the sky
	///  * Composes sky and clouds together
	///	 * Renders the shadow maps
	///	 * Renders the light cookie (optional)
	/// </summary>
	/// <param name="_CameraData">A bunch of camera data like tan(FOV), aspect ratio, near and far ranges, etc.</param>
	/// <param name="_Camera2World">The CAMERA=>WORLD transform</param>
	/// <param name="_World2Camera">The WORLD=>CAMERA transform</param>
	/// <remarks>This must only be called by the ComposeAtmosphere image effect's OnPreCull() method</remarks>
	internal void		Render( Vector4 _CameraData, Matrix4x4 _Camera2World, Matrix4x4 _World2Camera )
	{
		PreRender( _CameraData, _Camera2World, _World2Camera );
		MainRender();
	}

	/// <summary>
	/// Performs the pre-rendering job :
	///	 * Updates transforms for camera and shadow map
	///	 * Renders the shadow maps & environment maps
	///	 * Renders the light cookie (optional)
	/// </summary>
	/// <param name="_CameraData">A bunch of camera data like tan(FOV), aspect ratio, near and far ranges, etc.</param>
	/// <param name="_Camera2World">The CAMERA=>WORLD transform</param>
	/// <param name="_World2Camera">The WORLD=>CAMERA transform</param>
	/// <remarks>This must only be called by the ComposeAtmosphere image effect's OnPreCull() method</remarks>
	internal void		PreRender( Vector4 _CameraData, Matrix4x4 _Camera2World, Matrix4x4 _World2Camera )
	{
		if ( !enabled || m_bInErrorState || !gameObject.activeSelf )
			return;
		if ( !m_bInternalDataAreValid )
			Help.LogError( "INTERNAL DATA ARE NOT VALID !" );

		// BEGIN !
		BeginFrame();

		// Cache camera data
		m_CameraData = _CameraData;
		m_Camera2World = _Camera2World;
		m_World2Camera = _World2Camera;

		// Same matrices but with position in kilometers
		m_Camera2WorldKm = m_Camera2World;
		m_Camera2WorldKm.m03 *= m_WorldUnit2Kilometer;
		m_Camera2WorldKm.m13 *= m_WorldUnit2Kilometer;
		m_Camera2WorldKm.m23 *= m_WorldUnit2Kilometer;

		m_World2CameraKm = m_Camera2WorldKm.inverse;

		UpdateCameraCachedValues();

		// Update local variations
		UpdateLocalVariationsValues();

		// Update lightning
		UpdateLightningValues();


		//////////////////////////////////////////////////////////////////////////
		// 1] Update Sun direction if the light drives the Sun
		if ( m_Sun != null && !m_bSunDrivenDirection )
			SunDirection = -m_Sun.transform.forward;	// Our direction is given by the light

		//////////////////////////////////////////////////////////////////////////
		// 2] Build the sorted list of active cloud layers
		float	CloudAltitudeMaxKm = -m_PlanetRadiusKm;
		m_ShadowMapPlaneAltitudesKm = -m_PlanetRadiusKm;

		m_RenderCloudLayers.Clear();
		m_CloudLayersCastingShadowCount = 0;

		// Add fog layer
		ModulePerspective.FogLayer	FogLayer = m_ModulePerspective.Fog;
		bool	HasFog;
		if ( HasFog = (FogLayer.Enabled && !FogLayer.Bypass) )
		{
			m_RenderCloudLayers.Add( FogLayer );
			CloudAltitudeMaxKm = FogLayer.Altitude;
			m_ShadowMapPlaneAltitudesKm = CloudAltitudeMaxKm + FogLayer.Thickness;
			if ( FogLayer.CastShadow )
				m_CloudLayersCastingShadowCount++;
		}

		if ( m_ModuleCloudLayer.Enabled )
		{	// Add layer clouds
			foreach ( ICloudLayer L in m_ModuleCloudLayer.CloudLayers )
				if ( L.Enabled && !L.Bypass )
				{
					m_RenderCloudLayers.Add( L );
					if ( L.CastShadow && m_RenderCloudLayers.Count < MAX_ALLOWED_LAYERS )
						m_CloudLayersCastingShadowCount++;

					CloudAltitudeMaxKm = Math.Max( CloudAltitudeMaxKm, L.Altitude );
					m_ShadowMapPlaneAltitudesKm = Math.Max( m_ShadowMapPlaneAltitudesKm, L.Altitude + L.Thickness );
				}
		}

		if ( m_ModuleCloudVolume.Enabled )
		{	// Add volume clouds
			foreach ( ICloudLayer L in m_ModuleCloudVolume.CloudLayers )
				if ( L.Enabled && !L.Bypass )
				{
					m_RenderCloudLayers.Add( L );
					if ( L.CastShadow && m_RenderCloudLayers.Count < MAX_ALLOWED_LAYERS )
						m_CloudLayersCastingShadowCount++;

					CloudAltitudeMaxKm = Math.Max( CloudAltitudeMaxKm, L.Altitude );
					m_ShadowMapPlaneAltitudesKm = Math.Max( m_ShadowMapPlaneAltitudesKm, L.Altitude + L.Thickness );
				}
		}

		if ( m_RenderCloudLayers.Count > MAX_ALLOWED_LAYERS )
		{	// Can't render more than 4 layers at a time !
			EnterWarningState(	"You cannot render more than " + MAX_ALLOWED_LAYERS + " layer elements ! There are currently " + m_RenderCloudLayers.Count + " active layers." +
								"\nExcess elements will not be rendered. You must either disable or delete some layers for rendering to proceed correctly." );

			// Trim excess layers
			m_RenderCloudLayers.RemoveRange( MAX_ALLOWED_LAYERS, m_RenderCloudLayers.Count - MAX_ALLOWED_LAYERS );
		}
		else
			ExitWarningState();

		m_RenderCloudLayers.Sort( this );	// Sort from bottom to top
		m_CloudLayersArray = m_RenderCloudLayers.ToArray();


		//////////////////////////////////////////////////////////////////////////
		// 3] Compute shadow map boundaries
		PrepareShadowMap( m_LightSourceDirection );


		//////////////////////////////////////////////////////////////////////////
		// 4] Render layer module shadows from top to bottom so each top layer shadows the bottom one
		m_ShadowMapAltitudesMinKm = Vector4.zero;
		m_ShadowMapAltitudesMaxKm = 0.01f * Vector4.one;
		if ( m_CloudLayersCastingShadowCount < MAX_ALLOWED_LAYERS )
			ClearTarget( m_RTShadowMap, Vector4.one );		// Clear to unit extinction so non-existing layers don't interfere

		if ( m_RenderCloudLayers.Count > 0 )
		{
			// Initialize invalid layers to top atmosphere altitude
			for ( int LayerIndex=m_RenderCloudLayers.Count; LayerIndex < MAX_ALLOWED_LAYERS; LayerIndex++ )
			{
				switch ( LayerIndex )
				{
					case 0:
						m_ShadowMapAltitudesMinKm.x = m_PlanetAtmosphereAltitudeKm;
						m_ShadowMapAltitudesMaxKm.x = m_PlanetAtmosphereAltitudeKm + 1.0f;
						break;
					case 1:
						m_ShadowMapAltitudesMinKm.y = m_PlanetAtmosphereAltitudeKm;
						m_ShadowMapAltitudesMaxKm.y = m_PlanetAtmosphereAltitudeKm + 1.0f;
						break;
					case 2:
						m_ShadowMapAltitudesMinKm.z = m_PlanetAtmosphereAltitudeKm;
						m_ShadowMapAltitudesMaxKm.z = m_PlanetAtmosphereAltitudeKm + 1.0f;
						break;
					case 3:
						m_ShadowMapAltitudesMinKm.w = m_PlanetAtmosphereAltitudeKm;
						m_ShadowMapAltitudesMaxKm.w = m_PlanetAtmosphereAltitudeKm + 1.0f;
						break;
				}
			}

			// Render layer shadows from top to bottom
			for ( int LayerIndex=m_RenderCloudLayers.Count-1; LayerIndex >= 0; LayerIndex-- )
			{
				ICloudLayer		L = m_RenderCloudLayers[LayerIndex];

				RenderTexture	AmbientEnvMapSkyTop = LayerIndex < m_RenderCloudLayers.Count-1 ? m_RenderCloudLayers[LayerIndex+1].DownsampledEnvironmentRenderTargetSky : null;
				L.RenderShadow( LayerIndex, m_RTShadowMap, m_ShadowMapViewport, AmbientEnvMapSkyTop, !m_bRenderSoftwareEnvironment );

				// Update shadow altitudes one layer at a time
				// We do this AFTER the layer gets rendered so it doesn't take its own shadow into account...
				switch ( LayerIndex )
				{
					case 0:
						m_ShadowMapAltitudesMinKm.x = L.Altitude;
						m_ShadowMapAltitudesMaxKm.x = L.Altitude + (L.IsVolumetric ? L.Thickness : 0.01f);	// Include layer thickness only for volume clouds
						break;
					case 1:
						m_ShadowMapAltitudesMinKm.y = L.Altitude;
						m_ShadowMapAltitudesMaxKm.y = L.Altitude + (L.IsVolumetric ? L.Thickness : 0.01f);
						break;
					case 2:
						m_ShadowMapAltitudesMinKm.z = L.Altitude;
						m_ShadowMapAltitudesMaxKm.z = L.Altitude + (L.IsVolumetric ? L.Thickness : 0.01f);
						break;
					case 3:
						m_ShadowMapAltitudesMinKm.w = L.Altitude;
						m_ShadowMapAltitudesMaxKm.w = L.Altitude + (L.IsVolumetric ? L.Thickness : 0.01f);
						break;
				}

				// Send new data so the next layer can use the previous layer's shadow
				SetupShadowMapData();
			}
		}
		else
			SetupShadowMapData();	// Simply set empty shadow map data

		// Compute the most important layers' ordering data
		ComputeLayersOrder( HasFog );


		//////////////////////////////////////////////////////////////////////////
		// 5] Render environment Sky and Sun
		if ( CustomEnvironmentRender == null )
		{
			if ( m_bRenderSoftwareEnvironment )
				m_ModulePerspective.RenderEnvironmentSoftware();
			else
				m_ModulePerspective.RenderEnvironmentHardware( m_CloudLayersArray, m_RTShadowMap, m_RTBackgroundEnvironment );
		}
		else
		{	// Custom rendering
			Vector3	SunColor, SkyColor;
			CustomEnvironmentRender( this, out SunColor, out SkyColor );

			m_ModulePerspective.RenderEnvironmentCustom( SunColor, SkyColor );
		}

Help.LogDebug( "EnvSunColor = " + Help.PrintVector( m_ModulePerspective.EnvironmentSunColor ) + " EnvSkyColor = " + Help.PrintVector( m_ModulePerspective.EnvironmentSkyColor ) );


		//////////////////////////////////////////////////////////////////////////
		// 6] Render light cookie
		if ( m_bCastShadowUsingLightCookie && m_Sun != null && m_Sun.light != null && m_Sun.light.type == LightType.Directional )
		{
//			float	CookieSize = m_Sun.light.spotAngle;	// This is the cookie size for directional lights... !!UNITY BUG!!
			float	CookieSize = m_LightCookieSize;		// For the moment, can't access it another way because of some bug in Unity...
			float	SampleAltitudeKm = m_bLightCookieSampleAtCameraAltitude ? CameraAltitudeKm : m_LightCookieSampleAltitudeKm;

			m_MaterialRenderLightCookie.SetFloat( "_CookieSize", CookieSize );
			m_MaterialRenderLightCookie.SetFloat( "_SampleAltitudeKm", SampleAltitudeKm );
			m_MaterialRenderLightCookie.SetMatrix( "_Light2World", m_Sun.transform.localToWorldMatrix );
			m_MaterialRenderLightCookie.SetTexture( "_TexShadowMap", m_RTShadowMap );

			m_MaterialRenderLightCookie.Blit( null, m_RTLightCookie, 0 );
		}

		// SERIOUS UNITY BUG HERE !
		// It doesn't restore the active render target so the main scene gets initialized in the last set RenderTexture !
		RenderTexture.active = null;
	}

	/// <summary>
	/// Performs the main rendering job :
	///  * Renders the clouds
	///  * Renders the sky
	///  * Renders the satellites
	///  * Composes sky and clouds together
	/// </summary>
	/// <param name="_CameraData">A bunch of camera data like tan(FOV), aspect ratio, near and far ranges, etc.</param>
	/// <param name="_Camera2World">The CAMERA=>WORLD transform</param>
	/// <param name="_World2Camera">The WORLD=>CAMERA transform</param>
	/// <remarks>This must only be called by the ComposeAtmosphere image effect's OnPreCull() method</remarks>
	internal void		MainRender()
	{
		if ( !enabled || m_bInErrorState || !gameObject.activeSelf )
			return;
		if ( !m_bInternalDataAreValid )
			Help.LogError( "INTERNAL DATA ARE NOT VALID !" );

		//////////////////////////////////////////////////////////////////////////
		// 1] Render the cloud layers from top to bottom
		if ( m_RenderCloudLayers.Count > 0 )
		{
			for ( int LayerIndex=m_RenderCloudLayers.Count-1; LayerIndex >= 0; LayerIndex-- )
			{
				ICloudLayer		L = m_RenderCloudLayers[LayerIndex];

				RenderTexture	AmbientEnvMapSkyTop = LayerIndex < m_RenderCloudLayers.Count-1 ? m_RenderCloudLayers[LayerIndex+1].DownsampledEnvironmentRenderTargetSky : null;
				L.Render( LayerIndex, m_RTShadowMap, m_ShadowMapViewport, AmbientEnvMapSkyTop );
			}
		}


		//////////////////////////////////////////////////////////////////////////
		// 2] Render satellites

		// Custom clear ?
		if ( CustomBackgroundClear != null )
			CustomBackgroundClear( m_RTBackground );
		else
			ClearTarget( m_RTBackground, Vector4.zero );
		ClearTarget( m_RTBackgroundEnvironment, Vector4.zero );

		// Render
		if ( m_ModuleSatellites.Enabled && m_ModuleSatellites.EnabledSatellitesCount > 0 )
			m_ModuleSatellites.Render( m_RTBackground, m_RTBackgroundEnvironment );

		// A chance to render your own background
		Texture	RTBackground = m_RTBackground;
		if ( CustomBackgroundRender != null )
			RTBackground = CustomBackgroundRender( m_RTBackground );


		//////////////////////////////////////////////////////////////////////////
		// 3] Render sky module and compose with clouds
		if ( m_ModulePerspective.Enabled )
			m_ModulePerspective.Render( m_RTScattering, m_CloudLayersArray, m_RTShadowMap, RTBackground );
		else if ( CustomSkyComposition != null )
			CustomSkyComposition( m_CloudLayersArray, m_RTShadowMap, RTBackground );


		// SERIOUS UNITY BUG HERE !
		// It doesn't restore the active render target so the main scene gets initialized in the last set RenderTexture !
		RenderTexture.active = null;
	}

	/// <summary>
	/// Does the post-processing job of mixing and tone mapping the Unity scene and Nuaj's atmosphere
	/// </summary>
	/// <param name="_Source">The scene's render texture to compose with</param>
	/// <param name="_Destination">The final target with the composited result</param>
	/// <remarks>This must only be called by the ComposeAtmosphere image effect's OnRenderImage() method</remarks>
	internal void		PostProcess( RenderTexture _Source, RenderTexture _Destination )
	{
		if ( !enabled || m_bInErrorState || !gameObject.activeSelf )
			return;
		if ( !m_bInternalDataAreValid )
			Help.LogError( "INTERNAL DATA ARE NOT VALID !" );

		//////////////////////////////////////////////////////////////////////////
		// 1] Compute scene luminance as tone mapper input
		m_PreviousFrameLuminance = m_CurrentAdaptationLuminance;

		// 1.1] Compute the LDR->HDR luminance factor from previous frame
		Vector3	LDRSunLight = Vector3.one;
		Light	SunLight = null;
		if ( m_Sun != null && (SunLight = m_Sun.GetComponent<Light>()) != null )
			LDRSunLight = SunLight.intensity * Help.ColorToVec3( SunLight.color );
		float	LDRSunIntensity = Vector3.Dot( LDRSunLight, LUMINANCE );

		Vector3	HDRSunLight = m_ModulePerspective.EnvironmentSunColor;
		float	HDRSunIntensity = Vector3.Dot( HDRSunLight, LUMINANCE );
		float	LDR2HDRSunFactor = m_SceneLuminanceCorrection * HDRSunIntensity / Math.Max( 1e-3f, LDRSunIntensity );

		// Compute the LDR & HDR ambient luminances from previous frame
		float	LDRSkyIntensity = Vector3.Dot( Help.ColorToVec3( RenderSettings.ambientLight ), LUMINANCE );
		Vector3	HDRSkyColor = m_ModulePerspective.EnvironmentSkyColor;
		float	HDRSkyIntensity = m_SceneLuminanceCorrection * Vector3.Dot( HDRSkyColor, LUMINANCE );

		// 1.2] Compute current scene luminance
		switch ( m_LuminanceComputationType )
		{
			case LUMINANCE_COMPUTATION_TYPE.DOWNSAMPLE:
				m_ImageLuminance = m_ImageScaler.ComputeImageLuminance( this, _Source, m_RTScattering, LDR2HDRSunFactor, LDRSkyIntensity, HDRSkyIntensity, m_bSceneIsHDR );
				break;
			case LUMINANCE_COMPUTATION_TYPE.DOWNSAMPLE_LOG:
				m_ImageLuminance = m_ImageScaler.ComputeImageLuminanceLog( this, _Source, m_RTScattering, LDR2HDRSunFactor, LDRSkyIntensity, HDRSkyIntensity, m_bSceneIsHDR );
				break;
			case LUMINANCE_COMPUTATION_TYPE.ONE:
				m_ImageLuminance = 1.0f;
				break;
			case LUMINANCE_COMPUTATION_TYPE.CUSTOM:
				// The luminance is set by the user
				break;
		}

		// 1.3] Perform luminance adaptation
		if ( CustomLuminanceAdaptation == null )
			PerformDefaultLuminanceAdaptation();
		else
			m_CurrentAdaptationLuminance = CustomLuminanceAdaptation( this, m_PreviousFrameLuminance, m_ImageLuminance );

		// 1.4] Compute middle grey value necessary for several tone mapping algorithms
		// From eq. 10 in http://wiki.gamedev.net/index.php/D3DBook:High-Dynamic_Range_Rendering
		float	ImageLuminance = Vector3.Dot( m_CurrentAdaptationLuminance, LUMINANCE );
		float	MiddleGrey = 1.03f - 2.0f / (2.0f + Mathf.Log10( 1.0f + ImageLuminance ));

Help.LogDebug( "AdaptedLuminance = " + ImageLuminance + " (Immediate Luminance = " + m_ImageLuminance + " MiddleGrey = " + MiddleGrey + ")" );

		m_ToneMappingParamsFilmic.MiddleGrey = MiddleGrey;
		m_ToneMappingParamsReinhard.MiddleGrey = MiddleGrey;
		m_ToneMappingParamsLinear.MiddleGrey = MiddleGrey;


		//////////////////////////////////////////////////////////////////////////
		// 2] Update Sun & Ambient colors for next frame lighting
		if ( m_Sun != null )
		{
			// Update light's color & intensity
			if ( m_bSunDrivenDirectionalColor && SunLight != null )
				ConvertSunColorToUnityLight( HDRSunLight, SunLight );

			// Update ambient color
			if ( m_bSunDrivenAmbientColor )
				RenderSettings.ambientLight = ConvertAmbientSkyColorToUnityAmbient( HDRSkyColor );
		}


		//////////////////////////////////////////////////////////////////////////
		// 3] Tone Map & Compose the result
		m_MaterialCompose.SetTexture( "_TexScattering", m_RTScattering );
		m_MaterialCompose.SetVector( "_ToneMappingLuminance", m_CurrentAdaptationLuminance );
		m_MaterialCompose.SetFloat( "_ToneMappingBoostFactor", m_ToneMappingBoostFactor );
		m_MaterialCompose.SetFloat( "_Gamma", 1.0f / Mathf.Max( 1e-3f, m_ToneMappingGamma ) );

		m_MaterialCompose.SetFloat( "_GlowSupport", m_bEnableGlowSupport ? 1.0f : 0.0f );
		m_MaterialCompose.SetFloat( "_GlowUseMax", m_bCombineAlphas ? 1.0f : 0.0f );
		m_MaterialCompose.SetVector( "_GlowIntensityThreshold", m_GlowIntensityThreshold );


		// Send appropriate parameters based on chosen algorithm
		int		PassIndex = -1;
		switch ( m_ToneMappingType )
		{
			case NuajManager.TONE_MAPPING_TYPE.FILMIC:
				PassIndex = 0;
				m_MaterialCompose.SetFloat( "_Filmic_A", m_ToneMappingParamsFilmic.A );
				m_MaterialCompose.SetFloat( "_Filmic_B", m_ToneMappingParamsFilmic.B );
				m_MaterialCompose.SetFloat( "_Filmic_C", m_ToneMappingParamsFilmic.C );
				m_MaterialCompose.SetFloat( "_Filmic_D", m_ToneMappingParamsFilmic.D );
				m_MaterialCompose.SetFloat( "_Filmic_E", m_ToneMappingParamsFilmic.E );
				m_MaterialCompose.SetFloat( "_Filmic_F", m_ToneMappingParamsFilmic.F );
				m_MaterialCompose.SetFloat( "_Filmic_W", m_ToneMappingParamsFilmic.W );
				m_MaterialCompose.SetFloat( "_FilmicMiddleGrey", m_ToneMappingParamsFilmic.MiddleGrey );
				break;
			case NuajManager.TONE_MAPPING_TYPE.REINHARD:
				PassIndex = 1;
				m_MaterialCompose.SetFloat( "_ReinhardMiddleGrey", m_ToneMappingParamsReinhard.MiddleGrey );
				m_MaterialCompose.SetFloat( "_ReinhardWhiteLuminance", m_ToneMappingParamsReinhard.WhiteLuminance );
				break;
			case NuajManager.TONE_MAPPING_TYPE.DRAGO:
				PassIndex = 2;
				m_MaterialCompose.SetFloat( "_DragoMaxDisplayLuminance", m_ToneMappingParamsDrago.MaxDisplayLuminance );
				m_MaterialCompose.SetFloat( "_DragoBias", m_ToneMappingParamsDrago.Bias );
				break;
			case NuajManager.TONE_MAPPING_TYPE.EXPONENTIAL:
				PassIndex = 3;
				m_MaterialCompose.SetFloat( "_ExponentialExposure", m_ToneMappingParamsExponential.Exposure );
				m_MaterialCompose.SetFloat( "_ExponentialGain", m_ToneMappingParamsExponential.Gain );
				break;
			case NuajManager.TONE_MAPPING_TYPE.LINEAR:
				PassIndex = 4;
				m_MaterialCompose.SetFloat( "_LinearMiddleGrey", m_ToneMappingParamsLinear.MiddleGrey );
				m_MaterialCompose.SetFloat( "_LinearFactor", m_ToneMappingParamsLinear.Factor );
				break;
			case NuajManager.TONE_MAPPING_TYPE.DISABLED:
				PassIndex = 5;
				break;
		}

		m_MaterialCompose.Blit( _Source, _Destination, PassIndex );

		// SERIOUS UNITY BUG HERE !
		// It doesn't reset the active render target so the main scene gets initialized in the last set RenderTexture !
		RenderTexture.active = null;
	}

	internal void	EndFrame()
	{
		if ( !enabled || m_bInErrorState || !gameObject.activeSelf )
			return;

		// Clear cached downsampled ZBuffers for next frame
		foreach ( RenderTexture TempRT in m_CachedDownsampledZBuffers.Values )
			Help.ReleaseTemporary( TempRT );
		m_CachedDownsampledZBuffers.Clear();

		// Perform CPU readback if required
		if ( m_WrittenCPUDataCount > 0 )
		{
			// Transfer from RenderTexture -> Texture
			RenderTexture.active = m_GPU2CPURenderTextures[0];
			m_CPUReadableTexture.Texture.ReadPixels( new Rect( 0, 0, CPU_READBACK_COUNT, 1 ), 0, 0, false );
			m_CPUReadableTexture.Apply();
			RenderTexture.active = null;

			// Perform a single CPU read-back
 			m_CPUReadBack = m_CPUReadableTexture.GetPixels( 0 );
 

#if USE_CPU_READBACK_TRIPLE_BUFFER
			// Scroll textures
			RenderTexture	Temp = m_GPU2CPURenderTextures[0];
			m_GPU2CPURenderTextures[0] = m_GPU2CPURenderTextures[1];
			m_GPU2CPURenderTextures[1] = m_GPU2CPURenderTextures[2];
			m_GPU2CPURenderTextures[2] = Temp;
#endif
 		}

		// Patrol the temp textures and discard those that haven't been used for a while
		Help.GarbageCollectUnusedTemporaryTextures();


		// SERIOUS UNITY BUG HERE !
		// It doesn't reset the active render target so the main scene gets initialized in the last set RenderTexture !
		RenderTexture.active = null;
	}

	#endregion

	#region Render Targets Size Update

	/// <summary>
	/// This method is called by the EffectComposeAtmosphere camera effect every time the Camera calls "PreCull"
	/// RenderTargets are lazy-initialized
	/// </summary>
	internal void	InitializeTargets( int _ScreenWidth, int _ScreenHeight )
	{
		if ( _ScreenWidth != m_ScreenWidth || _ScreenHeight != m_ScreenHeight )
		{	// Update resolution
			DestroyRenderTargets();
			CreateRenderTargets( _ScreenWidth, _ScreenHeight );

			m_bInternalDataAreValid = true;
		}

		// Always attempt to create the scaler's targets (it has its own check against same width & height)
		m_ImageScaler.CreateRenderTargets( _ScreenWidth, _ScreenHeight );
	}
	
	protected void	CreateRenderTargets( int _ScreenWidth, int _ScreenHeight )
	{
		if ( _ScreenWidth < 1 || _ScreenHeight < 1 )
			return;	// Invalid !

		m_ScreenWidth = _ScreenWidth;
		m_ScreenHeight = _ScreenHeight;

		// Create our render targets
		m_RTScattering = Nuaj.Help.CreateRT( "Scattering0", m_ScreenWidth, m_ScreenHeight, RenderTextureFormat.ARGBHalf, FilterMode.Point, TextureWrapMode.Clamp );
		m_RTBackground = Nuaj.Help.CreateRT( "Background", m_ScreenWidth, m_ScreenHeight, RenderTextureFormat.ARGBHalf, FilterMode.Bilinear, TextureWrapMode.Clamp );
		m_RTBackgroundEnvironment = Nuaj.Help.CreateRT( "BackgroundEnvironment", 2 << NuajManager.ENVIRONMENT_TEXTURE_SIZE_POT, 1 << NuajManager.ENVIRONMENT_TEXTURE_SIZE_POT, RenderTextureFormat.ARGBHalf, FilterMode.Point, TextureWrapMode.Clamp );

		// Notify every module
		foreach ( ModuleBase Module in m_Modules )
			try
			{
 				Module.CreateRenderTargets( m_ScreenWidth, m_ScreenHeight );
			}
			catch ( Exception _e )
			{
				Module.Enabled = false;
				Help.LogError( "Disabling module \"" + Module.Name + "\" failed to create its render targets with error : " + _e.Message + "\n" + _e.StackTrace );
			}

		//////////////////////////////////////////////////////////////////////////
		// Create default stock textures

		// Build the 1x1 empty and transparent cloud texture
		m_TextureEmptyCloud = Help.CreateTexture( "Empty Cloud Texture", 1, 1, TextureFormat.RGBA32, false, FilterMode.Point, TextureWrapMode.Clamp );
		m_TextureEmptyCloud.SetPixel( 0, 0, new Color( 0.0f, 0.0f, 0.0f, 1.0f ) );
		m_TextureEmptyCloud.Apply();
		m_TextureEmptyCloud.IsDirty = false;

		// Build the 1x1 white texture
		m_TextureWhite = Help.CreateTexture( "White Texture", 1, 1, TextureFormat.RGBA32, false, FilterMode.Point, TextureWrapMode.Clamp );
		m_TextureWhite.SetPixel( 0, 0, Color.white );
		m_TextureWhite.Apply();
		m_TextureWhite.IsDirty = false;

		// Build the 1x1 black texture
		m_TextureBlack = Help.CreateTexture( "Black Texture", 1, 1, TextureFormat.RGBA32, false, FilterMode.Point, TextureWrapMode.Clamp );
		m_TextureBlack.SetPixel( 0, 0, Color.black );
		m_TextureBlack.Apply();
		m_TextureBlack.IsDirty = false;

		// Build the 2D noise texture
		m_TextureNoise2D = Help.CreateTexture( "2D Noise Texture", NOISE2D_TEXTURE_SIZE, NOISE2D_TEXTURE_SIZE, TextureFormat.RGBA32, false, FilterMode.Bilinear, TextureWrapMode.Repeat );
		Color[]	NoiseValues = new Color[NOISE2D_TEXTURE_SIZE*NOISE2D_TEXTURE_SIZE];
		Color	Temp;
		for ( int Y=0; Y < NOISE2D_TEXTURE_SIZE; Y++ )
			for ( int X=0; X < NOISE2D_TEXTURE_SIZE; X++ )
			{
				Temp.r = (float) Nuaj.SimpleRNG.GetNormal();
				Temp.g = (float) Nuaj.SimpleRNG.GetNormal();
				Temp.b = (float) Nuaj.SimpleRNG.GetNormal();
				Temp.a = (float) Nuaj.SimpleRNG.GetNormal();
				NoiseValues[NOISE2D_TEXTURE_SIZE*Y+X] = Temp;
			}
		m_TextureNoise2D.SetPixels( NoiseValues, 0 );
		m_TextureNoise2D.Apply();
		m_TextureNoise2D.IsDirty = false;

		// Create the generic 3D noise texture
		Build3DNoise();

		// Create the readable triple buffer
		for ( int BufferIndex=0; BufferIndex < 3; BufferIndex++ )
			m_GPU2CPURenderTextures[BufferIndex] = Help.CreateRT( "GPU2CPURenderTexture" + BufferIndex, CPU_READBACK_COUNT, 1, RenderTextureFormat.ARGB32, FilterMode.Point, TextureWrapMode.Clamp );
		m_CPUReadableTexture = Help.CreateTexture( "CPUReadableTexture", CPU_READBACK_COUNT, 1, TextureFormat.ARGB32, false, FilterMode.Point, TextureWrapMode.Clamp );
	}

	protected void	DestroyRenderTargets()
	{
		// Destroy our render targets
		SafeDestroy( ref m_RTScattering );
		SafeDestroy( ref m_RTBackground );
		SafeDestroy( ref m_RTBackgroundEnvironment );

		// Destroy tone mapper's targets
		m_ImageScaler.DestroyRenderTargets();

		// Notify every module
		if ( m_Modules != null )
			foreach ( ModuleBase Module in m_Modules )
 				Module.DestroyRenderTargets();

		// Destroy default stock textures
		SafeDestroyNuaj( ref m_TextureEmptyCloud );
		SafeDestroyNuaj( ref m_TextureWhite );
		SafeDestroyNuaj( ref m_TextureBlack );
		SafeDestroyNuaj( ref m_TextureNoise2D );
		for ( int BufferIndex=0; BufferIndex < 3; BufferIndex++ )
			SafeDestroy( ref m_GPU2CPURenderTextures[BufferIndex] );
		SafeDestroyNuaj( ref m_CPUReadableTexture );

		// Destroy 3D noise textures
		Destroy3DNoise();

		// Destroy "temp" textures
		Help.DestroyTemporaryTextures();

		GC.Collect();

		m_ScreenWidth = 0;
		m_ScreenHeight = 0;
	}

	// DEBUG
	public void		DEBUGResetRenderTargets()
	{
		int	TempWidth = m_ScreenWidth;
		int	TempHeight = m_ScreenHeight;
		Help.LogDebugSeparate( "" );
		Help.LogDebug( "Recreating RenderTargets " + TempWidth + "x" + TempHeight );

		DestroyRenderTargets();
		CreateRenderTargets( TempWidth, TempHeight );
	}
	// DEBUG

	#endregion

	#region 3D Noise Texture

	/// <summary>
	/// Create the "3D noise" texture
	/// To simulate 3D textures that are not available in Unity, I create a single long 2D slice of (17*16) x 16
	/// The width is 17*16 so that all 3D slices are packed into a single line, and I use 17 as a single slice width
	///	because I pad the last pixel with the first column of the same slice so bilinear interpolation is correct.
	/// The texture contains 2 significant values in Red and Green :
	///		Red is the noise value in the current W slice
	///		Green is the noise value in the next W slice
	///	Then, the actual 3D noise value is an interpolation of red and green based on actual W remainder
	/// </summary>
	protected void		Build3DNoise()
	{
		// Allocate textures & variables
		m_TextureNoise3D = new NuajTexture2D[NOISE3D_TEXTURE_POT];

		// Build first noise mip level
		float[,,]	NoiseValues = new float[NOISE3D_TEXTURE_SIZE,NOISE3D_TEXTURE_SIZE,NOISE3D_TEXTURE_SIZE];
		for ( int W=0; W < NOISE3D_TEXTURE_SIZE; W++ )
			for ( int V=0; V < NOISE3D_TEXTURE_SIZE; V++ )
				for ( int U=0; U < NOISE3D_TEXTURE_SIZE; U++ )
					NoiseValues[U,V,W] = (float) SimpleRNG.GetUniform();

		// Build actual textures
		for ( int MipLevel=0; MipLevel < NOISE3D_TEXTURE_POT; MipLevel++ )
		{
			int		MipSize = NOISE3D_TEXTURE_SIZE >> MipLevel;
			int		Width = MipSize*(MipSize+1);
			Color[]	Content = new Color[MipSize*Width];

			// Build content
			for ( int W=0; W < MipSize; W++ )
			{
				int	Offset = W * (MipSize+1);

				for ( int V=0; V < MipSize; V++ )
				{
					for ( int U=0; U <= MipSize; U++ )
					{
						Content[Offset+Width*V+U].r = NoiseValues[U & (MipSize-1),V,W];
						Content[Offset+Width*V+U].g = NoiseValues[U & (MipSize-1),V,(W+1) & (MipSize-1)];
						Content[Offset+Width*V+U].b = Content[Offset+Width*V+U].a = 0.0f;
					}
				}
			}

			// Create texture
			m_TextureNoise3D[MipLevel] = Help.CreateTexture( "Noise3D #" + MipLevel, Width, MipSize, TextureFormat.ARGB32, false, FilterMode.Bilinear, TextureWrapMode.Repeat );
			m_TextureNoise3D[MipLevel].SetPixels( Content, 0 );
			m_TextureNoise3D[MipLevel].Apply( false, true );

			// Downscale noise values
			int	NextMipSize = MipSize >> 1;
			if ( NextMipSize > 0 )
			{
				float[,,]	NextMipNoiseValues = new float[NextMipSize,NextMipSize,NextMipSize];
				for ( int W=0; W < NextMipSize; W++ )
				{
					int	PW = W << 1;
					for ( int V=0; V < NextMipSize; V++ )
					{
						int	PV = V << 1;
						for ( int U=0; U < NextMipSize; U++ )
						{
							int	PU = U << 1;
							float	Value  = NoiseValues[PU+0,PV+0,PW+0];
									Value += NoiseValues[PU+1,PV+0,PW+0];
									Value += NoiseValues[PU+0,PV+1,PW+0];
									Value += NoiseValues[PU+1,PV+1,PW+0];
									Value += NoiseValues[PU+0,PV+0,PW+1];
									Value += NoiseValues[PU+1,PV+0,PW+1];
									Value += NoiseValues[PU+0,PV+1,PW+1];
									Value += NoiseValues[PU+1,PV+1,PW+1];

							NextMipNoiseValues[U,V,W] = 0.125f * Value;
						}
					}
				}

				NoiseValues = NextMipNoiseValues;
			}
		}

		// Setup global variables
 		for ( int MipIndex=0; MipIndex < m_TextureNoise3D.Length; MipIndex++ )
 			NuajMaterial.SetGlobalTexture( "_NuajTexNoise3D" + MipIndex, m_TextureNoise3D[MipIndex], true );
	}

	protected void		Destroy3DNoise()
	{
		if ( m_TextureNoise3D != null )
			for ( int MipIndex=0; MipIndex < m_TextureNoise3D.Length; MipIndex++ )
				Help.SafeDestroyNuaj( ref m_TextureNoise3D[MipIndex] );
		m_TextureNoise3D = null;
	}

	#endregion

	#region Camera Effect

	protected void	DestroyCameraEffect()
	{
		if ( m_Camera == null )
			return;

		// Un-subscribe from previous camera
		m_CameraEffectComposeAtmosphere.enabled = false;
		DestroyImmediate( m_CameraEffectComposeAtmosphere );
		m_CameraEffectComposeAtmosphere = null;
	}

	protected void	CreateOrAttachCameraEffect()
	{
		if ( m_Camera == null )
			return;

		EffectComposeAtmosphere	ExistingComponent = m_Camera.GetComponent<EffectComposeAtmosphere>();
		if ( ExistingComponent == null )
		{	// Create a new one
			m_CameraEffectComposeAtmosphere = m_Camera.gameObject.AddComponent<EffectComposeAtmosphere>();
		}
		else if ( ExistingComponent != m_CameraEffectComposeAtmosphere )
		{	// It's ours now !
			m_CameraEffectComposeAtmosphere = ExistingComponent;
		}

		// Setup the owner no matter what
		m_CameraEffectComposeAtmosphere.Owner = this;
	}

	#endregion

	#region Software Tone Mapping

	// You'll find here the equivalent of what happens in the tone mapping shader

	///////////////////////////////////////////////////////////////////////////////
	// Reinhard algorithm
	//
	internal float	ToneMapReinhard( float Y, float _ImageLuminance )
	{
		float	Lwhite = m_ToneMappingParamsReinhard.WhiteLuminance;
		float	L = m_ToneMappingParamsReinhard.MiddleGrey * Y / (1e-3f + _ImageLuminance);
		return	L * (1.0f + L / (Lwhite * Lwhite)) / (1.0f + L);
	}

	///////////////////////////////////////////////////////////////////////////////
	// Drago et al. algorithm
	//
	internal float	ToneMapDrago( float Y, float _ImageLuminance )
	{
		float	Ldmax = m_ToneMappingParamsDrago.MaxDisplayLuminance;
		float	Lw = Y;
		float	Lwmax = _ImageLuminance;
		float	bias = m_ToneMappingParamsDrago.Bias;

		Y  = Ldmax * 0.01f * Mathf.Log( Lw + 1.0f );
		return Y / Mathf.Log10( Lwmax + 1.0f ) * Mathf.Log( 2.0f + 0.8f * Mathf.Pow( Lw / Lwmax, -1.4426950408889634073599246810019f * Mathf.Log( bias ) ) );
	}

	///////////////////////////////////////////////////////////////////////////////
	// Filmic Curve algorithm (Hable)
	//
	float	FilmicToneMapOperator( float _In )
	{
		return ((_In*(m_ToneMappingParamsFilmic.A*_In+m_ToneMappingParamsFilmic.C*m_ToneMappingParamsFilmic.B) + m_ToneMappingParamsFilmic.D*m_ToneMappingParamsFilmic.E) /
			   (_In*(m_ToneMappingParamsFilmic.A*_In+m_ToneMappingParamsFilmic.B) + m_ToneMappingParamsFilmic.D*m_ToneMappingParamsFilmic.F))
			   - m_ToneMappingParamsFilmic.E/m_ToneMappingParamsFilmic.F;
	}

	internal float	ToneMapFilmic( float Y, float _ImageLuminance )
	{
		Y *= m_ToneMappingParamsFilmic.MiddleGrey / _ImageLuminance;
		return FilmicToneMapOperator( Y ) / FilmicToneMapOperator( m_ToneMappingParamsFilmic.W );
	}

	///////////////////////////////////////////////////////////////////////////////
	// Exponential algorithm
	//
	internal float	ToneMapExponential( float Y, float _ImageLuminance )
	{
		return m_ToneMappingParamsExponential.Gain * (1.0f - Mathf.Exp( -m_ToneMappingParamsExponential.Exposure * Y ));
	}

	///////////////////////////////////////////////////////////////////////////////
	// Linear algorithm
	//
	internal float	ToneMapLinear( float Y, float _ImageLuminance )
	{
		return Y * m_ToneMappingParamsLinear.Factor * m_ToneMappingParamsLinear.MiddleGrey / _ImageLuminance;	// Exposure correction
	}

	/// <summary>
	/// Applies software luminance adaptation and tone mapping to the HDR color
	/// </summary>
	/// <param name="_RGB">The HDR color to tone map</param>
	/// <returns>The tone mapped LDR color useable by Unity</returns>
	public Vector3	ToneMap( Vector3 _RGB )
	{
		// Retrieve luminance and tint of the currently adapted luminance
		Vector3	CurrentAdaptationLuminance = m_CurrentAdaptationLuminance;
		float	ImageLuminance = Math.Max( 1e-3f, Math.Max( Math.Max( CurrentAdaptationLuminance.x, CurrentAdaptationLuminance.y ), CurrentAdaptationLuminance.z ) );
		Vector3	ImageTint = CurrentAdaptationLuminance / ImageLuminance;

		// Switch to xyY
		Vector3	xyY = Help.RGB2xyY( _RGB );

		// Apply tone mapping
		switch ( m_ToneMappingType )
		{
			case TONE_MAPPING_TYPE.REINHARD:
				xyY.z = ToneMapReinhard( xyY.z, ImageLuminance );
				break;
			case TONE_MAPPING_TYPE.DRAGO:
				xyY.z = ToneMapDrago( xyY.z, ImageLuminance );
				break;
			case TONE_MAPPING_TYPE.FILMIC:
				xyY.z = ToneMapFilmic( xyY.z, ImageLuminance );
				break;
			case TONE_MAPPING_TYPE.EXPONENTIAL:
				xyY.z = ToneMapExponential( xyY.z, ImageLuminance );
				break;
			case TONE_MAPPING_TYPE.LINEAR:
				xyY.z = ToneMapLinear( xyY.z, ImageLuminance );
				break;
		}

		xyY.z *= m_ToneMappingBoostFactor;

// 		// Apply gamma and back to RGB
// 		xyY.z = Mathf.Pow( Math.Max( 0.0f, xyY.z ), 1.0f / m_ToneMappingGamma );

		_RGB = Help.xyY2RGB( xyY );

		// Apply image tint
		_RGB = Help.Vec3Product( _RGB, ImageTint );

		return _RGB;
	}

	#endregion

	#region Luminance Adaptation

	/// <summary>
	/// This is the default luminance adaptation routine
	/// It slowly adapts to the current luminance over time so changes are not abrupt and unnatural.
	/// It also has a different behaviour at night where luminance adaptation time is adapted more slowly
	///  toward a much lower bottom limit (scotopic vision) and the environment shows a slightly blue-ish tint shift.
	/// 
	/// If you're not satisfied with this purely empirical function then you can subscribe to the
	///	 CustomLuminanceAdaptation event and write your own using this one as a model
	/// </summary>
	protected void	PerformDefaultLuminanceAdaptation()
	{
		float	Dt = NuajTime.UnityDeltaTime;

		// Adaptation speed slows down at night
		float	AdaptationSpeed = Mathf.Lerp( m_ToneMappingAdaptationSpeedAtDay, m_ToneMappingAdaptationSpeedAtNight, m_SmoothDayNight );
		float	LastFrameLuminance = Vector3.Dot( m_PreviousFrameLuminance, LUMINANCE );
		float	TemporalAdaptation = Mathf.Lerp( LastFrameLuminance, m_ImageLuminance, 1.0f - Mathf.Pow( 1.0f - AdaptationSpeed, Dt ) );

		// Adaptation low limit is higher during day
		float	MinLuminance = Mathf.Lerp( m_ToneMappingMinLuminanceAtDay, m_ToneMappingMinLuminanceAtNight, m_SmoothDayNight );
		float	MaxLuminance = Mathf.Lerp( m_ToneMappingMaxLuminanceAtDay, m_ToneMappingMaxLuminanceAtNight, m_SmoothDayNight );
		TemporalAdaptation = Mathf.Clamp( TemporalAdaptation, MinLuminance, MaxLuminance );

		// Account for blue shift
		Vector3	Tint = Vector3.Lerp( Vector3.one, new Vector3( 0.9f, 0.95f, 1.0f ), m_SmoothDayNight );

		m_CurrentAdaptationLuminance = TemporalAdaptation * Tint;
	}

	#endregion

	#region Default HDR->Unity Adaptation

	// You will find here the default methods to convert the current Sun light and average ambient sky light into useable Unity colors
	//
	// If you are not satisfied with these purely empirical functions, you can disable NuajDrivesSunAmbientColor
	//	and NuajDrivesSunDirectionalColor and compute the colors yourself
	//

	/// <summary>
	/// This is a simple conversion from a physical sun color to a nice looking Unity light setup
	/// (this is mainly an empirical formula)
	/// </summary>
	/// <param name="_SunColor"></param>
	/// <param name="_Light"></param>
	public void	ConvertSunColorToUnityLight( Vector3 _SunColor, Light _Light )
	{
		if ( _Light == null )
			return;

		if ( m_bSceneIsHDR )
		{	// Simply use as-is, no need for tone mapping
			Help.Vec3ToLight( _SunColor, _Light );
		}
		else
		{
			Vector3	ToneMappedSunColor = ToneMap( _SunColor );
			Help.Vec3ToLight( ToneMappedSunColor, _Light );
		}
		_Light.intensity *= m_UnitySunColorFactor;
	}

	/// <summary>
	/// This is a simple conversion from a physical ambient sky color to a nice looking Unity ambient light setup
	/// (this is mainly an empirical formula)
	/// </summary>
	/// <param name="_AmbientSky"></param>
	/// <returns></returns>
	public Color	ConvertAmbientSkyColorToUnityAmbient( Vector3 _AmbientSky )
	{
		if ( m_bSceneIsHDR )
			return m_UnityAmbientColorFactor * Help.Vec3ToColor( _AmbientSky );	// Return as-is...

		// Tone map
		Vector3	AmbientSkyLDR = ToneMap( _AmbientSky );

		AmbientSkyLDR *= m_UnityAmbientColorFactor;
		AmbientSkyLDR = Vector3.Min( AmbientSkyLDR, 1.0f * Vector3.one );	// Don't go brighter than white !
		Color	Result = Help.Vec3ToColor( AmbientSkyLDR );

		return Result;
	}

	#endregion

	#region Shadow Map Management

	protected void	InitializeShadowMap()
	{
		DestroyShadowMap();
		m_RTShadowMap = Help.CreateRT( "Global ShadowMap", m_ShadowMapSize, m_ShadowMapSize, RenderTextureFormat.ARGBHalf, FilterMode.Bilinear, TextureWrapMode.Clamp );
	}

	protected void	DestroyShadowMap()
	{
		Help.SafeDestroy( ref m_RTShadowMap );
	}

	/// <summary>
	/// The shadow map is a standard planar shadow map defined in light plane.
	/// We need to retrieve the boundaries of the rectangle in light plane that encompasses the visible scene.
	/// The visible scene is defined as the intersection of the camera frustum (with a limited far plane) and the scene's AABBox provided as a parameter
	/// 
	/// The idea is this:
	///
	///        ..           /
	///  top       ..      / Sun direction
	///  cloud ------ ..  /
	///               ---x..
	///                     --..
	///        -------          -- ..
	///        ///////-----         -  .. Tangent plane to the top cloud sphere
	///        /////////////--        -
	///        /////Earth//////-
	///
	/// 1) We compute the tangent plane to the top cloud sphere by projecting the Earth's center to the cloud sphere's surface following the Sun's direction.
	/// 2) We project the camera frustum onto that plane
	/// 3) We compute the axis-aligned bounding box to that frustum
	/// 4) We compute the data necessary to transform a world position into a shadow map position, and the reverse
	/// </summary>
	protected void		PrepareShadowMap( Vector3 _LightDirection )
	{
		_LightDirection.Normalize();

		//////////////////////////////////////////////////////////////////////////
		// Build the tangent plane's orientation
		float	CloudRadiusKm = m_PlanetRadiusKm + m_ShadowMapPlaneAltitudesKm;

		Vector3	ShadowPlaneFarCenterKm = m_PlanetCenterKm + CloudRadiusKm * _LightDirection;	// "Far" center on tangent shadow plane starting from planet center
		Vector3	Origin = Vector3.zero;															// The (0,0,0) position is arbitrary but should be fixed and close to the camera to avoid precision issues
		Vector3	ToCenter = ShadowPlaneFarCenterKm - Origin;
		float	Distance2PlaneKm = Vector3.Dot( ToCenter, _LightDirection );					// Distance it takes to reach the shadow plane from the arbitrary origin and following the Sun's direction
		Vector3	ShadowPlaneCenterKm = Origin + Distance2PlaneKm * _LightDirection;				// This is our center: the projection of the origin onto the shadow plane by following the Sun's direction

		Vector3	ShadowPlaneX = Vector3.Cross( _LightDirection, Vector3.up );
		if ( ShadowPlaneX.sqrMagnitude < 1e-6f )
			ShadowPlaneX = Vector3.right;
		else
			ShadowPlaneX.Normalize();
		Vector3	ShadowPlaneY = Vector3.Cross( ShadowPlaneX, _LightDirection );

 		m_ShadowPlane2World = new Matrix4x4();
		m_ShadowPlane2World.SetColumn( 0, Help.Vec3ToVec4( ShadowPlaneX, 0.0f ) );			// X axis becomes shadow U
		m_ShadowPlane2World.SetColumn( 1, Help.Vec3ToVec4( ShadowPlaneY, 0.0f ) );			// Y axis becomes shadow V
		m_ShadowPlane2World.SetColumn( 2, Help.Vec3ToVec4( _LightDirection, 0.0f ) );		// Z axis is kept as the distance to the shadow plane (very useful for projection onto the cloud plane later)
		m_ShadowPlane2World.SetColumn( 3, Help.Vec3ToVec4( ShadowPlaneCenterKm, 1.0f ) );

		m_World2ShadowPlane = m_ShadowPlane2World.inverse;


		//////////////////////////////////////////////////////////////////////////
		// Compute camera frustum's corners into shadow space & build bounding rectangle
		float	TanHalfFOVx = m_CameraData.x;
		float	TanHalfFOVy = m_CameraData.y;

		float	ShadowFarClipKm = m_WorldUnit2Kilometer * m_ShadowFarClip;

		Vector3[]	CameraCorners = new Vector3[]
		{
			Vector3.zero,
			new Vector3( -TanHalfFOVx, +TanHalfFOVy, -1.0f ),
			new Vector3( -TanHalfFOVx, -TanHalfFOVy, -1.0f ),
			new Vector3( +TanHalfFOVx, -TanHalfFOVy, -1.0f ),
			new Vector3( +TanHalfFOVx, +TanHalfFOVy, -1.0f ),
		};

		m_ShadowMapQuadMin = new Vector2( +1e6f, +1e6f );
		m_ShadowMapQuadMax = new Vector2( -1e6f, -1e6f );

		// Transform into world space
		for ( int CornerIndex = 0; CornerIndex < CameraCorners.Length; CornerIndex++ )
		{
			Vector3 CameraCornerWorldKm = m_Camera2WorldKm.MultiplyPoint( ShadowFarClipKm * CameraCorners[CornerIndex] );
			CameraCorners[CornerIndex] = CameraCornerWorldKm;
		}

		// Build the bounding slabs for the camera frustum
		BoundingSlabs	Slabs = new BoundingSlabs();
		Vector3			V0 = CameraCorners[0];
		for ( int SideIndex=0; SideIndex < 4; SideIndex++ )
		{
			Vector3	V1 = CameraCorners[1+SideIndex];
			Vector3	V2 = CameraCorners[1+((SideIndex+1)&3)];

			Vector3	Edge0 = V1 - V0;
			Vector3	Edge1 = V2 - V0;
			Vector3	InwardNormal = Vector3.Cross( Edge0, Edge1 ).normalized;

			Slabs.AddSlab( V0, InwardNormal );
		}

		// Final slab is far clip plane
		{
			V0 = CameraCorners[1];
			Vector3	V1 = CameraCorners[2];
			Vector3	V2 = CameraCorners[3];

			Vector3	Edge0 = V0 - V1;
			Vector3	Edge1 = V2 - V1;
			Vector3	InwardNormal = Vector3.Cross( Edge0, Edge1 ).normalized;	// Should point towards the camera

			Slabs.AddSlab( V0, InwardNormal );
		}

		Vector3	CameraPositionKm = m_Camera2WorldKm.GetColumn(3);
		Vector3	PlanetNormal = CameraPositionKm - m_PlanetCenterKm;
		float	CameraRadiusKm = PlanetNormal.magnitude;
		float	CameraAltitudeKm = CameraRadiusKm - m_PlanetRadiusKm;
				PlanetNormal /= CameraRadiusKm;

		if ( true )
		{
			// Add the shadow plane as a boundary (but only if we're below the plane)
			if ( Vector3.Dot( CameraPositionKm - ShadowPlaneCenterKm, _LightDirection ) < 0.0f )
				Slabs.AddSlab( ShadowPlaneCenterKm, -_LightDirection );

			// Add the top cloud plane as the upper boundary
			if ( CameraAltitudeKm < m_ShadowMapPlaneAltitudesKm )
				Slabs.AddSlab( m_PlanetCenterKm + (m_PlanetRadiusKm + m_ShadowMapPlaneAltitudesKm) * PlanetNormal, -PlanetNormal );	// Project camera to top cloud plane

			// Add a bottom slab that goes below the Earth's horizon
			{
				Vector3	StartPos = CameraCorners[1];
				Vector3	Direction = CameraCorners[2] - StartPos;
				float	HitDistance;
				if ( Help.ComputeForwardSphereIntersection( ref StartPos, ref Direction, ref m_PlanetCenterKm, m_PlanetRadiusKm, out HitDistance ) )
				{
					Vector3	LeftIntersection = StartPos + HitDistance * Direction;
					StartPos = CameraCorners[4];
					Direction = CameraCorners[3] - StartPos;
					if ( Help.ComputeForwardSphereIntersection( ref StartPos, ref Direction, ref m_PlanetCenterKm, m_PlanetRadiusKm, out HitDistance ) )
					{
						Vector3	RightIntersection = StartPos + HitDistance * Direction;

						// Our slab is the plane passing through the camera and these 2 intersections
						Vector3	DLeft = LeftIntersection - CameraPositionKm;
						Vector3	DRight = RightIntersection - CameraPositionKm;
						Vector3	Normal = Vector3.Cross( DLeft, DRight );
								Normal.Normalize();

						Slabs.AddSlab( CameraPositionKm, Normal );
					}
				}
			}
		}

		// Generate the final convex hull vertices and determine bounding quad
		Vector3[]	ConvexHull = Slabs.GenerateVertices();
		foreach ( Vector3 Vertex in ConvexHull )
		{
			// Project onto shadow plane
			Vector3 HullVertexShadowKm = m_World2ShadowPlane.MultiplyPoint( Vertex );
			Vector2 HullVertexProjKm = new Vector2( HullVertexShadowKm.x, HullVertexShadowKm.y );

			// Update bounding quad
			m_ShadowMapQuadMin = Vector2.Min( m_ShadowMapQuadMin, HullVertexProjKm );
			m_ShadowMapQuadMax = Vector2.Max( m_ShadowMapQuadMax, HullVertexProjKm );
		}

		// Apply a slight scale for security
		Vector2	Center = 0.5f * (m_ShadowMapQuadMin + m_ShadowMapQuadMax);
		Vector2	Size = 0.5f * (m_ShadowMapQuadMax - m_ShadowMapQuadMin);
				Size *= 1.1f;

		m_ShadowMapQuadMin = Center - Size;
		m_ShadowMapQuadMax = Center + Size;


		//////////////////////////////////////////////////////////////////////////
		// Compute rendering viewport
		// To avoid shadow flickering, we keep the size of a shadow texel constant but we rather render with a varying viewport size
		//
		ComputeShadowMapRenderingData( m_ShadowMapSize, out m_World2ShadowMap, out m_ShadowMap2World, out m_ShadowMapViewport, out m_ShadowMapUVBounds );

		// Setup global shadow map parameters
		SetupShadowMapData();
 	}

	/// <summary>
	/// Computes the shadow map transforms and viewport given the resolution of the shadow map
	/// </summary>
	/// <param name="_ShadowMapSize">The resolution of the considered shadow map</param>
	/// <param name="_World2ShadowMap">The transform from WORLD space to SHADOW MAP space</param>
	/// <param name="_ShadowMap2World">The transform from SHADOW MAP space to WORLD space</param>
	/// <param name="_Viewport">The rendering viewport (in pixels)</param>
	internal void		ComputeShadowMapRenderingData( int _ShadowMapSize, out Matrix4x4 _World2ShadowMap, out Matrix4x4 _ShadowMap2World, out Rect _Viewport, out Vector4 _UVBounds )
	{
		Vector2	QuadSizeKm = m_ShadowMapQuadMax - m_ShadowMapQuadMin;

		float	ShadowFarClipKm = m_WorldUnit2Kilometer * m_ShadowFarClip;
		float	MaxSizeKm = 400.0f;															// The default 400 km size is arbitrary and comes from experimenting with QuadSizeMax and moving the camera around and storing the largest value...
				MaxSizeKm *= ShadowFarClipKm / 100.0f;										// The max size was experimentally determined using a default clip distance of 100km
				MaxSizeKm = Math.Max( Math.Max( MaxSizeKm, QuadSizeKm.x ), QuadSizeKm.y );	// Don't go below existing quad size though...

		float	Kilometer2TexelScale = (_ShadowMapSize - 1.0f) / MaxSizeKm;					// This gives the amount of texels it takes to make a kilometer, if you invert this you can obtain the size of a shadow texel and contemplate in awe that there is a very poor shadow resolution indeed ! This is why the shadow flickering is so noticeable... And it's so much worse when the Sun is low...... *GASP*

		// Normalized size in texels
		Vector2	ShadowMapQuadMinTexel = Kilometer2TexelScale * m_ShadowMapQuadMin;
		Vector2	ShadowMapQuadMaxTexel = Kilometer2TexelScale * m_ShadowMapQuadMax;

		// Compute viewport size in texels
		int	ViewMinTexelX = (int) Math.Floor( ShadowMapQuadMinTexel.x );
		int	ViewMinTexelY = (int) Math.Floor( ShadowMapQuadMinTexel.y );
		int	ViewMaxTexelX = (int) Math.Ceiling( ShadowMapQuadMaxTexel.x );
		int	ViewMaxTexelY = (int) Math.Ceiling( ShadowMapQuadMaxTexel.y );

		int	ViewSizeTexelX = ViewMaxTexelX - ViewMinTexelX;
		int	ViewSizeTexelY = ViewMaxTexelY - ViewMinTexelY;

		_Viewport = new Rect( 0, 0, ViewSizeTexelX, ViewSizeTexelY );


		// Build the matrix that will transform shadow plane positions into normalized shadow UVs
		// So for now we assume m_ShadowMapQuadMin and m_ShadowMapQuadMax map to [0,0] and [1,1] respectively
		float	ScaleX = 1.0f / (m_ShadowMapQuadMax.x - m_ShadowMapQuadMin.x);
		float	ScaleY = 1.0f / (m_ShadowMapQuadMax.y - m_ShadowMapQuadMin.y);

		float	OffsetX = -m_ShadowMapQuadMin.x * ScaleX;
		float	OffsetY = -m_ShadowMapQuadMin.y * ScaleY;

		Matrix4x4	ShadowPlane2NormalizedUV = Matrix4x4.identity;
		ShadowPlane2NormalizedUV.SetColumn( 0, new Vector4( ScaleX, 0, 0, 0 ) );
		ShadowPlane2NormalizedUV.SetColumn( 1, new Vector4( 0, ScaleY, 0, 0 ) );
		ShadowPlane2NormalizedUV.SetColumn( 2, new Vector4( 0, 0, 1, 0 ) );
		ShadowPlane2NormalizedUV.SetColumn( 3, new Vector4( OffsetX, OffsetY, 0, 1 ) );


		// Build the matrix that will transform normalized shadow UVs into cropped shadow UVs
		// Since we don't render the entire viewport but a subset of it, we simply need to retrieve the values that will map the [0,0] / [1,1] corners into actual viewport corners

		// Compute the Min/Max UVs in the shadow map, taking the small offset of integer texels into account
		Vector2	UVMin = new Vector2( (ShadowMapQuadMinTexel.x - ViewMinTexelX) / _ShadowMapSize, (ShadowMapQuadMinTexel.y - ViewMinTexelY) / _ShadowMapSize );
		Vector2	UVMax = new Vector2( (ShadowMapQuadMaxTexel.x - ViewMinTexelX) / _ShadowMapSize, (ShadowMapQuadMaxTexel.y - ViewMinTexelY) / _ShadowMapSize );

		_UVBounds = new Vector4( UVMin.x, UVMin.y, UVMax.x - UVMin.x, UVMax.y - UVMin.y );

		// Build the final projection matrices
		_World2ShadowMap = ShadowPlane2NormalizedUV * m_World2ShadowPlane;	// Annoyingly, we have to compose in the reverse order because Unity stores its matrices in column-major order
		_ShadowMap2World = _World2ShadowMap.inverse;
	}

	/// <summary>
	/// Assigns the global shadow map variables
	/// </summary>
	protected void	SetupShadowMapData()
	{
		NuajMaterial.SetGlobalVector( "_ShadowAltitudesMinKm", m_ShadowMapAltitudesMinKm );
		NuajMaterial.SetGlobalVector( "_ShadowAltitudesMaxKm", m_ShadowMapAltitudesMaxKm );
		NuajMaterial.SetGlobalVector( "_ShadowMapUVBounds", m_ShadowMapUVBounds );
		NuajMaterial.SetGlobalMatrix( "_NuajShadow2World", m_ShadowMap2World );
		NuajMaterial.SetGlobalMatrix( "_NuajWorld2Shadow", m_World2ShadowMap );
	}

	#endregion

	#region Layer Ordering

	/// <summary>
	/// Computes the ordering of layers
	/// When tracing through cloud layers at a given camera altitude, there are 2 kinds of scenarii we can think of for the camera rays :
	///		* They either go up through layers above
	///		* Or they go down through layers below
	///
	/// What we're doing here is determining the order of the layers in each 2 cases and the way to distinguish between the cases.
	/// We are then able to feed the sky/cloud materials a set of swizzle vectors that will be used to order layers, as well as the altitude of the layer to test against to check if viewing "up or down".
	/// </summary>
	/// <param name="_bHasFog">True if there is a fog layer</param>
	protected void	ComputeLayersOrder( bool _bHasFog )
	{
 		Vector3	CameraPositionKm = m_Camera2WorldKm.GetColumn( 3 );
		float	CameraAltitudeKm = Vector3.Magnitude( CameraPositionKm - m_PlanetCenterKm ) - m_PlanetRadiusKm;

		int		LastTracedSegment = m_RenderCloudLayers.Count;	// When viewing down, the last traced segment is the one with godrays
		if ( _bHasFog )
			LastTracedSegment--;	// When we have fog, we don't care about what's below the fog : our last traced segment is the segment ABOVE the fog

		bool	InsideLayer = false;
		int		CaseLayer = -1;
		int		GodRaysLayerUp = 0;
		int		GodRaysLayerDown = LastTracedSegment;

		int[]	LayersTraceOrderUpExit = new int[4];
		int[]	LayersTraceOrderDownEnter = new int[4];
		if ( CameraAltitudeKm < m_ShadowMapAltitudesMinKm.x )
		{	// Below lowest layer
			LayersTraceOrderUpExit[0] = 0;		LayersTraceOrderUpExit[1] = 1;		LayersTraceOrderUpExit[2] = 2;		LayersTraceOrderUpExit[3] = 3;
			LayersTraceOrderDownEnter[0] = -1;	LayersTraceOrderDownEnter[1] = -1;	LayersTraceOrderDownEnter[2] = -1;	LayersTraceOrderDownEnter[3] = -1;

			GodRaysLayerUp = 0;		// We're inside the segment...
			GodRaysLayerDown = 0;	// We only trace one segment until we reach the ground...
		}
		else if ( CameraAltitudeKm < m_ShadowMapAltitudesMaxKm.x )
		{	// Inside lowest layer
			CaseLayer = 0;
			InsideLayer = true;
			LayersTraceOrderUpExit[0] = 0;		LayersTraceOrderUpExit[1] = 1;		LayersTraceOrderUpExit[2] = 2;		LayersTraceOrderUpExit[3] = 3;
			LayersTraceOrderDownEnter[0] = 0;	LayersTraceOrderDownEnter[1] = -1;	LayersTraceOrderDownEnter[2] = -1;	LayersTraceOrderDownEnter[3] = -1;

			GodRaysLayerUp = _bHasFog ? 1 : 0;
			GodRaysLayerDown = 0;	// We're in the second segment, godrays are in the next segment...
		}
		else if ( CameraAltitudeKm < m_ShadowMapAltitudesMinKm.y )
		{	// Below second layer
			CaseLayer = 0;
			LayersTraceOrderUpExit[0] = 1;		LayersTraceOrderUpExit[1] = 2;		LayersTraceOrderUpExit[2] = 3;		LayersTraceOrderUpExit[3] = -1;
			LayersTraceOrderDownEnter[0] = 0;	LayersTraceOrderDownEnter[1] = -1;	LayersTraceOrderDownEnter[2] = -1;	LayersTraceOrderDownEnter[3] = -1;

			GodRaysLayerDown = _bHasFog ? 0 : 1;
		}
		else if ( CameraAltitudeKm < m_ShadowMapAltitudesMaxKm.y )
		{	// Inside second layer
			CaseLayer = 1;
			InsideLayer = true;
			LayersTraceOrderUpExit[0] = 1;		LayersTraceOrderUpExit[1] = 2;		LayersTraceOrderUpExit[2] = 3;		LayersTraceOrderUpExit[3] = -1;
			LayersTraceOrderDownEnter[0] = 1;	LayersTraceOrderDownEnter[1] = 0;	LayersTraceOrderDownEnter[2] = -1;	LayersTraceOrderDownEnter[3] = -1;

			GodRaysLayerDown = _bHasFog ? 1 : 2;
		}
		else if ( CameraAltitudeKm < m_ShadowMapAltitudesMinKm.z )
		{	// Below third layer
			CaseLayer = 1;
			LayersTraceOrderUpExit[0] = 2;		LayersTraceOrderUpExit[1] = 3;		LayersTraceOrderUpExit[2] = -1;		LayersTraceOrderUpExit[3] = -1;
			LayersTraceOrderDownEnter[0] = 1;	LayersTraceOrderDownEnter[1] = 0;	LayersTraceOrderDownEnter[2] = -1;	LayersTraceOrderDownEnter[3] = -1;

			GodRaysLayerDown = _bHasFog ? 1 : 2;
		}
		else if ( CameraAltitudeKm < m_ShadowMapAltitudesMaxKm.z )
		{	// Inside third layer
			CaseLayer = 1;
			InsideLayer = true;
			LayersTraceOrderUpExit[0] = 2;		LayersTraceOrderUpExit[1] = 3;		LayersTraceOrderUpExit[2] = -1;		LayersTraceOrderUpExit[3] = -1;
			LayersTraceOrderDownEnter[0] = 2;	LayersTraceOrderDownEnter[1] = 1;	LayersTraceOrderDownEnter[2] = 0;	LayersTraceOrderDownEnter[3] = -1;

			GodRaysLayerDown = _bHasFog ? 2 : 3;
		}
		else if ( CameraAltitudeKm < m_ShadowMapAltitudesMinKm.w )
		{	// Below fourth layer
			CaseLayer = 2;
			LayersTraceOrderUpExit[0] = 3;		LayersTraceOrderUpExit[1] = -1;		LayersTraceOrderUpExit[2] = -1;		LayersTraceOrderUpExit[3] = -1;
			LayersTraceOrderDownEnter[0] = 2;	LayersTraceOrderDownEnter[1] = 1;	LayersTraceOrderDownEnter[2] = 0;	LayersTraceOrderDownEnter[3] = -1;

			GodRaysLayerDown = _bHasFog ? 2 : 3;
		}
		else if ( CameraAltitudeKm < m_ShadowMapAltitudesMaxKm.w )
		{	// Inside fourth layer
			CaseLayer = 2;
			InsideLayer = true;
			LayersTraceOrderUpExit[0] = 3;		LayersTraceOrderUpExit[1] = -1;		LayersTraceOrderUpExit[2] = -1;		LayersTraceOrderUpExit[3] = -1;
			LayersTraceOrderDownEnter[0] = 3;	LayersTraceOrderDownEnter[1] = 2;	LayersTraceOrderDownEnter[2] = 1;	LayersTraceOrderDownEnter[3] = 0;

			GodRaysLayerDown = _bHasFog ? 3 : 4;
		}
		else
		{	// Above fourth layer
			CaseLayer = 3;
			LayersTraceOrderUpExit[0] = -1;		LayersTraceOrderUpExit[1] = -1;		LayersTraceOrderUpExit[2] = -1;	LayersTraceOrderUpExit[3] = -1;
			LayersTraceOrderDownEnter[0] = 3;	LayersTraceOrderDownEnter[1] = 2;	LayersTraceOrderDownEnter[2] = 1;	LayersTraceOrderDownEnter[3] = 0;

			GodRaysLayerDown = _bHasFog ? 3 : 4;
		}

		// Build swizzles
		m_LayerOrderingCaseSwizzle = BuildSwizzle( CaseLayer );	// This will give the layer index to use to check if we're viewing up or down
		m_LayerOrderingInsideLayer = InsideLayer;
		m_LayerOrderingSwizzleExitUp0 = BuildSwizzle( LayersTraceOrderUpExit[0] );
		m_LayerOrderingSwizzleExitUp1 = BuildSwizzle( LayersTraceOrderUpExit[1] );
		m_LayerOrderingSwizzleExitUp2 = BuildSwizzle( LayersTraceOrderUpExit[2] );
		m_LayerOrderingSwizzleExitUp3 = BuildSwizzle( LayersTraceOrderUpExit[3] );
		m_LayerOrderingSwizzleEnterDown0 = BuildSwizzle( LayersTraceOrderDownEnter[0] );
		m_LayerOrderingSwizzleEnterDown1 = BuildSwizzle( LayersTraceOrderDownEnter[1] );
		m_LayerOrderingSwizzleEnterDown2 = BuildSwizzle( LayersTraceOrderDownEnter[2] );
		m_LayerOrderingSwizzleEnterDown3 = BuildSwizzle( LayersTraceOrderDownEnter[3] );
		m_LayerOrderingIsGodRaysLayerUp = BuildSwizzle( GodRaysLayerUp );
		m_LayerOrderingIsGodRaysLayerDown = BuildSwizzle( GodRaysLayerDown );
		m_LayerOrderingIsGodRaysLayerUpDown = new Vector2( GodRaysLayerUp == LastTracedSegment ? 1.0f : 0.0f, GodRaysLayerDown == LastTracedSegment ? 1.0f : 0.0f );
	}

	protected Vector4	BuildSwizzle( int _Index )
	{
		Vector4	Result = Vector4.zero;
		switch ( _Index )
		{
			case 0: Result.x = 1.0f; break;
			case 1: Result.y = 1.0f; break;
			case 2: Result.z = 1.0f; break;
			case 3: Result.w = 1.0f; break;
		}
		return Result;
	}

	internal void		SetupLayerOrderingData( NuajMaterial _Material )
	{
		_Material.SetVector( "_CaseSwizzle", m_LayerOrderingCaseSwizzle );
		_Material.SetFloat( "_CasePreventInfinity", m_LayerOrderingInsideLayer ? 0.0f : 1.0f );
		_Material.SetVector( "_SwizzleEnterDown0", m_LayerOrderingSwizzleEnterDown0 );
		_Material.SetVector( "_SwizzleEnterDown1", m_LayerOrderingSwizzleEnterDown1 );
		_Material.SetVector( "_SwizzleEnterDown2", m_LayerOrderingSwizzleEnterDown2 );
		_Material.SetVector( "_SwizzleEnterDown3", m_LayerOrderingSwizzleEnterDown3 );
		_Material.SetVector( "_SwizzleExitUp0", m_LayerOrderingSwizzleExitUp0 );
		_Material.SetVector( "_SwizzleExitUp1", m_LayerOrderingSwizzleExitUp1 );
		_Material.SetVector( "_SwizzleExitUp2", m_LayerOrderingSwizzleExitUp2 );
		_Material.SetVector( "_SwizzleExitUp3", m_LayerOrderingSwizzleExitUp3 );
		_Material.SetVector( "_IsGodRaysLayerUp", m_LayerOrderingIsGodRaysLayerUp );
		_Material.SetVector( "_IsGodRaysLayerDown", m_LayerOrderingIsGodRaysLayerDown );
		_Material.SetVector( "_IsGodRaysLayerUpDown", m_LayerOrderingIsGodRaysLayerUpDown );
	}

	protected Vector4	m_LayerOrderingCaseSwizzle;
	protected bool		m_LayerOrderingInsideLayer;
	protected Vector4	m_LayerOrderingSwizzleExitUp0;
	protected Vector4	m_LayerOrderingSwizzleExitUp1;
	protected Vector4	m_LayerOrderingSwizzleExitUp2;
	protected Vector4	m_LayerOrderingSwizzleExitUp3;
	protected Vector4	m_LayerOrderingSwizzleEnterDown0;
	protected Vector4	m_LayerOrderingSwizzleEnterDown1;
	protected Vector4	m_LayerOrderingSwizzleEnterDown2;
	protected Vector4	m_LayerOrderingSwizzleEnterDown3;
	protected Vector4	m_LayerOrderingIsGodRaysLayerUp, m_LayerOrderingIsGodRaysLayerDown;
	protected Vector2	m_LayerOrderingIsGodRaysLayerUpDown;

	#endregion

	#region Light Cookie Management

	protected void	InitializeLightCookie()
	{
		DestroyLightCookie();

		if ( m_bCastShadowUsingLightCookie )
			m_RTLightCookie = Help.CreateRT( "Light Cookie", m_LightCookieTextureSize, m_LightCookieTextureSize, RenderTextureFormat.ARGB32, FilterMode.Bilinear, TextureWrapMode.Repeat );

		// Assign cookie to light
 		if ( m_Sun != null && m_Sun.light != null )
 			m_Sun.light.cookie = m_RTLightCookie;
	}

	protected void	DestroyLightCookie()
	{
		Help.SafeDestroy( ref m_RTLightCookie );
	}

	#endregion

	#region Lightning Bolts Management

	/// <summary>
	/// Updates global variables for lightning bolts
	/// </summary>
	protected void	UpdateLightningValues()
	{
		NuajLightningBolt	Bolt = null;
		if ( m_LightningBolt0 != null && m_LightningBolt0.activeSelf && (Bolt = m_LightningBolt0.GetComponent<NuajLightningBolt>()) != null && Bolt.enabled )
		{
			Matrix4x4	M = m_LightningBolt0.transform.localToWorldMatrix;
			NuajMaterial.SetGlobalVector( "_NuajLightningPosition00", m_WorldUnit2Kilometer * M.MultiplyPoint( Bolt.P0 ) );
			NuajMaterial.SetGlobalVector( "_NuajLightningPosition01", m_WorldUnit2Kilometer * M.MultiplyPoint( Bolt.P1 ) );
			NuajMaterial.SetGlobalVector( "_NuajLightningColor0", Bolt.ShaderColor );
		}
		else
		{
			NuajMaterial.SetGlobalVector( "_NuajLightningColor0", Vector3.zero );
		}

		if ( m_LightningBolt1 != null && m_LightningBolt1.activeSelf && (Bolt = m_LightningBolt1.GetComponent<NuajLightningBolt>()) != null && Bolt.enabled )
		{
			Matrix4x4	M = m_LightningBolt1.transform.localToWorldMatrix;
			NuajMaterial.SetGlobalVector( "_NuajLightningPosition10", m_WorldUnit2Kilometer * M.MultiplyPoint( Bolt.P0 ) );
			NuajMaterial.SetGlobalVector( "_NuajLightningPosition11", m_WorldUnit2Kilometer * M.MultiplyPoint( Bolt.P1 ) );
			NuajMaterial.SetGlobalVector( "_NuajLightningColor1", Bolt.ShaderColor );
		}
		else
		{
			NuajMaterial.SetGlobalVector( "_NuajLightningColor1", Vector3.zero );
		}
	}

	#endregion

	#region Helpers

	/// <summary>
	/// Clears a render target with a solid color
	/// </summary>
	/// <param name="_Target"></param>
	/// <param name="_SolidColor"></param>
	internal void	ClearTarget( RenderTexture _Target, Vector4 _SolidColor )
	{
		m_MaterialClearTexture.SetVector( "_ClearColor", _SolidColor );
		m_MaterialClearTexture.SetFloat( "_bUseSolidColor", 1 );
		m_MaterialClearTexture.Blit( null, _Target, 0 );
	}

	/// <summary>
	/// Clears a render target with a texture
	/// </summary>
	/// <param name="_Target"></param>
	/// <param name="_SourceTexture"></param>
	internal void	ClearTarget( RenderTexture _Target, NuajTexture2D _SourceTexture )
	{
		m_MaterialClearTexture.SetTexture( "_ClearTexture", _SourceTexture, true );
		m_MaterialClearTexture.SetFloat( "_bUseSolidColor", 0 );
		m_MaterialClearTexture.SetFloat( "_bInvertTextureAlpha", 0 );
		m_MaterialClearTexture.Blit( null, _Target, 0 );
	}

	/// <summary>
	/// Clears a scattering render target with 0 for scattering and 1 for extinction
	/// </summary>
	/// <param name="_Target"></param>
	internal void	ClearScatteringExtinction( RenderTexture _Target )
	{
		m_MaterialClearTexture.Blit( null, _Target, 1 );
	}

	/// <summary>
	/// Downsamples the Z-Buffer to the appropriate resolution
	/// NOTE: Asking for 2 Z-Buffers at the same downsample factor will trigger only 1 computation so it's advised to use the same scale factors whenever possible
	/// </summary>
	/// <param name="_DownsampleFactor">The downsample factor</param>
	/// <returns>The downsampled Z-Buffer</returns>
	internal RenderTexture	DownsampleZBuffer( float _DownsampleFactor )
	{
		if ( m_CachedDownsampledZBuffers.ContainsKey( _DownsampleFactor ) )
			return m_CachedDownsampledZBuffers[_DownsampleFactor];	// We already have one in store !

		// Trigger a new downsampling
		FilterMode	Filter = FilterMode.Point;	// We need point sampling to be coherent with the sky downsampled targets that MUST use point sampling, there's no alternative here !

		// Compute downsampled with & height
		int	FinalWidth = (int) Math.Floor( _DownsampleFactor * m_ScreenWidth );
			FinalWidth = Math.Max( 32, FinalWidth );

		int	FinalHeight = (int) Math.Floor( _DownsampleFactor * m_ScreenHeight );
			FinalHeight = Math.Max( 32, FinalHeight );

		// Create the final downsampled target
		RenderTexture	Result = Help.CreateTempRT( FinalWidth, FinalHeight, RenderTextureFormat.ARGBHalf, Filter, TextureWrapMode.Clamp );
		if ( Result == null )
			throw new Exception( "Received a NULL ZBuffer !" );
		m_CachedDownsampledZBuffers[_DownsampleFactor] = Result;

		// Downsample
		float	fPassesCount = -Mathf.Log( _DownsampleFactor ) / Mathf.Log( 2.0f );
		int		PassesCount = Mathf.FloorToInt( fPassesCount );

		int		SourceWidth = m_ScreenWidth;
		int		SourceHeight = m_ScreenHeight;

		RenderTexture	Source = null;
		fPassesCount--;
		for ( int PassIndex=0; PassIndex < PassesCount; PassIndex++, fPassesCount-- )
			if ( fPassesCount > 0.0f )	// This avoids EXACT factors of 2
			{
				int	TargetWidth = (SourceWidth+1) >> 1;
				int	TargetHeight = (SourceHeight+1) >> 1;
				RenderTexture	Target = Help.CreateTempRT( TargetWidth, TargetHeight, RenderTextureFormat.ARGBHalf, Filter, TextureWrapMode.Clamp );

				m_MaterialDownsampleZBuffer.SetVector( "_dUV", new Vector4( 1.0f / SourceWidth, 1.0f / SourceHeight, 0.0f, 0.0f ) );
				if ( Source == null )
					m_MaterialDownsampleZBuffer.Blit( null, Target, 0 );	// First pass...
				else
					m_MaterialDownsampleZBuffer.Blit( Source, Target, 1 );	// Standard passes...

				// Scroll source & target
				if ( Source != null )
					Help.ReleaseTemporary( Source );
				Source = Target;
				SourceWidth = TargetWidth;
				SourceHeight = TargetHeight;
			}

		// Final pass...
		m_MaterialDownsampleZBuffer.SetVector( "_dUV", new Vector4( 1.0f / SourceWidth, 1.0f / SourceHeight, 0.0f, 0.0f ) );
		if ( Source == null )
			m_MaterialDownsampleZBuffer.Blit( null, Result, 0 );
		else
		{
			m_MaterialDownsampleZBuffer.Blit( Source, Result, 1 );
			Help.ReleaseTemporary( Source );
		}

		return Result;
	}

	protected Dictionary<float,RenderTexture>	m_CachedDownsampledZBuffers = new Dictionary<float,RenderTexture>();

	/// <summary>
	/// Destroys an object if not already null, then nullifies the reference
	/// </summary>
	/// <typeparam name="T"></typeparam>
	/// <param name="_Object"></param>
	internal static void	SafeDestroy<T>( ref T _Object ) where T:UnityEngine.Object
	{
		if ( _Object == null )
			return;

		DestroyImmediate( _Object );
		_Object = null;
	}

	/// <summary>
	/// Destroys an object if not already null, then nullifies the reference
	/// </summary>
	/// <typeparam name="T"></typeparam>
	/// <param name="_Object"></param>
	internal static void	SafeDestroyNuaj<T>( ref T _Object ) where T:class,IDisposable
	{
		if ( _Object == null )
			return;

		_Object.Dispose();
		_Object = null;
	}

	/// <summary>
	/// Performs rendering of a 1x1 value to a CPU-readable target
	/// </summary>
	/// <param name="_Source">The source texture to render</param>
	/// <param name="_ValueIndex">The index of the value to write in [0,3] (the target supports at most 4 readable pixels)</param>
	/// <param name="_Material">The material to use for rendering</param>
	/// <param name="_PassIndex">The index of the pass for rendering</param>
	internal void			RenderToCPU( Texture _Source, int _ValueIndex, NuajMaterial _Material, int _PassIndex )
	{
#if USE_CPU_READBACK_TRIPLE_BUFFER
		RenderTexture.active = m_GPU2CPURenderTextures[2];	// Render in the last buffer that will be read back 2 frames from now
#else
		RenderTexture.active = m_GPU2CPURenderTextures[0];	// Render in the first buffer that will be read back at the end of this frame
#endif
 		_Material.SetTextureRAW( "_MainTex", _Source );
 		_Material.SetPass( _PassIndex );

		// Render a single pixel at the specified X coordinate within the render texture
		GL.PushMatrix();
		GL.LoadPixelMatrix();
		GL.Viewport( new Rect( _ValueIndex, 0, 1, 1 ) );

		GL.Begin( GL.QUADS );
		// Here, I had to make sure we draw a huuuuge quad otherwise it misses pixels on ATI !
		GL.Vertex3(0, 0, 0);
		GL.Vertex3(0, 1000, 0);
		GL.Vertex3(1000, 1000, 0);
		GL.Vertex3(1000, 0, 0);
		GL.End();

		GL.PopMatrix();

		RenderTexture.active = null;
		m_WrittenCPUDataCount++;
	}

	/// <summary>
	/// Reads back a GPU data
	/// </summary>
	/// <param name="_ValueIndex">The index of the value to read back in [0,3]</param>
	/// <returns></returns>
	internal Color			CPUReadBack( int _ValueIndex )
	{
		return m_CPUReadBack != null && m_CPUReadBack.Length > _ValueIndex ? m_CPUReadBack[_ValueIndex] : Color.black;
	}

	#region Error/Warning States

	/// <summary>
	/// Enters error mode. The module is then disabled and can't render anymore
	/// </summary>
	/// <param name="_Error"></param>
	protected void			EnterErrorState( string _Error )
	{
		if ( m_bInErrorState )
			return;	// Already in error state !

		m_bInErrorState = true;
		m_Error = _Error;

		Nuaj.Help.LogWarning( "Nuaj' Manager cannot work as it entered error state with :\r\n" + _Error );

		// Notify
		if ( ErrorStateChanged != null )
			ErrorStateChanged( this, EventArgs.Empty );
	}

	/// <summary>
	/// Exits error mode. The module is then enabled again
	/// </summary>
	protected void			ExitErrorState()
	{
		if ( !m_bInErrorState )
			return;	// Not in error state !

		m_bInErrorState = false;

		// Notify
		if ( ErrorStateChanged != null )
			ErrorStateChanged( this, EventArgs.Empty );
	}

	/// <summary>
	/// Enters warning mode. The module is still enabled but may not render properly
	/// </summary>
	/// <param name="_Warning"></param>
	protected void			EnterWarningState( string _Warning )
	{
		if ( m_bInErrorState )
			return;	// Already in warning state !

		m_bInWarningState = true;
		m_Warning = _Warning;

		Nuaj.Help.LogWarning( "Nuaj' Manager cannot work as it entered error state with :\r\n" + _Warning );

		// Notify
		if ( WarningStateChanged != null )
			WarningStateChanged( this, EventArgs.Empty );
	}

	/// <summary>
	/// Exits warning mode. The module should render properly again
	/// </summary>
	protected void			ExitWarningState()
	{
		if ( !m_bInWarningState )
			return;	// Not in warning state !

		m_bInWarningState = false;

		// Notify
		if ( WarningStateChanged != null )
			WarningStateChanged( this, EventArgs.Empty );
	}

	#endregion

	/// <summary>
	/// Updates all the cached values
	/// </summary>
	protected void	UpdateCachedValues()
	{
		m_ImageScaler.AverageOrMax = m_LuminanceAverageOrMax;
		m_ImageLuminance = 1.0f;
		m_PreviousFrameLuminance = m_CurrentAdaptationLuminance = Vector3.one;

		UpdateCameraCachedValues();
		UpdateLightingCachedValues();
		UpdatePlanetCachedValues();
	}

	/// <summary>
	/// Update cached values
	/// </summary>
	protected void	UpdateCameraCachedValues()
	{
		NuajMaterial.SetGlobalVector( "_CameraData", m_CameraData );
		NuajMaterial.SetGlobalMatrix( "_Camera2WorldKm", m_Camera2WorldKm );
		NuajMaterial.SetGlobalMatrix( "_World2CameraKm", m_World2CameraKm );
	}

	/// <summary>
	/// Update cached values
	/// </summary>
	protected void	UpdateLightingCachedValues()
	{
		m_SunColor = m_SunIntensity * new Vector3( m_SunHue.r, m_SunHue.g, m_SunHue.b );

		// Check if it's day or night based on Sun's elevation above the horizon
		float	CosSunsetStart = Mathf.Cos( Mathf.Deg2Rad * m_SunsetAngleStart );
		float	CosSunsetEnd = Mathf.Cos( Mathf.Deg2Rad * m_SunsetAngleEnd );
		float	CosSun = Vector3.Dot( SunDirection, m_PlanetNormal );

		m_SmoothDayNight = Help.SmoothStep( CosSunsetStart, CosSunsetEnd, CosSun );

		// Build actual light source based on day/night time
		Vector3	LightSourceColor;
		float	LightSourceIntensity;
		if (  CosSun < CosSunsetEnd && m_bUseMoonAtNight )
		{	// Use the Moon as main light source
			m_LightSourceDirection = m_MoonDirection;
			LightSourceColor = m_MoonColor;
			LightSourceIntensity = m_MoonIntensity;
		}
		else
		{	// Use the Sun as main light source
			m_LightSourceDirection = m_SunDirection;
			LightSourceColor = m_SunColor;
			LightSourceIntensity = m_SunIntensity;
		}

		// Setup global shader values
		NuajMaterial.SetGlobalVector( "_SunColor", LightSourceColor );	// This is the _untainted_ Sun color for computations (not affected by atmosphere)
		NuajMaterial.SetGlobalFloat( "_SunLuminance", LightSourceIntensity );
		NuajMaterial.SetGlobalVector( "_SunDirection", m_LightSourceDirection );
		NuajMaterial.SetGlobalVector( "_AmbientNightSky", m_AmbientNightSky );
	}

	/// <summary>
	/// Update cached values
	/// </summary>
	protected void	UpdatePlanetCachedValues()
	{
		// Rebuild planet tangent space
		m_PlanetBiTangent = Vector3.Cross(	Vector3.right,	// TODO : choose an appropriate tangent space
											m_PlanetNormal ).normalized;
		m_PlanetTangent = Vector3.Cross( m_PlanetNormal, m_PlanetBiTangent );

		m_Kilometer2WorldUnit = 1.0f / m_WorldUnit2Kilometer;

		// Setup global shader values
		NuajMaterial.SetGlobalVector( "_PlanetCenterKm", m_PlanetCenterKm );
		NuajMaterial.SetGlobalVector( "_PlanetNormal", m_PlanetNormal );
		NuajMaterial.SetGlobalVector( "_PlanetTangent", m_PlanetTangent );
		NuajMaterial.SetGlobalVector( "_PlanetBiTangent", m_PlanetBiTangent );
		NuajMaterial.SetGlobalFloat( "_PlanetRadiusKm", m_PlanetRadiusKm );
		NuajMaterial.SetGlobalFloat( "_PlanetRadiusOffsetKm", m_PlanetRadiusOffsetKm );
		NuajMaterial.SetGlobalFloat( "_PlanetAtmosphereAltitudeKm", m_PlanetAtmosphereAltitudeKm );
		NuajMaterial.SetGlobalFloat( "_PlanetAtmosphereRadiusKm", m_PlanetRadiusKm + m_PlanetAtmosphereAltitudeKm );
		NuajMaterial.SetGlobalFloat( "_WorldUnit2Kilometer", m_WorldUnit2Kilometer );
		NuajMaterial.SetGlobalFloat( "_Kilometer2WorldUnit", m_Kilometer2WorldUnit );
	}

	/// <summary>
	/// Updates global variables for local variations
	/// </summary>
	protected void	UpdateLocalVariationsValues()
	{
		// Grab local coverage value
		Vector4			LocalCoverageOffset, LocalCoverageFactor;
		Matrix4x4		World2LocalCoverage;
		NuajTexture2D	LocalCoverageTexture = null;
		NuajMapLocator	Locator = null;
		if ( m_LocalCoverage != null && m_LocalCoverage.gameObject.activeSelf && (Locator = m_LocalCoverage.GetComponent<NuajMapLocator>()) != null )
		{
			LocalCoverageOffset = Locator.Offset;
			LocalCoverageFactor = Locator.Factor;
			LocalCoverageTexture = m_LocalCoverageTexture;
			m_LocalCoverageTexture.Texture = Locator.Texture;
			World2LocalCoverage = Locator.transform.worldToLocalMatrix;
		}
		else
		{	// No locator...
			LocalCoverageOffset = Vector4.zero;
			LocalCoverageFactor = Vector4.one;
			LocalCoverageTexture = m_TextureWhite;
			World2LocalCoverage = Matrix4x4.identity;
		}

		NuajMaterial.SetGlobalVector( "_NuajLocalCoverageOffset", LocalCoverageOffset );
		NuajMaterial.SetGlobalVector( "_NuajLocalCoverageFactor", LocalCoverageFactor );
		NuajMaterial.SetGlobalTexture( "_NuajLocalCoverageTexture", LocalCoverageTexture, false );
		NuajMaterial.SetGlobalMatrix( "_NuajLocalCoverageTransform", World2LocalCoverage );

		// Grab terrain emissive value
		Vector4			TerrainEmissiveOffset, TerrainEmissiveFactor;
		Matrix4x4		World2TerrainEmissive;
		NuajTexture2D	TerrainEmissiveTexture = null;
		Locator = null;
		if ( m_TerrainEmissive != null && m_TerrainEmissive.gameObject.activeSelf && (Locator = m_TerrainEmissive.GetComponent<NuajMapLocator>()) != null )
		{
			TerrainEmissiveOffset = Locator.Offset;
			TerrainEmissiveFactor = Locator.Factor;
			TerrainEmissiveTexture = m_TerrainEmissiveTexture;
			m_TerrainEmissiveTexture.Texture = Locator.Texture;
			World2TerrainEmissive = Locator.transform.worldToLocalMatrix;
		}
		else
		{	// No locator...
			TerrainEmissiveOffset = Vector4.zero;
			TerrainEmissiveFactor = Vector4.one;
			TerrainEmissiveTexture = m_TextureEmptyCloud;	// We need alpha=1 for full terrain albedo here...
			World2TerrainEmissive = Matrix4x4.identity;
		}

		NuajMaterial.SetGlobalVector( "_NuajTerrainEmissiveOffset", TerrainEmissiveOffset );
		NuajMaterial.SetGlobalVector( "_NuajTerrainEmissiveFactor", TerrainEmissiveFactor );
		NuajMaterial.SetGlobalTexture( "_NuajTerrainEmissiveTexture", TerrainEmissiveTexture, false );
		NuajMaterial.SetGlobalMatrix( "_NuajTerrainEmissiveTransform", World2TerrainEmissive );
	}

	void		OnDrawGizmos()
	{
		Help.DrawIcon( transform.position, "Nuaj Icon" );
	}

	#endregion

	#region IComparer<ICloudLayer> Members

	/// <summary>
	/// Compares the altitude of 2 clouds layers for sorting
	/// </summary>
	/// <param name="x"></param>
	/// <param name="y"></param>
	/// <returns></returns>
	public int Compare( ICloudLayer x, ICloudLayer y )
	{
		if ( x.Altitude < y.Altitude )
			return -1;
		else if ( x.Altitude > y.Altitude )
			return 1;
		else
			return 0;
	}

	#endregion

	#endregion

	#region EVENT HANDLERS

	protected void	ModulePerspective_SkyParametersChanged( object sender, EventArgs e )
	{
		UpdateLightingCachedValues();
	}

	#endregion
}
