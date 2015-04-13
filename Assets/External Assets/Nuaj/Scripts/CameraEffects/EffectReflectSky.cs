using System;
using System.Collections;
using UnityEngine;
using Nuaj;

/// <summary>
/// This camera effect initializes the reflection camera with the reflected sky
/// </summary>
[ExecuteInEditMode]
[RequireComponent( typeof(Camera) )]
public class	EffectReflectSky : MonoBehaviour
{
	#region FIELDS

	public Camera				m_CameraAbove = null;
	public GameObject			m_WaterObject = null;
	public float				m_DummyCloudHeightKm = 2.0f;

	protected NuajManager		m_Manager = null;
	protected NuajMaterial		m_MaterialComposeReflection = null;

	#endregion

	#region PROPERTIES

	public NuajManager		Manager
	{
		get
		{
			if ( m_Manager == null )
				m_Manager = FindObjectOfType( typeof(NuajManager) ) as NuajManager;
			return m_Manager;
		}
	}

	#endregion

	#region METHODS

	void	OnEnable()
	{
		try
		{
			m_MaterialComposeReflection = Help.CreateMaterial( "ComposeReflection" );
		}
		catch ( System.Exception _e )
		{
			Help.LogError( "An error occurred while creating the Sky Reflection shader : " + _e.Message );
		}
	}

	void	OnDisable()
	{
		Help.SafeDestroyNuaj( ref m_MaterialComposeReflection );
	}

	/// <summary>
	/// Post-process the camera's render texture with our sky reflection
	/// </summary>
	void	OnRenderImage( RenderTexture _Source, RenderTexture _Destination )
	{
		if ( Manager == null || m_MaterialComposeReflection == null )
			return;
		if ( camera.targetTexture == null )
			return;	// The reflection camera should have a render texture so we can clear it !

		if ( m_CameraAbove != null )
		{
			float	TanFOV = Mathf.Tan( 0.5f * Mathf.Deg2Rad * m_CameraAbove.fieldOfView );
			m_MaterialComposeReflection.SetMatrix( "_Camera2World", m_CameraAbove.cameraToWorldMatrix );
			m_MaterialComposeReflection.SetMatrix( "_World2Camera", m_CameraAbove.worldToCameraMatrix );
			m_MaterialComposeReflection.SetVector( "_CameraData", new Vector4( m_CameraAbove.aspect * TanFOV, TanFOV, m_CameraAbove.nearClipPlane, m_CameraAbove.farClipPlane ) );
		}

		float	TanFOVMirror = Mathf.Tan( 0.5f * Mathf.Deg2Rad * camera.fieldOfView );
		m_MaterialComposeReflection.SetMatrix( "_BelowCamera2World", camera.cameraToWorldMatrix );
		m_MaterialComposeReflection.SetVector( "_BelowCameraData", new Vector4( camera.aspect * TanFOVMirror, TanFOVMirror, camera.nearClipPlane, camera.farClipPlane ) );

		if ( m_WaterObject != null )
			m_MaterialComposeReflection.SetMatrix( "_Water2World", m_WaterObject.transform.localToWorldMatrix );

		m_MaterialComposeReflection.SetVector( "_BackgroundColorKey", camera.backgroundColor );	// Feed the camera's clear color as a color key for the shader so we know where to apply clouds
		m_MaterialComposeReflection.SetFloat( "_DummyCloudHeightKm", m_DummyCloudHeightKm );	// Feed the dummy cloud reflection altitude

		m_MaterialComposeReflection.SetTexture( "_TexScattering", m_Manager.TextureScattering );
		m_MaterialComposeReflection.Blit( _Source, _Destination, 0 );
	}

	#endregion
}