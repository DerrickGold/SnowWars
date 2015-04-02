/****************************************************************************************************
 * Primary Contributor: Derrick Gold
 * Secondary Contributors: Curtis Murray, Jaymeson Wickins
 * 
 * Description: This script is the driving force behind the AI. This script controls all of the AI
 *              in its entirety. Keeps track of the AI's variables and tells the AI how to act and
 *              behave.
 ****************************************************************************************************/

using UnityEngine;
using System.Collections;
using System.Collections.Generic;

public class AIController : CharacterBase {
	public enum State { WALKING, PLAYERTRACK, ATTACKING, DEAD, ITEMTRACK, RESPAWN };
	public State state = State.WALKING;

    static public float AIM_ADJUST_FACTOR = 1.0f;
    static public float MAX_TARGET_RANGE = 8.0f;

	public Transform currentTarget;
	private NavMeshAgent navMesh;
    private SphereCollider triggerCollider;
    public Animation throwingAnimation;
    private Common globalScript;
    public Transform snowballSpawnLocation;
    private List<GameObject> allEnemies = new List<GameObject>();
    public Transform helperGameObject;

	private float MovementSpeed;

	bool targetInSight = false;
	bool targetInRange = false;
    private bool beingSafe = false;

	bool stateCoroutine = false;
	bool pauseTimer = false;
    private bool zigZagWait = false;
    private int zigZagDirection = 1;


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
     * Description: This is the HUB of the AI. Controls and regulates almost everything.                *
     * Syntax: ---                                                                                      *
     ****************************************************************************************************/
    void Update()
    {
        //DEBUGGING ONLY
		//activateBuff(BuffFlag.SUPER_SNOWBALL);
        //setBuffTimer(BuffFlag.SUPER_SNOWBALL, 100.0f);
        updateBuffTimers();

        //If the AI has a target, check if the target is in range
        if (currentTarget)
            targetInRange = Vector3.Distance(transform.position, currentTarget.position) <= MAX_TARGET_RANGE ? true : false;

        switch (state)
        {
            case State.WALKING:
                if (currentTarget)
                {
                    updateBuffs();
                    targetInSight = isTargetInView();

                    //Be offensive if health isn't too low
                    if (Health > 30 && !beingSafe)
                    {
                        //Start walking to conserve stamina for desperate measures
                        navMesh.speed = WALK_SPEED;

                        //Make the head and body look towards the target
                        Head.transform.LookAt(currentTarget);
                        Thorax.transform.LookAt(currentTarget);

                        //Turn the helper gameobject towards the target (This helps us in getting the AI to circle the target)
                        helperGameObject.LookAt(currentTarget);
                        navMesh.destination = currentTarget.position + (helperGameObject.right * 10);

                        //Throw a snowball at its target if it's in range
                        if (targetInRange)
                            state = State.ATTACKING;
                    }
                    //Become aggressive when enough HP has regenerated
                    else if (Health > 50 && beingSafe)
                        beingSafe = !beingSafe;
                    //Be defensive if health has dropped to critical levels
                    else
                    {
                        //Run as fast as it can to escape danger!
                        navMesh.speed = RUN_SPEED;

                        beingSafe = true;

                        //Look away from the target
                        Head.transform.LookAt(2 * transform.position - currentTarget.position);
                        Thorax.transform.LookAt(2 * transform.position - currentTarget.position);

                        //Run away from the target
                        Vector3 moveDirection = Vector3.Normalize((currentTarget.position - transform.position) * -1);

                        //Randomly zigzag
                        if (!zigZagWait)
                        {
                            StartCoroutine("WaitSeconds");
                        }
                        switch (zigZagDirection)
                        {
                            case -1:
                                moveDirection -= transform.right - (transform.forward * 5);
                                break;
                            case 1:
                                moveDirection += transform.right + (transform.forward * 5);
                                break;
                        }

                        //Tell the AI where to go
                        navMesh.destination = transform.position + moveDirection;
                    }
                }
                break;

            case State.ATTACKING:
                updateBuffs();
                targetInSight = isTargetInView();
                throwingAnimation.Play("AIThrowingAnimation");
                break;

            case State.DEAD:
				
                if (!stateCoroutine)
                {
                    targetInRange = false;
                    deathAnimation();
                    StartCoroutine(defaultStateTimer(RESPAWN_TIME, RESPAWN_TIME, State.RESPAWN));
                }
                break;

            case State.ITEMTRACK:
                break;

            case State.RESPAWN:
				//increment the score for the opposite team
				//do not increment when the AI dies because the AI will remain in dead state for more than 1 frame
				if (gameObject.tag == "TeamA") globalScript.TEAM_B_KILLS++;
				else globalScript.TEAM_A_KILLS++;
                respawn();
                state = State.WALKING;
                break;
        }

        //Check to see if the AI is moving to regain HP
        if (Vector3.Distance(transform.position, lastRegenLocation) > 5 && Health < 100)
        {
            lastRegenLocation = transform.position;
            Health += 1.0f;
        }

        //Check to see if AI is dead
        if (Health <= 0) state = State.DEAD;

        //Check to see if the AI's current target is dead
        string curTargetName = currentTarget.gameObject.transform.root.name;
        if (curTargetName == "AI(Clone)")
        {
            if (currentTarget.gameObject.transform.root.GetComponent<AIController>().Health <= 0)
                pickRandomEnemy();
        }
        else if (curTargetName == "Player(Clone)")
        {
            if (currentTarget.gameObject.transform.root.GetComponent<PlayerController>().Health <= 0)
                pickRandomEnemy();
        }
        else if (curTargetName != "AI(Clone)" && curTargetName != "Player(Clone)")
            pickRandomEnemy();
    }


