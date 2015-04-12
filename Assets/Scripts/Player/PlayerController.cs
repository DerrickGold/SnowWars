/****************************************************************************************************
 * Primary Contributor: Curtis Murray
 * Secondary Contributors: Derrick Gold, Jaymeson Wickins, Shaun Yonkers
 * 
 * Description: This script is placed on the player. This is the driving force behind the player.
 ****************************************************************************************************/

using UnityEngine;
using System.Collections;
using UnityEngine.UI;

public class PlayerController : CharacterBase
{
    //Player variables
    public enum PlayerState
    {
        IDLE,
        WALKING,
        RUNNING,
        DEAD,
        RESPAWN
    };
    public PlayerState playerState = PlayerState.IDLE;
    private Vector3 moveDirection = Vector3.zero;
    private CharacterController controller;
    public Animation throwingAnimation;

	public Slider healthBar;
	public Slider staminaBar;

	private bool isPaused = false;
    private bool isJumping = false;
    private bool isGrounded = false;
    private bool runOnCooldown = false;
    private bool inWater = false;
    private bool stateCoroutine = false;
    private bool pauseTimer = false;

    private float jumpSpeed = 10.0f;
    private float throwingSpeed = 20.0f;
    private float gravity = 30.0f;
    private float slideAt = 0.6f;

    //Game variables
	private GameObject hud;// = GameObject.FindGameObjectWithTag("hud");
	private Image img;
    private Common globalScript;
    private AudioSource audio;
    public Transform snowballSpawnLocation;
    private Vector3 cameraInitialPosition;


    /****************************************************************************************************
     * Description: Called before Start(). Initializes values that are quickly required by other        *
     *              gameobjects such as the AI.                                                         *
     * Syntax: ---                                                                                      *
     ****************************************************************************************************/
    void Awake()
    {
        //Grab required variables
        globalScript = GameObject.FindGameObjectWithTag("Global").GetComponent<Common>();
        healthBar = GameObject.Find("HUD/Health").GetComponent<Slider>();
        staminaBar = GameObject.Find("HUD/Stamina").GetComponent<Slider>();
        controller = GetComponent<CharacterController>();

        //Initializes the head, thorax and body
		baseInitialization();

        //Let the global script know that this gameobject is the player
        globalScript.player = gameObject;

        //Set required variables
		healthBar.value = Health;
        lastRegenLocation = transform.position;
        spawnPosition = transform.position;
    }


    /****************************************************************************************************
     * Description: Called after Awake(). Initializes any other required variables that weren't         *
     *              initialized in Awake.                                                               *
     * Syntax: ---                                                                                      *
     ****************************************************************************************************/
    void Start()
    {
		hud = GameObject.FindGameObjectWithTag("hud");
		img = hud.transform.FindChild ("buff icon").GetComponent<Image> ();

        spawnPosition = transform.position;
        cameraInitialPosition = Camera.main.transform.localPosition;
    }


