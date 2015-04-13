/****************************************************************************************************
 * Primary Contributor: Jaymeson Wickins                                                            *
 *                                                                                                  *
 * Description: This is attached to an empty parent game object of spikes. The game object has a    *
 *              collider that will tell this script to drop the spikes whenever a snowman collides  *
 *              with it.                                                                            *
 ****************************************************************************************************/

using UnityEngine;
using System.Collections;

public class SpikeFall : MonoBehaviour
{
	public float FALL_SPEED;
	public float FALL_HEIGHT = 65f;
	private Vector3 originalPosition;
	private bool fallen;
	private Transform spikes;


	/****************************************************************************************************
     * Description: This is used to initialize required variables.                                      *
     * Syntax: ---                                                                                      *
     ****************************************************************************************************/
	void Start ()
    {
		FALL_SPEED = 9f;
		spikes = transform.Find ("Trap");
		originalPosition = spikes.position; 
	}


	/****************************************************************************************************
     * Description: Deals with anything that collides with the spikes hitbox.                           *
     * Syntax: ---                                                                                      *
     ****************************************************************************************************/
	void OnTriggerEnter(Collider col)
    {
		//If spikes are not already falling
		if (fallen == false)
        {
			if (col.gameObject.tag.Contains ("Team"))
            {
				fallen = true;
				StartCoroutine ("fall");
			}
		}
	}

	/****************************************************************************************************
     * Description: This coroutine deals with timing the dropping of the spikes just fast enough to     *
     *              kill any player or AI that is attempting to walk under them.                        *
     * Syntax: StartCoroutine("fall");                                                                  *
     ****************************************************************************************************/
	public IEnumerator fall()
    {
		while (spikes.position.y > FALL_HEIGHT) 
        {
			spikes.position = new Vector3(originalPosition.x, spikes.position.y-FALL_SPEED*Time.deltaTime, originalPosition.z );
			yield return null;
		}
		//After falling a certain distance, revert the spikes back to original position
		spikes.position = originalPosition; 
		fallen = false; //spikes are done falling
	}
}
