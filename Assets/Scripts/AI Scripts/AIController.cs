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
		case default:
			break;


		case State.WALKING:
			break;

		case State.PLAYERTRACK:
			break;

		case State.ATTACKING:
			break;

		case State.DEAD:
			break;

		case State.ITEMTRACK:
			break;

		}
	}



	void OnTriggerEnter(Collider collision) {

	}

	void OnTriggerExit(Collider collision) {

	}

}
