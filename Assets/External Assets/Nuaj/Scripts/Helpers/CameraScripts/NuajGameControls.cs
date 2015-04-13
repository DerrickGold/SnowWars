using UnityEngine;
using System.Collections;

/// <summary>
/// This little example class shows runtime GUI to access and modify the NuajOrchestrator's parameters
/// Usage: Drop it on your camera, press PLAY, tweak GUI
/// </summary>
public class NuajGameControls : MonoBehaviour
{
	protected static readonly float	STANDARD_HEIGHT = 20.0f;
	protected static readonly float	STANDARD_INDENTATION = 10.0f;

	NuajManager			Manager = null;
	NuajOrchestrator	Orch = null;

	float				X = 0;
	float				Y = 0;
	bool				ShowControls = false;
	bool				AdvancedMode = false;
	bool				m_bUsingGUI = false;

	ComboBox			SourcePreset = new ComboBox();
	ComboBox			TargetPreset = new ComboBox();
	GUIContent[]		ComboBoxContents = null;

	/// <summary>
	/// Returns true if we're using the GUI, so we can prevent any other mouse hook
	/// </summary>
	public bool		IsUsingGUI		{ get { return m_bUsingGUI; } }

	void	OnEnable()
	{
		// Human-Readable version
		string[]	EnumNames = new string[]
		{
			"CLEAR",					// Clear blue sky
			"MISTY",					// Slightly foggy
			"FOGGY",					// Thick fog
			"VALLEY MIST",				// Low dense fog
			"CLOUDY",					// Cloudy but no rain
			"ALTITUDE",					// High altitude wispy cirrus clouds
			"SHEEPS",					// Cute little cumulus clouds
			"SNOWY",					// Thick layer of low altitude grey clouds
			"RAIN",						// Dark clouds with a little rain
			"GLAMOUR",					// Glamour
			"STORMY",					// Storm is coming
			"STORM",					// Violent storm
		};

		ComboBoxContents = new GUIContent[EnumNames.Length];
		for ( int NameIndex=0; NameIndex < EnumNames.Length; NameIndex++ )
			ComboBoxContents[NameIndex] = new GUIContent( EnumNames[NameIndex] );
	}

	public Texture2D	m_Watermark = null;