    /****************************************************************************************************
     * Description: The HUB of the entire player. Controls and regulates almost everything.             *
     * Syntax: ---                                                                                      *
     ****************************************************************************************************/
    void Update()
    {
        //Checks to see if the player has any active buffs
		checkBuffs();

        //Is the player moving?
        if (playerState != PlayerState.DEAD && playerState != PlayerState.RESPAWN)
        {
            if (Input.GetAxis("Horizontal") != 0 || Input.GetAxis("Vertical") != 0 && !isJumping)
            {
                //Is the player walking or running?
                if (Input.GetKey(KeyCode.LeftShift) && getStamina() > 0 && runOnCooldown == false)
                    playerState = PlayerState.RUNNING;
                else
                    playerState = PlayerState.WALKING;
            }
            //Is the player idling?
            else if (!isJumping)
                playerState = PlayerState.IDLE;

            //Check to see if the players stamina has bottomed out
            if (getStamina() <= 0)
                runOnCooldown = true;
            //Check to see if the player can run again after cooldown is up
            if (runOnCooldown == true && getStamina() >= 100)
                runOnCooldown = false;

            //Is the player throwing a snowball?
            if (Input.GetButtonDown("Fire1"))
                throwingAnimation.Play("PlayerThrowingAnimation");

            //Check to see if the player is moving to regain HP
            if (Vector3.Distance(transform.position, lastRegenLocation) > 5 && getHealth() < 100)
            {
                lastRegenLocation = transform.position;
                Health += 1.0f + getHealthRecharge();
                if (getHealth() > 100)
                    Health = 100;
            }

            //If the player returned to the spawn location - give them full HP
            if (Vector3.Distance(transform.position, spawnPosition) < 2)
                Health = 100;

            //Keep parts of the player body in line with the camera
            bodyRotation();

            //If the player is standing in water, they will lose health
            if (inWater)
                Health = getHealth() - 1;

            //Check to see if the player is dead
            if (getHealth() <= 0)
                playerState = PlayerState.DEAD;
        }

        switch (playerState)
        {
            case PlayerState.IDLE:
                movement(0.0f);
				if(getStamina() < 100.0f)
					Stamina += Time.deltaTime * 5;
                break;

            case PlayerState.WALKING:
                movement(WALK_SPEED);
                if (getStamina() < 100.0f)
					Stamina += Time.deltaTime * 5;
                break;

            case PlayerState.RUNNING:
                movement(RUN_SPEED);
				Stamina -= Time.deltaTime * 10;
                if (getStamina() <= 0)
                {
                    Stamina = 0;
                    playerState = PlayerState.WALKING;
                }
                break;
			case PlayerState.DEAD:
                if (!stateCoroutine)
                {
                    dieAnimation();

                    Camera.main.gameObject.GetComponent<ThirdPersonCameraController>().enabled = true;
                    Camera.main.gameObject.GetComponent<MouseLook>().enabled = false;

                    Screen.lockCursor = false;

                    gameObject.GetComponent<MouseLook>().enabled = false;
                    gameObject.GetComponent<CharacterController>().enabled = false;
                    StartCoroutine(defaultStateTimer(RESPAWN_TIME, RESPAWN_TIME, PlayerState.RESPAWN));
                }
				break;
            case PlayerState.RESPAWN:
                if (gameObject.tag == "TeamA")
                    globalScript.TEAM_B_KILLS++;
				else
                    globalScript.TEAM_A_KILLS++;
                respawn();
                scoreHasBeenGiven = false;
                playerState = PlayerState.WALKING;
                break;
        }

        //Update the UI
        staminaBar.value = getStamina();
        healthBar.value = getHealth();

        //Keep track of the buff timers
        updateBuffTimers();
    }


    /****************************************************************************************************
     * Description: This is a helper function. This function is called in Update to keep the body and   *
     *              hat in rotation with the camera. This makes it easier to tell which way the player  *
     *              is facing.                                                                          *
     * Syntax: bodyRotation();                                                                          *
     ****************************************************************************************************/
    void bodyRotation()
    {
        Head.transform.rotation = Camera.main.transform.rotation;
    }


    /****************************************************************************************************
     * Description: This function is called when the player needs to respawn.                           *
     * Syntax: respawn();                                                                               *
     ****************************************************************************************************/
    void respawn()
    {
        //Rebuild the players body
        rebuild();

        //Reset the players health and stamina
        Health = getMaxHealth();
        Stamina = getMaxStamina();

        //Reset the players buff timers
        resetBuffs();

        //Spawn the player back at their original spawn position
        transform.position = spawnPosition;

        //Re-enable the first person camera and disable the third person camera
        Camera.main.gameObject.GetComponent<ThirdPersonCameraController>().enabled = false;
        Camera.main.gameObject.GetComponent<MouseLook>().enabled = true;
        Camera.main.transform.localPosition = cameraInitialPosition;
        Camera.main.transform.rotation = Head.transform.rotation;

        //Give back control to the player
        gameObject.GetComponent<MouseLook>().enabled = true;
        gameObject.GetComponent<CharacterController>().enabled = true;
    }


