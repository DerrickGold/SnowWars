using UnityEngine;
using System.Collections;

public class AIController : CharacterBase {
	public enum State { WALKING, PLAYERTRACK, ATTACKING, DEAD, ITEMTRACK, RESPAWN };
	public State state = State.WALKING;

	public Transform currentTarget;
    private Transform lastTargetAttacked;
	private NavMeshAgent navMesh;
    private SphereCollider triggerCollider;
    public Animation throwingAnimation;
    private Common globalScript;
    public Transform snowballSpawnLocation;

	private float MovementSpeed;

	bool targetInSight = false;
	bool targetInRange = false;
    private bool beingSafe = false;

	bool stateCoroutine = false;
	bool pauseTimer = false;

	void Awake () {
        baseInit();
        globalScript = GameObject.FindGameObjectWithTag("Global").GetComponent<Common>();
        navMesh = GetComponent<NavMeshAgent>();
	}

    void Start() {
        initSnowMan();
        lastRegenLocation = transform.position;
    }


	void initSnowMan() {
		triggerCollider = GetComponent<SphereCollider> ();
		triggerCollider.radius = Common.AIViewRange;
		MovementSpeed = navMesh.speed;
        currentTarget = globalScript.player.transform.Find("Snowman/Head");
	}

	
	void UpdateBuffs() {
		if (state == State.DEAD || state == State.RESPAWN)
						return;

		updateBuffTimers ();
		navMesh.speed = MovementSpeed + getSpeedBoost ();

		if (Health > 0.0f) {
			if(HitCollider.isHit) {
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
        float height = (currentTarget.position.y > transform.position.y) ? currentTarget.position.y : transform.position.y;

        float verticalSpeed = Mathf.Sqrt(2 * gravity * height);
        float travelTime = Mathf.Sqrt(2 * (height - offsetHeight) / gravity) + Mathf.Sqrt(2 * height / gravity);
        //float travelTime = Mathf.Sqrt(2 * Mathf.Abs (offsetHeight) / gravity) ;
        float horizontalSpeed = range / travelTime;
        float velocity = Mathf.Sqrt(Mathf.Pow(verticalSpeed, 2) + Mathf.Pow(horizontalSpeed, 2));

        return -Mathf.Atan2(verticalSpeed / velocity, horizontalSpeed / velocity) + Mathf.PI;

		//return (90 - (Mathf.Rad2Deg * Mathf.Atan (verticalSpeed / horizontalSpeed)))*Common.AIAimAdjustFactor;
	}

    /***************************************************************************
     * Description: Deals with letting the AI throw snowballs
     ***************************************************************************/
    public void Throwing()
    {
        if (navMesh.enabled == true)
		    navMesh.destination = currentTarget.position;
		if (!stateCoroutine) {
			Rigidbody instantiatedProjectile = Instantiate(SnowBallTemplate.rigidbody,
			                                               snowballSpawnLocation.position, snowballSpawnLocation.rotation) as Rigidbody;

			Projectile snowBall = instantiatedProjectile.GetComponent<Projectile>();
			snowBall.damage = getSnowBallDamage();
            print(getTargetAngle());
            instantiatedProjectile.transform.eulerAngles += new Vector3(-getTargetAngle(), 0, 0);

			instantiatedProjectile.AddForce (instantiatedProjectile.transform.forward * Common.MaxThrowForce, ForceMode.Impulse);


			state = State.WALKING;
			//StartCoroutine(defaultStateTimer(1, 1, State.WALKING));
			subtractAmmo();
		}
	}


	void DeathAnim() {
		DieAnim ();
        navMesh.enabled = false;
	}


	void Respawn () {
		Rebuild();
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
			    if (targetInRange)
				    Head.transform.LookAt(currentTarget);

                //Be offensive if health isn't too low
                if (Health > 30 && !beingSafe)
                {
                    navMesh.destination = currentTarget.position;
                    //Throw a snowball at its target if it's in range
                    if (targetInSight)
                        state = State.ATTACKING;
                }
                else if (Health > 50 && beingSafe)
                    beingSafe = !beingSafe;
                //Be defensive if health has dropped to critical levels
                else
                {
                    beingSafe = true;
                    Vector3 moveDiriection = Vector3.Normalize((lastTargetAttacked.position - transform.position) * -1);
                    navMesh.destination = transform.position + moveDiriection;
                }
			    break;

		    case State.ATTACKING:
			    UpdateBuffs ();
			    targetInSight = isTargetInView ();
			    if (targetInRange) {
				    Head.transform.LookAt(currentTarget);
			    }
                throwingAnimation.Play("AIThrowingAnimation");
                lastTargetAttacked = currentTarget;
			    break;

		    case State.DEAD:
			    if (!stateCoroutine) {
				    DeathAnim();
				    StartCoroutine(defaultStateTimer(Common.RespawnTime, Common.RespawnTime, State.RESPAWN));
			    }
			    break;

		    case State.ITEMTRACK:
			    break;

		    case State.RESPAWN:
			    Respawn();
			    state = State.WALKING;
			    break;
		}

        //Check to see if the player is moving to regain HP
        if (Vector3.Distance(transform.position, lastRegenLocation) > 5 && Health < 100)
        {
            lastRegenLocation = transform.position;
            Health += 2.5f;
        }
	}



	void OnTriggerEnter(Collider collision) {
	    //If another npc or character is in range, switch the target
		//otherwise, if a snowball enters, switch targets to who ever threw the snowball
		if (collision.gameObject.tag == "Player")
			targetInRange = true;

	}

	void OnTriggerExit(Collider collision) {
		if (collision.gameObject.tag == "Player")
			targetInRange = false;
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

    void OnCollisionEnter(Collision col)
    {
        print("Hit");
        Health -= col.gameObject.GetComponent<Projectile>().damage;
    }
}