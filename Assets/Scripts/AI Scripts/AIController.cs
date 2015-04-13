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

public class AIController : CharacterBase
{
    [HideInInspector]
	public enum State { WALKING, PLAYERTRACK, ATTACKING, DEAD, ITEMTRACK, RESPAWN };
	public State state = State.WALKING;

    static public float AIM_ADJUST_FACTOR = 1.0f;
    static public float MAX_TARGET_RANGE = 8.0f;

	public Transform currentTarget;
	private NavMeshAgent navMesh;
    public Animation throwingAnimation;
    private Common globalScript;
    public Transform snowballSpawnLocation;
    private List<GameObject> allEnemies = new List<GameObject>();
    public Transform helperGameObject;

	private float MovementSpeed;

	bool targetInRange = false;
    private Vector3 lastTargetPosition = Vector3.zero;
    private bool beingSafe = false;

	bool stateCoroutine = false;
	bool pauseTimer = false;

    private int zigZagDirection = 1;
    private bool reUpdateDestination = false;


    /****************************************************************************************************
     * Description: This is called before Start(). Helps to initialize important variables that are     *
     *              quickly needed.                                                                     *
     * Syntax: ---                                                                                      *
     ****************************************************************************************************/
	void Awake()
    {
        baseInitialization();
        globalScript = GameObject.FindGameObjectWithTag("Global").GetComponent<Common>();
        navMesh = GetComponent<NavMeshAgent>();
	}


    /****************************************************************************************************
     * Description: This is called after Awake(). Variables initialized here are in this call function  *
     *              to give other gameobjects time to initialize their own variables in Awake().        *
     * Syntax: ---                                                                                      *
     ****************************************************************************************************/
    void Start()
    {
        initializeSnowMan();
        lastRegenLocation = transform.position;
        spawnPosition = transform.position;
        pickRandomEnemy();
        checkForNearestBuff();
    }


