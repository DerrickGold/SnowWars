using UnityEngine;
using System.Collections;

/* 
 *  Script made by Jay
 * 
 * 	Find the grandchildren of the object and deactivate autodestruct on 
 *  all of their particle animators.
 */

public class Autodestruct : MonoBehaviour {

	// Use this for initialization
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
