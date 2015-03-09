using UnityEngine;
using System.Collections;

public class AIController : MonoBehaviour {
	public enum State { WALKING, PLAYERTRACK, ATTACKING, DEAD, ITEMTRACK };
	public State state = State.WALKING;

	//get location of current target to chase and kill
	public Transform currentTarget;
	private NavMeshAgent navMesh;

	private GameObject Thorax;
	private GameObject Head;
	private GameObject SnowBallTemplate;
	private SphereCollider TriggerCollider;

	//keep track of whether the target is visible to the AI or not
	bool targetInSight = false;
	bool targetInRange = false;

	bool stateCoroutine = false;
	bool pauseTimer = false;
	
	// Use this for initialization
	void Start () {
		navMesh = GetComponent<NavMeshAgent> ();
		SnowBallTemplate = GameObject.FindGameObjectWithTag ("Global").GetComponent<Common>().SnowBall;
		Thorax = GameObject.Find ("Thorax");
		Head = GameObject.Find ("Head");

		TriggerCollider = GetComponent<SphereCollider> ();
		TriggerCollider.radius = Common.AIViewRange;

	}




	// Update is called once per frame
	void Update () {

		targetInSight = isTargetInView ();

		if (targetInRange) {
			Head.transform.LookAt (currentTarget);
		}


		switch(state) {
		case State.WALKING:
			//keep tracking targets position
			navMesh.destination = currentTarget.position;
			if (targetInSight) state = State.ATTACKING;

			break;

		case State.ATTACKING:
			navMesh.destination = currentTarget.position;
			if (!stateCoroutine) {
				Rigidbody instantiatedProjectile = Instantiate(SnowBallTemplate.rigidbody, Thorax.transform.position, Head.transform.rotation) as Rigidbody;
				instantiatedProjectile.AddForce (transform.forward * 1200.0f);
			
				StartCoroutine(defaultStateTimer(1, 5, State.WALKING));
			}
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
		if (collision.gameObject.tag == "Player") {
			//state = State.ATTACKING;
			targetInRange = true;
		}

	}

	void OnTriggerExit(Collider collision) {
		if (collision.gameObject.tag == "Player") {
			//state = State.WALKING;
			targetInRange = false;
		}
	}




	bool isTargetInView() {
		if (!targetInRange) return false;
		return Physics.Raycast (Head.transform.position, Head.transform.forward, Common.AIViewRange);
	}



	/*	defaultStateTimer
	 * 
	 * calling:
	 * 	if(!stateCoroutine) StartCoroutine(defaultStateTimer(minTime, maxTime, nextState));
	 * 	This ensures the coroutine is only called once the state begins.
	 * 
	 * A generic co-routine for changing the state machine's
	 * state after a specific amount of time. This time is 
	 * randomly picked from the range between a minimum
	 * and maximum time.
	 * 
	 * 	minTime: minimum number of seconds to stay in 
	 * 			the current state.
	 * 
	 * 	maxTime: maximum number of seconds to stay in
	 * 			the current state.
	 * 
	 * 	next: next state to switch to after the timer 
	 * 		has finished.
	 * 
	 * 
	 * Returns nothing.
	 * 
	 * 
	 */
	
	IEnumerator defaultStateTimer(float minTime, float maxTime, State next) {
		stateCoroutine = true;
		float curTime = 0;
		float endTime = (Random.value * (maxTime - minTime)) + minTime;
		
		while(curTime < endTime) {
			if(!pauseTimer) curTime += Time.deltaTime;
			yield return new WaitForEndOfFrame();
		}
		stateCoroutine = false;
		state = next;
	}



}
