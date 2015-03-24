using UnityEngine;
using System.Collections;

public class AIController :CharacterBase {
	public enum State { WALKING, PLAYERTRACK, ATTACKING, DEAD, ITEMTRACK, RESPAWN};
	public State state = State.WALKING;

	//get location of current target to chase and kill
	public Transform currentTarget;
	private NavMeshAgent navMesh;

	private GameObject Base, Thorax, Head;
	private GameObject SnowBallTemplate;
	private SphereCollider TriggerCollider;
	public GameObject deathExplosionEffect;
	public HitBox HitCollider;

	private float MovementSpeed;

	//keep track of whether the target is visible to the AI or not
	bool targetInSight = false;
	bool targetInRange = false;

	bool stateCoroutine = false;
	bool pauseTimer = false;

	private Vector3[] oldPartPositions = new Vector3[3];


	// Use this for initialization
	void Start () {
		navMesh = GetComponent<NavMeshAgent> ();
		SnowBallTemplate = GameObject.FindGameObjectWithTag ("Global").GetComponent<Common>().SnowBall;
		initSnowMan ();



	}

	void initSnowMan() {
		foreach (Transform o in GetComponentsInChildren<Transform> ()){
			if (o.name == "Head") Head = o.gameObject;
			else if (o.name == "Thorax") Thorax = o.gameObject;
			else if (o.name == "Base") Base = o.gameObject;
		}
		//Thorax = this.GetComponentsInChildren<GameObject> ();
		//GameObject.Find ("Thorax");
		//Head = GameObject.Find ("Head");

		TriggerCollider = GetComponent<SphereCollider> ();
		TriggerCollider.radius = Common.AIViewRange;


		MovementSpeed = navMesh.speed;

		currentTarget = Common.player.transform.Find("Snowman/Head");

		oldPartPositions [0] = Base.transform.localPosition;
		oldPartPositions [1] = Thorax.transform.localPosition;
		oldPartPositions [2] = Head.transform.localPosition;

	}

	void destroySnowman() {
		Destroy (Base);
		Destroy (Head);
		Destroy (Thorax);
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
		} else {
			state = State.DEAD;
		}



	}


    /***************************************************************************
     * Description: Calculates the vertical angle between the AI and its target
     ***************************************************************************/
    /*
	float getTargetAngle() {
        float x = Mathf.Abs(currentTarget.position.x - transform.position.x);//Mathf.Sqrt(Mathf.Pow(currentTarget.position.x - transform.position.x, 2.0f) + Mathf.Pow(currentTarget.position.z - transform.position.z, 2.0f));
        float y = Mathf.Abs(currentTarget.position.y - transform.position.y);
        float v = Common.MaxThrowForce;

		float numerator = Mathf.Pow (v, 2) + Mathf.Sqrt (Mathf.Pow (v, 4)
						- Mathf.Pow (x, 2) + (-2.0f * y * Mathf.Pow (v, 2)));

		float angle = Mathf.Rad2Deg * Mathf.Atan (numerator / x);
		return angle;
	}*/

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

	void toggleCollider(GameObject part, bool flag) {
		SphereCollider temp = part.GetComponent<SphereCollider> ();
		temp.enabled = flag;
	}


	void deathAnim() {
		Instantiate(deathExplosionEffect, transform.position, transform.rotation);
		//Add physics to the players body
		//Base.AddComponent<SphereCollider>();
		toggleCollider (Base, true);
		Rigidbody bottomRigidbody = Base.AddComponent<Rigidbody>();
		bottomRigidbody.drag = 2;

		toggleCollider (Thorax, true);
		Rigidbody middleRigidbody = Thorax.AddComponent<Rigidbody>();
		middleRigidbody.drag = 2;
		//bodyMiddle.transform.position += Vector3.up * 0.50f;
		toggleCollider (Head, true);
		Rigidbody topRigidbody = Head.AddComponent<Rigidbody>();
		topRigidbody.drag = 2;
	}


	void respawn () {
		Destroy (Base.rigidbody);
		Destroy (Thorax.rigidbody);
		Destroy (Head.rigidbody);
		toggleCollider (Base, false);
		toggleCollider (Thorax, false);
		toggleCollider (Head, false);


		Base.transform.localPosition = oldPartPositions [0];
		Thorax.transform.localPosition = oldPartPositions [1];
		Head.transform.localPosition = oldPartPositions [2];

		//reset stats
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
