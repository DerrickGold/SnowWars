/****************************************************************************************************
 * Primary Contributor: Jaymeson Wickins
 * 
 * Description: Script that is attached to the spikes themselves to deal damage to any snowman, AI or
 * player, that the spikes hit. SpikeFall.cs that is attatched to the parent of the spikes is the 
 * script that controls the spike drop when a snowman is near.
 ****************************************************************************************************/

using UnityEngine;
using System.Collections;

public class TrapKill : MonoBehaviour {

	public int FALL_DAMAGE = 60; //amount of health the spikes take away

	//When the spikes collide with something
	void OnTriggerEnter(Collider col){

		//Any snowman will have the word "Team" somewhere in the tag
		if (col.gameObject.tag.Contains ("Team")) {

			GameObject snowman = col.gameObject;
			if (snowman.name.Contains("AI")) //if we hit an AI, get the controller script
				snowman.GetComponent<AIController>().Health -= FALL_DAMAGE; //remove health
			else //else we hit the player, get the player controller 
				snowman.GetComponent<PlayerController>().Health -= FALL_DAMAGE; //remove health
		}
	}
}
