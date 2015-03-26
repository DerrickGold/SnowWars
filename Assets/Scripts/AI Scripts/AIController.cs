using UnityEngine;
using System.Collections;
using System.Collections.Generic;

public class AIController : CharacterBase {
	public enum State { WALKING, PLAYERTRACK, ATTACKING, DEAD, ITEMTRACK, RESPAWN };
	public State state = State.WALKING;

	public Transform currentTarget;
	private NavMeshAgent navMesh;
    private SphereCollider triggerCollider;
    public Animation throwingAnimation;
    private Common globalScript;
    public Transform snowballSpawnLocation;
    private List<GameObject> allEnemies = new List<GameObject>();

	private float MovementSpeed;

	bool targetInSight = false;
	bool targetInRange = false;
    private bool beingSafe = false;

	bool stateCoroutine = false;
	bool pauseTimer = false;


    /****************************************************************************************************
     * Description: This is called before Start(). Helps to initialize important variables that are     *
     *              quickly needed.                                                                     *
     * Syntax: ---                                                                                      *
     ****************************************************************************************************/
	void Awake () {
        baseInitialization();
        globalScript = GameObject.FindGameObjectWithTag("Global").GetComponent<Common>();
        navMesh = GetComponent<NavMeshAgent>();
	}


    /****************************************************************************************************
     * Description: This is called after Awake(). Variables initialized here are in this call function  *
     *              to give other gameobjects time to initialize their own variables in Awake().        *
     * Syntax: ---                                                                                      *
     ****************************************************************************************************/
    void Start() {
        initializeSnowMan();
        lastRegenLocation = transform.position;
        spawnPosition = transform.position;
        pickRandomEnemy();
    }


    /****************************************************************************************************
     * Description: This is a helper function. Called to initialize the AI.                             *
     * Syntax: initializeSnowMan();                                                                     *
     ****************************************************************************************************/
    void initializeSnowMan() {
		triggerCollider = GetComponent<SphereCollider> ();
		triggerCollider.radius = Common.AIViewRange;
		MovementSpeed = navMesh.speed;
        //currentTarget = globalScript.player.transform.Find("Snowman/Head");
	}


    /****************************************************************************************************
     * Description: This is a helper function. Called when the AI needs to pick a random enemy.         *
     * Syntax: pickRandomEnemy();                                                                       *
     ****************************************************************************************************/
    void pickRandomEnemy()
    {
        //Get a list of all enemys in the game
        foreach (GameObject g in GameObject.FindGameObjectsWithTag("Enemy"))
        {
			State aiState = g.GetComponent<AIController>().state;
            if ( aiState != State.DEAD && aiState != State.RESPAWN) allEnemies.Add(g);
        }

		PlayerController.PlayerState playerState = globalScript.player.GetComponent<PlayerController> ().playerState;
        if (playerState != PlayerController.PlayerState.DEAD) allEnemies.Add(globalScript.player);

        //Pick a random enemy to attack
        do
            currentTarget = allEnemies[Random.Range(0, allEnemies.Count)].transform;
        while (currentTarget == transform);
    }


