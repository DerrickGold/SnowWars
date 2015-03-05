using UnityEngine;
using System.Collections;

public class AIController : MonoBehaviour {


	public enum State { WALKING, PLAYERTRACK, ATTACKING, DEAD, ITEMTRACK };
	public State state = State.WALKING;

	//get location of current target to chase and kill
	public Transform currentTarget;

	// Use this for initialization
	void Start () {
	
	}
	
	// Update is called once per frame
	void Update () {
		switch(state) {
		case State.WALKING:


			break;

		case State.PLAYERTRACK:
			break;

		case State.ATTACKING:
			//Rigidbody instantiatedProjectile = Instantiate(Common.snowball.rigidbody, transform.position, transform.rotation) as Rigidbody;
			//instantiatedProjectile.AddForce (transform.forward * 1200.0f);
			//Common.sfx[SNOWBALL_THROW].Play();

			state = State.WALKING;
			break;

		case State.DEAD:
			break;

		case State.ITEMTRACK:
			break;

		}
	}



	void OnTriggerEnter(Collider collision) {
		//If another npc or character is in range, switch the target
		//otherwise, if a snowball enters, switch targets to who ever threw the snowball
	}

	void OnTriggerExit(Collider collision) {

	}




}
