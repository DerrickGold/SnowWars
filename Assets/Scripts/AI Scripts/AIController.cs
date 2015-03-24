using UnityEngine;
using System.Collections;

public class AIController :CharacterBase {
	public enum State { WALKING, PLAYERTRACK, ATTACKING, DEAD, ITEMTRACK, RESPAWN};
	public State state = State.WALKING;

	//get location of current target to chase and kill
	public Transform currentTarget;
	private NavMeshAgent navMesh;
	
	private SphereCollider TriggerCollider;

	private float MovementSpeed;

	//keep track of whether the target is visible to the AI or not
	bool targetInSight = false;
	bool targetInRange = false;

	bool stateCoroutine = false;
	bool pauseTimer = false;



	// Use this for initialization
	void Start () {
		baseInit ();
		navMesh = GetComponent<NavMeshAgent> ();

		initSnowMan ();
	}


	void initSnowMan() {
		TriggerCollider = GetComponent<SphereCollider> ();
		TriggerCollider.radius = Common.AIViewRange;
		MovementSpeed = navMesh.speed;
		currentTarget = Common.player.transform.Find("Snowman/Head");
	}

	
	void UpdateBuffs() {
		if (state == State.DEAD || state == State.RESPAWN)
						return;

		updateBuffTimers ();
		navMesh.speed = MovementSpeed + getSpeedBoost ();

		if (Health > 0.0f) {
			if(HitCollider.isHit) {
				//todo: replace -1 with snowballs attached damage
				Health = getHealth () - HitCollider.Damage;
				HitCollider.reset();
			}
		} else
			state = State.DEAD;
	}


    float getTargetAngle()
    {
        float range = Mathf.Sqrt(Mathf.Pow(transform.position.x - currentTarget.position.x, 2) + Mathf.Pow(transform.position.z - currentTarget.position.z, 2));
        float offsetHeight = currentTarget.position.y - transform.position.y;
        float gravity = -Physics.gravity.y;

        float verticalSpeed = Mathf.Sqrt(2 * gravity * currentTarget.position.y);
        float travelTime = Mathf.Sqrt(2 * Mathf.Abs (offsetHeight) / gravity) ;
        float horizontalSpeed = range / travelTime;
        //float velocity = Mathf.Sqrt(Mathf.Pow(verticalSpeed, 2) + Mathf.Pow(horizontalSpeed, 2));
        //return (-Mathf.Atan2(verticalSpeed / velocity, horizontalSpeed / velocity) + Mathf.PI);

		return (90 - (Mathf.Rad2Deg * Mathf.Atan (verticalSpeed / horizontalSpeed)))*Common.AIAimAdjustFactor;
	}


	void attack() {
		navMesh.destination = currentTarget.position;
		if (!stateCoroutine) {
			Rigidbody instantiatedProjectile = Instantiate(SnowBallTemplate.rigidbody,
			                                               Thorax.transform.position, Head.transform.rotation) as Rigidbody;

			float targetAngle = getTargetAngle();
			Projectile snowBall = instantiatedProjectile.GetComponent<Projectile>();
			snowBall.damage = getSnowBallDamage();

			Quaternion derp = Quaternion.identity;
			derp.eulerAngles = new Vector3(-targetAngle, 0, 0);
			instantiatedProjectile.transform.eulerAngles += derp.eulerAngles;

			instantiatedProjectile.AddForce (instantiatedProjectile.transform.forward * Common.MaxThrowForce, ForceMode.Impulse);


			state = State.WALKING;
			StartCoroutine(defaultStateTimer(1, 1, State.WALKING));
			subtractAmmo();
		}
	}




	void deathAnim() {

		DieAnim ();
        navMesh.enabled = false;
	}


	void respawn () {
		Rebuild ();
		//reset stats
		navMesh.enabled = true;
		Health = getMaxHealth ();
		Stamina = getMaxStamina ();
		resetBuffs ();
		initSnowMan ();
	}

	void Update () {
		switch(state) {
		case State.WALKING:
			UpdateBuffs ();
			targetInSight = isTargetInView ();
			if (targetInRange) {
				Head.transform.LookAt(currentTarget);
			}
			//keep tracking targets position
			navMesh.destination = currentTarget.position;
			if (targetInSight) state = State.ATTACKING;

			break;

		case State.ATTACKING:
			UpdateBuffs ();
			targetInSight = isTargetInView ();
			if (targetInRange) {
				Head.transform.LookAt(currentTarget);
			}
			attack();
			break;

		case State.DEAD:
			if (!stateCoroutine) {
				deathAnim();
				StartCoroutine(defaultStateTimer(Common.RespawnTime, Common.RespawnTime, State.RESPAWN));
			}
			break;

		case State.ITEMTRACK:
			break;

		case State.RESPAWN:
			respawn ();
			state = State.WALKING;
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
