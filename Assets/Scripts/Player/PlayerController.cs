using UnityEngine;
using System.Collections;
using UnityEngine.UI;

public class PlayerController : MonoBehaviour
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
    public GameObject bodyTop, bodyMiddle, bodyBottom;

    private bool isJumping = false;
    private bool isGrounded = false;

    private float hp = 100.0f;
	private float stamina = 100.0f;

    private float walkSpeed = 10.0f;
    private float runSpeed = 20.0f;
    private float jumpSpeed = 10.0f;
    private float throwingSpeed = 20.0f;
    private float gravity = 30.0f;

    //Game variables
    private Common globalScript;
    private AudioSource audio;
    public Transform snowballSpawnLocation;
    public GameObject deathExplosionEffect;


    void Start()
    {
        globalScript = GameObject.FindGameObjectWithTag("Global").GetComponent<Common>();
        controller = GetComponent<CharacterController>();
		healthBar.value = hp;
    }


    void Update()
    {
        //Is the player moving?
        if (Input.GetAxis("Horizontal") != 0 || Input.GetAxis("Vertical") != 0 && !isJumping)
        {
            //Is the player walking or running?
            if (Input.GetKey(KeyCode.LeftShift) && stamina > 0)
            {

                playerState = PlayerState.RUNNING;
            }
            else
                playerState = PlayerState.WALKING;
        }
        else if (!isJumping)
            playerState = PlayerState.IDLE;

        switch (playerState)
        {
            case PlayerState.IDLE:
                Movement(0.0f);
				if(stamina < 100.0f)
					stamina += 0.1f;
                break;

            case PlayerState.WALKING:
                Movement(walkSpeed);
				if(stamina < 100.0f)
					stamina += 0.1f;
                break;

            case PlayerState.RUNNING:
                Movement(runSpeed);
				stamina -= 0.2f;
				if (stamina == 0)
					playerState = PlayerState.WALKING;
                break;
        }
		staminaBar.value = stamina;

        //Is the player throwing a snowball?
        if (Input.GetButtonDown("Fire1") && hp > 0)
            throwingAnimation.Play("throwingAnimation");

        //Check to see if the player is dead
        if (hp <= 0)
            Death();
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


    /*
     * Description: Deals with letting the player throw snowballs
     */
    public void Throwing()
    {
        Rigidbody snowBall = Instantiate(globalScript.SnowBall.rigidbody, snowballSpawnLocation.position, Camera.main.transform.rotation) as Rigidbody;
        snowBall.AddForce(Camera.main.transform.forward * throwingSpeed, ForceMode.Impulse);
        snowBall.AddForce(Camera.main.transform.forward * (controller.velocity.magnitude * Input.GetAxis("Vertical") / 2), ForceMode.Impulse);
        globalScript.sfx[(int)Common.AudioSFX.SNOWBALL_THROW].Play();

        hp -= 100;
		healthBar.value = hp;
        print("Player HP: " + hp);
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
        Instantiate(deathExplosionEffect, transform.position, transform.rotation);
        //Add physics to the players body
        bodyBottom.AddComponent<SphereCollider>();
        Rigidbody bottomRigidbody = bodyBottom.AddComponent<Rigidbody>();
        //bottomRigidbody.drag = 2;

        bodyMiddle.AddComponent<SphereCollider>();
        Rigidbody middleRigidbody = bodyMiddle.AddComponent<Rigidbody>();
        //middleRigidbody.drag = 2;
        //bodyMiddle.transform.position += Vector3.up * 0.50f;

        bodyTop.AddComponent<SphereCollider>();
        Rigidbody topRigidbody = bodyTop.AddComponent<Rigidbody>();
        //topRigidbody.drag = 2;
        //bodyTop.transform.position += Vector3.up * 0.75f;

        //Enable death camera
        //Camera.main.gameObject.GetComponent<ThirdPersonCameraController>().enabled = true;
        Screen.lockCursor = false;

        //Disable player controls
        Camera.main.gameObject.GetComponent<MouseLook>().enabled = false;
        gameObject.GetComponent<MouseLook>().enabled = false;
        gameObject.GetComponent<CharacterController>().enabled = false;
        gameObject.GetComponent<PlayerController>().enabled = false;
    }
}