    /****************************************************************************************************
     * Description: This is the HUB of the AI. Controls and regulates almost everything.                *
     * Syntax: ---                                                                                      *
     ****************************************************************************************************/
    void Update()
    {
        updateBuffTimers();

        //If the AI has a target, check if the target is in range
        if (currentTarget)
            targetInRange = Vector3.Distance(transform.position, currentTarget.position) <= MAX_TARGET_RANGE ? true : false;

        switch (state)
        {
            case State.WALKING:
                if (currentTarget)
                {
                    //Be offensive if health isn't too low
                    if (Health > 30 && !beingSafe)
                    {
                        //Start walking to conserve stamina for desperate measures
                        navMesh.speed = WALK_SPEED + getSpeedBoost();

                        //Make the head and body look towards the target
                        Head.transform.LookAt(currentTarget);
                        Thorax.transform.LookAt(currentTarget);

                        //Turn the helper gameobject towards the target (This helps us in getting the AI to circle the target)
                        helperGameObject.LookAt(currentTarget);

                        //If the target is too far away, only update the destination when the target has walked a considerable distance
                        if (Vector3.Distance(transform.position, currentTarget.position) > 20)
                        {
                            if (navMesh.enabled == true && Vector3.Distance(currentTarget.position, lastTargetPosition) > 15)
                            {
                                lastTargetPosition = currentTarget.position;
                                navMesh.SetDestination(lastTargetPosition + (helperGameObject.right * 10));
                            }
                        }
                        //If the target is close by, continuously update the destination
                        else
                        {
                            if (navMesh.enabled == true && Vector3.Distance(currentTarget.position, lastTargetPosition) > 2)
                            {
                                lastTargetPosition = currentTarget.position;
                                navMesh.SetDestination(lastTargetPosition + (helperGameObject.right * 10));
                            }
                        }

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
                        navMesh.speed = RUN_SPEED + getSpeedBoost();

                        beingSafe = true;

                        //Look away from the target
                        Head.transform.LookAt(2 * transform.position - currentTarget.position);
                        Thorax.transform.LookAt(2 * transform.position - currentTarget.position);

                        //Tell the AI to go back to the spawn point to refill up on HP
                        if (navMesh.enabled == true)
                            navMesh.SetDestination(spawnPosition);

                        //Give 100% health back if the AI manages to get back to spawn point
                        if (Vector3.Distance(transform.position, spawnPosition) < 2)
                            Health = 100;
                    }
                }
                break;

            case State.ATTACKING:
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
				navMesh.speed = WALK_SPEED;

				//Make the head and body look towards the target
				Head.transform.LookAt(currentTarget);
				Thorax.transform.LookAt(currentTarget);

                //Set the destination of the AI to the buff location
                if (navMesh.enabled == true && Vector3.Distance(currentTarget.position, lastTargetPosition) > 2)
                {
                    lastTargetPosition = currentTarget.position;
                    navMesh.SetDestination(lastTargetPosition);
                }
				navMesh.stoppingDistance = 0.0f;

                //Check to make sure no one else has picked up the buff
                if (currentTarget.FindChild("Present-01").gameObject.activeInHierarchy == false)
                    pickRandomEnemy();
				break;

            case State.RESPAWN:
                //Rebuild the AI's body
                rebuild();

                //Re-enable the AI's nav mesh
		        navMesh.enabled = true;

                //Reset the AI's Health and Stamina
		        Health = getMaxHealth ();
		        Stamina = getMaxStamina ();

                //Reset the AI's buff
		        resetBuffs ();
		        initializeSnowMan ();

                navMesh.Warp(spawnPosition);
		        pickRandomEnemy ();
                reUpdateDestination = true;
                scoreHasBeenGiven = false;
                state = State.WALKING;
				checkForNearestBuff();
                break;
        }

        //Check to see if the AI needs to re-update their destination (This only occurs after the AI dies)
        if (reUpdateDestination)
        {
            if (navMesh.enabled == true)
            {
                lastTargetPosition = currentTarget.position;
                navMesh.SetDestination(lastTargetPosition);
            }
        }

        //Check to see if the AI is moving to regain HP
        if (Vector3.Distance(transform.position, lastRegenLocation) > 5 && Health < 100)
        {
            lastRegenLocation = transform.position;
            Health += 1.0f + getHealthRecharge();
            if (getHealth() > 100)
                Health = 100;
        }

        //Check to see if the AI's current target is dead
		if (currentTarget)
        {
			string curTargetName = currentTarget.gameObject.transform.root.name;
			if (curTargetName == "AI(Clone)")
            {
                //If the AI target is dead, pick a new target and check if there is a buff nearby
                if (currentTarget.gameObject.transform.root.GetComponent<AIController>().Health <= 0)
                {
                    pickRandomEnemy();
                    checkForNearestBuff();
                }
            }
            //If the player target is dead, pick a new target and check if there is a buff nearby
            else if (curTargetName == "Player(Clone)")
            {
                if (currentTarget.gameObject.transform.root.GetComponent<PlayerController>().Health <= 0)
                {
                    pickRandomEnemy();
                    checkForNearestBuff();
                }
            }
            //If there is no target, pick a new target and check if there is a buff nearby
            else if (curTargetName != "AI(Clone)" && curTargetName != "Player(Clone)")
            {
                pickRandomEnemy();
                checkForNearestBuff();
            }
		}

        //Check to see if AI is dead
        if (Health <= 0)
        {
            state = State.DEAD;
        }
    }


    /****************************************************************************************************
     * Description: This is a helper function. Called when the AI starts, respawns and when their       *
     *              target dies. It checks if there are any buffs in the local vicinity.                *
     * Syntax: checkForNearestBuff();                                                                     *
     ****************************************************************************************************/
    void checkForNearestBuff()
    {
		float shortestDistance = 99999.0f;
		Transform targetBuff = null;

		if (globalScript.buffs.Count <= 0)
			return;

        //Loop through all of the buffs and grab the closest one
		foreach (Transform o  in globalScript.buffs)
        {
			float dist = Vector3.Distance (transform.position, o.position);
			if (dist < shortestDistance)
            {
				shortestDistance = dist;
				targetBuff = o;
			}
		}

		//Only go after a buff if it is within a suitable range
		if (shortestDistance < MAX_TARGET_RANGE * 1000)
        {
			currentTarget = targetBuff;
			state = State.ITEMTRACK;
		}
	}


    /****************************************************************************************************
     * Description: This is a helper function. Called to initialize the AI.                             *
     * Syntax: initializeSnowMan();                                                                     *
     ****************************************************************************************************/
    void initializeSnowMan()
    {
		MovementSpeed = navMesh.speed;
	}