    /****************************************************************************************************
     * Description: This is a helper function. Called to initialize the AI.                             *
     * Syntax: initializeSnowMan();                                                                     *
     ****************************************************************************************************/
    void initializeSnowMan() {
		triggerCollider = GetComponent<SphereCollider> ();
		MovementSpeed = navMesh.speed;
        //currentTarget = globalScript.player.transform.Find("Snowman/Head");
	}

	/****************************************************************************************************
     * Description: This is a helper function. Return the tag of an enemy.                              *
     *                                                                                                  *
     * Syntax: getEnemyTag();                                                                           *
     ****************************************************************************************************/
	string getEnemyTag(){
		switch (gameObject.tag) {
		case "TeamA":
			return "TeamB";
			break;
		case "TeamB":
			return "TeamA";
			break;
		default:
			return "Team0";
			break;
		}
	}
    /****************************************************************************************************
     * Description: This is a helper function. Grabs a list of all possible enemies that can be         *
     *              targeted.                                                                           *
     * Syntax: getListOfEnemies();                                                                      *
     ****************************************************************************************************/
    void getListOfEnemies()
    {
		string enemyTag = getEnemyTag ();

        //Get a list of all enemys in the game
        foreach (GameObject g in GameObject.FindGameObjectsWithTag(enemyTag))
        {
            //Don't add itself!
            if (g != gameObject)
            {
				if (g.GetComponent<AIController>() != null){
					State aiState = g.GetComponent<AIController>().state;
					if (aiState != State.DEAD && aiState != State.RESPAWN)
                    	allEnemies.Add(g);
				}
				else if (g.GetComponent<PlayerController>() != null){
					PlayerController.PlayerState playerState = g.GetComponent<PlayerController>().playerState;
					if (playerState != PlayerController.PlayerState.DEAD) allEnemies.Add(globalScript.player);
				}
			}
        }

        //Add the player to the list of possible targets
        //PlayerController.PlayerState playerState = globalScript.player.GetComponent<PlayerController>().playerState;
        //if (playerState != PlayerController.PlayerState.DEAD) allEnemies.Add(globalScript.player);
    }


    /****************************************************************************************************
     * Description: This is a helper function. Called when the AI needs to pick a random enemy.         *
     * Syntax: pickRandomEnemy();                                                                       *
     ****************************************************************************************************/
    void pickRandomEnemy()
    {
        //Reset targetInRange
        targetInRange = false;
        getListOfEnemies();

        //Pick a random enemy to attack from the list of all possible targets and target their head
        foreach (Transform child in allEnemies[Random.Range(0, allEnemies.Count)].GetComponentsInChildren<Transform>())
        {
            if (child.name == "Head")
                currentTarget = child;
        }
    }


    /****************************************************************************************************
     * Description: PLEASE ADD A DESCRIPTION HERE ABOUT WHAT THIS FUNCTION DOES. TRY TO KEEP FORMATTING *
     * Syntax: updateBuffs();                                                                           *
     ****************************************************************************************************/
    void updateBuffs() {
        if (state == State.DEAD || state == State.RESPAWN) return;

        updateBuffTimers ();
        navMesh.speed = MovementSpeed + getSpeedBoost ();
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
        //if (navMesh.enabled == true)
		//    navMesh.destination = currentTarget.position;
		if (!stateCoroutine) {
			Rigidbody instantiatedProjectile = Instantiate(SnowBallTemplate.rigidbody,
			                                               snowballSpawnLocation.position, snowballSpawnLocation.rotation) as Rigidbody;

			superSizeSnowBall (instantiatedProjectile);
            instantiatedProjectile.transform.eulerAngles += new Vector3(-getTargetAngle(), 0, 0);

			instantiatedProjectile.AddForce (instantiatedProjectile.transform.forward * MAX_THROW_FORCE, ForceMode.Impulse);

			state = State.WALKING;
			//StartCoroutine(defaultStateTimer(1, 1, State.WALKING));
			subtractAmmo();
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
     * Description: Checks to see if the AI is within view of its target.                               *
     * Syntax: bool value = isTargetInView();                                                           *
     * Returns: True if the target is in view | False if the target is not in view                      *
     ****************************************************************************************************/
	bool isTargetInView() {
		return Physics.Raycast (Head.transform.position, Head.transform.forward);
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
     * Description: This is a helper function. This is only used to help the AI strafe back and forth   *
     *              when running away to help dodge incoming projectiles. Waits exactly 1 second.       *
     * Syntax: StartCoroutine("WaitSeconds");                                                           *
     ****************************************************************************************************/
    IEnumerator WaitSeconds()
    {
        zigZagWait = true;
        zigZagDirection = -zigZagDirection;
        yield return new WaitForSeconds(1);
        zigZagWait = false;
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
	
	
	/****************************************************************************************************
     * Description: Called when something collides with the AI's trigger. This is used only for         *
     *              checking to see if there is an enemy really close by.                               *
     * Syntax: ---                                                                                      *
     ****************************************************************************************************/
    void OnTriggerEnter(Collider col)
    {
		if (col.gameObject.tag == getEnemyTag()) {
			foreach (Transform child in col.transform.GetComponentsInChildren<Transform>()) {
				if (child.name == "Head")
					currentTarget = child;
			}
		}
		getPickup(col);
	}
}