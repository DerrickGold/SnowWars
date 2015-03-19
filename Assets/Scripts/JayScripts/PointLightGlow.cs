using UnityEngine;
using System.Collections;

/* Script made by Jay 
 * 
 *  Simple script used to make point lights glow
 */

public class PointLightGlow : MonoBehaviour {

	private Light pointLight;
	public float GLOW_SPEED = 3f; //how fast the light goes through a cycle

	// Use this for initialization
	void Start () {
		pointLight = gameObject.GetComponent<Light> ();
	}
	
	// Update is called once per frame
	void Update () {
		//sin values range from -1 to 1 as time goes on
		float t = Mathf.Sin (GLOW_SPEED*Time.time); 
		pointLight.intensity = 1.5f + t; //intensity varies from 0.5 to 2.5
	}
}
