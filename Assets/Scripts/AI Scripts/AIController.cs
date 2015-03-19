using UnityEngine;
using System.Collections;

public class AIController :CharacterBase {
	public enum State { WALKING, PLAYERTRACK, ATTACKING, DEAD, ITEMTRACK };
	public State state = State.WALKING;

	//get location of current target to chase and kill
	public Transform currentTarget;
	private NavMeshAgent navMesh;

	private Transform Thorax, Head;
	private GameObject SnowBallTemplate;
	private SphereCollider TriggerCollider;

	private float MovementSpeed;

	//keep track of whether the target is visible to the AI or not
	bool targetInSight = false;
	bool targetInRange = false;

	bool stateCoroutine = false;
	bool pauseTimer = false;


	// Use this for initialization
	void Start () {
		navMesh = GetComponent<NavMeshAgent> ();
		SnowBallTemplate = GameObject.FindGameObjectWithTag ("Global").GetComponent<Common>().SnowBall;

		foreach (Transform o in GetComponentsInChildren<Transform> ()){
			if (o.name == "Head") Head = o;
			else if (o.name == "Thorax") Thorax = o;
		}
		//Thorax = this.GetComponentsInChildren<GameObject> ();
			//GameObject.Find ("Thorax");
		//Head = GameObject.Find ("Head");

		TriggerCollider = GetComponent<SphereCollider> ();
		TriggerCollider.radius = Common.AIViewRange;

		MovementSpeed = navMesh.speed;

        currentTarget = Common.player.transform.Find("Snowman/Head");
	}



	void UpdateBuffs() {
		updateBuffTimers ();
		navMesh.speed = MovementSpeed + getSpeedBoost ();


	}


    /***************************************************************************
     * Description: Calculates the vertical angle between the AI and its target
     ***************************************************************************/
	float getTargetAngle() {
        float x = Mathf.Abs(currentTarget.position.x - transform.position.x);//Mathf.Sqrt(Mathf.Pow(currentTarget.position.x - transform.position.x, 2.0f) + Mathf.Pow(currentTarget.position.z - transform.position.z, 2.0f));
        float y = Mathf.Abs(currentTarget.position.y - transform.position.y);
        float v = Common.MaxThrowForce;

		float numerator = Mathf.Pow (v, 2) + Mathf.Sqrt (Mathf.Pow (v, 4) 
						- Mathf.Pow (x, 2) + (-2.0f * y * Mathf.Pow (v, 2)));

		float angle = Mathf.Rad2Deg * Mathf.Atan (numerator / x);
		return angle;
	}

	void Update () {
		UpdateBuffs ();
		targetInSight = isTargetInView ();
		if (targetInRange) {
			Head.transform.LookAt(currentTarget);
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
				Rigidbody instantiatedProjectile = Instantiate(SnowBallTemplate.rigidbody, 
				                                               Thorax.position, Head.rotation) as Rigidbody;



				float targetAngle = getTargetAngle();
				print (targetAngle);

				Quaternion derp = Quaternion.identity;
				derp.eulerAngles = new Vector3(-targetAngle, 0, 0);
				instantiatedProjectile.transform.eulerAngles += derp.eulerAngles;

				instantiatedProjectile.AddForce (instantiatedProjectile.transform.forward * Common.MaxThrowForce, ForceMode.Impulse);

			
				state = State.WALKING;
				StartCoroutine(defaultStateTimer(1, 1, State.WALKING));
				subtractAmmo();
				//print ("Health: " + Health + "/" + getMaxHealth());
			}
			break;

		case State.DEAD:
			break;

		case State.ITEMTRACK:
			break;

		}
	}



	void OnTriggerEnter(Collider collision) {
	//void OnCollisionEnter(Collision collision) {
	//If another npc or character is in range, switch the target
		//otherwise, if a snowball enters, switch targets to who ever threw the snowball
		if (collision.gameObject.tag == "Player") {
			//state = State.ATTACKING;
			targetInRange = true;
			print ("target in range");
		}

	}

	void OnTriggerExit(Collider collision) {
	//void OnCollisionExit(Collision collision) {
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