    /****************************************************************************************************
     * Description: Controls the throwing of snowballs from the player. This function is called from    *
     *              throwSnowball.cs to help sync the throwing of the snowball with the arm movement.   *
     * Syntax: ---                                                                                      *
     ****************************************************************************************************/
    public void throwing()
    {
        //Create a new snowball
		Rigidbody snowBall = Instantiate(SnowBallTemplate.rigidbody, snowballSpawnLocation.position, Camera.main.transform.rotation) as Rigidbody;

		superSizeSnowBall (snowBall);
        snowBall.AddForce(Camera.main.transform.forward * throwingSpeed, ForceMode.Impulse);
        snowBall.AddForce(Camera.main.transform.forward * (controller.velocity.magnitude * Input.GetAxis("Vertical") / 2), ForceMode.Impulse);
        globalScript.sfx[(int)Common.AudioSFX.SNOWBALL_THROW].Play();
        snowBall.gameObject.GetComponent<Projectile>().origin = transform;

        subtractAmmo();
    }


    /****************************************************************************************************
     * Description: Calculates the movement of the player. Also calls the jumping() and applyGravity()  *
     *              functions when needed.                                                              *
     * Syntax: movement(float speed);                                                                   *
     * Values:                                                                                          *
     *          speed = The speed at which to move the player                                           *
     ****************************************************************************************************/
    void movement(float speed)
    {
        if (isGrounded)
        {
            moveDirection = new Vector3(Input.GetAxis("Horizontal"), 0, Input.GetAxis("Vertical"));

            //If moving forward and to the side at the same time, compensate for distance 
            if (Input.GetMouseButton(1) && (Input.GetAxis("Horizontal") != 0) && (Input.GetAxis("Vertical") != 0))
                moveDirection *= 0.7f;

            moveDirection *= speed + getSpeedBoost();
            moveDirection = transform.TransformDirection(moveDirection);
        }

        jumping();
        applyGravity();
        groundPlayer();

        //Move the player and check if the player is grounded
        isGrounded = ((controller.Move(moveDirection * Time.deltaTime)) & CollisionFlags.Below) != 0;
    }


    /****************************************************************************************************
     * Description: Call this function keep track of player jumping.                                    *
     * Syntax: jumping();                                                                               *
     ****************************************************************************************************/
    void jumping()
    {
        if (isGrounded)
            isJumping = false;

        //Make sure the player can't jump if they are too high off the ground
        RaycastHit hit;
        if (Physics.Raycast(transform.position, -Vector3.up, out hit))
        {
            if (hit.distance > 1.5f)
                isJumping = true;
        }

        if (Input.GetButtonDown("Jump") && !isJumping)
        {
            isJumping = true;
            moveDirection.y = jumpSpeed;
        }
    }


    /****************************************************************************************************
     * Description: This is a helper function used by the function movement(). Calculates the gravity   *
     *              acted upon on the player.                                                           *
     * Syntax: applyGravity();                                                                          *
     ****************************************************************************************************/
    void applyGravity()
    {
        moveDirection.y -= gravity * Time.deltaTime;

        //Make sure the player isn't falling faster than gravity should allow
        if (moveDirection.y < -70)
            moveDirection.y = -70;
    }


