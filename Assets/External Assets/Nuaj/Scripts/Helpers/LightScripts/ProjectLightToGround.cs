using UnityEngine;
using System.Collections;

/// <summary>
/// This is a very useful script that you should assign to your directional Sun light
/// It will attempt to move the light's position to a path in front of the camera exactly half the cookie size units away as shown on the figure below:
/// 
///  C
///  .---------------X---------------> Camera Forward Vector
///  |               ^
///  +-------D-------+
///	                 |
///           New light position
/// 
/// D = Half the cookie size
/// 
/// This helps to maximize the shadow zone represented by the cookie
/// </summary>
[ExecuteInEditMode]
public class ProjectLightToGround : MonoBehaviour
{
	protected NuajManager	m_Manager = null;

	void		Update()
	{
		if ( !enabled )
			return;

		// Get the manager first...
		if ( m_Manager == null )
			m_Manager = FindObjectOfType( typeof(NuajManager) ) as NuajManager;
		if ( m_Manager == null )
			return;	// No manager
		if ( m_Manager.Camera == null )
			return;	// No camera attached...

		Transform	T = m_Manager.Camera.transform;
		Vector3		Position = T.position;
		Vector3		View = T.forward;
		Position += 0.5f * m_Manager.LightCookieSize * View;	// Place it in front of the camera

		// Simply project camera position to the specified altitude
		if ( !m_Manager.LightCookieSampleAtCameraAltitude )
			Position.y = m_Manager.LightCookieSampleAltitudeKm / m_Manager.WorldUnit2Kilometer;

		transform.position = Position;

		// TODO: project position using view ray hitting the ground, then update cookie size on light and in Nuaj, based on distance
		// CANTDO: because of the fu..ing Unity bug that prevents us from changing the cookie size by script !!!!
	}
}
