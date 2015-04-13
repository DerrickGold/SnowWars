using System;
using System.Collections;
using UnityEngine;

/// <summary>
/// This is the main Nuaj' camera effect that composes the rendered atmospheric effects together
/// </summary>
[ExecuteInEditMode]
[RequireComponent( typeof(Camera) )]
public class	EffectComposeAtmosphere : MonoBehaviour
{
	#region FIELDS

	protected NuajManager		m_Owner = null;
	protected RenderTexture		m_Target = null;

	#endregion

	#region PROPERTIES

	public NuajManager		Owner	{ get { return m_Owner; } internal set { m_Owner = value; } }

	/// <summary>
	/// Gets or sets an optional target to render to
	/// This is useful when rendering to a cube map
	/// </summary>
	public RenderTexture	Target	{ get { return m_Target; } set { m_Target = value; } }

	#endregion

	#region METHODS

	void	OnEnable()
	{
		// Make the camera render depth (should be already the case with a deferred pipeline)
		camera.depthTextureMode |= DepthTextureMode.Depth;
	}

	void	OnDisable()
	{
		// Destroy render targets
	}

	static int	ms_Counter = 0;
	void	OnPreCull()
	{
		if ( m_Owner == null )
		{
			Nuaj.Help.LogError( "EffectComposeAtmosphere has an invalid owner !" );
			return;
		}

		// Notify the owner to recreate all pertinent render targets
		m_Owner.InitializeTargets( Screen.width, Screen.height );
	}

	// This is the correct way to render clouds :
	//	1] We render the shadow maps, cookie, and environment map in OnPreRender() so Unity can use them to render the main scene
	//	2] We let Unity render the main scene normally
	//	3] We render the clouds using the scene's ZBuffer and compose the rendered scene with the clouds as a post-process in OnRenderImage()

	/// <summary>
	/// Performs the atmosphere pre-rendering (i.e. shadows & envmap)
	/// </summary>
	void	OnPreRender()
	{
		if ( !enabled )
			return;
		if ( m_Owner == null )
		{
			Nuaj.Help.LogError( "EffectComposeAtmosphere has an invalid owner !" );
			return;
		}
		if ( !m_Owner.enabled || !m_Owner.gameObject.activeSelf )
			return;	// Don't render anything

		// Compute camera data
		float	TanHalfFOV = Mathf.Tan( 0.5f * camera.fieldOfView * Mathf.PI / 180.0f );
		Vector4	CameraData = new Vector4( camera.aspect * TanHalfFOV, TanHalfFOV, camera.nearClipPlane, camera.farClipPlane );

		// Render clouds, sky, atmosphere, etc.
		RenderTexture	OldRT = RenderTexture.active;

		m_Owner.PreRender( CameraData, camera.cameraToWorldMatrix, camera.worldToCameraMatrix );

		// Prevent Unity bug !!!
		// http://answers.unity3d.com/questions/173210/unwanted-render-texture-clear.html
		RenderTexture.active = OldRT;
	}

	/// <summary>
	/// Applies post-processing to the scene (i.e. composes the atmosphere with the scene and tone maps the result)
	/// </summary>
	/// <param name="_Source"></param>
	/// <param name="_Destination"></param>
	public void	OnRenderImage( RenderTexture _Source, RenderTexture _Destination )
	{
		if ( !enabled )
			return;
		if ( m_Owner == null )
		{
			Nuaj.Help.LogError( "EffectComposeAtmosphere has an invalid owner !" );
			return;
		}
		if ( !m_Owner.enabled || !m_Owner.gameObject.activeSelf )
		{	// Don't render anything
			Graphics.Blit( _Source, null as RenderTexture );
			return;
		}

		// Render clouds & sky
		m_Owner.MainRender();

		// Compose and Tone-map
		m_Owner.PostProcess( _Source, m_Target != null ? m_Target : _Destination );
		
		// Clear stuff...
		m_Owner.EndFrame();
		
		// Frame counter
		ms_Counter++;
	}

	#endregion
}
