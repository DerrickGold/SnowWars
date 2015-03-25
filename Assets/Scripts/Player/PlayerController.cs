using UnityEngine;
using System.Collections;
using UnityEngine.UI;

public class PlayerController : CharacterBase
{
    //Player variables
    private enum PlayerState
    {
        IDLE,
        WALKING,
        RUNNING
    };

    private Vector3 moveDirection = Vector3.zero;
    private CharacterController controller;
    private PlayerState playerState = PlayerState.IDLE;
    public Animation throwingAnimation;

	public Slider healthBar;
	public Slider staminaBar;

    private bool isJumping = false;
    private bool isGrounded = false;
    private bool runOnCooldown = false;

    private float walkSpeed = 5.0f;
    private float runSpeed = 7.0f;
    private float jumpSpeed = 10.0f;
    private float throwingSpeed = 20.0f;
    private float gravity = 30.0f;

    //Game variables
    private Common globalScript;
    private AudioSource audio;
    public Transform snowballSpawnLocation;


    void Awake()
    {
        healthBar = GameObject.Find("HUD/Health").GetComponent<Slider>();
        staminaBar = GameObject.Find("HUD/Stamina").GetComponent<Slider>();

        //Initializes the head, thorax and body
		baseInit ();

        globalScript = GameObject.FindGameObjectWithTag("Global").GetComponent<Common>();
        globalScript.player = gameObject;
        controller = GetComponent<CharacterController>();
		healthBar.value = Health;
        lastRegenLocation = transform.position;
    }


    void Update()
    {
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
                Movement(0.0f);
				if(getStamina() < 100.0f)
					Stamina += 0.1f;
                break;

            case PlayerState.WALKING:
                Movement(walkSpeed);
                if (getStamina() < 100.0f)
					Stamina += 0.1f;
                break;

            case PlayerState.RUNNING:
                Movement(runSpeed);
				Stamina -= 0.2f;
                if (getStamina() == 0)
					playerState = PlayerState.WALKING;
                break;
        }

        //Is the player throwing a snowball?
        if (Input.GetButtonDown("Fire1") && Health > 0)
            throwingAnimation.Play("PlayerThrowingAnimation");

        //Check to see if the player is dead
        if (Health <= 0)
            Death();

        //Check to see if the player is moving to regain HP
        if (Vector3.Distance(transform.position, lastRegenLocation) > 5 && Health < 100)
        {
            lastRegenLocation = transform.position;
            Health += 2.5f;
        }

        //Update UI
        staminaBar.value = Stamina;
        healthBar.value = Health;
    }


    /*
     * Description: Call this function to apply gravity to the player
     */
    void ApplyGravity()
    {
        moveDirection.y -= gravity * Time.deltaTime;
        
        //Make sure the player isn't falling faster than gravity should allow
        if (moveDirection.y < -70)
            moveDirection.y = -70;
    }


    /*
     * Description: Call this function keep track of player jumping
     */
    void Jumping()
    {
        //Check to see if the player can jump again
        if (isGrounded)
            isJumping = false;

        //Deal with jumping
        if (Input.GetButton("Jump") && !isJumping)
        {
            isJumping = true;
            moveDirection.y = jumpSpeed;
        }
    }


    /***************************************************************************
     * Description: Deals with letting the player throw snowballs
     ***************************************************************************/
    public void Throwing()
    {
        //Create a new snowball
		Rigidbody snowBall = Instantiate(SnowBallTemplate.rigidbody, snowballSpawnLocation.position, Camera.main.transform.rotation) as Rigidbody;
        snowBall.AddForce(Camera.main.transform.forward * throwingSpeed, ForceMode.Impulse);
        snowBall.AddForce(Camera.main.transform.forward * (controller.velocity.magnitude * Input.GetAxis("Vertical") / 2), ForceMode.Impulse);
        globalScript.sfx[(int)Common.AudioSFX.SNOWBALL_THROW].Play();

        //Subtract health from the player
        subtractAmmo();
    }


    /*
     * Description: Deals with the movement of the player
     * Syntax: Movement(float);
     * Values:
     *       : speed = The max speed the player can move at
     */
    void Movement(float speed)
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

        Jumping();
        ApplyGravity();
        GroundPlayer();

        //Move the player and check if the player is grounded
        isGrounded = ((controller.Move(moveDirection * Time.deltaTime)) & CollisionFlags.Below) != 0;
    }

    /*
     * Description: Keeps the player on the ground when walking down hills (Prevents bouncing when walking down hills)
     */
    void GroundPlayer()
    {
        if (!isJumping)
        {
            RaycastHit hit;
            Vector3 slopeAdjust = Vector3.zero;
            if (Physics.Raycast(transform.position, -Vector3.up, out hit))
            {
                slopeAdjust = new Vector3(0, hit.distance, 0);
                controller.Move((transform.position - slopeAdjust) - transform.position);
            }
        }
    }

    void Death()
    {
		DieAnim ();

        //Enable death camera
        Camera.main.gameObject.GetComponent<ThirdPersonCameraController>().enabled = true;
        Screen.lockCursor = false;

        //Disable player controls
        Camera.main.gameObject.GetComponent<MouseLook>().enabled = false;
        gameObject.GetComponent<MouseLook>().enabled = false;
        gameObject.GetComponent<CharacterController>().enabled = false;
        gameObject.GetComponent<PlayerController>().enabled = false;
    }

    void OnCollisionEnter(Collision col)
    {
        Health -= col.gameObject.GetComponent<Projectile>().damage;
    }
}