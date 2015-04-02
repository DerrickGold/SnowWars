/****************************************************************************************************
 * Primary Contributor: Curtis Murray
 * Secondary Contributors: Derrick Gold, Jaymeson Wickins
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

    private float jumpSpeed = 10.0f;
    private float throwingSpeed = 20.0f;
    private float gravity = 30.0f;
    private float slideAt = 0.6f;

    //Game variables
    private Common globalScript;
    private AudioSource audio;
    public Transform snowballSpawnLocation;


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

		//activateBuff(BuffFlag.INF_HEALTH);
		//activateBuff(BuffFlag.SUPER_SNOWBALL);
    }


    /****************************************************************************************************
     * Description: The HUB of the entire player. Controls and regulates almost everything.             *
     * Syntax: ---                                                                                      *
     ****************************************************************************************************/
    void Update()
    {
        //DEBUGGING ONLY
		//setBuffTimer (BuffFlag.SUPER_SNOWBALL, 100.0f);
		//setBuffTimer (BuffFlag.INF_HEALTH, 100.0f);
		updateBuffTimers();


        //Is the player moving?
        if (Input.GetAxis("Horizontal") != 0 || Input.GetAxis("Vertical") != 0 && !isJumping)
        {
            //Is the player walking or running?
            if (Input.GetKey(KeyCode.LeftShift) && Stamina > 0 && runOnCooldown == false)
                playerState = PlayerState.RUNNING;
            else
                playerState = PlayerState.WALKING;
        }
        //Is the player idling?
        else if (!isJumping)
            playerState = PlayerState.IDLE;

        //Check to see if the players stamina has bottomed out
        if (Stamina <= 0)
            runOnCooldown = true;
        //Check to see if the player can run again after cooldown is up
        if (runOnCooldown == true && Stamina >= 100)
            runOnCooldown = false;

        switch (playerState)
        {
            case PlayerState.IDLE:
                movement(0.0f);
				if(getStamina() < 100.0f)
					Stamina += 0.1f;
                break;

            case PlayerState.WALKING:
                movement(WALK_SPEED);
                if (getStamina() < 100.0f)
					Stamina += 0.1f;
                break;

            case PlayerState.RUNNING:
                movement(RUN_SPEED);
				Stamina -= 0.2f;
                if (getStamina() == 0)
					playerState = PlayerState.WALKING;
                break;
			case PlayerState.DEAD:
				break;
        }

        //Is the player throwing a snowball?
        if (Input.GetButtonDown("Fire1") && getHealth () > 0)
            throwingAnimation.Play("PlayerThrowingAnimation");

        //Check to see if the player is dead
        if (getHealth () <= 0)
            death();

        //Check to see if the player is moving to regain HP
        if (Vector3.Distance(transform.position, lastRegenLocation) > 5 && getHealth () < 100)
        {
            lastRegenLocation = transform.position;
            Health += 1.0f;
        }

        //Update the UI
        staminaBar.value = getStamina ();
        healthBar.value = getHealth ();

        //Keep parts of the player body in line with the camera
        bodyRotation();

		//If the player is standing in water, they will lose health
		if (inWater)
			Health = getHealth() - 1;
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
        rebuild();
        Health = getMaxHealth();
        Stamina = getMaxStamina();
        resetBuffs();
        transform.position = spawnPosition;
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

            moveDirection *= speed;
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
     * Description: Called when the player dies. Disables appropriate components and gives the players  *
     *              body physics for ragdoll effect.                                                    *
     * Syntax: death();                                                                                 *
     ****************************************************************************************************/
    void death()
    {
		dieAnimation();

        Camera.main.gameObject.GetComponent<ThirdPersonCameraController>().enabled = true;
        Screen.lockCursor = false;

        Camera.main.gameObject.GetComponent<MouseLook>().enabled = false;
        gameObject.GetComponent<MouseLook>().enabled = false;
        gameObject.GetComponent<CharacterController>().enabled = false;
        gameObject.GetComponent<PlayerController>().enabled = false;

		playerState = PlayerState.DEAD;
    }


    /****************************************************************************************************
     * Description: This is called whenever something collides with the player.                         *
     * Syntax: ---                                                                                      *
     ****************************************************************************************************/
    void OnCollisionEnter(Collision col)
    {
        //Did the player get hit by a snowball?
        if (col.gameObject.name == "Snowball(Clone)") 
            Health = getHealth() - col.gameObject.GetComponent<Projectile>().damage;
    }

	/****************************************************************************************************
     * Description: This is called whenever something with IsTrigger set collides with the player.      *
     * Syntax: ---                                                                                      *
     ****************************************************************************************************/
	void OnTriggerEnter (Collider col)
	{
        //If the player hits spikes, instant death!
		if (col.gameObject.tag.Equals ("SPIKES"))
			Health = getHealth() - getMaxHealth();
        //Did the player pickup a buff?
		if (col.gameObject.tag.Equals ("PickUp")) {
			int randBuff = Random.Range(1,7);
			print(randBuff);
			ActiveBuffs |= (1<<randBuff);
		}
		//If the player has stepped into some water
		if (col.gameObject.tag.Equals ("WATER")) {
			inWater = true;
		}

	}


    /****************************************************************************************************
     * Description: This is called whenever something with IsTrigger stops colliding with the player.   *
     * Syntax: ---                                                                                      *
     ****************************************************************************************************/
	void OnTriggerExit( Collider col){
		//If the player stepped out of water
		if (col.gameObject.tag.Equals ("WATER")) {
			inWater = false;
		}
	}


    /****************************************************************************************************
     * Description: This is called whenever a collider collides with the player. This is only being     *
     *              used to calculate whether or not to slide the player.                               *
     * Syntax: ---                                                                                      *
     ****************************************************************************************************/
    void OnControllerColliderHit(ControllerColliderHit hit)
    {
        //This is for sliding the player down too steep of slopes
        if (hit.gameObject.tag == "Level") {
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