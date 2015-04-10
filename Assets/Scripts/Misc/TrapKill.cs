using UnityEngine;
using System.Collections;

public class TrapKill : MonoBehaviour {

	public int FALL_DAMAGE = 60;

	void OnTriggerEnter(Collider col){

		if (col.gameObject.tag.Contains ("Team")) {

			GameObject snowman = col.gameObject;
			if (snowman.name.Contains("AI"))
				snowman.GetComponent<AIController>().Health -= FALL_DAMAGE;
			else
				snowman.GetComponent<PlayerController>().Health -= FALL_DAMAGE;
		}
	}
}