    /****************************************************************************************************
     * Description: Keeps the player on the ground when walking down hills.                             *
     *              (Prevents bouncing when walking down hills)                                         *
     * Syntax: groundPlayer();
     ****************************************************************************************************/
    void groundPlayer()
    {
        if (!isJumping)
        {
            RaycastHit hit;
            Vector3 slopeAdjust = Vector3.zero;
            if (Physics.Raycast(transform.position, -Vector3.up, out hit))
            {
                if (hit.distance <= 2.0f)
                {
                    slopeAdjust = new Vector3(0, hit.distance, 0);
                    controller.Move((transform.position - slopeAdjust) - transform.position);
                }
            }
        }
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
    IEnumerator defaultStateTimer(float minTime, float maxTime, PlayerState next)
    {
        stateCoroutine = true;
        float curTime = 0;
        float endTime = (Random.value * (maxTime - minTime)) + minTime;

        while (curTime < endTime)
        {
            if (!pauseTimer) curTime += Time.deltaTime;
            yield return new WaitForEndOfFrame();
        }
        stateCoroutine = false;
        playerState = next;
    }


    /****************************************************************************************************
     * Description: This is called whenever something collides with the player.                         *
     * Syntax: ---                                                                                      *
     ****************************************************************************************************/
    void OnCollisionEnter(Collision col)
    {
        //Did the player get hit by a snowball?
        if (col.gameObject.name == "Snowball(Clone)")
        {
            Health = getHealth() - col.gameObject.GetComponent<Projectile>().damage;
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

	void checkBuffs(){
		if (isEffectActive (BuffFlag.INF_AMMO)) {
			img.enabled = true;
			img.sprite = globalScript.infAmmonIcon;
			globalScript.buffText.text = "Infinite Ammo";
		} else if (isEffectActive (BuffFlag.INF_HEALTH)) {
			img.enabled = true;
			img.sprite = globalScript.infHealthIcon;
			globalScript.buffText.text = "Infinite Health";
		} else if (isEffectActive (BuffFlag.INF_STAMINA)) {
			img.enabled = true;
			img.sprite = globalScript.infStaminIcon;
			globalScript.buffText.text = "Infinite Stamina";
		} else if (isEffectActive (BuffFlag.MAX_HEALTH_BOOST)) {
			img.enabled = true;
			img.sprite = globalScript.healthIcon;
			globalScript.buffText.text = "Health Boost";
		} else if (isEffectActive (BuffFlag.SPEED_BOOST)) {
			img.enabled = true;
			img.sprite = globalScript.speedBoostIcon;
			globalScript.buffText.text = "Speed Boost";
		} else if (isEffectActive (BuffFlag.SUPER_SNOWBALL)) {
			img.enabled = true;
			img.sprite = globalScript.superSnowballIcon;
			globalScript.buffText.text = "SUPER SNOWBALL";
		} else {
			img.enabled = false;
			globalScript.buffText.text = "";
		}
	}

	/****************************************************************************************************
     * Description: This is called whenever something with IsTrigger set collides with the player.      *
     * Syntax: ---                                                                                      *
     ****************************************************************************************************/
	void OnTriggerEnter (Collider col)
	{
        //If the player hits spikes, instant death!
		if (col.gameObject.tag == "SPIKES")
			Health = -1;
        //Did the player pickup a buff?
		getPickup(col);
		//If the player has stepped into some water
		if (col.gameObject.tag == "WATER")
			inWater = true;
	}


    /****************************************************************************************************
     * Description: This is called whenever something with IsTrigger stops colliding with the player.   *
     * Syntax: ---                                                                                      *
     ****************************************************************************************************/
	void OnTriggerExit( Collider col){
		//If the player stepped out of water
		if (col.gameObject.tag == "WATER")
			inWater = false;
	}


    /****************************************************************************************************
     * Description: This is called whenever a collider collides with the player. This is only being     *
     *              used to calculate whether or not to slide the player.                               *
     * Syntax: ---                                                                                      *
     ****************************************************************************************************/
    void OnControllerColliderHit(ControllerColliderHit hit)
    {
        //This is for sliding the player down too steep of slopes
        if (hit.gameObject.tag == "Level")
        {
            if (!isJumping)
            {
                if (hit.normal.x > slideAt || hit.normal.x < -slideAt || hit.normal.z > slideAt || hit.normal.z < -slideAt)
                {
                    moveDirection = hit.moveDirection;
                    moveDirection += hit.normal;
                    moveDirection *= gravity / 2;
                }
            }
        }
    }
}