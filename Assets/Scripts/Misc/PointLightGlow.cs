/****************************************************************************************************
 * Primary Contributor: Jaymeson Wickins                                                            *
 *                                                                                                  *
 * Description: This script is used to make the lights on the crystals glow in the level one cave.  * 
 ****************************************************************************************************/

using UnityEngine;
using System.Collections;

public class PointLightGlow : MonoBehaviour
{
    private Light pointLight;
    
    //How fast the light goes through a cycle
	public float GLOW_SPEED = 3f;
	public float TIME_DELAY = 0f;


	/****************************************************************************************************
     * Description: Used to initialized required variables.                                             *
     * Syntax: ---                                                                                      *
     ****************************************************************************************************/
	void Start ()
    {
		pointLight = gameObject.GetComponent<Light> ();
	}
	

	/****************************************************************************************************
     * Description: Used for changing the intensity of the light.                                       *
     * Syntax: ---                                                                                      *
     ****************************************************************************************************/
	void Update ()
    {
		if (Time.time > TIME_DELAY)
        {
			//SIN values range from -1 to 1 as time goes on
			float t = Mathf.Sin (GLOW_SPEED * Time.time);
            //Intensity varies from 0.5 to 2.5
			pointLight.intensity = 1.5f + t;
		}
	}
}