	/****************************************************************************************************
     * Description: This is a helper function. Return the tag of an enemy.                              *
     *                                                                                                  *
     * Syntax: getEnemyTag();                                                                           *
     ****************************************************************************************************/
	string getEnemyTag()
    {
		switch (gameObject.tag)
        {
		case "TeamA":
			return "TeamB";
		case "TeamB":
			return "TeamA";
		default:
			return "Team0";
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
                //If it is another AI
				if (g.GetComponent<AIController>() != null){
					State aiState = g.GetComponent<AIController>().state;
					if (aiState != State.DEAD && aiState != State.RESPAWN)
                    	allEnemies.Add(g);
				}
                //If it is the player
				else if (g.GetComponent<PlayerController>() != null){
					PlayerController.PlayerState playerState = g.GetComponent<PlayerController>().playerState;
					if (playerState != PlayerController.PlayerState.DEAD) allEnemies.Add(globalScript.player);
				}
			}
        }
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
        state = State.WALKING;
    }


    /****************************************************************************************************
     * Description: PLEASE ADD A DESCRIPTION HERE ABOUT WHAT THIS FUNCTION DOES. TRY TO KEEP FORMATTING *
     * Syntax: updateBuffs();                                                                           *
     ****************************************************************************************************/
    void updateBuffs()
    {
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
        float horizontalSpeed = range / travelTime;
        float velocity = Mathf.Sqrt(Mathf.Pow(verticalSpeed, 2) + Mathf.Pow(horizontalSpeed, 2));

        return -Mathf.Atan2(verticalSpeed / velocity, horizontalSpeed / velocity) + Mathf.PI;
	}


    /****************************************************************************************************
     * Description: Controls the throwing of snowballs from the AI. This function is called from        *
     *              throwSnowball.cs to help sync the throwing of the snowball with the arm movement    *
     * Syntax: ---                                                                                      *
     ****************************************************************************************************/
    public void throwing()
    {
		if (!stateCoroutine)
        {
			Rigidbody instantiatedProjectile = Instantiate(SnowBallTemplate.rigidbody,
			                                               snowballSpawnLocation.position, snowballSpawnLocation.rotation) as Rigidbody;

			superSizeSnowBall (instantiatedProjectile);
            instantiatedProjectile.transform.eulerAngles += new Vector3(-getTargetAngle(), 0, 0);

			instantiatedProjectile.AddForce (instantiatedProjectile.transform.forward * MAX_THROW_FORCE, ForceMode.Impulse);
			instantiatedProjectile.gameObject.GetComponent<Projectile>().origin = transform;

			state = State.WALKING;
			subtractAmmo();
		}
	}


    /****************************************************************************************************
     * Description: Called when the AI dies. Disables appropriate components and gives the AI's body    *
     *              physics for ragdoll effect.                                                         *
     * Syntax: deathAnimation();                                                                        *
     ****************************************************************************************************/
	private void deathAnimation()
    {
		dieAnimation();
        navMesh.enabled = false;
	}


    /****************************************************************************************************
     * Description: Checks to see if the AI is within view of its target.                               *
     * Syntax: bool value = isTargetInView();                                                           *
     * Returns: True if the target is in view | False if the target is not in view                      *
     ****************************************************************************************************/
	private bool isTargetInView()
    {
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
    IEnumerator defaultStateTimer(float minTime, float maxTime, State next)
    {
		stateCoroutine = true;
		float curTime = 0;
		float endTime = (Random.value * (maxTime - minTime)) + minTime;

		while(curTime < endTime) 
        {
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
        zigZagDirection = -zigZagDirection;
        yield return new WaitForSeconds(1);
    }


    /****************************************************************************************************
     * Description: Called when something collides with the AI.                                         *
     * Syntax: ---                                                                                      *
     ****************************************************************************************************/
    void OnCollisionEnter(Collision col)
    {
        //If a snowball hit the AI
        if (col.gameObject.name == "Snowball(Clone)")
        {
            Health -= col.gameObject.GetComponent<Projectile>().damage;
			if (Health <= 0 && !scoreHasBeenGiven)
            {
                scoreHasBeenGiven = true;
				GameObject myKiller = col.gameObject.GetComponent<Projectile> ().origin.gameObject;

				//If this snowman was killed by someone on their own team, and this is not a free for all
				if(!gameObject.CompareTag("Team0") && gameObject.tag == myKiller.tag)
					myKiller.GetComponent<CharacterBase> ().score -= 1;
				else
					myKiller.GetComponent<CharacterBase> ().score += 1;
			}
		}
	}
	
	
	/****************************************************************************************************
     * Description: Called when something collides with the AI's trigger.                               *
     * Syntax: ---                                                                                      *
     ****************************************************************************************************/
    void OnTriggerEnter(Collider col)
    {
        //If an enemy got too close to the AI
		if (col.gameObject.tag == getEnemyTag())
        {
            currentTarget = col.transform.Find("Snowman/Head");
            state = State.WALKING;
		}

        //If the AI collided with a buff
		if (getPickup(col))
        {
            pickRandomEnemy();
			state = State.WALKING;
		}
	}
}