	void	OnGUI()
	{
		m_bUsingGUI = false;
		if ( Manager == null )
		{	// Get the manager first...
			Manager = FindObjectOfType( typeof(NuajManager) ) as NuajManager;
			if ( Manager == null )
				return;
		}

		// Retrieve the orchestrators
		if ( Orch == null )
			Orch = FindObjectOfType( typeof(NuajOrchestrator) ) as NuajOrchestrator;
		bool	bCanShowSimpleMode = Orch != null;

		// Watermark
		if ( m_Watermark )
			GUI.Label( new Rect( Screen.width - 0.0f - m_Watermark.width, Screen.height - 4.0f - m_Watermark.height, m_Watermark.width, m_Watermark.height ), new GUIContent( m_Watermark ) );

		// Display
		X = Y = 0.0f;

		Label( "Arrow Keys + Space : Move", 250.0f );
		Label( "Left Mouse : Look", 200.0f );

		if ( !(ShowControls = CheckBox( "Show Controls", ShowControls )) )
			return;

		PreviousY();	// Come back
		if ( bCanShowSimpleMode && GUI.Button( new Rect( X + 120.0f, NextY(), 120.0f, STANDARD_HEIGHT ), AdvancedMode ? "Simple" : "Advanced" ) )
			AdvancedMode = !AdvancedMode;

		Indent();

		Separate( 4 );

		if ( Orch != null && !AdvancedMode )
		{	// ==== SIMPLE CONTROLS ====
			// Simple Day/Night
			Orch.TimeOfDay = Slider( "Time of Day", Orch.TimeOfDay, 0.0f, 24.0f );
			Orch.DensityMultiplierAtNight = Slider( "Sunset Drama", Orch.DensityMultiplierAtNight, 0.0f, 8.0f );

			// Weather interpolant
			GUI.Label( new Rect( X, Y, 100.0f, STANDARD_HEIGHT ), "Source Weather" );
			GUI.Label( new Rect( X + 300.0f, Y, 100.0f, STANDARD_HEIGHT ), "Target Weather" );
			NextY();
			Orch.WeatherTypeSource = (NuajOrchestrator.WEATHER_PRESETS) SourcePreset.List( new Rect( X, Y, 100.0f, STANDARD_HEIGHT ), (int) Orch.WeatherTypeSource, ComboBoxContents, GUIStyle.none );
			Orch.WeatherBalance = HorizontalSlider( new Rect( X + 100.0f, Y + 4, 200.0f, STANDARD_HEIGHT-8.0f ), Orch.WeatherBalance, 0.0f, 1.0f );
			Orch.WeatherTypeTarget = (NuajOrchestrator.WEATHER_PRESETS) TargetPreset.List( new Rect( X + 300.0f, Y, 100.0f, STANDARD_HEIGHT ), (int) Orch.WeatherTypeTarget, ComboBoxContents, GUIStyle.none );
			NextY();
			Orch.WindForce = Slider( "Wind", Orch.WindForce, 0.0f, 0.2f );
		}
		else
		{	// ==== ADVANCED CONTROLS ====
			NextY();
			// Sun
			Manager.SunElevation = Slider( "Sun Elevation", Manager.SunElevation, 0.0f, 180.0f, Mathf.Rad2Deg );
			Manager.SunAzimuth = Slider( "Sun Azimuth", Manager.SunAzimuth, -180.0f, 180.0f, Mathf.Rad2Deg );
			Manager.ModuleSky.DensityRayleigh = Slider( "Air Density", Manager.ModuleSky.DensityRayleigh, 0.0f, 100.0f, 1e5f );
			Manager.ModuleSky.DensityMie = Slider( "Fog", Manager.ModuleSky.DensityMie, 0.0f, 500.0f, 1e4f );

			Separate();

			// Clouds
			if ( Manager.ModuleCloudVolume.CloudLayersCount > 0 )
			{
				Nuaj.ModuleCloudVolume.CloudLayer	L0 = Manager.ModuleCloudVolume.CloudLayers[0] as Nuaj.ModuleCloudVolume.CloudLayer;
				Label( "Layer 0", 100.0f );
				Indent();
				L0.CoverageOffset = Slider( "Coverage", L0.CoverageOffset, -1.0f, 1.0f );
				L0.Density = Slider( "Density", L0.Density, 0.0f, 1.0f, 0.1f );
				L0.WindForce = Slider( "Wind", L0.WindForce, 0.0f, 0.5f );
				if ( L0.Thickness < 1.0f )
					L0.Thickness = 1.0f;	// So we can always tweak something...
				UnIndent();
			}

			if ( Manager.ModuleCloudLayer.CloudLayersCount > 0 )
			{
				Nuaj.ModuleCloudLayer.CloudLayer	L1 = Manager.ModuleCloudLayer.CloudLayers[0] as Nuaj.ModuleCloudLayer.CloudLayer;
				Label( "Layer 1", 100.0f );
				Indent();
				L1.Coverage = Slider( "Coverage", L1.Coverage, -1.0f, 1.0f );
				L1.Density = Slider( "Density", L1.Density, 0.0f, 1.0f, 4.0f );
				L1.WindForce = Slider( "Wind", L1.WindForce, 0.0f, 1.0f );
				UnIndent();
			}
		}

		Manager.ToneMappingGamma = Slider( "Gamma", Manager.ToneMappingGamma, 0.0f, 4.0f );

		UnIndent();
	}

	float	NextY()
	{
		float	Result = Y;
		Y += STANDARD_HEIGHT;
		return Result;
	}

	float	PreviousY()
	{
		return Y -= STANDARD_HEIGHT;
	}

