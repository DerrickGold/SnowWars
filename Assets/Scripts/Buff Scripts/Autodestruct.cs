/****************************************************************************************************
 * Primary Contributor: Jaymeson Wickins
 * 
 * Description: PLEASE ADD A GENERIC DESCRIPTION HERE. I KNOW BELOW DESCRIBES THIS SCRIPT QUITE
 *              NICELY ALREADY, BUT IN THIS DESCRIPTION, JUST TELL US WHAT OBJECT THIS IS ATTACHED
 *              TO AND WHAT NOT.
 ****************************************************************************************************/

using UnityEngine;
using System.Collections;

public class Autodestruct : MonoBehaviour {

    /****************************************************************************************************
     * Description: Called once. Find the grandchildren of the gameobject and autodestruct on all of    *
     *              their particle animators.                                                           *
     * Syntax: ---                                                                                      *
     ****************************************************************************************************/
	void Start () {
		for (int i =0; i < transform.childCount; i++) {
			Transform child = transform.GetChild(i);
			for(int j = 0; j <= transform.childCount; j++){
				ParticleAnimator particle = child.transform.GetChild(j).GetComponent<ParticleAnimator>();
				particle.autodestruct = false;
			}
		}
	}

}
