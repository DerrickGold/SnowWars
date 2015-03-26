/****************************************************************************************************
 * Primary Contributor: Jaymeson Wickins
 * 
 * Description: This script is used to make point lights glow.
 *              PLEASE ADD ONTO THIS DESCRIPTION.
 ****************************************************************************************************/

using UnityEngine;
using System.Collections;

public class PointLightGlow : MonoBehaviour {
	private Light pointLight;
	public float GLOW_SPEED = 3f; //How fast the light goes through a cycle
	public float TIME_DELAY = 0f;


	/****************************************************************************************************
     * Description: Used to initialized required variables.                                             *
     * Syntax: ---                                                                                      *
     ****************************************************************************************************/
	void Start () {
		pointLight = gameObject.GetComponent<Light> ();
	}
	

	/****************************************************************************************************
     * Description: ADD BREIF DESCRIPTION ABOUT WHAT UPDATE() IS USED FOR.                              *
     * Syntax: ---                                                                                      *
     ****************************************************************************************************/
	void Update () {
		if (Time.time > TIME_DELAY) {
			//SIN values range from -1 to 1 as time goes on
			float t = Mathf.Sin (GLOW_SPEED * Time.time); 
			pointLight.intensity = 1.5f + t; //Intensity varies from 0.5 to 2.5
		}
	}
}