	void	Label( string _Text, float _Width )
	{
		GUI.Label( new Rect( X, NextY(), _Width, STANDARD_HEIGHT ), _Text );
	}

	float	Slider( string _Label, float _Value, float _Min, float _Max )
	{
		return Slider( _Label, _Value, _Min, _Max, 1.0f );
	}

	float	Slider( string _Label, float _Value, float _Min, float _Max, float _ScaleFactor )
	{
		float	Y = NextY();
		GUI.Label( new Rect( X, Y, 100.0f, STANDARD_HEIGHT ), _Label );

		return HorizontalSlider( new Rect( X + 100.0f, Y + 4, 200.0f, STANDARD_HEIGHT-8.0f ), _ScaleFactor * _Value, _Min, _Max ) / _ScaleFactor;
	}

	float	HorizontalSlider( Rect _Rect, float _Value, float _Min, float _Max )
	{
		GUI.changed = false;
		float	Result = GUI.HorizontalSlider( _Rect, _Value, _Min, _Max );

		m_bUsingGUI |= GUI.changed;

		return Result;
	}

	bool	CheckBox( string _Label, bool _Value )
	{
		return GUI.Toggle( new Rect( X, NextY(), 120.0f, STANDARD_HEIGHT ), _Value, _Label );
	}

	bool	CheckBoxButton( string _Label )
	{
		return GUI.Button( new Rect( X, NextY(), 120.0f, STANDARD_HEIGHT ), _Label );
	}

	void	Separate()
	{
		Separate( STANDARD_HEIGHT );
	}

	void	Separate( float _Value )
	{
		Y+= _Value;
	}

	void	Indent()
	{
		X += STANDARD_INDENTATION;
	}

	void	UnIndent()
	{
		X -= STANDARD_INDENTATION;
	}

	#region ComboBox

	/// <summary>
	/// From http://www.unifycommunity.com/wiki/index.php?title=PopupList#C.23_-_ComboBox_-_Update
	/// </summary>
	public class ComboBox
	{
		private static bool forceToUnShow = false; 
		private static int useControlID = -1;
		private bool isClickedComboButton = false;  

		public int selectedItemIndex = 0;

		public int List( Rect rect, int _index, GUIContent[] listContent, GUIStyle listStyle )
		{
			selectedItemIndex = _index;
			return List( rect, listContent[selectedItemIndex], listContent, "button", "box", listStyle);
		}

		public int List( Rect rect, GUIContent buttonContent, GUIContent[] listContent, GUIStyle buttonStyle, GUIStyle boxStyle, GUIStyle listStyle )
		{
			if( forceToUnShow )
			{
				forceToUnShow = false;
				isClickedComboButton = false;         
			}

			bool done = false;
			int controlID = GUIUtility.GetControlID( FocusType.Passive );    

			switch( Event.current.GetTypeForControl(controlID) )
			{
				case EventType.mouseUp:
				{
					if( isClickedComboButton )
					{
						done = true;
					}
				}
				break;
			}      

			if( GUI.Button( rect, buttonContent, buttonStyle ) )
			{
				if( useControlID == -1 )
				{
					useControlID = controlID;
					isClickedComboButton = false;
				}

				if( useControlID != controlID )
				{
					forceToUnShow = true;
					useControlID = controlID;
				}
				isClickedComboButton = true;
			}
        
			if( isClickedComboButton )
			{
				Rect listRect = new Rect( rect.x, rect.y + buttonStyle.CalcHeight(listContent[0], 1.0f), rect.width, listStyle.CalcHeight(listContent[0], 1.0f) * listContent.Length );

				GUI.Box( listRect, "", boxStyle );
				int newSelectedItemIndex = GUI.SelectionGrid( listRect, selectedItemIndex, listContent, 1, listStyle );
				if( newSelectedItemIndex != selectedItemIndex )
					selectedItemIndex = newSelectedItemIndex;
			}

			if( done )
				isClickedComboButton = false;

			return selectedItemIndex;
		}
	}
 
	#endregion
}
