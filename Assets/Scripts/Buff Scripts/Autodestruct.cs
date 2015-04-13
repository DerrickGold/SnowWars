/****************************************************************************************************
 * Primary Contributor: Jaymeson Wickins                                                            *
 *                                                                                                  *
 * Description: This script insures that spawn point effects are not destroyed at the beginning of  *
 *              the game. This script is only used on spawn location effects.                       *
 ****************************************************************************************************/

using UnityEngine;
using System.Collections;

public class Autodestruct : MonoBehaviour
{
    /****************************************************************************************************
     * Description: Called once. Find the grandchildren of the gameobject and autodestruct on all of    *
     *              their particle animators.                                                           *
     * Syntax: ---                                                                                      *
     ****************************************************************************************************/
	void Start ()
    {
		for (int i =0; i < transform.childCount; i++)
        {
			Transform child = transform.GetChild(i);
			for(int j = 0; j <= transform.childCount; j++)
            {
				ParticleAnimator particle = child.transform.GetChild(j).GetComponent<ParticleAnimator>();
				particle.autodestruct = false;
			}
		}
	}
}