    /****************************************************************************************************
     * Description: PLEASE ADD A DESCRIPTION HERE ABOUT WHAT THIS FUNCTION DOES. TRY TO KEEP FORMATTING *
     * Syntax: updateBuggs();                                                                           *
     ****************************************************************************************************/
    void updateBuffs() {
        if (state == State.DEAD || state == State.RESPAWN) return;

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


    /****************************************************************************************************
     * Description: This is a helper function. Calculates the required angle to throw a snowball to     *
     *              hit the target the AI is currently targeted onto.                                   *
     * Syntax: getTargetAngle();                                                                        *
     ****************************************************************************************************/
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


    /****************************************************************************************************
     * Description: Controls the throwing of snowballs from the AI. This function is called from        *
     *              throwSnowball.cs to help sync the throwing of the snowball with the arm movement    *
     * Syntax: ---                                                                                      *
     ****************************************************************************************************/
    public void throwing()
    {
        if (navMesh.enabled == true)
		    navMesh.destination = currentTarget.position;
		if (!stateCoroutine) {
			Rigidbody instantiatedProjectile = Instantiate(SnowBallTemplate.rigidbody,
			                                               snowballSpawnLocation.position, snowballSpawnLocation.rotation) as Rigidbody;

			Projectile snowBall = instantiatedProjectile.GetComponent<Projectile>();
			snowBall.damage = getSnowBallDamage();
            snowBall.origin = transform;
            snowBall.originHP = Health;
            instantiatedProjectile.transform.eulerAngles += new Vector3(-getTargetAngle(), 0, 0);

			instantiatedProjectile.AddForce (instantiatedProjectile.transform.forward * Common.MaxThrowForce, ForceMode.Impulse);

			state = State.WALKING;
			//StartCoroutine(defaultStateTimer(1, 1, State.WALKING));
			//subtractAmmo();
		}
	}


    /****************************************************************************************************
     * Description: Called when the AI dies. Disables appropriate components and gives the AI's body    *
     *              physics for ragdoll effect.                                                         *
     * Syntax: deathAnimation();                                                                        *
     ****************************************************************************************************/
	void deathAnimation() {
		dieAnimation();
        navMesh.enabled = false;
	}


    /****************************************************************************************************
     * Description: Called when the AI needs to respawn. The AI respawns at it's starting position.     *
     * Syntax: respawn();                                                                               *
     ****************************************************************************************************/
	void respawn() {
		rebuild();
		navMesh.enabled = true;
		Health = getMaxHealth ();
		Stamina = getMaxStamina ();
		resetBuffs ();
		initializeSnowMan ();
        transform.position = spawnPosition;
		pickRandomEnemy ();
	}


    /****************************************************************************************************
     * Description: This is the HUB of the AI. Controls and regulates almost everything.                *
     * Syntax: ---                                                                                      *
     ****************************************************************************************************/
	void Update () {
		switch(state) {
		    case State.WALKING:
			    updateBuffs ();
			    targetInSight = isTargetInView ();
			    if (targetInRange){
				    Head.transform.LookAt(currentTarget);
					Thorax.transform.LookAt(currentTarget);
				}
				
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
                    Vector3 moveDiriection = Vector3.Normalize((currentTarget.position - transform.position) * -1);
                    navMesh.destination = transform.position + moveDiriection;
                }
			    break;

		    case State.ATTACKING:
			    updateBuffs ();
			    targetInSight = isTargetInView ();
			    if (targetInRange) {
				    Head.transform.LookAt(currentTarget);
			    }
                throwingAnimation.Play("AIThrowingAnimation");
			    break;

		    case State.DEAD:
			    if (!stateCoroutine) {
				    deathAnimation();
				    StartCoroutine(defaultStateTimer(Common.RespawnTime, Common.RespawnTime, State.RESPAWN));
			    }
			    break;

		    case State.ITEMTRACK:
			    break;

		    case State.RESPAWN:
			    respawn();
			    state = State.WALKING;
			    break;
		}

        //Check to see if the player is moving to regain HP
        if (Vector3.Distance(transform.position, lastRegenLocation) > 5 && Health < 100)
        {
            lastRegenLocation = transform.position;
            Health += 2.5f;
        }

        //Check to see if the AI's current target is dead
        if (currentTarget.gameObject.name == "AI")
        {
            if (currentTarget.gameObject.GetComponent<AIController>().Health <= 0)
                pickRandomEnemy();
        }
        else if (currentTarget.gameObject.name == "Player")
        {
            if (currentTarget.gameObject.GetComponent<PlayerController>().Health <= 0)
                pickRandomEnemy();
        }
        else
            pickRandomEnemy();
	}


    /****************************************************************************************************
     * Description: Called when something collides with the AI.                                         *
     * Syntax: ---                                                                                      *
     ****************************************************************************************************/
	void OnTriggerEnter(Collider collision) {
	    //If another npc or character is in range, switch the target
		//otherwise, if a snowball enters, switch targets to who ever threw the snowball
        if (currentTarget != null)
        {
            if (collision.gameObject == currentTarget.gameObject)
                targetInRange = true;
        }

	}


    /****************************************************************************************************
     * Description: Called when whatever has collidied with the AI leaves the collision area.           *
     * Syntax: ---                                                                                      *
     ****************************************************************************************************/
	void OnTriggerExit(Collider collision) {
        if (currentTarget != null)
        {
            if (collision.gameObject == currentTarget.gameObject)
                targetInRange = false;
        }
	}


    /****************************************************************************************************
     * Description: Checks to see if the AI is within view of its target.                               *
     * Syntax: bool value = isTargetInView();                                                           *
     * Returns: True if the target is in view | False if the target is not in view                      *
     ****************************************************************************************************/
	bool isTargetInView() {
		if (!targetInRange) return false;
		return Physics.Raycast (Head.transform.position, Head.transform.forward, Common.AIViewRange);
	}


    /****************************************************************************************************
     * Description: A generic co-routine for changing the state machine's state after a specific amount *
     *              of time. This time is randomly picked from the range between a minimum and maximum  *
     *              time.                                                                               *
     * Syntax: StartCoroutine(defaultStateTimer(float minTime, float maxTime, State next));             *
     * Values:                                                                                          *
     *          minTime = Minimum number of seconds to stay in the current state                        *
     *          maxTime = Maximum number of seconds to stay in the current state                        *
     *          next = Next state to switch to after the timer has finished                             *
     ****************************************************************************************************/
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


    /****************************************************************************************************
     * Description: Called when something collides with the AI.                                         *
     * Syntax: ---                                                                                      *
     ****************************************************************************************************/
    void OnCollisionEnter(Collision col)
    {
        //If a snowball hit the AI
        if (col.gameObject.name == "Snowball(Clone)")
            Health -= col.gameObject.GetComponent<Projectile>().damage;
    }
}