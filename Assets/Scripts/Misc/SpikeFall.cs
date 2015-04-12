/****************************************************************************************************
 * Primary Contributor: Jaymeson Wickins
 * 
 * Description: This is attached to an empty parent game object of spikes. The game object has a 
 * collider that will tell this script to drop the spikes whenever a snowman collides with it.  
 ****************************************************************************************************/

using UnityEngine;
using System.Collections;

public class SpikeFall : MonoBehaviour {

	public float FALL_SPEED; //fall speed of the spikes
	public float FALL_HEIGHT = 65f;
	private Vector3 originalPosition; //spikes original position
	private bool fallen; //if the spikes are falling
	private Transform spikes; //the spikes themselves

	// Use this for initialization
	void Start () {
		FALL_SPEED = 9f;
		spikes = transform.Find ("Trap"); //find the child object named "Trap", these are the spikes
		originalPosition = spikes.position; 
	}

	//whenever something enters the fall region
	void OnTriggerEnter(Collider col){
		//if spikes are not already falling
		if (fallen == false) {
			//any snowman, AI or player, will have "Team" in their tag
			//if snowman collides with region, drop spikes
			if (col.gameObject.tag.Contains ("Team")) {
				fallen = true;
				StartCoroutine ("fall");
			}
		}
	}

	//coroutine to drop the spikes over a few seconds
	public IEnumerator fall(){
		while (spikes.position.y > FALL_HEIGHT) { //fall a certain distance
			spikes.position = new Vector3(originalPosition.x, spikes.position.y-FALL_SPEED*Time.deltaTime, originalPosition.z );
			yield return null;
		}
		//after falling a certain distance, revert the spikes back to original position
		spikes.position = originalPosition; 
		fallen = false; //spikes are done falling
	}
}
